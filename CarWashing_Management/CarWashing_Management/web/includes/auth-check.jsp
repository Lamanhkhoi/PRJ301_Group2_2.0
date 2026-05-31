<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Kiểm tra Session đăng nhập bảo vệ hệ thống
    Account userAcc = (Account) session.getAttribute("USER");
    Customer cus = (Customer) session.getAttribute("CUSTOMER");
    
    if (userAcc == null || cus == null) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return; // Dừng việc render các HTML phía dưới lại
    }
%>
