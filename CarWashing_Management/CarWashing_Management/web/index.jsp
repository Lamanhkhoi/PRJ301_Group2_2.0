<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Thực hiện redirect ngược lại MainController kèm theo tham số hành động cụ thể
    response.sendRedirect("MainController?action=home");
%>