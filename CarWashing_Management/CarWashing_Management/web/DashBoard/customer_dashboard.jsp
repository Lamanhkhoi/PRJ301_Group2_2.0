<%-- 
    Document   : customer_dashboard.jsp
    Created on : May 29, 2026, 3:05:22 PM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Customer Dashboard - SmartWash</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        /* CSS tạo dải màu loang lổ nghệ thuật cho Header */
        .mesh-gradient-header {
            background-color: #0f172a;
            background-image: 
                radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), 
                radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), 
                radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
        }
    </style>
</head>
<body class="bg-[#F8FAFC] text-gray-800">

    <div class="flex h-screen overflow-hidden">
        <aside class="w-64 bg-[#1E293B] text-white flex flex-col justify-between">
            <div>
                <div class="h-20 flex items-center justify-center border-b border-slate-700">
                    <img src="<%=request.getContextPath()%>/image/logo-fpt.png" alt="SmartWash" class="h-10">
                </div>

                <nav class="mt-6 flex flex-col gap-1 px-3">
                    <%-- Dùng biến activeTab từ Controller truyền sang để đổi màu khối nền Emerald --%>
                    <a href="dashboard" class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${activeTab == 'tongquan' ? 'bg-emerald-500 text-white font-semibold' : 'text-slate-300 hover:bg-slate-700 hover:text-white'}">
                        <i class="fa-solid fa-chart-pie w-5"></i>
                        <span>Tổng Quan</span>
                    </a>
                    
                    <a href="booking" class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${activeTab == 'datlich' ? 'bg-emerald-500 text-white font-semibold' : 'text-slate-300 hover:bg-slate-700 hover:text-white'}">
                        <i class="fa-solid fa-calendar-check w-5"></i>
                        <span>Đặt Lịch</span>
                    </a>

                    <a href="customer_vehicles.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${activeTab == 'xecuatoi' ? 'bg-emerald-500 text-white font-semibold' : 'text-slate-300 hover:bg-slate-700 hover:text-white'}">
                        <i class="fa-solid fa-car w-5"></i>
                        <span>Xe Của Tôi</span>
                    </a>
                    
                    <a href="history" class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${activeTab == 'lichsu' ? 'bg-emerald-500 text-white font-semibold' : 'text-slate-300 hover:bg-slate-700 hover:text-white'}">
                        <i class="fa-solid fa-clock-rotate-left w-5"></i>
                        <span>Lịch Sử</span>
                    </a>
                </nav>
            </div>

            <div class="px-3 mb-6">
                <div class="border-t border-slate-700 pt-4 flex flex-col gap-1">
                    <a href="profile" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-slate-700 transition-colors">
                        <i class="fa-solid fa-user-gear w-5"></i>
                        <span>Hồ Sơ</span>
                    </a>
                    <a href="logout" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-red-500/20 hover:text-red-400 transition-colors">
                        <i class="fa-solid fa-arrow-right-from-bracket w-5"></i>
                        <span>Đăng Xuất</span>
                    </a>
                </div>
            </div>
        </aside>

        <main class="flex-1 flex flex-col overflow-hidden">
            
            <header class="h-20 mesh-gradient-header flex items-center justify-between px-8 shadow-md z-10">
                <div class="flex items-center">
                    <h2 class="text-xl font-bold text-white drop-shadow-md tracking-wide">
                        Chào mừng, <span class="text-emerald-300">Nguyễn Văn A</span> 👋
                    </h2>
                </div>

                <div class="flex items-center gap-6">
                    <div class="flex items-center bg-white/10 backdrop-blur-md border border-white/20 rounded-full px-4 py-2 w-72 focus-within:bg-white/20 focus-within:border-white/40 transition-all">
                        <i class="fa-solid fa-magnifying-glass text-white/70"></i>
                        <input type="text" placeholder="Tìm biển số xe..." class="bg-transparent border-none outline-none text-white placeholder-white/60 ml-3 w-full text-sm">
                        <button class="text-white/70 hover:text-white transition cursor-pointer ml-2">
                            <i class="fa-solid fa-filter"></i>
                        </button>
                    </div>

                    <button class="relative text-white/80 hover:text-white transition">
                        <i class="fa-regular fa-bell text-xl"></i>
                        <span class="absolute -top-1 -right-1 bg-red-500 rounded-full w-3 h-3 border-2 border-slate-900"></span>
                    </button>
                    <div class="w-10 h-10 rounded-full bg-emerald-500 flex items-center justify-center font-bold text-white border-2 border-white/20 shadow-sm cursor-pointer">
                        A
                    </div>
                </div>
            </header>

            <div class="flex-1 overflow-y-auto p-8">
                
                <div class="grid grid-cols-4 gap-6 mb-6">
                    <div class="bg-gradient-to-br from-yellow-50 to-amber-100 p-6 rounded-2xl shadow-sm border border-yellow-200 flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-yellow-700">Hạng hiện tại</p>
                            <h3 class="text-2xl font-bold text-yellow-900 mt-1">Khách Hàng Gold</h3>
                        </div>
                        <i class="fa-solid fa-crown text-3xl text-yellow-500 drop-shadow-sm"></i>
                    </div>
                    
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-slate-500">Điểm Tích Lũy</p>
                            <h3 class="text-2xl font-bold text-slate-800 mt-1">2,000 PTS</h3>
                        </div>
                        <div class="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500 text-xl"><i class="fa-solid fa-star"></i></div>
                    </div>

                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-slate-500">Tổng Số Lần Rửa</p>
                            <h3 class="text-2xl font-bold text-slate-800 mt-1">15 Lần</h3>
                        </div>
                        <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center text-blue-500 text-xl"><i class="fa-solid fa-droplet"></i></div>
                    </div>

                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                        <div>
                            <p class="text-sm font-medium text-slate-500">Ưu Đãi Hiện Có</p>
                            <h3 class="text-2xl font-bold text-slate-800 mt-1">0</h3>
                        </div>
                        <div class="w-12 h-12 rounded-full bg-purple-50 flex items-center justify-center text-purple-500 text-xl"><i class="fa-solid fa-ticket"></i></div>
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-6">
                    
                    <div class="col-span-1 bg-white rounded-2xl shadow-sm border border-slate-100 p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-lg font-bold text-slate-800">Xe Của Tôi</h3>
                            <button class="text-sm text-emerald-500 font-medium hover:underline">Xem tất cả</button>
                        </div>
                        
                        <div class="grid grid-cols-2 gap-4 items-center bg-slate-50 rounded-xl p-4 border border-slate-100">
                            <div class="flex justify-center">
                                <img src="https://cdn-icons-png.flaticon.com/512/3204/3204005.png" alt="Car" class="w-24 drop-shadow-md opacity-80">
                            </div>
                            <div>
                                <p class="font-mono text-xl font-bold text-slate-800 bg-white border-2 border-slate-300 px-2 py-1 rounded inline-block shadow-sm">51H-123.45</p>
                                <p class="text-sm text-slate-600 mt-2 font-medium">VinFast VF8</p>
                                <p class="text-xs text-slate-500 mt-1 flex items-center gap-1"><span class="w-3 h-3 rounded-full bg-blue-600 inline-block"></span> Xanh Dương</p>
                            </div>
                        </div>
                    </div>

                    <div class="col-span-2 flex flex-col gap-6">
                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex-1">
                            <h3 class="text-lg font-bold text-slate-800 mb-4">Tiến trình lên hạng Diamond</h3>
                            <div class="w-full bg-slate-100 rounded-full h-3 mb-2 overflow-hidden">
                                <div class="bg-gradient-to-r from-emerald-400 to-teal-500 h-3 rounded-full" style="width: 70%"></div>
                            </div>
                            <p class="text-sm text-slate-500">Cần thêm <span class="font-bold text-emerald-600">500 PTS</span> nữa để thăng hạng.</p>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex-1">
                            <h3 class="text-lg font-bold text-slate-800 mb-4">Lịch hẹn sắp tới</h3>
                            <div class="flex items-center justify-between border-l-4 border-emerald-500 bg-emerald-50/50 p-4 rounded-r-lg">
                                <div>
                                    <p class="font-bold text-slate-800">Rửa xe tự động - Gói Siêu Tốc</p>
                                    <p class="text-sm text-slate-500 mt-1"><i class="fa-regular fa-clock mr-1"></i> Hôm nay, 15:30 PM - Xe: 51H-123.45</p>
                                </div>
                                <span class="px-3 py-1 bg-emerald-100 text-emerald-700 text-sm font-semibold rounded-full">Đã xác nhận</span>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>
    </div>

</body>
</html>
