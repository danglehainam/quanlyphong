---
description: Quy trình phát triển và bảo trì tính năng chuẩn Clean Architecture & UI Design cho dự án ChuNha
---

Khi phát triển mới hoặc chỉnh sửa (Refactor) bất kỳ tính năng nào, hãy tuân thủ nghiêm ngặt quy trình làm việc chuyên nghiệp sau:

### // turbo-all

## Bước 0: Chuẩn bị & Thiết kế (Database First)
- Trước khi code, hãy đọc hoặc cập nhật tài liệu `docs/database.md`.
- Đảm bảo bạn nắm rõ Schema của thực thể liên quan (tên trường, kiểu dữ liệu, quan hệ gốc-ngọn).

## Bước 1: Domain Layer (Yêu cầu & Nghiệp vụ)
Luôn bắt đầu từ "Trái tim" của ứng dụng.
1. **Entity**: Tạo file `[name]_entity.dart` trong `lib/domain/entities/`.
    - Class thuần, chứa các thuộc tính `final`. 
    - Không chứa bất kỳ logic biến đổi dữ liệu nào từ Firestore.
2. **Repository Interface**: Định nghĩa "hợp đồng" tại `lib/domain/repositories/`.
3. **UseCase**: Tạo các class xử lý một nghiệp vụ cụ thể tại `lib/domain/usecases/`.
4. **Failure**: Nếu nghiệp vụ phức tạp, định nghĩa lỗi tương ứng trong `lib/core/error/failures.dart`.

## Bước 2: Data Layer (Cấu trúc & Truy cập dữ liệu)
1. **Model**: Tạo file `[name]_model.dart` trong `lib/data/models/`.
    - **QUY TẮC VÀNG**: Tuyệt đối KHÔNG `extends` từ Entity.
    - Phải có mapper: `fromFirestore`, `toFirestore`, `toEntity`, `fromEntity`.
2. **DataSource**: Gọi Firestore tại `lib/data/datasources/remote/`. 
3. **Repository Implementation**: Hiện thực interface tại `lib/data/repositories/`. 
    - Biến đổi Model -> Entity trước khi trả về cho Domain.

## Bước 3: Presentation Layer (UI & Logic Giao diện)
1. **BLoC**: Quản lý trạng thái tại `lib/presentation/bloc/`. 
    - Phải có `Event` và `State` tường minh.
2. **Widgets & Composition**: Xây dựng UI tại `lib/presentation/screens/`.
    - **Ưu tiên**: Chia nhỏ màn hình thành các Widget nhỏ để dễ quản lý và tái sử dụng.
    - **Cấu trúc thư mục**:
        - Nếu Widget **chỉ dùng cho 1 màn hình**: Đặt trong thư mục `widgets/` bên trong thư mục của màn hình đó (VD: `lib/presentation/screens/phong/widgets/`).
        - Nếu Widget **dùng chung cho nhiều màn hình**: Đặt trong thư mục `lib/presentation/widgets/`.
    - **QUY TẮC MÀU SẮC**: Tất cả màu sắc khi sử dụng trong Widget hoặc Style bắt buộc phải lấy từ lớp `AppColors` tại `lib/core/constants/app_colors.dart`.
    - **CẤM**: Tuyệt đối không hardcode mã hex (VD: `Color(0xFF...)`) hoặc sử dụng trực tiếp các hằng số màu của Flutter (VD: `Colors.blue`) trong code UI.

## Bước 4: Dependency Injection (Gắn kết)
- Đăng ký tuần tự trong `lib/core/di/dependency_injection.dart`:
  `DataSource -> Repository -> UseCase -> Bloc`.

## Bước 5: Kiểm tra & Hoàn thiện
1. **Unit Test**: Viết test cho UseCase và Repository trong thư mục `test/`.
2. **Analysis**: Chạy `flutter analyze` để đảm bảo code sạch, không unused imports, không cảnh báo lint.
3. **Refactor**: Xóa bỏ các file cũ, code thừa sau khi hoàn tất.

---
**Ghi chú**: Mọi thay đổi vi phạm quy trình này (như để logic database vào Entity hay hardcode màu trong Screen) đều được coi là lỗi kỹ thuật nghiêm trọng.
