package dto;

import java.util.List;

/**
 * DTO tổng hợp toàn bộ dữ liệu hiển thị trên trang Admin Dashboard (Người 4).
 * Gộp chung 1 file duy nhất theo yêu cầu hạn chế số lượng DTO -- các khối dữ liệu
 * có cấu trúc lặp lại (chart, danh sách dịch vụ, danh sách booking) được tách thành
 * các static nested class nhỏ bên trong, không tạo thêm file riêng.
 */
public class AdminDashboardData {

    // ===================== 1. KPI CARDS (luôn cố định "Hôm nay", không đổi theo filter) =====================
    private double todayRevenue;
    private int todayBookings;
    private int completedOrdersToday;
    private int cancelledBookingsToday;
    private int newCustomersToday;

    // ===================== 2. REVENUE CHART (theo filter, biểu đồ đường) =====================
    private List<ChartPoint> revenueChart;

    // ===================== 3. BOOKING TREND (theo filter, biểu đồ cột) =====================
    private List<ChartPoint> bookingTrend;

    // ===================== 4. PAYMENT OVERVIEW (theo filter, biểu đồ tròn) =====================
    private int paidCount;
    private int pendingCount;
    private int cancelCount;

    // ===================== Thông tin kỳ đang xem (phục vụ ô chọn ngày + hiển thị khoảng ngày) =====================
    private String referenceDate;   // Ngày tham chiếu đang chọn, định dạng yyyy-MM-dd (giá trị mặc định cho <input type="date">)
    private String rangeLabel;      // Khoảng ngày đã tính, định dạng "dd/MM/yyyy - dd/MM/yyyy", chỉ để hiển thị

    // ===================== 5. TOP SERVICES (theo filter, biểu đồ cột ngang, hiển thị tất cả gói) =====================
    private List<ServiceStat> topServices;

    // ===================== 6. RECENT BOOKINGS (real-time, không theo filter) =====================
    private int currentSlotNumber;      // Slot hiện tại dựa theo giờ thực
    private String currentSlotLabel;    // VD: "Ca 5 (10:00 - 10:30)"
    private List<RecentBooking> currentSlotBookings;  // Tối đa 3 booking
    private int nextSlotNumber;
    private String nextSlotLabel;
    private List<RecentBooking> nextSlotBookings;     // Tối đa 3 booking

    // ===================== 7. PROMOTION / MEMBERSHIP (Voucher Used & New Members theo filter, Members all-time) =====================
    private int voucherUsedCount;
    private int totalMembers;
    private int newMembersCount;

    public AdminDashboardData() {
    }

    // ---------- Getters/Setters: KPI Cards ----------
    public double getTodayRevenue() {
        return todayRevenue;
    }

    public void setTodayRevenue(double todayRevenue) {
        this.todayRevenue = todayRevenue;
    }

    public int getTodayBookings() {
        return todayBookings;
    }

    public void setTodayBookings(int todayBookings) {
        this.todayBookings = todayBookings;
    }

    public int getCompletedOrdersToday() {
        return completedOrdersToday;
    }

    public void setCompletedOrdersToday(int completedOrdersToday) {
        this.completedOrdersToday = completedOrdersToday;
    }

    public int getCancelledBookingsToday() {
        return cancelledBookingsToday;
    }

    public void setCancelledBookingsToday(int cancelledBookingsToday) {
        this.cancelledBookingsToday = cancelledBookingsToday;
    }

    public int getNewCustomersToday() {
        return newCustomersToday;
    }

    public void setNewCustomersToday(int newCustomersToday) {
        this.newCustomersToday = newCustomersToday;
    }

    // ---------- Getters/Setters: Revenue Chart & Booking Trend ----------
    public List<ChartPoint> getRevenueChart() {
        return revenueChart;
    }

    public void setRevenueChart(List<ChartPoint> revenueChart) {
        this.revenueChart = revenueChart;
    }

    public List<ChartPoint> getBookingTrend() {
        return bookingTrend;
    }

    public void setBookingTrend(List<ChartPoint> bookingTrend) {
        this.bookingTrend = bookingTrend;
    }

    // ---------- Getters/Setters: Payment Overview ----------
    public int getPaidCount() {
        return paidCount;
    }

    public void setPaidCount(int paidCount) {
        this.paidCount = paidCount;
    }

    public int getPendingCount() {
        return pendingCount;
    }

    public void setPendingCount(int pendingCount) {
        this.pendingCount = pendingCount;
    }

    public int getCancelCount() {
        return cancelCount;
    }

    public void setCancelCount(int cancelCount) {
        this.cancelCount = cancelCount;
    }

    // ---------- Getters/Setters: Thông tin kỳ đang xem ----------
    public String getReferenceDate() {
        return referenceDate;
    }

    public void setReferenceDate(String referenceDate) {
        this.referenceDate = referenceDate;
    }

    public String getRangeLabel() {
        return rangeLabel;
    }

