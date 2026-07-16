package dao;

import dbutils.DBContext;
import dto.Booking;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
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
                return currentCars < 3;
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
                + "SlotNumber, TotalAmount, Note) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

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

                pst.setString(7, "");

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
                    + "AND BookingStatus = 'Pending'";
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

    public void scanAndUpdateNoShowStatus(String dateStr, Map<Integer, dto.TimeSlot> timeSlotMap) {
        List<Map<String, Object>> allBookings = getAdminBookingSlots(dateStr, "");
        if (allBookings == null) {
            return;
        }

        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        LocalDate bDate = LocalDate.parse(dateStr);
        boolean isPastDate = bDate.isBefore(today);

        for (Map<String, Object> b : allBookings) {
            String status = (String) b.get("BookingStatus");
            int slotNumber = (Integer) b.get("SlotNumber");
            int bookingId = (Integer) b.get("BookingId");

            // Nếu đơn ở trạng thái Pending ở QUÁ KHỨ, hoặc hôm nay đã trễ quá 1 phút -> NoShow
            if ("Pending".equals(status)) {
                dto.TimeSlot tsInfo = (timeSlotMap != null) ? timeSlotMap.get(slotNumber) : null;
                LocalTime slotStartTime = (tsInfo != null)
                        ? LocalTime.parse(tsInfo.getStartTime())
                        : LocalTime.of(8, 0);
                LocalTime noShowDeadline = slotStartTime.plusMinutes(1);

                boolean isTodayAndOverdue = bDate.isEqual(today) && now.isAfter(noShowDeadline);

                if (isPastDate || isTodayAndOverdue) {
                    updateBookingStatus(bookingId, "NoShow");
                }
            }

            // Nếu đơn CheckedIn ở QUÁ KHỨ -> Completed
            if ("CheckedIn".equals(status) && isPastDate) {
                updateBookingStatus(bookingId, "Completed");
            }
        }
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
                    map.put("BookingDate", rs.getDate("BookingDate"));
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

                java.sql.Date sqlDate = rs.getDate("BookingDate");
                if (sqlDate != null) {
                    b.setBookingDate(sqlDate.toLocalDate());
                }

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

                java.sql.Date sqlDate = rs.getDate("BookingDate");
                if (sqlDate != null) {
                    b.setBookingDate(sqlDate.toLocalDate());
                }

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

//    public boolean canCancelBooking(Date bookingDate, int slotNumber) {
//
//        LocalDate bookingLocalDate
//                = new java.sql.Date(bookingDate.getTime()).toLocalDate();
//
//        // Slot 1 = 08:00
//        LocalTime bookingTime = LocalTime.of(8, 0)
//                .plusMinutes((slotNumber - 1) * 30);
//
//        LocalDateTime bookingDateTime
//                = LocalDateTime.of(bookingLocalDate, bookingTime);
//
//        LocalDateTime now = LocalDateTime.now();
//
//        return now.isBefore(bookingDateTime.minusHours(2));
//    }
    public boolean canCancelBooking(int bookingId) {

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql
                = "SELECT BookingDate, "
                + "SlotNumber, "
                + "BookingStatus "
                + "FROM Bookings "
                + "WHERE BookingId = ?";

        try {

            cn = DBContext.getConnection();

            pst = cn.prepareStatement(sql);

            pst.setInt(1, bookingId);

            rs = pst.executeQuery();

            if (rs.next()) {

                java.sql.Date bookingDate = rs.getDate("BookingDate");

                int slot
                        = rs.getInt("SlotNumber");

                String status
                        = rs.getString("BookingStatus");

                // ===============================
                // BƯỚC 2.6: Tính thời điểm booking
                // ===============================
                LocalDate bookingLocalDate
                        = bookingDate.toLocalDate();

                int totalMinutesStart = (slot - 1) * 30;

                int hour = 8 + totalMinutesStart / 60;

                int minute = totalMinutesStart % 60;

                LocalTime bookingTime
                        = LocalTime.of(hour, minute);

                LocalDateTime bookingDateTime
                        = LocalDateTime.of(
                                bookingLocalDate,
                                bookingTime
                        );

                if (!"Pending".equalsIgnoreCase(status)) {
                    return false;
                }

                LocalDateTime now = LocalDateTime.now();

                LocalDateTime cancelDeadline
                        = bookingDateTime.minusHours(2);
                System.out.println("========== DEBUG CANCEL ==========");
                System.out.println("BookingId = " + bookingId);
                System.out.println("BookingDateTime = " + bookingDateTime);
                System.out.println("Now = " + now);
                System.out.println("CancelDeadline = " + cancelDeadline);
                System.out.println("Result = " + (!now.isAfter(cancelDeadline)));
                System.out.println("==================================");
                return !now.isAfter(cancelDeadline);

            }

        } catch (Exception e) {

            e.printStackTrace();

        } finally {

            try {
                if (rs != null) {
                    rs.close();
                }

                if (pst != null) {
                    pst.close();
                }

                if (cn != null) {
                    cn.close();
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        return false;
    }

    public boolean insertRealPaidBooking(int accountId, Booking draft, int pointsUsed, int rewardId, double voucherDiscount, int promotionId, double promotionDiscount, double finalPrice, String paymentMemo) {
        Connection cn = null;
        PreparedStatement pstBooking = null;
        PreparedStatement pstPoints = null;
        PreparedStatement pstPointTrans = null;
        PreparedStatement pstVoucher = null;
        PreparedStatement pstPayment = null;   // ← THÊM
        ResultSet rs = null;

        String sqlInsertBooking = "INSERT INTO Bookings (CustomerId, VehicleId, ServiceId, BookingDate, "
                + "SlotNumber, TotalAmount, Note) VALUES (?, ?, ?, ?, ?, ?, ?)";

        String sqlUpdatePoints = "UPDATE CustomerLoyalty SET CurrentPoints = CurrentPoints - ?, "
                + "LifetimeRedeemedPoints = LifetimeRedeemedPoints + ?, UpdatedAt = GETDATE() WHERE AccountId = ?";

        String sqlInsertPointTrans = "INSERT INTO LoyaltyPointTransactions (AccountId, BookingId, RedemptionId, "
                + "PointsChange, TransactionType, ExpiresAt, Description, CreatedAt) "
                + "VALUES (?, ?, NULL, ?, 'Redeem', NULL, ?, GETDATE())";

        String sqlUpdateReward = "UPDATE RewardRedemptions SET Status = 'Used', UsedBookingId = ?, UsedAt = GETDATE() "
                + "WHERE CustomerId = ? AND RewardId = ? AND Status = 'Available'";

        // CÂU LỆNH MỚI: Ghi bản ghi Payments 1-1 với Booking, đúng theo schema (PromotionId, VoucherDiscountAmount...)
        String sqlInsertPayment = "INSERT INTO Payments (BookingId, PromotionId, PromotionDiscountAmount, "
                + "RedemptionId, VoucherDiscountAmount, FinalAmount, PaymentMethod, IsPaid, PaidAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'QR', 1, GETDATE())";

        try {
            cn = DBContext.getConnection();
            if (cn != null) {
                cn.setAutoCommit(false);

                // --- HÀNH ĐỘNG 1: INSERT BOOKING ---
                pstBooking = cn.prepareStatement(sqlInsertBooking, java.sql.Statement.RETURN_GENERATED_KEYS);   // ← SỬA: thêm lại RETURN_GENERATED_KEYS (bug thiếu dòng này khiến booking luôn fail)
                pstBooking.setInt(1, draft.getCustomerId());
                pstBooking.setInt(2, draft.getVehicleId());
                pstBooking.setInt(3, draft.getServiceId());
                pstBooking.setDate(4, java.sql.Date.valueOf(draft.getBookingDate()));
                pstBooking.setInt(5, draft.getSlotNumber());
                pstBooking.setDouble(6, finalPrice);
                pstBooking.setString(7, "Thanh toan QR Code. Ma GD: " + paymentMemo);

                int bookingRows = pstBooking.executeUpdate();
                if (bookingRows <= 0) {
                    cn.rollback();
                    return false;
                }

                int generatedBookingId = -1;
                rs = pstBooking.getGeneratedKeys();
                if (rs.next()) {
                    generatedBookingId = rs.getInt(1);
                }
                if (generatedBookingId == -1) {
                    cn.rollback();
                    return false;
                }

                // --- HÀNH ĐỘNG 2: CẬP NHẬT ĐIỂM & GHI LỊCH SỬ GIAO DỊCH ĐIỂM ---
                if (pointsUsed > 0) {
                    pstPoints = cn.prepareStatement(sqlUpdatePoints);
                    pstPoints.setInt(1, pointsUsed);
                    pstPoints.setInt(2, pointsUsed);
                    pstPoints.setInt(3, accountId);

                    int pointRows = pstPoints.executeUpdate();
                    if (pointRows <= 0) {
                        cn.rollback();
                        return false;
                    }

                    pstPointTrans = cn.prepareStatement(sqlInsertPointTrans);
                    pstPointTrans.setInt(1, accountId);
                    pstPointTrans.setInt(2, generatedBookingId);
                    pstPointTrans.setInt(3, -pointsUsed);
                    pstPointTrans.setString(4, "Trừ điểm tiêu dùng cho đơn đặt lịch #" + generatedBookingId);

                    int transRows = pstPointTrans.executeUpdate();
                    if (transRows <= 0) {
                        cn.rollback();
                        return false;
                    }
                }

                // --- HÀNH ĐỘNG 3: VÔ HIỆU HÓA REWARD TRONG REWARDREDEMPTIONS ---
                if (rewardId > 0) {
                    pstVoucher = cn.prepareStatement(sqlUpdateReward);
                    pstVoucher.setInt(1, generatedBookingId);
                    pstVoucher.setInt(2, draft.getCustomerId());
                    pstVoucher.setInt(3, rewardId);

                    int voucherRows = pstVoucher.executeUpdate();
                    if (voucherRows <= 0) {
                        cn.rollback();
                        return false;
                    }
                }

                // --- HÀNH ĐỘNG 4: GHI BẢN GHI PAYMENTS (tính lại 2 khoản giảm để lưu đúng theo schema) ---
                double basePrice = draft.getTotalAmount();

//                RewardDAO rewardDAO = new RewardDAO();
//                double voucherDiscount = rewardId > 0 ? rewardDAO.calculateVoucherDiscount(rewardId, basePrice) : 0.0;
//
//                PromotionDAO promotionDAO = new PromotionDAO();
//                double promotionDiscount = promotionId > 0 ? promotionDAO.calculatePromoDiscount(promotionId, basePrice) : 0.0;
                if (rewardId <= 0) {
                    voucherDiscount = 0.0;
                }
                if (promotionId <= 0) {
                    promotionDiscount = 0.0;
                }
                // Áp cùng logic co giãn tỉ lệ như CalculatePaymentController, đảm bảo không vượt basePrice
                double totalDiscount = voucherDiscount + promotionDiscount;
                if (totalDiscount > basePrice) {
                    double ratio = basePrice / totalDiscount;
                    voucherDiscount = voucherDiscount * ratio;
                    promotionDiscount = basePrice - voucherDiscount;
                }

                pstPayment = cn.prepareStatement(sqlInsertPayment);
                pstPayment.setInt(1, generatedBookingId);
//                if (promotionId > 0) {
                    pstPayment.setInt(2, promotionId);
//                } else {
//                    pstPayment.setNull(2, java.sql.Types.INTEGER);
//                }
                pstPayment.setDouble(3, promotionDiscount);
//                if (rewardId > 0) {
                    pstPayment.setInt(4, rewardId);
//                } else {
//                    pstPayment.setNull(4, java.sql.Types.INTEGER);
//                }
                pstPayment.setDouble(5, voucherDiscount);
                pstPayment.setDouble(6, finalPrice);   // FinalAmount lấy từ số tiền thực khách đã chuyển qua QR

                int paymentRows = pstPayment.executeUpdate();
                if (paymentRows <= 0) {
                    cn.rollback();
                    return false;
                }

                cn.commit();
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (cn != null) {
                    cn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (cn != null) {
                    cn.setAutoCommit(true);
                }
                if (pstBooking != null) {
                    pstBooking.close();
                }
                if (pstPoints != null) {
                    pstPoints.close();
                }
                if (pstPointTrans != null) {
                    pstPointTrans.close();
                }
                if (pstVoucher != null) {
                    pstVoucher.close();
                }
                if (pstPayment != null) {
                    pstPayment.close();   // ← THÊM
                }
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }
}
