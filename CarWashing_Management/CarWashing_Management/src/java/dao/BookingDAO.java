package dao;

import dbutils.DBContext;
import dto.Booking;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public boolean isSlotAvailable(String bookingDate, int slotNumber) {
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = "SELECT COUNT(*) FROM Bookings "
                    + "WHERE BookingDate = ? AND SlotNumber = ? "
                    + "AND BookingStatus = 'Pending'";
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

            if (cn != null) {
                // 2. Gán các giá trị tham số tương ứng vào dấu ?
                pst = cn.prepareStatement(sql);
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
                    + "AND BookingStatus IN ('Pending', 'CheckedIn')";
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

    public boolean isDuplicateBooking(int vehicleId, String bookingDate, int slotNumber) {
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT COUNT(*) FROM Bookings WHERE VehicleId = ? AND bookingDate = ? AND slotNumber = ? AND BookingStatus <> 'Cancelled'";
        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setInt(1, vehicleId);
            pst.setString(2, bookingDate);
            pst.setInt(3, slotNumber);
            rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0; // Nếu > 0 nghĩa là đã tồn tại
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Map<String, Object>> getAdminBookingSlots(String bookingDate, String searchLicensePlate) {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT b.BookingId, b.SlotNumber, b.BookingStatus, b.Note, b.TotalAmount, "
                + "       v.LicensePlate, s.ServiceName, acc.FullName, t.TierName "
                + "FROM Bookings b "
                + "JOIN CustomerVehicles v ON b.VehicleId = v.VehicleId "
                + "JOIN WashServices s ON b.ServiceId = s.ServiceId "
                + "JOIN Customers c ON b.CustomerId = c.CustomerId "
                + "JOIN Accounts acc ON c.AccountId = acc.AccountId "
                + "JOIN CustomerLoyalty cl ON acc.AccountId = cl.AccountId "
                + "JOIN LoyaltyTiers t ON cl.CurrentTierId = t.TierId "
                + "WHERE b.BookingDate = ? ";

        // Lọc theo biển số xe theo tìm kiếm
        if (searchLicensePlate != null && !searchLicensePlate.trim().isEmpty()) {
            sql += " AND v.LicensePlate LIKE ?";
        }

        // Sắp xếp thứ tự theo ca cho dễ quản lý
        sql += " ORDER BY b.SlotNumber ASC";

        try {
            cn = dbutils.DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, bookingDate);

            if (searchLicensePlate != null && !searchLicensePlate.trim().isEmpty()) {
                pst.setString(2, "%" + searchLicensePlate.trim() + "%");
            }

            rs = pst.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("BookingId", rs.getInt("BookingId"));
                map.put("SlotNumber", rs.getInt("SlotNumber"));
                map.put("BookingStatus", rs.getString("BookingStatus"));
                map.put("Note", rs.getString("Note"));
                map.put("TotalAmount", rs.getDouble("TotalAmount"));
                map.put("LicensePlate", rs.getString("LicensePlate"));
                map.put("ServiceName", rs.getString("ServiceName"));
                map.put("FullName", rs.getString("FullName"));
                map.put("TierName", rs.getString("TierName"));

                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return list;
    }

    public boolean updateBookingStatus(int bookingId, String newStatus) {
        Connection cn = null;
        PreparedStatement pst = null;
        String sql = "UPDATE Bookings SET BookingStatus = ? WHERE BookingId = ?";
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setString(1, newStatus);
                pst.setInt(2, bookingId);
                return pst.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public Map<String, Object> getBookingById(int bookingId) {
        Map<String, Object> map = null;
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        String sql = "SELECT BookingId, SlotNumber, BookingStatus, BookingDate, Note, TotalAmount "
                + "FROM Bookings WHERE BookingId = ?";
        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                pst = cn.prepareStatement(sql);
                pst.setInt(1, bookingId);
                rs = pst.executeQuery();
                if (rs.next()) {
                    map = new HashMap<>();
                    map.put("BookingId", rs.getInt("BookingId"));
                    map.put("SlotNumber", rs.getInt("SlotNumber"));
                    map.put("BookingStatus", rs.getString("BookingStatus"));
                    map.put("BookingDate", rs.getDate("BookingDate")); // Trả về dạng Date hoặc String tương ứng
                    map.put("Note", rs.getString("Note"));
                    map.put("TotalAmount", rs.getDouble("TotalAmount"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (pst != null) {
                    pst.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return map;
    }

    public List<Booking> getUpcomingBookingsByCustomer(int customerId) {

        List<Booking> list = new ArrayList<>();

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql
                = "SELECT b.*, "
                + "v.LicensePlate, "
                + "v.VehicleBrand, "
                + "v.VehicleModel, "
                + "s.ServiceName "
                + "FROM Bookings b "
                + "INNER JOIN CustomerVehicles v ON b.VehicleId = v.VehicleID "
                + "INNER JOIN WashServices s ON b.ServiceId = s.ServiceId "
                + "WHERE b.CustomerId = ? "
                + "AND b.BookingStatus IN ('Pending', 'CheckedIn') "
                + "ORDER BY b.BookingDate DESC";

        try {

            cn = DBContext.getConnection();

            pst = cn.prepareStatement(sql);

            pst.setInt(1, customerId);

            rs = pst.executeQuery();

            while (rs.next()) {

                Booking b = new Booking();

                b.setBookingId(rs.getInt("BookingId"));
                b.setCustomerId(rs.getInt("CustomerId"));
                b.setVehicleId(rs.getInt("VehicleId"));
                b.setServiceId(rs.getInt("ServiceId"));

                b.setBookingDate(rs.getDate("BookingDate"));

                b.setSlotNumber(rs.getInt("SlotNumber"));

                b.setBookingStatus(
                        rs.getString("BookingStatus"));

                b.setLicensePlate(
                        rs.getString("LicensePlate"));

                b.setVehicleBrand(
                        rs.getString("VehicleBrand"));

                b.setVehicleModel(
                        rs.getString("VehicleModel"));

                b.setServiceName(
                        rs.getString("ServiceName"));

                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Booking> getPendingBookingsByCustomer(int customerId) {

        List<Booking> list = new ArrayList<>();

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql
                = "SELECT b.*, "
                + "v.LicensePlate, "
                + "v.VehicleBrand, "
                + "v.VehicleModel, "
                + "s.ServiceName "
                + "FROM Bookings b "
                + "INNER JOIN CustomerVehicles v "
                + "ON b.VehicleId = v.VehicleID "
                + "INNER JOIN WashServices s "
                + "ON b.ServiceId = s.ServiceId "
                + "WHERE b.CustomerId = ? "
                + "AND b.BookingStatus = 'Pending' "
                + "ORDER BY b.BookingDate DESC";

        try {

            cn = DBContext.getConnection();

            pst = cn.prepareStatement(sql);

            pst.setInt(1, customerId);

            rs = pst.executeQuery();

            while (rs.next()) {

                Booking b = new Booking();

                b.setBookingId(rs.getInt("BookingId"));
                b.setCustomerId(rs.getInt("CustomerId"));
                b.setVehicleId(rs.getInt("VehicleId"));
                b.setServiceId(rs.getInt("ServiceId"));

                b.setBookingDate(rs.getDate("BookingDate"));

                b.setSlotNumber(rs.getInt("SlotNumber"));

                b.setBookingStatus(
                        rs.getString("BookingStatus"));

                b.setLicensePlate(
                        rs.getString("LicensePlate"));

                b.setVehicleBrand(
                        rs.getString("VehicleBrand"));

                b.setVehicleModel(
                        rs.getString("VehicleModel"));

                b.setServiceName(
                        rs.getString("ServiceName"));

                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

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

        return list;
    }

    public boolean cancelBooking(int bookingId) {

        Connection cn = null;
        PreparedStatement pst = null;

        String sql
                = "UPDATE Bookings "
                + "SET BookingStatus = 'Cancelled' "
                + "WHERE BookingId = ?";

        try {

            cn = DBContext.getConnection();

            pst = cn.prepareStatement(sql);

            pst.setInt(1, bookingId);

            return pst.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {

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

        return false;
    }

    public void updateExpiredBookings() {

        try {

            Connection cn = DBContext.getConnection();

            String sql1
                    = "UPDATE Bookings "
                    + "SET BookingStatus = 'NoShow' "
                    + "WHERE BookingStatus = 'Pending' "
                    + "AND BookingDate < CAST(GETDATE() AS DATE)";

            PreparedStatement ps1
                    = cn.prepareStatement(sql1);

            ps1.executeUpdate();

            String sql2
                    = "UPDATE Bookings "
                    + "SET BookingStatus = 'Completed' "
                    + "WHERE BookingStatus = 'CheckedIn' "
                    + "AND BookingDate < CAST(GETDATE() AS DATE)";

            PreparedStatement ps2
                    = cn.prepareStatement(sql2);

            ps2.executeUpdate();

            ps1.close();
            ps2.close();
            cn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
