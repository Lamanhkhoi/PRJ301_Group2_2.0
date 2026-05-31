<%-- 
    Document   : customer_profile.jsp
    Created on : May 31, 2026, 10:20:20 PM
    Author     : Admin
--%>

<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông Tin Cá Nhân - SmartWash</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .mesh-gradient-header {
            background-color: #0f172a;
            background-image: radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
        }
        /* Ẩn input type="file" mặc định */
        input[type="file"] { display: none; }
    </style>
</head>
<body class="bg-[#F8FAFC] text-gray-800">

    <div class="flex h-screen overflow-hidden relative">
        
        <% request.setAttribute("activeTab", "thongtincanhan"); %>
        <jsp:include page="/includes/sidebar_DashBoard.jsp" />

        <main class="flex-1 flex flex-col overflow-hidden relative">
            
            <jsp:include page="/includes/topbar.jsp"/>

            <div class="flex-1 overflow-y-auto p-8">
                
                <%
                    // BỘ BIẾN MOCKUP - SAU NÀY BACKEND SẼ GÁN DỮ LIỆU THẬT TỪ DB VÀO ĐÂY
                    String username = "khoila29";
                    String email = "lamanhkhoi@example.com";
                    String fullName = "Lâm Anh Khôi";
                    String phone = "0901234567";
                    String dob = "2006-03-29"; // Chuẩn format yyyy-mm-dd cho thẻ input type="date"
                    String gender = "Nam"; 
                    String address = "Thành phố Hồ Chí Minh";
                    String avatarUrl = "https://ui-avatars.com/api/?name=K&background=10b981&color=fff&size=128"; 
                %>

                <div class="max-w-5xl mx-auto space-y-6">
                    
                    <div class="flex justify-between items-center mb-2">
                        <div>
                            <h2 class="text-2xl font-bold text-slate-800">Quản lý hồ sơ</h2>
                            <p class="text-sm text-slate-500 mt-1">Cập nhật thông tin cá nhân và cài đặt bảo mật của bạn.</p>
                        </div>
                    </div>

                    <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
                        <form action="updateProfile" method="POST" enctype="multipart/form-data" class="p-8">
                            <div class="flex flex-col md:flex-row gap-10">
                                
                                <div class="flex flex-col items-center gap-4">
                                    <div class="relative group">
                                        <div class="w-32 h-32 rounded-full border-4 border-slate-50 shadow-md overflow-hidden bg-slate-100">
                                            <img src="<%= avatarUrl %>" alt="Avatar" id="avatarPreview" class="w-full h-full object-cover">
                                        </div>
                                        <label for="avatarUpload" class="absolute inset-0 bg-black/50 rounded-full flex flex-col items-center justify-center text-white opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer backdrop-blur-sm">
                                            <i class="fa-solid fa-camera text-xl mb-1"></i>
                                            <span class="text-xs font-medium">Thay ảnh</span>
                                        </label>
                                        <input type="file" id="avatarUpload" name="avatarFile" accept="image/*" onchange="previewImage(event)">
                                    </div>
                                    <p class="text-xs text-slate-400 text-center w-32">Định dạng JPEG, PNG.<br>Dung lượng tối đa 2MB.</p>
                                </div>

                                <div class="flex-1 grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Tên đăng nhập (Username)</label>
                                        <input type="text" name="username" value="<%= username %>" readonly class="w-full px-4 py-2.5 rounded-xl bg-slate-100 border border-slate-200 text-slate-500 cursor-not-allowed outline-none">
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Họ và Tên</label>
                                        <input type="text" name="fullName" value="<%= fullName %>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Email</label>
                                        <input type="email" name="email" value="<%= email %>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Số điện thoại</label>
                                        <input type="tel" name="phoneNumber" value="<%= phone %>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Ngày sinh</label>
                                        <input type="date" name="dateOfBirth" value="<%= dob %>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition text-slate-700">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Giới tính</label>
                                        <select name="gender" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition cursor-pointer text-slate-700">
                                            <option value="Nam" <%= gender.equals("Nam") ? "selected" : "" %>>Nam</option>
                                            <option value="Nữ" <%= gender.equals("Nữ") ? "selected" : "" %>>Nữ</option>
                                            <option value="Khác" <%= gender.equals("Khác") ? "selected" : "" %>>Khác</option>
                                        </select>
                                    </div>

                                    <div class="md:col-span-2">
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Địa chỉ (Address)</label>
                                        <input type="text" name="address" value="<%= address %>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-8 flex justify-end gap-3 pt-6 border-t border-slate-100">
                                <button type="reset" class="px-6 py-2.5 rounded-xl font-medium text-slate-600 hover:bg-slate-100 transition">Khôi phục</button>
                                <button type="submit" class="px-6 py-2.5 rounded-xl font-bold bg-[#464BE5] text-white hover:bg-blue-700 transition shadow-md shadow-blue-500/30">Lưu Thay Đổi</button>
                            </div>
                        </form>
                    </div>

                    <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
                        <div class="px-8 py-5 border-b border-slate-100">
                            <h3 class="text-lg font-bold text-slate-800"><i class="fa-solid fa-shield-halved text-emerald-500 mr-2"></i>Bảo mật tài khoản</h3>
                        </div>
                        <form action="changePassword" method="POST" class="p-8">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl">
                                <div>
                                    <label class="block text-sm font-medium text-slate-600 mb-1">Mật khẩu hiện tại</label>
                                    <input type="password" name="oldPassword" placeholder="••••••••" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                </div>
                                <div class="hidden md:block"></div> <div>
                                    <label class="block text-sm font-medium text-slate-600 mb-1">Mật khẩu mới</label>
                                    <input type="password" name="newPassword" placeholder="Nhập mật khẩu mới" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                </div>
                                
                                <div>
                                    <label class="block text-sm font-medium text-slate-600 mb-1">Xác nhận mật khẩu mới</label>
                                    <input type="password" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                </div>
                            </div>
                            
                            <div class="mt-6">
                                <button type="submit" class="px-6 py-2.5 rounded-xl font-bold bg-slate-800 text-white hover:bg-slate-900 transition shadow-md">Cập nhật mật khẩu</button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </main>
    </div>

    <script>
        function previewImage(event) {
            const reader = new FileReader();
            reader.onload = function() {
                const output = document.getElementById('avatarPreview');
                output.src = reader.result;
            };
            if(event.target.files[0]) {
                reader.readAsDataURL(event.target.files[0]);
            }
        }
    </script>
</body>
</html>
