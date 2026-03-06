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
  soPhong       [BẮT_BUỘC] string           — Nhãn phòng, VD: "P101", "Phòng 3"
  nhaTroId      [BẮT_BUỘC] string [INDEXED] — ref → nha_tro/{nhaTroId}
  chuNhaId      [BẮT_BUỘC] string [INDEXED] — ref → users/{chuNhaId} (lưu thừa để query nhanh)
  loaiPhong     [BẮT_BUỘC] string           — ENUM: "1_nguoi" | "2_nguoi" | "ghep"
  dienTich      [BẮT_BUỘC] number           — Diện tích (m²)
  tang          [BẮT_BUỘC] number           — Số tầng (0 = tầng trệt)
  trangThai     [BẮT_BUỘC] string [INDEXED] — ENUM: "trong" | "da_thue" | "bao_tri"
  moTa          [CÓ_THỂ_NULL] string        — Ghi chú thêm
  createdAt     [BẮT_BUỘC] Timestamp

QUY TẮC NGHIỆP VỤ:
  - trangThai phải đặt thành "da_thue" khi có hop_dong với trangThai="dang_thue" cho phòng này.
  - trangThai trở về "trong" khi tất cả hop_dong của phòng này đều có trangThai != "dang_thue".

VÍ DỤ DOCUMENT (phong/p101):
```json
{
  "soPhong": "P101",
  "nhaTroId": "nt001",
  "chuNhaId": "abc123",
  "loaiPhong": "2_nguoi",
  "dienTich": 20,
  "tang": 1,
  "trangThai": "da_thue",
  "moTa": "Phòng có cửa sổ, ban công nhỏ",
  "createdAt": "2025-01-10T00:00:00Z"
}
```

---

## COLLECTION: bang_gia/{bangGiaId}

MỤC ĐÍCH: Bảng giá theo thời kỳ. Mỗi khi giá thay đổi → tạo document MỚI,
          KHÔNG BAO GIỜ cập nhật document cũ. Cách này giúp lưu lịch sử giá
          để hóa đơn luôn tính đúng giá tại thời điểm phát sinh.

SCHEMA:
  nhaTroId      [BẮT_BUỘC]    string [INDEXED] — ref → nha_tro/{nhaTroId}
  phongId       [CÓ_THỂ_NULL] string [INDEXED] — ref → phong/{phongId}
                                                  null = áp dụng cho cả nhà trọ
  chuNhaId      [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId} (lưu thừa)
  giaThue       [BẮT_BUỘC]    number           — Giá thuê (VND/tháng)
  giaDien       [BẮT_BUỘC]    number           — Giá điện (VND/kWh)
  giaNuoc       [BẮT_BUỘC]    number           — Giá nước (VND/m³)
  giaInternet   [BẮT_BUỘC]    number           — Phí internet (VND/tháng), để 0 nếu không có
  giaRac        [BẮT_BUỘC]    number           — Phí rác (VND/tháng), để 0 nếu không có
  hieuLucTu     [BẮT_BUỘC]    Timestamp [INDEXED] — Ngày bắt đầu áp dụng giá này
  hieuLucDen    [CÓ_THỂ_NULL] Timestamp        — Ngày hết hiệu lực; null = đang áp dụng

QUY TẮC NGHIỆP VỤ:
  - Khi tạo bang_gia mới: đặt hieuLucDen của document đang active = (hieuLucTu mới - 1 ngày).
  - Mỗi phongId (hoặc nhaTroId nếu phongId là null) chỉ được có 1 document có hieuLucDen = null.
  - Để tìm giá đang áp dụng của một phòng: query phongId == phongId AND hieuLucDen == null.

VÍ DỤ DOCUMENT (bang_gia/bg001):
```json
{
  "nhaTroId": "nt001",
  "phongId": "p101",
  "chuNhaId": "abc123",
  "giaThue": 2500000,
  "giaDien": 3500,
  "giaNuoc": 15000,
  "giaInternet": 100000,
  "giaRac": 20000,
  "hieuLucTu": "2025-01-01T00:00:00Z",
  "hieuLucDen": null
}
```

---

## COLLECTION: nguoi_thue/{nguoiThueId}

MỤC ĐÍCH: Hồ sơ cá nhân của người thuê. Một hồ sơ tồn tại xuyên suốt nhiều
          hop_dong (họ có thể chuyển phòng hoặc thuê lại sau này).

SCHEMA:
  hoTen         [BẮT_BUỘC]    string           — Họ và tên đầy đủ
  soDienThoai   [BẮT_BUỘC]    string           — Số điện thoại
  cccd          [BẮT_BUỘC]    string           — Số CCCD hoặc CMND
  ngaySinh      [BẮT_BUỘC]    Timestamp        — Ngày sinh
  queQuan       [CÓ_THỂ_NULL] string           — Quê quán / địa chỉ thường trú
  anhCCCD       [BẮT_BUỘC]    string[]         — Danh sách URL ảnh CCCD (Firebase Storage)
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
  danhSachNguoiO    [BẮT_BUỘC]    string[]         — Tất cả nguoiThueId đang ở trong phòng
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
  "danhSachNguoiO": ["nt_user001", "nt_user002"],
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
  trangThai         [BẮT_BUỘC]    string [INDEXED] — ENUM: "chua_thanh_toan" | "da_thanh_toan" | "qua_han"
  ngayLap           [BẮT_BUỘC]    Timestamp        — Ngày lập hóa đơn
  ngayThanhToan     [CÓ_THỂ_NULL] Timestamp        — Ngày thu tiền; null = chưa thanh toán
  ghiChu            [CÓ_THỂ_NULL] string           — Ghi chú

QUY TẮC NGHIỆP VỤ:
  - tongTien phải bằng: tienThue + tienDien + tienNuoc + tienDichVuKhac (luôn tính lại, không tin client).
  - trangThai tự chuyển sang "qua_han" nếu ngayThanhToan = null và ngày hiện tại > (ngayLap + 30 ngày).
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
  "trangThai": "chua_thanh_toan",
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
| `bang_gia` | `phongId` ASC, `hieuLucDen` ASC | Tìm giá đang áp dụng của một phòng |
| `hop_dong` | `phongId` ASC, `trangThai` ASC | Tìm hợp đồng đang thuê của một phòng |
| `hoa_don` | `chuNhaId` ASC, `thang` ASC | Danh sách hóa đơn theo chủ nhà + tháng |
| `hoa_don` | `hopDongId` ASC, `thang` ASC | Danh sách hóa đơn của một hợp đồng |
| `hoa_don` | `chuNhaId` ASC, `trangThai` ASC | Tìm hóa đơn chưa thanh toán |
