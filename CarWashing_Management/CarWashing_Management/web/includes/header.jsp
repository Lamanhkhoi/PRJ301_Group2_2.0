<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
        <div class="user-trigger">
            <span class="user-name">Tên khách hàng</span>
            <div class="avatar"></div>
        </div>
        <div class="dropdown-menu">
            <a href="profile">Hồ sơ</a>
            <a href="logout">Đăng xuất</a>
        </div>
    </div>
</nav>