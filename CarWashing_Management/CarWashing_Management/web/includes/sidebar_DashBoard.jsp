<%-- 
    Document   : sidebar_DashBoard.jsp
    Created on : May 29, 2026, 10:24:27 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<aside class="w-64 bg-[#1E293B] text-white flex flex-col justify-between z-10">
    <div>
        <div class="h-20 flex items-center justify-center border-b border-slate-700">
            <img src="<%=request.getContextPath()%>/image/logo-fpt.png" alt="SmartWash" class="h-10">
        </div>
        <nav class="mt-6 flex flex-col gap-1 px-3" id="mainSidebar">
            
            <% 
                String activeTab = (String) request.getAttribute("activeTab"); 
                // Biến giả lập đếm số ưu đãi từ DB (Nếu null hoặc = 0 thì không hiện thông báo)
                Integer promoCount = (Integer) request.getAttribute("promoCount");
            %>

            <a href="customer_dashboard.jsp" data-tab="tongquan" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "tongquan".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700" %>">
                <i class="fa-solid fa-chart-pie w-5"></i> <span>Tổng Quan</span>
            </a>
            
            <a href="booking" data-tab="datlich" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "datlich".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700" %>">
                <i class="fa-solid fa-calendar-check w-5"></i> <span>Đặt Lịch</span>
            </a>
            
            <a href="customer_vehicles.jsp" data-tab="xecuatoi" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "xecuatoi".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700" %>">
                <i class="fa-solid fa-car w-5"></i> <span>Xe Của Tôi</span>
            </a>
            
            <a href="history" data-tab="lichsu" class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-lg transition-colors <%= "lichsu".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700" %>">
                <i class="fa-solid fa-clock-rotate-left w-5"></i> <span>Lịch Sử</span>
            </a>

            <a href="promotions" data-tab="uudai" class="sidebar-item flex items-center justify-between px-4 py-3 rounded-lg transition-colors <%= "uudai".equals(activeTab) ? "bg-emerald-500 text-white font-semibold" : "text-slate-300 hover:bg-slate-700" %>">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-ticket w-5"></i> <span>Ưu Đãi</span>
                </div>
                <% if (promoCount != null && promoCount > 0) { %>
                    <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full shadow-sm"><%= promoCount %></span>
                <% } %>
            </a>
        </nav>
    </div>
    
    <div class="px-3 mb-6">
        <a href="logout" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-red-500/20 hover:text-red-400 transition-colors border-t border-slate-700 mt-4">
            <i class="fa-solid fa-arrow-right-from-bracket w-5"></i> <span>Đăng Xuất</span>
        </a>
    </div>
</aside>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const currentPath = window.location.pathname;
        const allItems = document.querySelectorAll('#mainSidebar .sidebar-item');
        
        allItems.forEach(item => {
            item.classList.remove('bg-emerald-500', 'text-white', 'font-semibold');
            item.classList.add('text-slate-300', 'hover:bg-slate-700');
        });

        allItems.forEach(item => {
            const href = item.getAttribute('href');
            if (href && currentPath.includes(href)) {
                item.classList.remove('text-slate-300', 'hover:bg-slate-700');
                item.classList.add('bg-emerald-500', 'text-white', 'font-semibold');
            }
        });
    });
</script>
