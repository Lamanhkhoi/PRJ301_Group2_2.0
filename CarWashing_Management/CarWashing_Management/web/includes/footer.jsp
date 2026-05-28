<%-- 
    Document   : footer.jsp
    Created on : May 28, 2026, 3:13:03 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<footer class="bg-[#1F2937] border-t border-gray-700 py-8">
    <div class="max-w-6xl mx-auto px-10 flex flex-col md:flex-row justify-between items-center gap-6">
        
        <div class="flex-shrink-0">
            <img src="<%=request.getContextPath()%>/image/Logo_Trường_Đại_học_FPT.svg.png" alt="Logo FPT" class="h-20 w-auto object-contain drop-shadow-md">
        </div>

        <div class="text-center md:text-right">
            <h4 class="text-white font-medium text-lg mb-2">Thông tin</h4>
            
            <div class="text-[#9CA3AF] text-sm flex flex-wrap justify-center md:justify-end items-center gap-2 md:gap-3">
                <span class="hover:text-white transition cursor-default">Lâm Anh Khôi</span>
                <span class="text-gray-600 hidden md:inline">•</span>
                <span class="hover:text-white transition cursor-default">Mai Khương Duy</span>
                <span class="text-gray-600 hidden md:inline">•</span>
                <span class="hover:text-white transition cursor-default">Lê Nguyễn Minh Thắng</span>
                <span class="text-gray-600 hidden md:inline">•</span>
                <span class="hover:text-white transition cursor-default">Dương Vĩ Lâm</span>
            </div>
            
            <p class="text-xs text-gray-500 mt-4">
                © 2026 SmartWash Project. Được phát triển cho mục đích đồ án môn học.
            </p>
        </div>
        
    </div>
</footer>
