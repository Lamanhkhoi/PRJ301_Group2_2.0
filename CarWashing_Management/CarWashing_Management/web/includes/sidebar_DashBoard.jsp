<%-- 
    Document   : sidebar_DashBoard.jsp
    Created on : May 29, 2026, 10:24:27 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%-- 
    CẢI THIỆN UI: Chuyển sang phong cách Floating Sidebar (Nổi), bo tròn góc lớn 
    và đổ bóng mượt mà để tạo ranh giới mềm mại với nền trắng.
--%>
<aside class="w-64 bg-[#1E293B] text-white flex flex-col justify-between z-10 
              ml-6 my-6 rounded-3xl shadow-2xl overflow-hidden border border-slate-700/50">
    <div>
        <%-- Điều chỉnh lại khu vực Logo cho khớp với góc bo tròn --%>
        <div class="py-2 flex items-center justify-center border-b border-slate-700/50 mx-0">
            <img src="<%=request.getContextPath()%>/image/logo.png" alt="SmartWash" class="h-35 opacity-100">
        </div>
        
        <nav class="mt-6 flex flex-col gap-2 px-4" id="mainSidebar">
            
            <% 
                String activeTab = (String) request.getAttribute("activeTab"); 
                // Biến giả lập đếm số ưu đãi (Mặc định không có)
                Integer promoCount = (Integer) request.getAttribute("promoCount");
            %>

            <%-- NÚT TỔNG QUAN --%>
            <a href="customer_dashboard.jsp" data-tab="tongquan" 
               class="sidebar-item flex items-center gap-3 px-4 py-3.5 rounded-xl transition-all duration-200 group
                      <%= "tongquan".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white" %>">
                <i class="fa-solid fa-chart-pie w-5 text-lg <%= "tongquan".equals(activeTab) ? "" : "group-hover:scale-110" %> transition-transform"></i> 
                <span>Tổng Quan</span>
            </a>
            
            <%-- NÚT ĐẶT LỊCH --%>
            <a href="booking" data-tab="datlich" 
               class="sidebar-item flex items-center gap-3 px-4 py-3.5 rounded-xl transition-all duration-200 group
                      <%= "datlich".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white" %>">
                <i class="fa-solid fa-calendar-check w-5 text-lg <%= "datlich".equals(activeTab) ? "" : "group-hover:scale-110" %> transition-transform"></i> 
                <span>Đặt Lịch</span>
            </a>
            
            <%-- NÚT XE CỦA TÔI --%>
            <a href="customer_vehicles.jsp" data-tab="xecuatoi" 
               class="sidebar-item flex items-center gap-3 px-4 py-3.5 rounded-xl transition-all duration-200 group
                      <%= "xecuatoi".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white" %>">
                <i class="fa-solid fa-car w-5 text-lg <%= "xecuatoi".equals(activeTab) ? "" : "group-hover:scale-110" %> transition-transform"></i> 
                <span>Xe Của Tôi</span>
            </a>
            
            <%-- NÚT LỊCH SỬ --%>
            <a href="history" data-tab="lichsu" 
               class="sidebar-item flex items-center gap-3 px-4 py-3.5 rounded-xl transition-all duration-200 group
                      <%= "lichsu".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white" %>">
                <i class="fa-solid fa-clock-rotate-left w-5 text-lg <%= "lichsu".equals(activeTab) ? "" : "group-hover:scale-110" %> transition-transform"></i> 
                <span>Lịch Sử</span>
            </a>

            <%-- NÚT ƯU ĐÃI (MỚI THÊM) --%>
            <a href="promotions" data-tab="uudai" 
               class="sidebar-item flex items-center justify-between px-4 py-3.5 rounded-xl transition-all duration-200 group
                      <%= "uudai".equals(activeTab) ? "bg-emerald-500 text-white font-semibold shadow-md shadow-emerald-500/20" : "text-slate-300 hover:bg-slate-700/50 hover:text-white" %>">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-ticket w-5 text-lg <%= "uudai".equals(activeTab) ? "" : "group-hover:scale-110" %> transition-transform"></i> 
                    <span>Ưu Đãi</span>
                </div>
                <% if (promoCount != null && promoCount > 0) { %>
                    <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-sm"><%= promoCount %></span>
                <% } %>
            </a>
        </nav>
    </div>
    
    <%-- Khu vực Đăng Xuất chân trang --%>
    <div class="px-4 mb-6">
        <a href="logout" class="flex items-center gap-3 px-4 py-3.5 rounded-xl text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-colors border-t border-slate-700/50 mt-4">
            <i class="fa-solid fa-arrow-right-from-bracket w-5 text-lg"></i> <span>Đăng Xuất</span>
        </a>
    </div>
</aside>

<%-- GIỮ NGUYÊN JAVASCRIPT LOGIC --%>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Lấy đường dẫn URL hiện tại
        const currentPath = window.location.pathname;
        const allItems = document.querySelectorAll('#mainSidebar .sidebar-item');
        
        // Bước 1: "Tẩy" sạch màu xanh ở tất cả các nút (đề phòng HTML bị gắn cứng)
        allItems.forEach(item => {
            item.classList.remove('bg-emerald-500', 'text-white', 'font-semibold', 'shadow-md', 'shadow-emerald-500/20');
            item.classList.add('text-slate-300', 'hover:bg-slate-700/50', 'hover:text-white');
        });

        // Bước 2: Đối chiếu URL, nếu trùng với href thì tô màu xanh
        allItems.forEach(item => {
            const href = item.getAttribute('href');
            // Kiểm tra xem URL có chứa tên trang (VD: customer_dashboard.jsp) không
            if (href && currentPath.includes(href)) {
                item.classList.remove('text-slate-300', 'hover:bg-slate-700/50', 'hover:text-white');
                item.classList.add('bg-emerald-500', 'text-white', 'font-semibold', 'shadow-md', 'shadow-emerald-500/20');
            }
        });
    });
</script>
