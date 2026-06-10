<%-- 
    Document   : admin_dashboard.jsp
    Created on : Jun 10, 2026, 12:53:28 PM
    Author     : Admin
--%>

<%@ include file="../includes/auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Trị Hệ Thống - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; background-color: #F1F5F9; }</style>
    </head>
    <body class="text-slate-800 relative">

        <div class="flex h-screen overflow-hidden relative">
            
            <% request.setAttribute("ACTIVE_TAB", "tongquan"); // Bạn nam/nữ làm phần này nhớ tự đổi tên tab nhé %>
            <jsp:include page="/includes/sidebar_admin.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-7xl mx-auto">
                        
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-8 text-center min-h-[400px] flex flex-col items-center justify-center border-dashed border-2">
                            <i class="fa-solid fa-code text-4xl text-slate-300 mb-4"></i>
                            <h2 class="text-xl font-bold text-slate-700">Khu vực code của tính năng</h2>
                            <p class="text-slate-500 mt-2">Đồng đội vui lòng xóa khối div này và thay bằng HTML/JSP thật của mình (Bảng dữ liệu, Biểu đồ thống kê...).</p>
                        </div>
                        
                        </div>
                </div>
            </main>
        </div>
    </body>
</html>
