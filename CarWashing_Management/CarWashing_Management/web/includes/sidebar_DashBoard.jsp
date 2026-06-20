<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (request.getAttribute("javax.servlet.include.request_uri") == null) {
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }
%>
<aside class="w-64 bg-[#1E293B] text-white flex flex-col justify-between z-10">
    <div>
        <div class="h-20 flex items-center justify-center border-b border-slate-700">
            <img src="<%=request.getContextPath()%>/image/logo.png" alt="SmartWash" class="h-20 opacity-100">
        </div>
        <nav class="mt-6 flex flex-col gap-1 px-3" id="mainSidebar">

            <%
                // 1. ĐỔI TÊN BIẾN LẤY TỪ CONTROLLER TẠI ĐÂY
                String activeTab = (String) request.getAttribute("ACTIVE_TAB");
                Integer promoCount = (Integer) request.getAttribute("promoCount");
                // Giả lập biến đếm số lượng "Lịch đã hẹn" (Backend sẽ gửi biến này qua request)
                Integer activeBookingCount = (Integer) request.getAttribute("ACTIVE_BOOKING_COUNT");
            %>

            <a href="<%=request.getContextPath()%>/MainController?action=customerPage" data-tab="tongquan" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "tongquan".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <i class="fa-solid fa-chart-pie w-5"></i> <span>Tổng Quan</span>
            </a>

            <a href="<%=request.getContextPath()%>/MainController?action=customerBookingPage" data-tab="datlich" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "datlich".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <i class="fa-solid fa-calendar-check w-5"></i> <span>Đặt Lịch</span>
            </a>

            <a href="<%=request.getContextPath()%>/DashBoard/customer_upcoming.jsp" data-tab="lichdahen" class="sidebar-item flex items-center justify-between px-4 py-3 rounded-lg transition-colors <%= "lichdahen".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-stopwatch w-5"></i> <span>Lịch đã hẹn</span>
                </div>
                <% if (activeBookingCount != null && activeBookingCount > 0) {%>
                    <span class="bg-amber-500 text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-sm"><%= activeBookingCount %></span>
                <% } %>
            </a>  

            <a href="<%=request.getContextPath()%>/MainController?action=customerHistoryDashboard" data-tab="lichsu" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "lichsu".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <i class="fa-solid fa-clock-rotate-left w-5"></i> <span>Lịch Sử</span>
            </a>

            <a href="<%=request.getContextPath()%>/MainController?action=customerVehicle" data-tab="cus_vehicle" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "cus_vehicle".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <i class="fa-solid fa-car w-5"></i> <span>Xe Của Tôi</span>
            </a>

            <a href="promotions" data-tab="uudai" class="sidebar-item flex items-center justify-between px-4 py-3 rounded-lg transition-colors <%= "uudai".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700"%>">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-ticket w-5"></i> <span>Ưu Đãi</span>
                </div>
                <% if (promoCount != null && promoCount > 0) {%>
                <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-sm"><%= promoCount%></span>
                <% }%>
            </a>
        </nav>
    </div>

    <%-- Khu vực Chân trang Sidebar --%>
    <div class="px-4 mb-6 mt-auto">
        <%-- NÚT THÔNG TIN CÁ NHÂN (MỚI THÊM) --%>
        <a href="<%=request.getContextPath()%>/MainController?action=customerProfile" data-tab="thongtincanhan" class="sidebar-item flex items-center gap-3 px-4 py-3.5 rounded-xl transition-all duration-200 group
           <%= "thongtincanhan".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white"%>">
            <i class="fa-solid fa-user-gear w-5 text-lg <%= "thongtincanhan".equals(activeTab) ? "" : "group-hover:scale-110"%> transition-transform"></i> 
            <span>Thông tin cá nhân</span>
        </a>

        <%-- Nút Đăng Xuất --%>
        <a href="${pageContext.request.contextPath}/LogoutController" class="flex items-center gap-3 px-4 py-3.5 rounded-xl text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-colors border-t border-slate-700/50 mt-4">
            <i class="fa-solid fa-arrow-right-from-bracket w-5 text-lg"></i> <span>Đăng Xuất</span>
        </a>
    </div>
</aside>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const currentPath = window.location.pathname;
        const allItems = document.querySelectorAll('#mainSidebar .sidebar-item');

        // Lấy giá trị từ biến Java activeTab ở trên (đã đổi sang đọc ACTIVE_TAB)
        const serverActiveTab = "<%= activeTab != null ? activeTab : ""%>";

        let matchedItem = null;

        // Ưu tiên 1: Tìm theo định danh tab từ Server gửi xuống
        if (serverActiveTab !== "") {
            matchedItem = document.querySelector(`#mainSidebar .sidebar-item[data-tab="${serverActiveTab}"]`);
        }

        // Ưu tiên 2: Nếu không thấy (hoặc click trực tiếp), tìm theo URL
        if (!matchedItem) {
            allItems.forEach(item => {
                const href = item.getAttribute('href');
                if (href && currentPath.includes(href)) {
                    matchedItem = item;
                }
            });
        }

        // Thực hiện xóa màu cũ và tô màu xanh cho tab đúng
        if (matchedItem) {
            allItems.forEach(item => {
                item.classList.remove('bg-emerald-500', 'text-white', 'font-semibold');
                item.classList.add('text-slate-300', 'hover:bg-slate-700');
            });

            matchedItem.classList.remove('text-slate-300', 'hover:bg-slate-700');
            matchedItem.classList.add('bg-emerald-500', 'text-white', 'font-semibold');
        }
    });
</script>