<%@ include file="../includes/admin-auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="dto.AdminDashboardData"%>
<%@page import="dto.AdminDashboardData.ChartPoint"%>
<%@page import="dto.AdminDashboardData.ServiceStat"%>
<%@page import="dto.AdminDashboardData.RecentBooking"%>
<%!
    // Chuyển List<ChartPoint> thành 2 mảng JSON (labels, values) để nạp vào Chart.js.
    // Viết thủ công (không dùng thư viện JSON ngoài) vì dữ liệu chỉ gồm số và nhãn tiếng Việt đơn giản.
    private String chartLabelsJson(List<ChartPoint> points) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < points.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(points.get(i).getLabel().replace("\"", "\\\"")).append("\"");
        }
        return sb.append("]").toString();
    }

    private String chartValuesJson(List<ChartPoint> points) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < points.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(points.get(i).getValue());
        }
        return sb.append("]").toString();
    }

    private String serviceLabelsJson(List<ServiceStat> stats) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < stats.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(stats.get(i).getServiceName().replace("\"", "\\\"")).append("\"");
        }
        return sb.append("]").toString();
    }

    private String serviceValuesJson(List<ServiceStat> stats) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < stats.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append(stats.get(i).getBookingCount());
        }
        return sb.append("]").toString();
    }

    private String statusBadgeClass(String status) {
        if (status == null) return "bg-slate-100 text-slate-600";
        switch (status) {
            case "Pending": return "bg-amber-100 text-amber-700";
            case "CheckedIn": return "bg-blue-100 text-blue-700";
            case "Completed": return "bg-emerald-100 text-emerald-700";
            case "NoShow": return "bg-rose-100 text-rose-700";
            default: return "bg-slate-100 text-slate-600";
        }
    }

    private String statusLabel(String status) {
        if (status == null) return "--";
        switch (status) {
            case "Pending": return "Chờ xử lý";
            case "CheckedIn": return "Đang rửa";
            case "Completed": return "Hoàn tất";
            case "NoShow": return "Không đến";
            default: return status;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Trị Hệ Thống - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
        <style>body { font-family: 'Inter', sans-serif; background-color: #F1F5F9; }</style>
    </head>
    <body class="text-slate-800 relative">

        <%
            AdminDashboardData data = (AdminDashboardData) request.getAttribute("DASHBOARD_DATA");
            String selectedFilter = (String) request.getAttribute("SELECTED_FILTER");
            if (selectedFilter == null) selectedFilter = "week";
            DecimalFormat money = new DecimalFormat("###,###,###");
        %>

        <div class="flex h-screen overflow-hidden relative">

            <% request.setAttribute("ACTIVE_ADMIN", "tongquan"); %>
            <jsp:include page="/includes/sidebar_admin.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-7xl mx-auto space-y-8">

                        <% if (data == null) { %>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-8 text-center">
                            <i class="fa-solid fa-triangle-exclamation text-3xl text-amber-400 mb-3"></i>
                            <p class="text-slate-500">Không tải được dữ liệu Dashboard. Vui lòng tải lại trang.</p>
                        </div>
                        <% } else { %>

                        <!-- ============ CÂU HỎI 1: HÔM NAY KIẾM ĐƯỢC BAO NHIÊU? ============ -->
                        <section>
                            <div class="flex items-center gap-2 mb-4">
                                <span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Hôm nay</span>
                                <span class="h-px flex-1 bg-slate-200"></span>
                            </div>
                            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <div class="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center mb-3">
                                        <i class="fa-solid fa-sack-dollar"></i>
                                    </div>
                                    <p class="text-xs text-slate-500">Doanh Thu Hôm Nay</p>
                                    <p class="text-xl font-bold text-slate-800 mt-1"><%= money.format(data.getTodayRevenue()) %>đ</p>
                                </div>

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <div class="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center mb-3">
                                        <i class="fa-solid fa-calendar-day"></i>
                                    </div>
                                    <p class="text-xs text-slate-500">Lượt Đặt Hôm Nay</p>
                                    <p class="text-xl font-bold text-slate-800 mt-1"><%= data.getTodayBookings() %></p>
                                </div>

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center mb-3">
                                        <i class="fa-solid fa-circle-check"></i>
                                    </div>
                                    <p class="text-xs text-slate-500">Đơn Hoàn Tất</p>
                                    <p class="text-xl font-bold text-slate-800 mt-1"><%= data.getCompletedOrdersToday() %></p>
                                </div>

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center mb-3">
                                        <i class="fa-solid fa-ban"></i>
                                    </div>
                                    <p class="text-xs text-slate-500">Đơn Hủy / Không Đến</p>
                                    <p class="text-xl font-bold text-slate-800 mt-1"><%= data.getCancelledBookingsToday() %></p>
                                </div>

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center mb-3">
                                        <i class="fa-solid fa-user-plus"></i>
                                    </div>
                                    <p class="text-xs text-slate-500">Khách Mới Hôm Nay</p>
                                    <p class="text-xl font-bold text-slate-800 mt-1"><%= data.getNewCustomersToday() %></p>
                                </div>

                            </div>
                        </section>

                        <!-- ============ CÂU HỎI 2: CỬA HÀNG CÓ VẤN ĐỀ GÌ KHÔNG? ============ -->
                        <section>
                            <div class="flex items-center gap-2 mb-4">
                                <span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Tình Hình Kinh Doanh</span>
                                <span class="h-px flex-1 bg-slate-200"></span>
                            </div>

                            <!-- Thanh bộ lọc thời gian: chọn ngày tham chiếu + kỳ trước/sau + loại kỳ -->
                            <form id="dashboardFilterForm" method="post" action="MainController"
                                  class="bg-white border border-slate-200 rounded-xl shadow-sm p-3 mb-4 flex flex-wrap items-center gap-3">
                                <input type="hidden" name="action" value="adminDashboard">
                                <input type="hidden" id="filterTypeInput" name="filterType" value="<%= selectedFilter %>">
                                <input type="hidden" id="navigateInput" name="navigate" value="">

                                <div class="flex items-center gap-1">
                                    <button type="button" onclick="dashboardNavigate('prev')"
                                            class="w-8 h-8 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-100 flex items-center justify-center">
                                        <i class="fa-solid fa-chevron-left text-xs"></i>
                                    </button>
                                    <input type="date" name="referenceDate" value="<%= data.getReferenceDate() %>"
                                           onchange="document.getElementById('navigateInput').value=''; document.getElementById('dashboardFilterForm').submit();"
                                           class="text-sm border border-slate-200 rounded-lg px-2 py-1.5 text-slate-600">
                                    <button type="button" onclick="dashboardNavigate('next')"
                                            class="w-8 h-8 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-100 flex items-center justify-center">
                                        <i class="fa-solid fa-chevron-right text-xs"></i>
                                    </button>
                                    <button type="button" onclick="dashboardNavigate('today')"
                                            class="ml-1 px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-100">
                                        Hôm nay
                                    </button>
                                </div>

                                <span class="text-sm text-slate-400 font-medium"><%= data.getRangeLabel() %></span>

                                <span class="flex-1"></span>

                                <div class="flex bg-slate-100 rounded-xl p-1">
                                    <% String[][] filters = {{"week","Tuần"},{"month","Tháng"},{"quarter","Quý"},{"year","Năm"}}; %>
                                    <% for (String[] f : filters) {
                                        boolean active = f[0].equals(selectedFilter);
                                    %>
                                    <button type="button" onclick="dashboardSetFilter('<%= f[0] %>')"
                                            class="px-4 py-1.5 text-sm font-medium rounded-lg transition-colors <%= active ? "bg-blue-600 text-white shadow-sm" : "text-slate-500 hover:bg-white" %>">
                                        <%= f[1] %>
                                    </button>
                                    <% } %>
                                </div>
                            </form>

                            <!-- Revenue Chart + Booking Trend -->
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4">
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <p class="text-sm font-semibold text-slate-700 mb-3">Doanh Thu Theo Thời Gian</p>
                                    <div class="h-64"><canvas id="revenueChart"></canvas></div>
                                </div>
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <p class="text-sm font-semibold text-slate-700 mb-3">Xu Hướng Đặt Lịch</p>
                                    <div class="h-64"><canvas id="bookingTrendChart"></canvas></div>
                                </div>
                            </div>

                            <!-- Payment Overview + Top Services -->
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-4">
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <p class="text-sm font-semibold text-slate-700 mb-3">Tình Trạng Thanh Toán</p>
                                    <div class="h-56"><canvas id="paymentChart"></canvas></div>
                                </div>
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 lg:col-span-2">
                                    <p class="text-sm font-semibold text-slate-700 mb-3">Gói Dịch Vụ Được Chọn Nhiều Nhất</p>
                                    <div class="h-56"><canvas id="topServicesChart"></canvas></div>
                                </div>
                            </div>

                            <!-- Promotion / Membership -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 flex items-center gap-4">
                                    <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
                                        <i class="fa-solid fa-ticket"></i>
                                    </div>
                                    <div>
                                        <p class="text-xs text-slate-500">Voucher Đã Dùng</p>
                                        <p class="text-lg font-bold text-slate-800"><%= data.getVoucherUsedCount() %></p>
                                    </div>
                                </div>
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 flex items-center gap-4">
                                    <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                                        <i class="fa-solid fa-users"></i>
                                    </div>
                                    <div>
                                        <p class="text-xs text-slate-500">Tổng Thành Viên</p>
                                        <p class="text-lg font-bold text-slate-800"><%= data.getTotalMembers() %></p>
                                    </div>
                                </div>
                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5 flex items-center gap-4">
                                    <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                                        <i class="fa-solid fa-user-plus"></i>
                                    </div>
                                    <div>
                                        <p class="text-xs text-slate-500">Thành Viên Mới</p>
                                        <p class="text-lg font-bold text-slate-800"><%= data.getNewMembersCount() %></p>
                                    </div>
                                </div>
                            </div>
                        </section>

                        <!-- ============ CÂU HỎI 3: NHỮNG NGÀY TỚI CẦN CHUẨN BỊ GÌ? ============ -->
                        <section>
                            <div class="flex items-center gap-2 mb-4">
                                <span class="text-xs font-semibold uppercase tracking-wider text-blue-600">Đang Diễn Ra</span>
                                <span class="h-px flex-1 bg-slate-200"></span>
                            </div>
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <p class="text-sm font-semibold text-slate-700 mb-1">Ca Hiện Tại</p>
                                    <p class="text-xs text-slate-400 mb-3"><%= data.getCurrentSlotLabel() %></p>
                                    <% List<RecentBooking> curList = data.getCurrentSlotBookings(); %>
                                    <% if (curList == null || curList.isEmpty()) { %>
                                    <p class="text-sm text-slate-400 italic py-4 text-center">Không có booking nào trong ca này.</p>
                                    <% } else { %>
                                    <div class="space-y-2">
                                        <% for (RecentBooking rb : curList) { %>
                                        <div class="flex items-center justify-between px-3 py-2 rounded-xl bg-slate-50">
                                            <div>
                                                <p class="text-sm font-medium text-slate-700"><%= rb.getCustomerName() %> · <%= rb.getLicensePlate() %></p>
                                                <p class="text-xs text-slate-400"><%= rb.getServiceName() %></p>
                                            </div>
                                            <span class="text-xs font-medium px-2 py-1 rounded-full <%= statusBadgeClass(rb.getBookingStatus()) %>">
                                                <%= statusLabel(rb.getBookingStatus()) %>
                                            </span>
                                        </div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                </div>

                                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
                                    <p class="text-sm font-semibold text-slate-700 mb-1">Ca Kế Tiếp</p>
                                    <p class="text-xs text-slate-400 mb-3"><%= data.getNextSlotLabel() %></p>
                                    <% List<RecentBooking> nextList = data.getNextSlotBookings(); %>
                                    <% if (nextList == null || nextList.isEmpty()) { %>
                                    <p class="text-sm text-slate-400 italic py-4 text-center">Không có booking nào trong ca này.</p>
                                    <% } else { %>
                                    <div class="space-y-2">
                                        <% for (RecentBooking rb : nextList) { %>
                                        <div class="flex items-center justify-between px-3 py-2 rounded-xl bg-slate-50">
                                            <div>
                                                <p class="text-sm font-medium text-slate-700"><%= rb.getCustomerName() %> · <%= rb.getLicensePlate() %></p>
                                                <p class="text-xs text-slate-400"><%= rb.getServiceName() %></p>
                                            </div>
                                            <span class="text-xs font-medium px-2 py-1 rounded-full <%= statusBadgeClass(rb.getBookingStatus()) %>">
                                                <%= statusLabel(rb.getBookingStatus()) %>
                                            </span>
                                        </div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                </div>

                            </div>
                        </section>

                        <% } // end if data != null %>

                    </div>
                </div>
            </main>
        </div>

        <% if (data != null) { %>
        <script>
            // 2 hàm nhỏ dùng cho thanh bộ lọc: đổi loại kỳ (Tuần/Tháng/Quý/Năm) hoặc
            // dịch chuyển kỳ (Kỳ trước/Kỳ sau/Hôm nay). Vẫn là 1 lượt submit form POST
            // bình thường (reload lại trang), không dùng fetch/AJAX.
            function dashboardSetFilter(type) {
                document.getElementById('filterTypeInput').value = type;
                document.getElementById('navigateInput').value = '';
                document.getElementById('dashboardFilterForm').submit();
            }
            function dashboardNavigate(direction) {
                document.getElementById('navigateInput').value = direction;
                document.getElementById('dashboardFilterForm').submit();
            }

            const revenueLabels = <%= chartLabelsJson(data.getRevenueChart()) %>;
            const revenueValues = <%= chartValuesJson(data.getRevenueChart()) %>;
            const bookingLabels = <%= chartLabelsJson(data.getBookingTrend()) %>;
            const bookingValues = <%= chartValuesJson(data.getBookingTrend()) %>;
            const serviceLabels = <%= serviceLabelsJson(data.getTopServices()) %>;
            const serviceValues = <%= serviceValuesJson(data.getTopServices()) %>;
            const paidCount = <%= data.getPaidCount() %>;
            const pendingCount = <%= data.getPendingCount() %>;
            const cancelCount = <%= data.getCancelCount() %>;

            new Chart(document.getElementById('revenueChart'), {
                type: 'line',
                data: {
                    labels: revenueLabels,
                    datasets: [{
                        label: 'Doanh thu',
                        data: revenueValues,
                        borderColor: '#2563eb',
                        backgroundColor: 'rgba(37, 99, 235, 0.1)',
                        tension: 0.35,
                        fill: true,
                        pointRadius: 3
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { callback: v => v.toLocaleString('vi-VN') } } }
                }
            });

            new Chart(document.getElementById('bookingTrendChart'), {
                type: 'bar',
                data: {
                    labels: bookingLabels,
                    datasets: [{
                        label: 'Số lượt đặt',
                        data: bookingValues,
                        backgroundColor: '#7c3aed',
                        borderRadius: 6
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
                }
            });

            new Chart(document.getElementById('paymentChart'), {
                type: 'doughnut',
                data: {
                    labels: ['Đã thanh toán', 'Đang chờ', 'Đã hủy'],
                    datasets: [{
                        data: [paidCount, pendingCount, cancelCount],
                        backgroundColor: ['#16a34a', '#f59e0b', '#e11d48']
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom', labels: { boxWidth: 10, font: { size: 11 } } } }
                }
            });

            new Chart(document.getElementById('topServicesChart'), {
                type: 'bar',
                data: {
                    labels: serviceLabels,
                    datasets: [{
                        label: 'Lượt đặt',
                        data: serviceValues,
                        backgroundColor: '#2563eb',
                        borderRadius: 6
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { x: { beginAtZero: true, ticks: { precision: 0 } } }
                }
            });
        </script>
        <% } %>
    </body>
</html>
