<%-- 
    Document   : login_view.jsp
    Created on : May 29, 2026, 12:29:08 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<div class="p-10">
    <div class="text-center mb-8">
        <div class="w-16 h-16 bg-[#F4F7F6] rounded-2xl mx-auto mb-4 flex items-center justify-center border-2 border-[#464BE5]">
            <span class="font-heading text-[#464BE5] font-bold">SW</span>
        </div>
        <h2 class="text-2xl font-bold text-[#111827]">Đăng Nhập Tài Khoản</h2>
    </div>

    <div id="loginErrorMsg" class="hidden bg-red-100 text-red-600 text-sm text-center py-2 rounded-lg mb-4 font-medium">
    </div>

    <form action="login" method="POST" class="space-y-4">
        <div>
            <input type="text" name="username" placeholder="Tên Người Dùng/Email" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] border-transparent focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
        </div>
        <div>
            <input type="password" name="password" placeholder="Mật Khẩu" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] border-transparent focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
        </div>

        <button type="submit" name="action" value="login" class="w-full py-3 bg-[#111827] text-white font-bold rounded-xl hover:bg-gray-800 transition mt-2">
            Đăng Nhập
        </button>
    </form>

    <div class="flex justify-between items-center mt-6 text-sm">
        <a href="#" class="text-[#9CA3AF] hover:text-[#464BE5] transition">Gặp Khó Khăn?</a>
        <button onclick="toggleAuthView('register')" class="text-[#464BE5] font-semibold hover:underline">Đăng Ký Ngay</button>
    </div>

    <div class="mt-8">
        <div class="relative flex items-center justify-center mb-6">
            <div class="border-t border-gray-200 w-full"></div>
            <span class="bg-white px-3 text-xs text-[#9CA3AF] absolute">Đăng nhập bằng phương thức khác</span>
        </div>
        <div class="flex justify-center gap-4">
            <button title="Coming soon" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 hover:bg-gray-200 cursor-not-allowed transition">G</button>
            <button title="Coming soon" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 hover:bg-gray-200 cursor-not-allowed transition">f</button>
            <button title="Coming soon" class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 hover:bg-gray-200 cursor-not-allowed transition">X</button>
        </div>
    </div>
</div>
