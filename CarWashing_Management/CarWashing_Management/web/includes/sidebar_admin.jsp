<%-- 
    Document   : sidebar_admin.jsp
    Created on : Jun 10, 2026, 12:53:09 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<aside class="w-64 bg-slate-900 text-slate-300 flex flex-col justify-between z-10 h-screen shadow-xl">
    <div>
        <div class="h-20 flex items-center justify-center border-b border-slate-800 bg-slate-950/50">
            <img src="<%=request.getContextPath()%>/image/logo.png" alt="SmartWash" class="h-12 opacity-100 mb-1">
            <span class="text-xs font-bold text-blue-500 uppercase tracking-widest ml-2 mt-1">Admin</span>
        </div>
        
        <nav class="mt-6 flex flex-col gap-2 px-4" id="adminSidebar">
            <%
                // Đồng đội của bạn sẽ điều khiển biến này từ Controller
                String activeTab = (String) request.getAttribute("ACTIVE_TAB");
            %>

            <a href="<%=request.getContextPath()%>/AdminController?action=dashboard" data-tab="tongquan" 
               class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 <%= "tongquan".equals(activeTab) ? "bg-blue-600 text-white font-bold shadow-md shadow-blue-600/20" : "hover:bg-slate-800 hover:text-white" %>">
                <i class="fa-solid fa-chart-line w-5 text-lg"></i> 
                <span>Tổng Quan</span>
            </a>

            <a href="<%=request.getContextPath()%>/AdminController?action=manageBooking" data-tab="quanly_datlich" 
               class="sidebar-item flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 <%= "quanly_datlich".equals(activeTab) ? "bg-blue-600 text-white font-bold shadow-md shadow-blue-600/20" : "hover:bg-slate-800 hover:text-white" %>">
                <i class="fa-solid fa-calendar-check w-5 text-lg"></i> 
                <span>Quản Lý Đặt Lịch</span>
            </a>
        </nav>
    </div>

    <div class="px-4 mb-6 mt-auto">
        <a href="${pageContext.request.contextPath}/LogoutController" class="flex items-center gap-3 px-4 py-3.5 rounded-xl text-slate-400 hover:bg-red-500/10 hover:text-red-400 transition-colors border-t border-slate-800 mt-4">
            <i class="fa-solid fa-arrow-right-from-bracket w-5 text-lg"></i> <span>Đăng Xuất</span>
        </a>
    </div>
</aside>
