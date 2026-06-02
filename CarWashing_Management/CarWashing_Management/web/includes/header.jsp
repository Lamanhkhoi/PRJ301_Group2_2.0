<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (request.getAttribute("javax.servlet.include.request_uri") == null) {
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }
%>

<nav class="navbar sticky-navbar">
    <div class="logo">
        <span class="logo-text">SMARTWASH</span>
    </div>

    <ul class="nav-links">
        <li>
            <a href="MainController?action=home" class="nav-pill ${activeTab == 'trangchu' ? 'active' : ''}">Trang chủ</a>
        </li>
        <li>
            <a href="MainController?action=services" class="nav-pill ${activeTab == 'dichvu' ? 'active' : ''}">Dịch vụ</a>
        </li>
        <li>
            <a href="MainController?action=promos" class="nav-pill ${activeTab == 'uudai' ? 'active' : ''}">Ưu đãi</a>
        </li>
    </ul>

    <div class="user-dropdown">
        <%
            Object currentUser = session.getAttribute("LOGIN_USER");
            if (currentUser != null) { 
        %>
            <div class="user-trigger">
                <span class="user-name">Khách hàng VIP</span>
                <div class="avatar"></div>
            </div>
            
            <div class="dropdown-menu">
                <a href="MainController?action=profile">Hồ sơ</a>
                <a href="MainController?action=logout">Đăng xuất</a>
            </div>

        <%  } else { %>
            <div onclick="openAuthModal('login')" class="flex items-center gap-2 cursor-pointer bg-gray-100 px-4 py-2 rounded-full hover:bg-gray-200 transition">
                <span class="user-name text-sm font-semibold">Đăng Nhập</span>
            </div>
            
        <%  } %>
    </div>
</nav>

<jsp:include page="/login_page/main_modal.jsp" />