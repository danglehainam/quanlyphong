import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // --- 2 MÀU CHỦ ĐẠO (Tạo điểm nhấn và nhận diện thương hiệu) ---
  // Tượng trưng cho sự tin cậy, bảo mật và tài chính (Tiền bạc/Hóa đơn)
  static const Color primary = Color(0xFF1E3A8A); // Xanh dương đậm (Navy)
  
  // Tượng trưng cho sự tươi mới, thân thiện (Nhà cửa/Phòng ốc)
  static const Color secondary = Color(0xFF14B8A6); // Xanh lơ (Teal / Mint)

  // --- 4 MÀU PHỤ (Dùng cho nền và văn bản để giao diện dễ nghìn) ---
  // 1. Nền tổng thể của app (Trắng xám nhẹ, giúp các Card nổi bật hơn)
  static const Color background = Color(0xFFF3F4F6);
  
  // 2. Nền của các thành phần nổi (Card, Dialog, BottomSheet)
  static const Color surface = Colors.white;

  // 3. Chữ chính (Tiêu đề, tên phòng, số tiền) - Không dùng đen xì 100% để đỡ mỏi mắt
  static const Color textPrimary = Color(0xFF111827); 
  
  // 4. Chữ phụ (Mô tả, ghi chú, icon phụ)
  static const Color textSecondary = Color(0xFF6B7280); 

  // --- MÀU TRẠNG THÁI (Dùng cho nhãn, thông báo) ---
  static const Color success = Color(0xFF10B981); // Xanh lá (Phòng trống, Đã thu tiền)
  static const Color warning = Color(0xFFF59E0B); // Vàng cam (Bảo trì, Nợ một phần)
  static const Color error = Color(0xFFEF4444);   // Đỏ (Quá hạn, Lỗi)
  
  // (Aliasing cho dễ gọi từ UI Phòng)
  static const Color phongTrong = success;
  static const Color phongDaThue = primary; // Dùng màu chủ đạo cho phòng bình thường
  static const Color phongBaoTri = warning;
  static const Color phongChuaThanhToan = error;
}
