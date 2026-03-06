# Thiết kế Database — Chủ Nhà App
# Nền tảng: Firebase Firestore (NoSQL)
# Mã hóa: UTF-8
# Cập nhật lần cuối: 2026-03-06
#
# QUY ƯỚC:
#   - Tất cả timestamp: Firestore Timestamp (UTC)
#   - Tất cả giá trị tiền: số nguyên VND (VD: 2500000 = 2,500,000 VND)
#   - Các field kết thúc bằng "Id" là khóa ngoại (string = Firestore document ID)
#   - Field có [BẮT_BUỘC] phải luôn có giá trị
#   - Field có [CÓ_THỂ_NULL] có thể để null
#   - Field có [INDEXED] cần tạo Firestore index
#   - Mọi document thuộc về một user đều lưu "chuNhaId" để query trực tiếp
#     (tránh join nhiều bước vì Firestore không hỗ trợ JOIN như SQL)
#   - ID của document (Ví dụ: `nt001`, `p101`) là khóa chính nằm ở đường dẫn,
#     KHÔNG LƯU THỪA trường `id` bên trong dữ liệu JSON (ngoại trừ `uid` ở `users`).
#     Khi đọc dữ liệu lên code, lấy Document ID gán vào thuộc tính `id` của Model.
#
# SƠ ĐỒ QUAN HỆ:
#
#   users
#     └── nha_tro (1 user → nhiều nha_tro)
#           ├── phong    (1 nha_tro → nhiều phong)
#           ├── bang_gia (lịch sử giá theo từng phong hoặc cả nhà trọ)
#           └── hop_dong (1 phong → 1 hop_dong đang hoạt động)
#                 ├── nguoi_thue (nhiều nguoi_thue → 1 hop_dong qua danhSachNguoiO[])
#                 └── hoa_don   (1 hop_dong → nhiều hoa_don, mỗi tháng 1 cái)

---

## COLLECTION: users/{userId}

MỤC ĐÍCH: Lưu thông tin tài khoản chủ nhà, được tạo khi đăng nhập Google lần đầu.

SCHEMA:
  uid           [BẮT_BUỘC] string        — Firebase Auth UID, trùng với document ID
  email         [BẮT_BUỘC] string        — Email tài khoản Google
  displayName   [BẮT_BUỘC] string        — Họ tên đầy đủ từ Google
  photoUrl      [CÓ_THỂ_NULL] string     — URL ảnh đại diện từ Google
  createdAt     [BẮT_BUỘC] Timestamp     — Thời điểm tạo tài khoản

