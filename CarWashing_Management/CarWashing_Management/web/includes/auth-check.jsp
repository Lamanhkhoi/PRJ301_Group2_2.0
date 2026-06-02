<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. BẪY BẢO MẬT: Nếu cố tình gõ trực tiếp file này trên thanh URL của trình duyệt
    if (request.getRequestURI().contains("auth-check.jsp")) {
        request.getSession().invalidate(); // Hủy toàn bộ phiên đăng nhập (Logout)
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }

    // 2. KIỂM TRA QUYỀN ĐĂNG NHẬP (Dùng cho trang Dashboard gọi)
    Account userAcc = (Account) session.getAttribute("USER");
    Customer cus = (Customer) session.getAttribute("CUSTOMER");
    
    if (userAcc == null || cus == null) {
        // Chưa đăng nhập mà đòi vào Dashboard -> Đá về trang chủ (Không cần invalidate vì vốn đã có session đâu)
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return; 
    }
%>