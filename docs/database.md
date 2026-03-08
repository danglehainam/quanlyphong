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
#           ├── bang_gia (cấu hình giá theo từng phòng hoặc loại phòng)
#           └── hoa_don  (hóa đơn thuê theo từng phòng mỗi kỳ)

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
  khachThue          [CÓ_THỂ_NULL] string[]         — Danh sách ref → nguoi_thue/{nguoiThueId} đang ở phòng này
  chiSoDienHienTai   [CÓ_THỂ_NULL] number           — Chỉ số điện hiện tại (kWh) — tự động điền vào khi tạo hóa đơn mới
  chiSoNuocHienTai   [CÓ_THỂ_NULL] number           — Chỉ số nước hiện tại (m³) — tự động điền vào khi tạo hóa đơn mới
  trangThai         [CÓ_THỂ_NULL] number [INDEXED] — ENUM: 0 = "trống", 1 = "đã thuê", 2 = "bảo trì", 3 = "chưa thanh toán"
  moTa              [CÓ_THỂ_NULL] string           — Ghi chú thêm
  createdAt         [BẮT_BUỘC] Timestamp

QUY TẮC NGHIỆP VỤ:
  - Sau khi lưu mỗi hóa đơn: cập nhật chiSoDienHienTai = hoa_don.chiSoDienCuoi
    và chiSoNuocHienTai = hoa_don.chiSoNuocCuoi.
  - Khi tạo hóa đơn mới: đọc 2 trường này từ phong để điền sẵn vào đầu kỳ.

VÍ DỤ DOCUMENT (phong/p101):
```json
{
  "tenPhong": "P101",
  "nhaTroId": "nt001",
  "chuNhaId": "abc123",
  "bangGiaId": "bg001",
  "khachThue": ["nt_user001", "nt_user002"],
  "chiSoDienHienTai": 210,
  "chiSoNuocHienTai": 35,
  "trangThai": 1,
  "moTa": "Phòng có cửa sổ, ban công nhỏ",
  "createdAt": "2025-01-10T00:00:00Z"
}
```

---

## COLLECTION: bang_gia/{bangGiaId}

MỤC ĐÍCH: Lưu trữ cấu hình giá tính tiền (điện, nước, dịch vụ) dưới dạng "Template Bảng Giá".
            Bảng giá này tồn tại độc lập, không gắn chết vào một Nhà Trọ hay một cụm Phòng nào cả.
            Khi muốn áp dụng giá, 1 Phòng sẽ lưu lại `bangGiaId` mà nó đang sử dụng.

SCHEMA:
  tenBangGia       [BẮT_BUỘC]    string           — Tên bảng giá để dễ chọn (VD: "Giá Sinh Viên VIP", "Giá Gia Đình", "Giá Cố Định 2025")
  chuNhaId         [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId} (Phân quyền: Chủ nhà nào tự tạo/quản lý danh sách bảng giá của người đó)
  giaThue          [BẮT_BUỘC]    number           — Giá thuê cơ sở (VND/tháng)

  # --- Cách tính tiền ĐIỆN ---
  giaDien          [BẮT_BUỘC]    number           — Mức giá điện (VND). Ý nghĩa tuỳ theo cachTinhDien
  cachTinhDien     [BẮT_BUỘC]    number           — ENUM: 0 = VNĐ/số (kWh), 1 = VNĐ/người, 2 = tự nhập khi lập hóa đơn

  # --- Cách tính tiền NƯỚC ---
  giaNuoc          [BẮT_BUỘC]    number           — Mức giá nước (VND). Ý nghĩa tuỳ theo cachTinhNuoc
  cachTinhNuoc     [BẮT_BUỘC]    number           — ENUM: 0 = VNĐ/số (m³), 1 = VNĐ/người, 2 = tự nhập khi lập hóa đơn

  # --- Cách tính tiền INTERNET ---
  giaInternet      [BẮT_BUỘC]    number           — Mức giá internet (VND). Ý nghĩa tuỳ theo cachTinhInternet
  cachTinhInternet [BẮT_BUỘC]    number           — ENUM: 0 = VNĐ/phòng, 1 = VNĐ/người

  # --- CHI PHÍ KHÁC ---
  chiPhiKhac       [CÓ_THỂ_NULL] number           — Chi phí khác cố định (VND/tháng), VD: rác, vệ sinh
  ghiChu           [CÓ_THỂ_NULL] string           — Ghi chú cho chi phí khác, VD: "Tiền rác + vệ sinh hành lang"