VÍ DỤ DOCUMENT (users/abc123):
```json
{
  "uid": "abc123",
  "email": "chuNha@gmail.com",
  "displayName": "Nguyễn Văn Chủ",
  "photoUrl": "https://lh3.googleusercontent.com/...",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

---

## COLLECTION: nha_tro/{nhaTroId}

MỤC ĐÍCH: Một chủ nhà có thể quản lý nhiều nhà trọ. Mỗi nhà trọ nhóm các
          phong, bang_gia và hop_dong lại với nhau.

SCHEMA:
  tenNhaTro     [BẮT_BUỘC] string           — Tên nhà trọ, VD: "Nhà Trọ Bình Dân"
  diaChi        [BẮT_BUỘC] string           — Địa chỉ đầy đủ
  chuNhaId      [BẮT_BUỘC] string [INDEXED] — ref → users/{chuNhaId}
  createdAt     [BẮT_BUỘC] Timestamp

VÍ DỤ DOCUMENT (nha_tro/nt001):
```json
{
  "tenNhaTro": "Nhà Trọ Bình Dân",
  "diaChi": "123 Lê Văn Việt, Quận 9, TP.HCM",
  "chuNhaId": "abc123",
  "createdAt": "2025-01-05T00:00:00Z"
}
```

---

## COLLECTION: phong/{phongId}

MỤC ĐÍCH: Từng phòng thuộc một nhà trọ.

SCHEMA:
  tenPhong      [BẮT_BUỘC] string           — Tên phòng (VD: "P101", "Phòng 3")
  nhaTroId      [BẮT_BUỘC] string [INDEXED] — ref → nha_tro/{nhaTroId}
  chuNhaId      [BẮT_BUỘC] string [INDEXED] — ref → users/{chuNhaId} (lưu thừa để query nhanh)
  bangGiaId     [CÓ_THỂ_NULL] string [INDEXED] — ref → bang_gia/{bangGiaId} (bảng giá ĐANG áp dụng)
  khachThue     [CÓ_THỂ_NULL] string[]         — Danh sách ref → nguoi_thue/{nguoiThueId} đang ở phòng này
  trangThai     [BẮT_BUỘC] number [INDEXED] — ENUM: 0 = "trống", 1 = "đã thuê", 2 = "bảo trì"
  moTa          [CÓ_THỂ_NULL] string        — Ghi chú thêm
  createdAt     [BẮT_BUỘC] Timestamp

QUY TẮC NGHIỆP VỤ:
  - trangThai phải đặt thành 1 ("đã thuê") khi có hop_dong với trangThai="dang_thue" cho phòng này.
  - trangThai trở về 0 ("trống") khi tất cả hop_dong của phòng này đều có trangThai != "dang_thue".

VÍ DỤ DOCUMENT (phong/p101):
```json
{
  "tenPhong": "P101",
  "nhaTroId": "nt001",
  "chuNhaId": "abc123",
  "bangGiaId": "bg001",
  "khachThue": ["nt_user001", "nt_user002"],
  "trangThai": 1,
  "moTa": "Phòng có cửa sổ, ban công nhỏ",
  "createdAt": "2025-01-10T00:00:00Z"
}
```

---

## COLLECTION: bang_gia/{bangGiaId}

MỤC ĐÍCH: Lưu trữ cấu hình giá tính tiền (điện, nước, dịch vụ) cho nhà trọ,
            từng phòng hoặc theo loại phòng. Cập nhật trực tiếp khi có thay đổi.

SCHEMA:
  nhaTroId      [BẮT_BUỘC]    string [INDEXED] — ref → nha_tro/{nhaTroId}
  phongId       [CÓ_THỂ_NULL] string [INDEXED] — ref → phong/{phongId}
                                                  null = áp dụng cho cả nhà trọ hoặc 1 loại phòng
  loaiPhong     [CÓ_THỂ_NULL] string [INDEXED] — ENUM: "1_nguoi" | "2_nguoi" | "ghep" (áp dụng theo loại phòng)
  chuNhaId      [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId} (lưu thừa)
  giaThue       [BẮT_BUỘC]    number           — Giá thuê (VND/tháng)
  giaDien       [BẮT_BUỘC]    number           — Giá điện (VND/kWh)
  giaNuoc       [BẮT_BUỘC]    number           — Giá nước (VND/m³)
  giaInternet   [BẮT_BUỘC]    number           — Phí internet (VND/tháng), để 0 nếu không có
  giaRac        [BẮT_BUỘC]    number           — Phí rác (VND/tháng), để 0 nếu không có

VÍ DỤ DOCUMENT (bang_gia/bg001):
```json
{
  "nhaTroId": "nt001",
  "phongId": null,
  "loaiPhong": "2_nguoi",
  "chuNhaId": "abc123",
  "giaThue": 2500000,
  "giaDien": 3500,
  "giaNuoc": 15000,
  "giaInternet": 100000,
  "giaRac": 20000
}
```

---

## COLLECTION: nguoi_thue/{nguoiThueId}

MỤC ĐÍCH: Hồ sơ cá nhân của người thuê. Một hồ sơ tồn tại xuyên suốt nhiều
          hop_dong (họ có thể chuyển phòng hoặc thuê lại sau này).

SCHEMA:
  hoTen         [BẮT_BUỘC]    string           — Họ và tên đầy đủ
  soDienThoai   [BẮT_BUỘC]    string           — Số điện thoại
  cccd          [CÓ_THỂ_NULL] string           — Số CCCD hoặc CMND
  ngaySinh      [CÓ_THỂ_NULL] Timestamp        — Ngày sinh
  queQuan       [CÓ_THỂ_NULL] string           — Quê quán / địa chỉ thường trú
  anhCCCD       [CÓ_THỂ_NULL] string[]         — Danh sách URL ảnh CCCD (Firebase Storage)
  chuNhaId      [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId}
  createdAt     [BẮT_BUỘC]    Timestamp

VÍ DỤ DOCUMENT (nguoi_thue/nt_user001):
```json
{
  "hoTen": "Trần Thị B",
  "soDienThoai": "0909123456",
  "cccd": "079204012345",
  "ngaySinh": "1998-05-15T00:00:00Z",
  "queQuan": "Bến Tre",
  "anhCCCD": [
    "https://firebasestorage.googleapis.com/.../cccd_mat_truoc.jpg",
    "https://firebasestorage.googleapis.com/.../cccd_mat_sau.jpg"
  ],
  "chuNhaId": "abc123",
  "createdAt": "2025-02-01T00:00:00Z"
}
```

---

## COLLECTION: hop_dong/{hopDongId}

MỤC ĐÍCH: Hợp đồng thuê — liên kết một phong với một hoặc nhiều nguoi_thue.
          Mỗi phòng chỉ được có MỘT hop_dong đang hoạt động tại một thời điểm.

SCHEMA:
  phongId           [BẮT_BUỘC]    string [INDEXED] — ref → phong/{phongId}
  nguoiThueId       [BẮT_BUỘC]    string           — ref → nguoi_thue (người đại diện ký hợp đồng)
  khachThue         [BẮT_BUỘC]    string[]         — Tất cả nguoiThueId đang ở trong phòng
  bangGiaId         [BẮT_BUỘC]    string           — ref → bang_gia (giá tại thời điểm ký hợp đồng)
  chuNhaId          [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId}
  ngayBatDau        [BẮT_BUỘC]    Timestamp [INDEXED] — Ngày bắt đầu thuê
  ngayKetThuc       [CÓ_THỂ_NULL] Timestamp        — Ngày kết thúc hợp đồng; null = vô thời hạn
  tienCoc           [BẮT_BUỘC]    number           — Tiền đặt cọc (VND)
  trangThai         [BẮT_BUỘC]    string [INDEXED] — ENUM: "dang_thue" | "het_han" | "da_ket_thuc"
  ghiChu            [CÓ_THỂ_NULL] string           — Ghi chú
  createdAt         [BẮT_BUỘC]    Timestamp

QUY TẮC NGHIỆP VỤ:
  - Mỗi phòng chỉ được có 1 hop_dong có trangThai = "dang_thue" tại một thời điểm.
  - Khi tạo hop_dong: cập nhật phong.trangThai thành "da_thue".
  - Khi kết thúc hợp đồng (trangThai → "da_ket_thuc"): cập nhật phong.trangThai về "trong".

VÍ DỤ DOCUMENT (hop_dong/hd001):
```json
{
  "phongId": "p101",
  "nguoiThueId": "nt_user001",
  "khachThue": ["nt_user001", "nt_user002"],
  "bangGiaId": "bg001",
  "chuNhaId": "abc123",
  "ngayBatDau": "2025-02-01T00:00:00Z",
  "ngayKetThuc": null,
  "tienCoc": 5000000,
  "trangThai": "dang_thue",
  "ghiChu": null,
  "createdAt": "2025-02-01T00:00:00Z"
}
```

---

## COLLECTION: hoa_don/{hoaDonId}

MỤC ĐÍCH: Hóa đơn hàng tháng cho mỗi hop_dong đang hoạt động.
          Mỗi tháng chỉ có 1 document cho mỗi cặp (hopDongId + thang).

SCHEMA:
  hopDongId         [BẮT_BUỘC]    string [INDEXED] — ref → hop_dong/{hopDongId}
  phongId           [BẮT_BUỘC]    string [INDEXED] — ref → phong/{phongId} (lưu thừa)
  chuNhaId          [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId} (lưu thừa)
  thang             [BẮT_BUỘC]    string [INDEXED] — Kỳ hóa đơn, định dạng: "YYYY-MM" VD: "2025-03"
  chiSoDienDau      [BẮT_BUỘC]    number           — Chỉ số điện đầu kỳ (kWh)
  chiSoDienCuoi     [BẮT_BUỘC]    number           — Chỉ số điện cuối kỳ (kWh)
  chiSoNuocDau      [BẮT_BUỘC]    number           — Chỉ số nước đầu kỳ (m³)
  chiSoNuocCuoi     [BẮT_BUỘC]    number           — Chỉ số nước cuối kỳ (m³)
  tienThue          [BẮT_BUỘC]    number           — Tiền thuê phòng (VND)
  tienDien          [BẮT_BUỘC]    number           — Tiền điện = (cuoi - dau) × giaDien
  tienNuoc          [BẮT_BUỘC]    number           — Tiền nước = (cuoi - dau) × giaNuoc
  tienDichVuKhac    [BẮT_BUỘC]    number           — Phí khác: internet + rác + phát sinh (VND)
  tongTien          [BẮT_BUỘC]    number           — Tổng = tienThue + tienDien + tienNuoc + tienDichVuKhac
  daThanhToan       [BẮT_BUỘC]    boolean [INDEXED] — Trạng thái toán: true = đã thanh toán, false = chưa thanh toán
  ngayLap           [BẮT_BUỘC]    Timestamp        — Ngày lập hóa đơn
  ngayThanhToan     [CÓ_THỂ_NULL] Timestamp        — Ngày thu tiền; null = chưa thanh toán
  ghiChu            [CÓ_THỂ_NULL] string           — Ghi chú

QUY TẮC NGHIỆP VỤ:
  - tongTien phải bằng: tienThue + tienDien + tienNuoc + tienDichVuKhac (luôn tính lại, không tin client).
  - Ràng buộc duy nhất: chỉ 1 document cho mỗi cặp (hopDongId + thang).

VÍ DỤ DOCUMENT (hoa_don/hd001_2025-03):
```json
{
  "hopDongId": "hd001",
  "phongId": "p101",
  "chuNhaId": "abc123",
  "thang": "2025-03",
  "chiSoDienDau": 150,
  "chiSoDienCuoi": 210,
  "chiSoNuocDau": 30,
  "chiSoNuocCuoi": 35,
  "tienThue": 2500000,
  "tienDien": 210000,
  "tienNuoc": 75000,
  "tienDichVuKhac": 120000,
  "tongTien": 2905000,
  "daThanhToan": false,
  "ngayLap": "2025-03-01T00:00:00Z",
  "ngayThanhToan": null,
  "ghiChu": null
}
```

---

## FIRESTORE SECURITY RULES

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Người dùng chỉ đọc/ghi được hồ sơ của chính mình
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Tất cả collection còn lại: chỉ chủ nhà (chuNhaId) mới được truy cập
    match /{collection}/{docId} {
      allow read, update, delete: if request.auth != null
        && resource.data.chuNhaId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.chuNhaId == request.auth.uid;
    }
  }
}
```

---

## INDEX KẾT HỢP CẦN TẠO

| Collection | Các field | Mục đích |
|---|---|---|
| `phong` | `chuNhaId` ASC, `trangThai` ASC | Lọc phòng theo chủ nhà + trạng thái |
| `phong` | `nhaTroId` ASC, `trangThai` ASC | Lọc phòng theo nhà trọ + trạng thái |
| `hop_dong` | `phongId` ASC, `trangThai` ASC | Tìm hợp đồng đang thuê của một phòng |
| `hoa_don` | `chuNhaId` ASC, `thang` ASC | Danh sách hóa đơn theo chủ nhà + tháng |
| `hoa_don` | `hopDongId` ASC, `thang` ASC | Danh sách hóa đơn của một hợp đồng |
| `hoa_don` | `chuNhaId` ASC, `daThanhToan` ASC | Tìm hóa đơn chưa thanh toán/đã thanh toán |
