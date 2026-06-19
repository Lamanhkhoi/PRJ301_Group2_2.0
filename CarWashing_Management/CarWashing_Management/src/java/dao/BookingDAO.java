/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import dbutils.DBContext;
import dto.Booking;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author LENOVO
 */
public class BookingDAO {

    public boolean isSlotAvailable(String bookingDate, int slotNumber) {
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = "SELECT COUNT(*) FROM Bookings "
                    + "WHERE BookingDate = ? AND SlotNumber = ? "
                    + "AND BookingStatus IN ('Pending', 'CheckedIn')";
            pst = cn.prepareStatement(sql);
            pst.setString(1, bookingDate);
            pst.setInt(2, slotNumber);
            rs = pst.executeQuery();
            if (rs.next()) {
                int currentCars = rs.getInt(1);
                return currentCars < 3; // Trả về true nếu còn slot trống (< 3)
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createNewBooking(int customerId, int vehicleId, int serviceId, String bookingDate, int slotNumber, double totalAmount) {
        boolean check = false;
        Connection cn = null;
        PreparedStatement pst = null;

        // Đồng bộ: Đổi tên bảng thành 'Bookings' và các cột theo đúng cấu trúc thực tế của bạn
        String sql = "INSERT INTO Bookings (CustomerId, VehicleId, ServiceId, BookingDate, "
                + "SlotNumber, TotalAmount, BookingStatus, Note) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            // Đồng bộ: Dùng DBContext thay vì utils.DBUtils cũ
            cn = DBContext.getConnection();
            System.out.println(slotNumber);
            if (cn != null) {
                // 2. Gán các giá trị tham số tương ứng vào dấu ?
                pst.setInt(1, customerId);
                pst.setInt(2, vehicleId);
                pst.setInt(3, serviceId);
                pst.setString(4, bookingDate); // Truyền chuỗi dạng "YYYY-MM-DD"
                pst.setInt(5, slotNumber);
                pst.setDouble(6, totalAmount);
                pst.setString(7, "Pending");

                pst.setString(8, "");

                // 3. Thực thi câu lệnh SQL, trả về số dòng bị ảnh hưởng
                int rowsAffected = pst.executeUpdate();

                // Nếu chèn thành công >= 1 dòng, trả về true
                return rowsAffected > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Đóng tài nguyên hệ thống an toàn
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
            }
        }
        return check;
    }

    public int countBookedCars(String bookingDate, int slotNumber) {
        int totalCars = 0;
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = "SELECT COUNT(*) FROM Bookings "
                    + "WHERE BookingDate = ? AND SlotNumber = ? "
                    + "AND BookingStatus IN ('Pending', 'Confirmed')";
            pst = cn.prepareStatement(sql);
            pst.setString(1, bookingDate);
            pst.setInt(2, slotNumber);
            rs = pst.executeQuery();
            if (rs.next()) {
                totalCars = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Đóng tài nguyên hệ thống ngay sau khi thực thi xong một truy vấn
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception e) {
            }
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
            }
        }
        return totalCars;
    }

    public boolean isBookingWindowValid(String bookingDateStr, String customerTier) {
        // Câu lệnh SQL tính số ngày chênh lệch giữa ngày đặt và ngày hiện tại
        // CAST(GETDATE() AS DATE) giúp loại bỏ phần giờ, chỉ giữ lại ngày để tính toán chính xác số ngày
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = "SELECT DATEDIFF(day, CAST(GETDATE() AS DATE), ?) AS DaysDifference";
            pst = cn.prepareStatement(sql);
            pst.setString(1, bookingDateStr);
            rs = pst.executeQuery();
            if (rs.next()) {
                int daysDifference = rs.getInt("DaysDifference");

                // Khách không được đặt lịch cho các ngày đã qua trong quá khứ
                if (daysDifference < 0) {
                    return false;
                }

                // Kiểm tra số ngày tối đa được đặt trước theo từng hạng (Tier-based booking window)
                switch (customerTier.trim().toLowerCase()) {
                    case "member":
                        return daysDifference <= 7;  // Member: 7 ngày 
                    case "silver":
                        return daysDifference <= 10; // Silver: 10 ngày 
                    case "gold":
                        return daysDifference <= 12; // Gold: 12 ngày 
                    case "platinum":
                        return daysDifference <= 14; // Platinum: 14 ngày 
                    default:
                        return daysDifference <= 7;  // Mặc định như Member
                    }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
