package dto;

import java.util.List;

public class AdminDashboardData {

    private double todayRevenue;
    private int todayBookings;
    private int completedOrdersToday;
    private int cancelledBookingsToday;
    private int newCustomersToday;
    
    private List<ChartPoint> revenueChart;
    
    private List<ChartPoint> bookingTrend;

    private int paidCount;
    private int pendingCount;
    private int cancelCount;

    private List<ServiceStat> topServices;

    private int currentSlotNumber;     
    private String currentSlotLabel;    
    private List<RecentBooking> currentSlotBookings; 
    private int nextSlotNumber;
    private String nextSlotLabel;
    private List<RecentBooking> nextSlotBookings;    

    private int voucherUsedCount;
    private int totalMembers;
    private int newMembersCount;

    public AdminDashboardData() {
    }

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

    public List<ServiceStat> getTopServices() {
        return topServices;
    }

    public void setTopServices(List<ServiceStat> topServices) {
        this.topServices = topServices;
    }

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

    public static class RecentBooking {
        private String customerName;
        private String licensePlate;
        private String serviceName;
        private int slotNumber;
        private String startTime;   
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