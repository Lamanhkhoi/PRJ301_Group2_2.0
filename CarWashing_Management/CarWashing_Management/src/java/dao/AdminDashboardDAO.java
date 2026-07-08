package dao;

import dbutils.DBContext;
import dto.AdminDashboardData;
import dto.AdminDashboardData.ChartPoint;
import dto.AdminDashboardData.RecentBooking;
import dto.AdminDashboardData.ServiceStat;
import dto.TimeSlot;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import util.DateRangeUtil;
import util.DateRangeUtil.FilterType;
import util.DateRangeUtil.PeriodBucket;

public class AdminDashboardDAO {

    private static final DateTimeFormatter TIME_LABEL_FORMAT = DateTimeFormatter.ofPattern("H:mm");

    // ================================================================
    // 1. KPI CARDS
    // ================================================================
    public void loadTodayKpi(AdminDashboardData data) {
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String today = LocalDate.now().toString();

        String sql = "SELECT "
                + "  (SELECT ISNULL(SUM(p.FinalAmount), 0) FROM Payments p "
                + "     JOIN Bookings b ON p.BookingId = b.BookingId "
                + "     WHERE b.BookingDate = ? AND p.IsPaid = 1) AS TodayRevenue, "
                + "  (SELECT COUNT(*) FROM Bookings WHERE BookingDate = ?) AS TodayBookings, "
                + "  (SELECT COUNT(*) FROM Bookings WHERE BookingDate = ? AND BookingStatus = 'Completed') AS CompletedToday, "
                + "  (SELECT COUNT(*) FROM Bookings WHERE BookingDate = ? AND BookingStatus IN ('Cancelled', 'NoShow')) AS CancelledToday, "
                + "  (SELECT COUNT(*) FROM Customers WHERE CAST(CreatedAt AS DATE) = ?) AS NewCustomersToday";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            for (int i = 1; i <= 5; i++) {
                pst.setString(i, today);
            }
            rs = pst.executeQuery();
            if (rs.next()) {
                data.setTodayRevenue(rs.getDouble("TodayRevenue"));
                data.setTodayBookings(rs.getInt("TodayBookings"));
                data.setCompletedOrdersToday(rs.getInt("CompletedToday"));
                data.setCancelledBookingsToday(rs.getInt("CancelledToday"));
                data.setNewCustomersToday(rs.getInt("NewCustomersToday"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeAll(cn, pst, rs);
        }
    }

    // ================================================================
    // 2. REVENUE CHART 
    // ================================================================
    public void loadRevenueChart(AdminDashboardData data, FilterType filterType) {
        List<PeriodBucket> buckets = DateRangeUtil.getBuckets(filterType, LocalDate.now());
        List<ChartPoint> chart = new ArrayList<>();

        String sql = "SELECT ISNULL(SUM(p.FinalAmount), 0) AS Revenue "
                + "FROM Payments p JOIN Bookings b ON p.BookingId = b.BookingId "
                + "WHERE b.BookingDate BETWEEN ? AND ? AND p.IsPaid = 1";

        for (PeriodBucket bucket : buckets) {
            double revenue = 0;
            Connection cn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            try {
                cn = DBContext.getConnection();
                pst = cn.prepareStatement(sql);
                pst.setString(1, bucket.getStart().toString());
                pst.setString(2, bucket.getEnd().toString());
                rs = pst.executeQuery();
                if (rs.next()) {
                    revenue = rs.getDouble("Revenue");
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                closeAll(cn, pst, rs);
            }
            chart.add(new ChartPoint(bucket.getLabel(), revenue));
        }

        data.setRevenueChart(chart);
    }

    // ================================================================
    // 3. BOOKING TREND
    // ================================================================
    public void loadBookingTrend(AdminDashboardData data, FilterType filterType) {
        List<PeriodBucket> buckets = DateRangeUtil.getBuckets(filterType, LocalDate.now());
        List<ChartPoint> chart = new ArrayList<>();

        String sql = "SELECT COUNT(*) AS BookingCount FROM Bookings WHERE BookingDate BETWEEN ? AND ?";

        for (PeriodBucket bucket : buckets) {
            int count = 0;
            Connection cn = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            try {
                cn = DBContext.getConnection();
                pst = cn.prepareStatement(sql);
                pst.setString(1, bucket.getStart().toString());
                pst.setString(2, bucket.getEnd().toString());
                rs = pst.executeQuery();
                if (rs.next()) {
                    count = rs.getInt("BookingCount");
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                closeAll(cn, pst, rs);
            }
            chart.add(new ChartPoint(bucket.getLabel(), count));
        }

        data.setBookingTrend(chart);
    }

    // ================================================================
    // 4. PAYMENT OVERVIEW
    // ================================================================
    public void loadPaymentOverview(AdminDashboardData data, FilterType filterType) {
        LocalDate[] range = DateRangeUtil.getRange(filterType, LocalDate.now());
        String start = range[0].toString();
        String end = range[1].toString();

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT "
                + "  (SELECT COUNT(*) FROM Payments p JOIN Bookings b ON p.BookingId = b.BookingId "
                + "     WHERE b.BookingDate BETWEEN ? AND ? AND p.IsPaid = 1) AS PaidCount, "
                + "  (SELECT COUNT(*) FROM Payments p JOIN Bookings b ON p.BookingId = b.BookingId "
                + "     WHERE b.BookingDate BETWEEN ? AND ? AND p.IsPaid = 0 "
                + "     AND b.BookingStatus NOT IN ('Cancelled', 'NoShow')) AS PendingCount, "
                + "  (SELECT COUNT(*) FROM Bookings WHERE BookingDate BETWEEN ? AND ? "
                + "     AND BookingStatus IN ('Cancelled', 'NoShow')) AS CancelCount";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, start);
            pst.setString(2, end);
            pst.setString(3, start);
            pst.setString(4, end);
            pst.setString(5, start);
            pst.setString(6, end);
            rs = pst.executeQuery();
            if (rs.next()) {
                data.setPaidCount(rs.getInt("PaidCount"));
                data.setPendingCount(rs.getInt("PendingCount"));
                data.setCancelCount(rs.getInt("CancelCount"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeAll(cn, pst, rs);
        }
    }

    // ================================================================
    // 5. TOP SERVICES
    // ================================================================
    public void loadTopServices(AdminDashboardData data, FilterType filterType) {
        LocalDate[] range = DateRangeUtil.getRange(filterType, LocalDate.now());
        List<ServiceStat> stats = new ArrayList<>();

        String sql = "SELECT ws.ServiceName, COUNT(b.BookingId) AS BookingCount "
                + "FROM WashServices ws "
                + "LEFT JOIN Bookings b ON b.ServiceId = ws.ServiceId AND b.BookingDate BETWEEN ? AND ? "
                + "GROUP BY ws.ServiceId, ws.ServiceName "
                + "ORDER BY BookingCount DESC";

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, range[0].toString());
            pst.setString(2, range[1].toString());
            rs = pst.executeQuery();
            while (rs.next()) {
                stats.add(new ServiceStat(rs.getString("ServiceName"), rs.getInt("BookingCount")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeAll(cn, pst, rs);
        }

        data.setTopServices(stats);
    }

    // ================================================================
    // 6. RECENT BOOKINGS
    // ================================================================
    public void loadRecentBookings(AdminDashboardData data) {
        TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
        Map<Integer, TimeSlot> timeSlotMap = timeSlotDAO.getAllTimeSlots();

        LocalTime now = LocalTime.now();
        String today = LocalDate.now().toString();

        int currentSlotNumber = -1;
        int nextSlotNumber = -1;

        for (int slotNo = 1; slotNo <= 28; slotNo++) {
            TimeSlot slot = timeSlotMap.get(slotNo);
            if (slot == null) {
                continue;
            }
            LocalTime start = LocalTime.parse(slot.getStartTime());
            LocalTime end = LocalTime.parse(slot.getEndTime());
            if (!now.isBefore(start) && now.isBefore(end)) {
                currentSlotNumber = slotNo;
                nextSlotNumber = (slotNo < 28) ? slotNo + 1 : -1;
                break;
            }
        }

        if (currentSlotNumber == -1) {
            TimeSlot firstSlot = timeSlotMap.get(1);
            if (firstSlot != null && now.isBefore(LocalTime.parse(firstSlot.getStartTime()))) {
                nextSlotNumber = 1;
            } else {
                nextSlotNumber = -1;
            }
        }

        data.setCurrentSlotNumber(currentSlotNumber);
        data.setCurrentSlotLabel(buildSlotLabel(currentSlotNumber, timeSlotMap));
        data.setCurrentSlotBookings(
                (currentSlotNumber == -1) ? new ArrayList<>() : getBookingsForSlot(today, currentSlotNumber));

        data.setNextSlotNumber(nextSlotNumber);
        data.setNextSlotLabel(buildSlotLabel(nextSlotNumber, timeSlotMap));
        data.setNextSlotBookings(
                (nextSlotNumber == -1) ? new ArrayList<>() : getBookingsForSlot(today, nextSlotNumber));
    }

    private String buildSlotLabel(int slotNumber, Map<Integer, TimeSlot> timeSlotMap) {
        if (slotNumber == -1) {
            return "Ngoài giờ hoạt động";
        }
        TimeSlot slot = timeSlotMap.get(slotNumber);
        if (slot == null) {
            return "Ca " + slotNumber;
        }
        String start = LocalTime.parse(slot.getStartTime()).format(TIME_LABEL_FORMAT);
        String end = LocalTime.parse(slot.getEndTime()).format(TIME_LABEL_FORMAT);
        return "Ca " + slotNumber + " (" + start + " - " + end + ")";
    }

    private List<RecentBooking> getBookingsForSlot(String bookingDate, int slotNumber) {
        List<RecentBooking> list = new ArrayList<>();
        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT TOP 3 a.FullName, cv.LicensePlate, ws.ServiceName, "
                + "b.SlotNumber, b.BookingStatus "
                + "FROM Bookings b "
                + "JOIN Customers c ON b.CustomerId = c.CustomerId "
                + "JOIN Accounts a ON c.AccountId = a.AccountId "
                + "JOIN CustomerVehicles cv ON b.VehicleId = cv.VehicleId "
                + "JOIN WashServices ws ON b.ServiceId = ws.ServiceId "
                + "WHERE b.BookingDate = ? AND b.SlotNumber = ? AND b.BookingStatus <> 'Cancelled' "
                + "ORDER BY b.BookingId ASC";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, bookingDate);
            pst.setInt(2, slotNumber);
            rs = pst.executeQuery();
            while (rs.next()) {
                RecentBooking rb = new RecentBooking();
                rb.setCustomerName(rs.getString("FullName"));
                rb.setLicensePlate(rs.getString("LicensePlate"));
                rb.setServiceName(rs.getString("ServiceName"));
                rb.setSlotNumber(rs.getInt("SlotNumber"));
                rb.setBookingStatus(rs.getString("BookingStatus"));
                list.add(rb);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeAll(cn, pst, rs);
        }
        return list;
    }

    // ================================================================
    // 7. PROMOTION / MEMBERSHIP
    // ================================================================
    public void loadPromotionMembership(AdminDashboardData data, FilterType filterType) {
        LocalDate[] range = DateRangeUtil.getRange(filterType, LocalDate.now());
        String start = range[0].toString();
        String end = range[1].toString();

        Connection cn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        String sql = "SELECT "
                + "  (SELECT COUNT(*) FROM RewardRedemptions "
                + "     WHERE Status = 'Used' AND CAST(UsedAt AS DATE) BETWEEN ? AND ?) AS VoucherUsedCount, "
                + "  (SELECT COUNT(*) FROM Customers) AS TotalMembers, "
                + "  (SELECT COUNT(*) FROM Customers WHERE CAST(CreatedAt AS DATE) BETWEEN ? AND ?) AS NewMembersCount";

        try {
            cn = DBContext.getConnection();
            pst = cn.prepareStatement(sql);
            pst.setString(1, start);
            pst.setString(2, end);
            pst.setString(3, start);
            pst.setString(4, end);
            rs = pst.executeQuery();
            if (rs.next()) {
                data.setVoucherUsedCount(rs.getInt("VoucherUsedCount"));
                data.setTotalMembers(rs.getInt("TotalMembers"));
                data.setNewMembersCount(rs.getInt("NewMembersCount"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeAll(cn, pst, rs);
        }
    }

    private void closeAll(Connection cn, PreparedStatement pst, ResultSet rs) {
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
}