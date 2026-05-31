<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String fullName = "Khách Vãng Lai"; 
    String avatarChar = "K";
    String roleDisplay = "Thành viên";
    String roleColorClass = "text-emerald-300";

    try {
        Customer cus = (Customer) session.getAttribute("CUSTOMER");
        Account acc = (Account) session.getAttribute("USER"); 
        
        if (cus != null) {
            fullName = "Ly Xuan Khoa"; // Mock UI
        }
        
        if (acc != null) {
            if ("Admin".equalsIgnoreCase(acc.getRole())) {
                roleDisplay = "Quản trị viên";
                roleColorClass = "text-red-400 font-bold";
            } else {
                roleDisplay = "Thành viên"; 
            }
        }
        
        if (!fullName.trim().isEmpty()) {
            String[] nameParts = fullName.trim().split(" ");
            avatarChar = nameParts[nameParts.length - 1].substring(0, 1).toUpperCase();
        }
    } catch(Exception e) {}

    String pageTitle = request.getParameter("title");
    if (pageTitle == null || pageTitle.trim().isEmpty()) {
        pageTitle = "SmartWash Dashboard";
    }
%>

<header class="h-20 bg-gradient-to-r from-[#1E293B] via-[#1E293B] to-[#2e1065] flex items-center justify-between px-8 shadow-md z-10 relative">
    
    <div class="flex items-center">
        <h2 class="text-xl font-bold text-white drop-shadow-md tracking-wide"><%= pageTitle %></h2>
    </div>

    <div class="flex items-center gap-6 relative">
        <button class="relative text-white/80 hover:text-white transition">
            <i class="fa-regular fa-bell text-xl"></i>
            <span class="absolute -top-1 -right-1 bg-red-500 rounded-full w-3 h-3 border-2 border-[#2e1065]"></span>
        </button>
        
        <div class="flex items-center gap-3 cursor-pointer hover:opacity-80 transition group">
            <div class="text-right hidden md:block">
                <p class="text-sm font-bold text-white leading-tight"><%= fullName %></p>
                <p class="text-xs <%= roleColorClass %> font-medium"><%= roleDisplay %></p>
            </div>
            <div class="w-10 h-10 rounded-full <%= "Admin".equals(roleDisplay) ? "bg-red-500" : "bg-emerald-500" %> flex items-center justify-center font-bold text-white border-2 border-white/20 shadow-sm group-hover:scale-105 transition-transform">
                <%= avatarChar %>
            </div>
        </div>
    </div>
</header>