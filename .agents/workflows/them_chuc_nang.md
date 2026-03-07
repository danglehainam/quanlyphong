---
description: Quy trình chuẩn để thêm một chức năng/thực thể mới vào dự án ChuNha
---

Khi có yêu cầu thêm một thực thể (Ví dụ: HoaDon, KhachThue) dựa trên tài liệu `docs/database.md`, hãy thực hiện các bước sau một cách tuần tự:

1. Đọc và phân tích Schema
   Đọc file `docs/database.md` để nắm cấu trúc dữ liệu của thực thể cần tạo. 

2. Xây dựng Domain Layer (Lõi)
   - Tạo file `[name]_entity.dart` trong thư mục `lib/domain/entities/`.
     Lưu ý: Không kế thừa bất kỳ class nào ngoài luồng, chỉ chứa dữ liệu thuần.
   - Tạo các UseCase tương ứng trong `lib/domain/usecases/`.

3. Xây dựng Data Layer (Dữ liệu)
   - Tạo file `[name]_model.dart` trong `lib/data/models/`.
     Lưu ý: KHÔNG extends Entity. Bắt buộc có các hàm: `fromFirestore`, `toFirestore`, `toEntity`, và `fromEntity`.
   - Tạo RemoteDataSource và RepositoryImpl để CRUD dữ liệu với Firestore.
     Lưu ý: Các class Impl phải biến đổi qua lại giữa Model và Entity thông qua các hàm mapper chứ không trả thẳng Model ra ngoài.

4. Cập nhật Dependency Injection (DI)
   Đăng ký tất cả các DataSource, Repository và UseCase mới vừa tạo vào file `lib/core/di/dependency_injection.dart`.

// turbo-all
5. Kiểm tra tính toàn vẹn của mã nguồn
   Chạy lệnh `flutter analyze` tại thư mục gốc để đảm bảo quá trình viết code Data và Domain không gây ra lỗi cú pháp hay cảnh báo nào. Nếu có lỗi, phải sửa ngay lập tức.
