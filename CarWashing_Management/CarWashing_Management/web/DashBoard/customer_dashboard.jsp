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
            .mesh-gradient-header {
                background-color: #0f172a;
                background-image:
                    radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%),
                    radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%),
                    radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            }
            .scrollbar-hide::-webkit-scrollbar { display: none; }
            .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">
            
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

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
                        <div class="w-10 h-10 rounded-full bg-emerald-500 flex items-center justify-center font-bold text-white border-2 border-white/20 shadow-sm cursor-pointer">A</div>
                    </div>
                </header>

                <div class="flex-1 overflow-y-auto p-8">

                    <%
                        // ==========================================================
                        // TRUNG TÂM ĐIỀU KHIỂN LOGIC (Mock Data từ Backend)
                        // ==========================================================
                        String currentRank = "Gold"; 
                        
                        Integer points = 0; 
                        Integer yearlyWashes = 0; 
                        Integer currentSpent = 0; 

                        boolean hasVehicle = false; 
                        String priorityPlate = "51H-123.45";
                        String priorityBrand = "VinFast VF8";
                        String priorityColor = "Xanh Dương";

                        boolean hasAppointments = false; 

                        // LOGIC ĐỔI MÀU THẺ & NỘI DUNG ĐẶC QUYỀN
                        String bgClass = "bg-white border-slate-100";
                        String textClass = "text-slate-800";
                        String labelClass = "text-slate-500";
                        String iconColor = "text-slate-400";
                        String iconClass = "fa-user";
                        String currentBenefits = ""; // Biến chứa đặc quyền tiếng Việt

                        if (currentRank.equalsIgnoreCase("Member") || currentRank.equalsIgnoreCase("Thành viên")) {
                            currentBenefits = "1 điểm thưởng = 1.000 VNĐ chi tiêu";
                        } else if (currentRank.equalsIgnoreCase("Silver") || currentRank.equalsIgnoreCase("Bạc")) {
                            bgClass = "bg-gradient-to-br from-slate-100 to-gray-200 border-gray-300";
                            textClass = "text-gray-900";
                            labelClass = "text-gray-600";
                            iconColor = "text-gray-500";
                            iconClass = "fa-shield-halved";
                            currentBenefits = "Thưởng 10% điểm số • Có slot ưu tiên";
                        } else if (currentRank.equalsIgnoreCase("Gold") || currentRank.equalsIgnoreCase("Vàng")) {
                            bgClass = "bg-gradient-to-br from-yellow-50 to-amber-100 border-yellow-200";
                            textClass = "text-yellow-900";
                            labelClass = "text-yellow-700";
                            iconColor = "text-yellow-500";
                            iconClass = "fa-crown";
                            currentBenefits = "Thưởng 20% điểm số • Miễn phí nâng cấp/tháng";
                        } else if (currentRank.equalsIgnoreCase("Platinum") || currentRank.equalsIgnoreCase("Bạch Kim")) {
                            bgClass = "bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 border-purple-200";
                            textClass = "text-purple-900";
                            labelClass = "text-purple-700";
                            iconColor = "text-purple-500";
                            iconClass = "fa-gem";
                            currentBenefits = "Thưởng 30% điểm số • 1 lần rửa miễn phí/tháng";
                        }

                        // LOGIC TÍNH TOÁN 2 VÒNG TRÒN THĂNG HẠNG
                        String targetRank = "";
                        int targetWashes = 1;
                        int targetSpent = 1;

                        if (currentRank.equalsIgnoreCase("Member") || currentRank.equalsIgnoreCase("Thành viên")) {
                            targetRank = "Bạc (Silver)";
                            targetWashes = 5;
                            targetSpent = 2000000;
                        } else if (currentRank.equalsIgnoreCase("Silver") || currentRank.equalsIgnoreCase("Bạc")) {
                            targetRank = "Vàng (Gold)";
                            targetWashes = 15;
                            targetSpent = 6000000;
                        } else if (currentRank.equalsIgnoreCase("Gold") || currentRank.equalsIgnoreCase("Vàng")) {
                            targetRank = "Bạch Kim (Platinum)";
                            targetWashes = 30;
                            targetSpent = 15000000;
                        } else {
                            targetRank = "MAX"; 
                        }

                        int washPercent = 100;
                        int spentPercent = 100;
                        if (!targetRank.equals("MAX")) {
                            washPercent = (int) Math.min(100, ((double) yearlyWashes / targetWashes) * 100);
                            spentPercent = (int) Math.min(100, ((double) currentSpent / targetSpent) * 100);
                        }

                        int c = 226; 
                        int washOffset = c - (c * washPercent) / 100;
                        int spentOffset = c - (c * spentPercent) / 100;
                    %>

                    <div class="grid grid-cols-4 gap-6 mb-6">
                        <div class="<%= bgClass%> p-6 rounded-2xl shadow-sm border flex items-center justify-between transition-all duration-300">
                            <div>
                                <p class="text-sm font-medium <%= labelClass%>">Hạng hiện tại</p>
                                <h3 class="text-2xl font-bold <%= textClass%> mt-1"><%= currentRank%></h3>
                            </div>
                            <i class="fa-solid <%= iconClass%> text-3xl <%= iconColor%> drop-shadow-sm"></i>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-slate-500">Điểm Tích Lũy</p>
                                <h3 class="text-2xl font-bold text-slate-800 mt-1"><%= points%> PTS</h3>
                            </div>
                            <div class="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500 text-xl"><i class="fa-solid fa-star"></i></div>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-slate-500">Tổng Lần Rửa Trong Năm</p>
                                <h3 class="text-2xl font-bold text-slate-800 mt-1"><%= yearlyWashes%> Lần</h3>
                            </div>
                            <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center text-blue-500 text-xl"><i class="fa-solid fa-droplet"></i></div>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col justify-center relative group transition-all hover:shadow-md hover:border-emerald-200">
                            <div class="flex justify-between items-start mb-2">
                                <p class="text-sm font-medium text-slate-500">Đặc quyền hạng <%= currentRank %></p>
                                <button onclick="openTierInfoModal()" class="text-slate-300 hover:text-[#464BE5] transition" title="Xem chi tiết hệ thống hạng">
                                    <i class="fa-solid fa-circle-exclamation text-lg"></i>
                                </button>
                            </div>
                            <div class="w-full overflow-hidden">
                                <p class="font-bold text-[#464BE5] text-[15px] leading-tight truncate"><i class="fa-solid fa-gift mr-1"></i> <%= currentBenefits %></p>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                        <div class="col-span-1 bg-white rounded-2xl shadow-sm border border-slate-100 p-6 flex flex-col">
                            <div class="flex justify-between items-center mb-4">
                                <h3 class="text-lg font-bold text-slate-800">Danh sách xe của tôi</h3>
                                <a href="customer_vehicles.jsp" class="text-sm text-emerald-500 font-medium hover:underline">Xem tất cả</a>
                            </div>
                            <div class="flex-1 flex flex-col justify-center">
                                <% if (hasVehicle) { %>
                                    <div class="relative bg-slate-50 rounded-xl p-5 border border-slate-100 overflow-hidden">
                                        <div class="absolute top-0 right-0 bg-yellow-400 text-yellow-900 text-[10px] font-bold px-2 py-1 rounded-bl-lg"><i class="fa-solid fa-star"></i> Đang ưu tiên</div>
                                        <div class="flex flex-col items-center text-center">
                                            <img src="https://cdn-icons-png.flaticon.com/512/3204/3204005.png" alt="Car" class="w-28 drop-shadow-md opacity-90 mb-3">
                                            <p class="font-mono text-2xl font-bold text-slate-800 bg-white border-2 border-slate-300 px-3 py-1 rounded shadow-sm"><%= priorityPlate %></p>
                                            <p class="text-slate-600 mt-2 font-semibold"><%= priorityBrand %></p>
                                            <p class="text-sm text-slate-500 mt-1 flex items-center justify-center gap-1"><span class="w-3 h-3 rounded-full bg-blue-600 border border-slate-200"></span> <%= priorityColor %></p>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <div class="bg-slate-50 border-2 border-dashed border-slate-200 rounded-xl p-8 flex flex-col items-center justify-center text-center h-full">
                                        <div class="w-16 h-16 bg-slate-200 rounded-full flex items-center justify-center text-slate-400 mb-3 text-3xl"><i class="fa-solid fa-car-side"></i></div>
                                        <p class="text-slate-500 font-medium mb-4">Bạn chưa có xe hiện tại.</p>
                                        <a href="customer_vehicles.jsp" class="bg-emerald-100 text-emerald-700 font-semibold px-4 py-2 rounded-lg hover:bg-emerald-200 transition"><i class="fa-solid fa-plus mr-1"></i> Thêm xe ngay</a>
                                    </div>
                                <% } %>
                            </div>
                        </div>

                        <div class="col-span-2 flex flex-col gap-6">
                            
                            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                                <div class="flex justify-between items-end mb-6">
                                    <div>
                                        <h3 class="text-lg font-bold text-slate-800">Tiến trình lên hạng <%= targetRank.equals("MAX") ? "Tối Đa" : targetRank %></h3>
                                        <p class="text-sm text-slate-500 mt-1">Hoàn thành 1 trong 2 điều kiện dưới đây để thăng hạng.</p>
                                    </div>
                                </div>
                                <div class="flex justify-around items-center bg-slate-50 rounded-xl p-6 border border-slate-100">
                                    <div class="flex flex-col items-center">
                                        <div class="relative w-28 h-28">
                                            <svg class="w-full h-full transform -rotate-90">
                                                <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-slate-200" />
                                                <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-emerald-500 transition-all duration-1000" stroke-dasharray="276" stroke-dashoffset="<%= washOffset %>" stroke-linecap="round" />
                                            </svg>
                                            <div class="absolute inset-0 flex flex-col items-center justify-center"><span class="text-2xl font-bold text-slate-800"><%= washPercent %>%</span></div>
                                        </div>
                                        <div class="text-center mt-3">
                                            <p class="font-bold text-slate-700"><i class="fa-solid fa-droplet text-blue-500 mr-1"></i> Số lần rửa</p>
                                            <p class="text-sm text-slate-500"><%= yearlyWashes %> / <%= targetRank.equals("MAX") ? "-" : targetWashes %> lần</p>
                                        </div>
                                    </div>
                                    <div class="text-slate-400 font-bold bg-white px-3 py-1 rounded-full border border-slate-200 shadow-sm">HOẶC</div>
                                    <div class="flex flex-col items-center">
                                        <div class="relative w-28 h-28">
                                            <svg class="w-full h-full transform -rotate-90">
                                                <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-slate-200" />
                                                <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-orange-500 transition-all duration-1000" stroke-dasharray="276" stroke-dashoffset="<%= spentOffset %>" stroke-linecap="round" />
                                            </svg>
                                            <div class="absolute inset-0 flex flex-col items-center justify-center"><span class="text-2xl font-bold text-slate-800"><%= spentPercent %>%</span></div>
                                        </div>
                                        <div class="text-center mt-3">
                                            <p class="font-bold text-slate-700"><i class="fa-solid fa-coins text-orange-500 mr-1"></i> Chi tiêu</p>
                                            <p class="text-sm text-slate-500"><%= String.format("%,d", currentSpent) %> / <%= targetRank.equals("MAX") ? "-" : String.format("%,d", targetSpent) %> VNĐ</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex-1 flex flex-col">
                                <div class="flex justify-between items-center mb-4">
                                    <h3 class="text-lg font-bold text-slate-800">Lịch hẹn sắp tới</h3>
                                    <% if (hasAppointments) { %><a href="booking" class="text-sm bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700 transition"><i class="fa-solid fa-plus"></i> Đặt thêm</a><% } %>
                                </div>
                                <div class="flex-1 overflow-y-auto pr-2 space-y-4 max-h-[220px]">
                                    <% if (hasAppointments) { %>
                                        <div class="flex items-center justify-between border-l-4 border-emerald-500 bg-emerald-50/50 p-4 rounded-r-lg">
                                            <div>
                                                <p class="font-bold text-slate-800">Rửa xe tự động - Gói Siêu Tốc</p>
                                                <p class="text-sm text-slate-500 mt-1"><i class="fa-regular fa-clock mr-1 text-emerald-600"></i> Hôm nay, 15:30 PM - Xe: 51H-123.45</p>
                                            </div>
                                            <span class="px-3 py-1 bg-emerald-100 text-emerald-700 text-xs font-bold rounded-full">Đã xác nhận</span>
                                        </div>
                                    <% } else { %>
                                        <div class="flex flex-col items-center justify-center h-full py-4">
                                            <img src="https://cdn-icons-png.flaticon.com/512/7470/7470876.png" alt="No Appointment" class="w-20 opacity-60 mb-3">
                                            <p class="text-slate-500 mb-4 font-medium">Bạn chưa có lịch hẹn nào sắp tới.</p>
                                            <a href="booking" class="bg-[#464BE5] hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-lg shadow-md transition-colors flex items-center gap-2"><i class="fa-regular fa-calendar-plus"></i> Đặt lịch rửa xe ngay</a>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </main>

            <div id="tierInfoModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-3xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300" id="tierModalContent">
                    
                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-[#464BE5]"><i class="fa-solid fa-ranking-star text-lg"></i></div>
                            <div>
                                <h3 class="text-lg font-bold text-slate-800 leading-tight">Hệ Thống Thành Viên SmartWash</h3>
                                <p class="text-xs text-slate-500">Chi tiết cấp bậc và quyền lợi</p>
                            </div>
                        </div>
                        <button onclick="closeTierInfoModal()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-2xl"></i></button>
                    </div>

                    <div class="p-6">
                        <div class="overflow-hidden border border-slate-200 rounded-xl">
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 border-b border-slate-200">
                                        <th class="py-3 px-4 font-bold text-slate-700">Hạng (Tier)</th>
                                        <th class="py-3 px-4 font-bold text-slate-700">Điều kiện thăng hạng</th>
                                        <th class="py-3 px-4 font-bold text-slate-700">Đặc quyền nhận được</th>
                                    </tr>
                                </thead>
                                <tbody class="text-sm">
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                                        <td class="py-3 px-4 font-semibold text-slate-600 flex items-center gap-2"><i class="fa-solid fa-user text-slate-400"></i> Member</td>
                                        <td class="py-3 px-4 text-slate-600">Đăng ký tài khoản + 1 Lần rửa xe</td>
                                        <td class="py-3 px-4 text-emerald-600 font-medium">1 điểm thưởng = 1.000 VNĐ chi tiêu</td>
                                    </tr>
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition bg-slate-50/50">
                                        <td class="py-3 px-4 font-bold text-slate-800 flex items-center gap-2"><i class="fa-solid fa-shield-halved text-gray-500"></i> Bạc (Silver)</td>
                                        <td class="py-3 px-4 text-slate-600">5 Lần rửa xe HOẶC 2.000.000 VNĐ</td>
                                        <td class="py-3 px-4 text-emerald-600 font-medium">+10% Điểm thưởng<br>Ưu tiên đặt lịch slot trống</td>
                                    </tr>
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                                        <td class="py-3 px-4 font-bold text-yellow-600 flex items-center gap-2"><i class="fa-solid fa-crown text-yellow-500"></i> Vàng (Gold)</td>
                                        <td class="py-3 px-4 text-slate-600">15 Lần rửa xe HOẶC 6.000.000 VNĐ</td>
                                        <td class="py-3 px-4 text-emerald-600 font-medium">+20% Điểm thưởng<br>Miễn phí nâng cấp dịch vụ/tháng</td>
                                    </tr>
                                    <tr class="hover:bg-slate-50 transition bg-slate-50/50">
                                        <td class="py-3 px-4 font-bold text-purple-700 flex items-center gap-2"><i class="fa-solid fa-gem text-purple-500"></i> Bạch Kim (Platinum)</td>
                                        <td class="py-3 px-4 text-slate-600">30 Lần rửa xe HOẶC 15.000.000 VNĐ</td>
                                        <td class="py-3 px-4 text-emerald-600 font-medium">+30% Điểm thưởng<br>1 lần rửa xe hoàn toàn miễn phí/tháng</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end">
                        <button onclick="closeTierInfoModal()" class="px-6 py-2 bg-[#464BE5] text-white font-bold rounded-lg hover:bg-blue-700 transition">Đã Hiểu</button>
                    </div>
                </div>
            </div>

        </div>

        <script>
            const tierModal = document.getElementById('tierInfoModal');
            const tierContent = document.getElementById('tierModalContent');

            function openTierInfoModal() {
                tierModal.classList.remove('hidden');
                setTimeout(() => {
                    tierModal.classList.remove('opacity-0');
                    tierContent.classList.remove('scale-95');
                    tierContent.classList.add('scale-100');
                }, 10);
            }

            function closeTierInfoModal() {
                tierModal.classList.add('opacity-0');
                tierContent.classList.remove('scale-100');
                tierContent.classList.add('scale-95');
                setTimeout(() => {
                    tierModal.classList.add('hidden');
                }, 300);
            }
        </script>
    </body>
</html>