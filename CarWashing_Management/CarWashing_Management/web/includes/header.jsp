<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- <%@page import="dto.CustomerDTO"%> --%>

<nav class="navbar sticky-navbar">
    <div class="logo">
        <span class="logo-text">SMARTWASH</span>
    </div>

    <ul class="nav-links">
        <li>
            <a href="home" class="nav-pill ${activeTab == 'trangchu' ? 'active' : ''}">Trang chủ</a>
        </li>
        <li>
            <a href="services" class="nav-pill ${activeTab == 'dichvu' ? 'active' : ''}">Dịch vụ</a>
        </li>
        <li>
            <a href="promos" class="nav-pill ${activeTab == 'uudai' ? 'active' : ''}">Ưu đãi</a>
        </li>
    </ul>

    <div class="user-dropdown">
        <%
            // Lấy thông tin user từ Session. 
            // Lưu ý Backend: Đổi chữ "LOGIN_USER" thành đúng key mà Controller đang dùng để lưu Session.
            Object currentUser = session.getAttribute("LOGIN_USER");
            
            if (currentUser != null) { 
                // ==========================================
                // TRẠNG THÁI 1: KHÁCH HÀNG ĐÃ ĐĂNG NHẬP
                // ==========================================
        %>
            <div class="user-trigger">
                <span class="user-name">Khách hàng VIP</span>
                <div class="avatar"></div>
            </div>
            
            <div class="dropdown-menu">
                <a href="profile">Hồ sơ</a>
                <a href="logout">Đăng xuất</a>
            </div>

        <%  } else { 
                // ==========================================
                // TRẠNG THÁI 2: KHÁCH HÀNG CHƯA ĐĂNG NHẬP
                // ==========================================
        %>
            <div onclick="openAuthModal()" class="flex items-center gap-2 cursor-pointer bg-gray-100 px-4 py-2 rounded-full hover:bg-gray-200 transition">
                <div class="avatar"></div>
                <span class="user-name text-sm font-semibold">Đăng Nhập</span>
            </div>
            
        <%  } %>
    </div>
</nav>

<jsp:include page="/login_page/main_modal.jsp" />