VÍ DỤ DOCUMENT (bang_gia/bg_sinh_vien_vip):
```json
{
  "tenBangGia": "Bảng Giá Sinh Viên VIP 2025",
  "chuNhaId": "abc123",
  "giaThue": 2500000,
  "giaDien": 3500,
  "cachTinhDien": 0,
  "giaNuoc": 15000,
  "cachTinhNuoc": 0,
  "giaInternet": 100000,
  "cachTinhInternet": 0,
  "chiPhiKhac": 30000,
  "ghiChu": "Tiền rác hàng tháng"
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


## COLLECTION: hoa_don/{hoaDonId}

MỤC ĐÍCH: Hóa đơn được lập mỗi kỳ (tháng/quý) cho từng phòng đang được thuê.

SCHEMA:
  bangGiaId         [BẮT_BUỘC]    string           — ref → bang_gia/{bangGiaId} (bảng giá tại thời điểm lập hóa đơn)
  phongId           [BẮT_BUỘC]    string [INDEXED] — ref → phong/{phongId}
  chuNhaId          [BẮT_BUỘC]    string [INDEXED] — ref → users/{chuNhaId}
  tenHoaDon         [BẮT_BUỘC]    string [INDEXED] — Tên hóa đơn, VD: "Tháng 3/2025", "Quý 1/2025"
  chiSoDienDau      [CÓ_THỂ_NULL] number           — Chỉ số điện đầu kỳ (kWh)
  chiSoDienCuoi     [CÓ_THỂ_NULL] number           — Chỉ số điện cuối kỳ (kWh)
  chiSoNuocDau      [CÓ_THỂ_NULL] number           — Chỉ số nước đầu kỳ (m³)
  chiSoNuocCuoi     [CÓ_THỂ_NULL] number           — Chỉ số nước cuối kỳ (m³)
  tienThue          [CÓ_THỂ_NULL] number           — Tiền thuê phòng (VND)
  tienDien          [CÓ_THỂ_NULL] number           — Tiền điện (VND)
  tienNuoc          [CÓ_THỂ_NULL] number           — Tiền nước (VND)
  tienInternet      [CÓ_THỂ_NULL] number           — Tiền mạng (VND)
  tienChiPhiKhac    [CÓ_THỂ_NULL] number           — Chi phí khác (VND)
  giamGia           [CÓ_THỂ_NULL] number           — Số tiền giảm trực tiếp (VND), null hoặc 0 = không giảm
  tongTien          [BẮT_BUỘC]    number           — Tổng = tienThue + tienDien + tienNuoc + tienInternet + tienChiPhiKhac - giamGia
  daThanhToan       [CÓ_THỂ_NULL] boolean [INDEXED] — true = đã thanh toán, false = chưa thanh toán
  ngayLap           [CÓ_THỂ_NULL] Timestamp        — Ngày lập hóa đơn
  ngayThanhToan     [CÓ_THỂ_NULL] Timestamp        — Ngày thu tiền
  ghiChu            [CÓ_THỂ_NULL] string           — Ghi chú

QUY TẮC NGHIỆP VỤ:
  - tongTien phải bằng: tienThue + tienDien + tienNuoc + tienInternet + tienChiPhiKhac - giamGia.
  - Ràng buộc duy nhất: chỉ 1 document cho mỗi cặp (phongId + tenHoaDon).

VÍ DỤ DOCUMENT (hoa_don/hd001_2025-03):
```json
{
  "bangGiaId": "bg001",
  "phongId": "p101",
  "chuNhaId": "abc123",
  "tenHoaDon": "Tháng 3/2025",
  "chiSoDienDau": 150,
  "chiSoDienCuoi": 210,
  "chiSoNuocDau": 30,
  "chiSoNuocCuoi": 35,
  "tienThue": 2500000,
  "tienDien": 210000,
  "tienNuoc": 75000,
  "tienInternet": 100000,
  "tienChiPhiKhac": 30000,
  "giamGia": null,
  "tongTien": 2915000,
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
| `hoa_don` | `chuNhaId` ASC, `tenHoaDon` ASC | Danh sách hóa đơn theo chủ nhà + tên |
| `hoa_don` | `phongId` ASC, `tenHoaDon` ASC | Danh sách hóa đơn của một phòng |
| `hoa_don` | `chuNhaId` ASC, `daThanhToan` ASC | Tìm hóa đơn chưa thanh toán/đã thanh toán |
| `nguoi_thue` | `chuNhaId` ASC, `createdAt` DESC | Danh sách người thuê theo chủ nhà + mới nhất |
