<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (request.getAttribute("javax.servlet.include.request_uri") == null) {
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/MainController?action=home");
        return;
    }
%>

<div class="p-10">
    <div class="text-center mb-8">
        <h2 class="text-2xl font-bold text-[#111827]">Tạo Tài Khoản Mới</h2>
        <p class="text-[#9CA3AF] text-sm mt-2">Trở thành Member để nhận ưu đãi</p>
    </div>

    <div id="registerErrorMsg" class="hidden bg-red-100 text-red-600 text-sm text-center py-2 rounded-lg mb-4 font-medium">
    </div>

    <form action="MainController" method="POST" class="space-y-4">
        <input type="text" name="reg_fullname" placeholder="Họ và Tên" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none" required>
        <input type="email" name="reg_email" placeholder="Ví dụ: nva@gmail.com" pattern="^[a-zA-Z0-9._%+-]+@gmail\.com$" title="Vui lòng nhập đúng định dạng Gmail (ví dụ: bando@gmail.com)" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none" required>
        <input type="tel" name="reg_phoneNumber" placeholder="Nhập số điện thoại" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none" required>
        <input type="password" name="reg_password" placeholder="Mật Khẩu" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none" required>
        <input type="password" name="reg_RE_password" placeholder="Nhập lại mật Khẩu" class="w-full px-5 py-3 rounded-xl bg-[#F4F7F6] focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none" required>

        <div class="space-y-3 mt-4 mb-6 text-sm text-[#9CA3AF] text-left">
            <label class="flex items-start gap-3 cursor-pointer group">
                <input type="checkbox" name="agree_terms" required class="mt-0.5 w-4 h-4 rounded-full border-gray-300 text-[#464BE5] focus:ring-[#464BE5] cursor-pointer accent-[#464BE5]">
                <span class="leading-tight">Tôi đã đọc và đồng ý <a href="#" class="text-[#464BE5] hover:underline">Điều Khoản Dịch Vụ</a> & <a href="#" class="text-[#464BE5] hover:underline">Chính Sách Về Quyền Riêng Tư</a></span>
            </label>

            <label class="flex items-start gap-3 cursor-pointer group">
                <input type="checkbox" name="receive_promos" required class="mt-0.5 w-4 h-4 rounded-full border-gray-300 text-[#464BE5] focus:ring-[#464BE5] cursor-pointer accent-[#464BE5]">
                <span class="leading-tight">Tôi muốn nhận thông tin về các chương trình khuyến mãi và ưu đãi thành viên.</span>
            </label>

            <label class="flex items-start gap-3 cursor-pointer group">
                <input type="checkbox" name="love_teacher" value="10_diem" required class="mt-0.5 w-4 h-4 rounded-full border-gray-300 text-[#464BE5] focus:ring-[#464BE5] cursor-pointer accent-[#464BE5]">
                <span class="leading-tight text-[#111827] font-medium">Em yêu cô!!! Cô cho em 10 điểm nha</span>
            </label>
        </div>

        <button type="submit" name="action" value="register" class="w-full py-3 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition mt-2">
            Hoàn Tất Đăng Ký
        </button>
    </form>

    <div class="text-center mt-6 text-sm">
        <span class="text-[#9CA3AF]">Đã có tài khoản?</span>
        <button onclick="toggleAuthView('login')" class="text-[#464BE5] font-semibold hover:underline ml-1">Đăng Nhập</button>
    </div>
</div>