    public void setRangeLabel(String rangeLabel) {
        this.rangeLabel = rangeLabel;
    }

    // ---------- Getters/Setters: Top Services ----------
    public List<ServiceStat> getTopServices() {
        return topServices;
    }

    public void setTopServices(List<ServiceStat> topServices) {
        this.topServices = topServices;
    }

    // ---------- Getters/Setters: Recent Bookings ----------
    public int getCurrentSlotNumber() {
        return currentSlotNumber;
    }

    public void setCurrentSlotNumber(int currentSlotNumber) {
        this.currentSlotNumber = currentSlotNumber;
    }

    public String getCurrentSlotLabel() {
        return currentSlotLabel;
    }

    public void setCurrentSlotLabel(String currentSlotLabel) {
        this.currentSlotLabel = currentSlotLabel;
    }

    public List<RecentBooking> getCurrentSlotBookings() {
        return currentSlotBookings;
    }

    public void setCurrentSlotBookings(List<RecentBooking> currentSlotBookings) {
        this.currentSlotBookings = currentSlotBookings;
    }

    public int getNextSlotNumber() {
        return nextSlotNumber;
    }

    public void setNextSlotNumber(int nextSlotNumber) {
        this.nextSlotNumber = nextSlotNumber;
    }

    public String getNextSlotLabel() {
        return nextSlotLabel;
    }

    public void setNextSlotLabel(String nextSlotLabel) {
        this.nextSlotLabel = nextSlotLabel;
    }

    public List<RecentBooking> getNextSlotBookings() {
        return nextSlotBookings;
    }

    public void setNextSlotBookings(List<RecentBooking> nextSlotBookings) {
        this.nextSlotBookings = nextSlotBookings;
    }

    // ---------- Getters/Setters: Promotion / Membership ----------
    public int getVoucherUsedCount() {
        return voucherUsedCount;
    }

    public void setVoucherUsedCount(int voucherUsedCount) {
        this.voucherUsedCount = voucherUsedCount;
    }

    public int getTotalMembers() {
        return totalMembers;
    }

    public void setTotalMembers(int totalMembers) {
        this.totalMembers = totalMembers;
    }

    public int getNewMembersCount() {
        return newMembersCount;
    }

    public void setNewMembersCount(int newMembersCount) {
        this.newMembersCount = newMembersCount;
    }


    /**
     * Cặp (nhãn, giá trị) dùng chung cho Revenue Chart và Booking Trend.
     * VD: label = "T2" hoặc "01/07" hoặc "Tuần 1" hoặc "Tháng 3", value = doanh thu hoặc số lượng booking.
     */
    public static class ChartPoint {
        private String label;
        private double value;

        public ChartPoint() {
        }

        public ChartPoint(String label, double value) {
            this.label = label;
            this.value = value;
        }

        public String getLabel() {
            return label;
        }

        public void setLabel(String label) {
            this.label = label;
        }

        public double getValue() {
            return value;
        }

        public void setValue(double value) {
            this.value = value;
        }
    }

    /**
     * Thống kê số lượt đặt theo từng gói dịch vụ (Top Services).
     */
    public static class ServiceStat {
        private String serviceName;
        private int bookingCount;

        public ServiceStat() {
        }

        public ServiceStat(String serviceName, int bookingCount) {
            this.serviceName = serviceName;
            this.bookingCount = bookingCount;
        }

        public String getServiceName() {
            return serviceName;
        }

        public void setServiceName(String serviceName) {
            this.serviceName = serviceName;
        }

        public int getBookingCount() {
            return bookingCount;
        }

        public void setBookingCount(int bookingCount) {
            this.bookingCount = bookingCount;
        }
    }

    /**
     * 1 dòng trong bảng Recent Bookings.
     */
    public static class RecentBooking {
        private String customerName;
        private String licensePlate;
        private String serviceName;
        private int slotNumber;
        private String startTime;   // Giờ bắt đầu ca, lấy từ TimeSlot (dạng chuỗi, VD "10:00")
        private String bookingStatus;

        public RecentBooking() {
        }

        public String getCustomerName() {
            return customerName;
        }

        public void setCustomerName(String customerName) {
            this.customerName = customerName;
        }

        public String getLicensePlate() {
            return licensePlate;
        }

        public void setLicensePlate(String licensePlate) {
            this.licensePlate = licensePlate;
        }

        public String getServiceName() {
            return serviceName;
        }

        public void setServiceName(String serviceName) {
            this.serviceName = serviceName;
        }

        public int getSlotNumber() {
            return slotNumber;
        }

        public void setSlotNumber(int slotNumber) {
            this.slotNumber = slotNumber;
        }

        public String getStartTime() {
            return startTime;
        }

        public void setStartTime(String startTime) {
            this.startTime = startTime;
        }

        public String getBookingStatus() {
            return bookingStatus;
        }

        public void setBookingStatus(String bookingStatus) {
            this.bookingStatus = bookingStatus;
        }
    }
}