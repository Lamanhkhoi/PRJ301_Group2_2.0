<%@page import="dto.Admin"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. BẪY BẢO MẬT: Nếu cố tình gõ trực tiếp file này trên thanh URL của trình duyệt
    if (request.getRequestURI().contains("admin-auth-check.jsp")) {
        request.getSession().invalidate(); // Hủy toàn bộ phiên đăng nhập (Logout)
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }

    // 2. KIỂM TRA QUYỀN ĐĂNG NHẬP (Dùng cho trang Dashboard gọi)
    Account userAcc = (Account) session.getAttribute("USER");
    Admin admin = (Admin) session.getAttribute("ADMIN");
    
    if (userAcc == null || admin == null) {
        // Chưa đăng nhập mà đòi vào Dashboard -> Đá về trang chủ (Không cần invalidate vì vốn đã có session đâu)
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return; 
    }
%>
