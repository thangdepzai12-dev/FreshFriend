# FreshFriends Mobile - Flutter App

Ứng dụng di động **FreshFriends** được viết bằng **Flutter** (thay thế cho React Native cũ), giữ nguyên backend Node.js/Express và hợp đồng API hiện tại.

## 1. Thông tin kỹ thuật & Toolchain
- **Framework:** Flutter (Dart stable)
- **State Management:** Riverpod (đề xuất)
- **Networking:** Dio (hoặc http client cấu hình sẵn base URL, interceptors xử lý Token & Error)
- **Routing:** GoRouter (điều hướng 5 tab chính + các màn hình con)
- **Local Storage:** Flutter Secure Storage (cho token) & SharedPreferences / Hive (cho preferences & bản nháp quét)
- **Màu sắc chủ đạo:** Xanh lá (`#006a44`), vàng cảnh báo (`#745b00`), đỏ lỗi (`#ba1a1a`), nền sáng (`#fcf9f8`).

## 2. Cấu trúc Project (Feature-First)
```text
lib/
├── core/
│   ├── network/       # Dio client, interceptors, error handling
│   ├── router/        # GoRouter configuration
│   ├── theme/         # Material 3 theme & color schemes
│   └── storage/       # Secure storage & local persistence
├── features/
│   ├── auth/          # Đăng nhập, đăng ký, OTP, quên mật khẩu
│   ├── inventory/     # Kho thực phẩm, vị trí lưu trữ, bộ lọc
│   ├── scan/          # Quét ảnh, OCR hóa đơn, review, bản nháp
│   ├── household/     # Quản lý hộ gia đình, thành viên, lời mời
│   ├── planner/       # Kế hoạch bữa ăn, công thức, dinh dưỡng
│   ├── shopping/      # Danh sách mua sắm, cửa hàng gần đây (maps)
│   ├── settings/      # Hồ sơ, thông báo, gói dịch vụ
│   └── admin/         # Quản trị hệ thống (theo role ADMIN)
└── main.dart
```

## 3. Hướng dẫn Chạy & Cấu hình
1. Cài đặt Flutter SDK và mở thư mục trong Android Studio / VS Code.
2. Chạy lệnh lấy thư viện:
   ```bash
   flutter pub get
   ```
3. Cấu hình API Base URL (mặc định cho Android Emulator: `http://10.0.2.2:4000/api`).
4. Chạy ứng dụng trên máy ảo hoặc thiết bị thật:
   ```bash
   flutter run
   ```
5. Chạy kiểm thử:
   ```bash
   flutter test
   ```
