<%@page import="java.util.List"%>
<%@page import="dto.Vehicle"%>
<%@page import="dao.CustomerVehicleDAO"%>
<%@page import="dto.LoyaltyTier"%>
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dao.CustomerLoyaltyDAO"%>
<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page import="dto.Booking"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/auth-check.jsp" %>

<%    CustomerLoyaltyDAO loyaltyDAO = new CustomerLoyaltyDAO();
    CustomerLoyalty loyalty = loyaltyDAO.getLoyaltyProfileByAccountId(userAcc.getAccountID());
    LoyaltyTier nextTier = loyalty.getNextTierDetails();

    CustomerVehicleDAO vehicleDAO = new CustomerVehicleDAO();
    List<Vehicle> vehicleList = vehicleDAO.getAllVehicles(cus.getCustomerId());
    List<Booking> upcomingBookings
            = (List<Booking>) request.getAttribute(
                    "upcomingBookings");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Customer Dashboard - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .mesh-gradient-header {
                background-color: #0f172a;
                background-image:
                    radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%),
                    radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%),
                    radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            }
            .scrollbar-hide::-webkit-scrollbar {
                display: none;
            }
            .scrollbar-hide {
                -ms-overflow-style: none;
                scrollbar-width: none;
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="../includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>


                <div class="flex-1 overflow-y-auto p-8">

                    <div class="grid grid-cols-4 gap-6 mb-6">
                        <div class="<%= loyalty.getBgClass()%> p-6 rounded-2xl shadow-sm border flex items-center justify-between transition-all duration-300">
                            <div>
                                <p class="text-sm font-medium <%= loyalty.getLabelClass()%>">Hạng hiện tại</p>
                                <h3 class="text-2xl font-bold <%= loyalty.getTextClass()%> mt-1"><%= (loyalty.getCurrentTierDetails() != null) ? loyalty.getCurrentTierDetails().getTierName() : "Member"%></h3>
                            </div>
                            <i class="fa-solid <%= loyalty.getIconClass()%> text-3xl <%= loyalty.getIconColor()%> drop-shadow-sm"></i>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-slate-500">Điểm Tích Lũy</p>
                                <h3 class="text-2xl font-bold text-slate-800 mt-1"><%= loyalty.getCurrentPoints()%> PTS</h3>
                            </div>
                            <div class="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500 text-xl"><i class="fa-solid fa-star"></i></div>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-slate-500">Tổng Lần Rửa Trong Năm</p>
                                <h3 class="text-2xl font-bold text-slate-800 mt-1"><%= loyalty.getTotalWashCount()%> Lần</h3>
                            </div>
                            <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center text-blue-500 text-xl"><i class="fa-solid fa-droplet"></i></div>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col justify-center relative group transition-all hover:shadow-md hover:border-emerald-200">
                            <div class="flex justify-between items-start mb-2">
                                <p class="text-sm font-medium text-slate-500">Đặc quyền hạng <%= (loyalty.getCurrentTierDetails() != null) ? loyalty.getCurrentTierDetails().getTierName() : "Member"%></p>
                                <button onclick="openTierInfoModal()" class="text-slate-300 hover:text-[#464BE5] transition">
                                    <i class="fa-solid fa-circle-exclamation text-lg"></i>
                                </button>
                            </div>
                            <div class="w-full overflow-hidden">
                                <p class="font-bold text-[#464BE5] text-[15px] leading-tight truncate"><i class="fa-solid fa-gift mr-1"></i> <%= loyalty.getCurrentBenefits()%></p>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                        <div class="col-span-1 bg-white rounded-2xl shadow-sm border border-slate-100 p-6 flex flex-col">
                            <div class="flex justify-between items-center mb-4">
                                <h3 class="text-lg font-bold text-slate-800">Danh sách xe của tôi</h3>
                                <a href="<%= request.getContextPath()%>/MainController?action=customerVehicle" class="text-sm text-emerald-500 font-medium hover:underline">Xem tất cả</a>
                            </div>
                            <div class="flex-1 overflow-y-auto max-h-[320px] pr-1 space-y-3">
                                <% if (vehicleList != null && !vehicleList.isEmpty()) {
                                        for (Vehicle v : vehicleList) {%>
                                <div class="flex items-center justify-between p-4 bg-slate-50 border border-slate-100 rounded-xl hover:bg-slate-100 transition">
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-lg flex items-center justify-center text-xl">
                                            <i class="fa-solid fa-car"></i>
                                        </div>
                                        <div>
                                            <h4 class="font-bold text-slate-800 text-sm tracking-wider"><%= v.getLicensePlate()%></h4>
                                            <p class="text-xs text-slate-500"><%= v.getBrand()%> - <%= v.getModel()%> (<%= v.getColor()%>)</p>
                                        </div>
                                    </div>
                                    <% if (v.getIsDefault() != null && v.getIsDefault()) { %>
                                    <span class="text-[10px] font-bold bg-emerald-500 text-white px-2 py-0.5 rounded-full shadow-sm">Mặc định</span>
                                    <% } %>
                                </div>
                                <% }
                                } else {%>
                                <div class="bg-slate-50 border-2 border-dashed border-slate-200 rounded-xl p-6 flex flex-col items-center justify-center text-center h-full">
                                    <div class="w-12 h-12 bg-slate-200 rounded-full flex items-center justify-center text-slate-400 mb-2 text-xl"><i class="fa-solid fa-car-side"></i></div>
                                    <p class="text-xs text-slate-500 font-medium mb-3">Bạn chưa đăng ký xe nào.</p>
                                    <a href="<%= request.getContextPath()%>/MainController?action=customerVehicle" class="bg-emerald-100 text-emerald-700 text-xs font-semibold px-3 py-1.5 rounded-lg hover:bg-emerald-200 transition"><i class="fa-solid fa-plus mr-1"></i> Thêm ngay</a>
                                </div>
                                <% }%>
                            </div>
                        </div>

                        <div class="col-span-2 flex flex-col gap-6">

                            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                                <div class="flex justify-between items-end mb-6">
                                    <div>
                                        <h3 class="text-lg font-bold text-slate-800">
                                            Tiến trình lên hạng: <%= (nextTier != null) ? nextTier.getTierName() : "Tối Đa (Platinum)"%>
                                        </h3>
                                        <p class="text-sm text-slate-500 mt-1">Hoàn thành 1 trong 2 điều kiện dưới đây để thăng hạng.</p>
                                    </div>
                                </div>
                                <div class="flex justify-around items-center bg-slate-50 rounded-xl p-6 border border-slate-100">
                                    <div class="flex flex-col items-center">
                                        <div class="relative w-28 h-28">
                                            <svg class="w-full h-full transform -rotate-90">
                                            <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-slate-200" />
                                            <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-emerald-500 transition-all duration-1000" stroke-dasharray="276" stroke-dashoffset="<%= loyalty.getWashOffset()%>" stroke-linecap="round" />
                                            </svg>
                                            <div class="absolute inset-0 flex flex-col items-center justify-center"><span class="text-2xl font-bold text-slate-800"><%= loyalty.getWashPercent()%>%</span></div>
                                        </div>
                                        <div class="text-center mt-3">
                                            <p class="font-bold text-slate-700"><i class="fa-solid fa-droplet text-blue-500 mr-1"></i> Số lần rửa</p>
                                            <p class="text-sm text-slate-500"><%= loyalty.getTotalWashCount()%> / <%= (nextTier != null) ? nextTier.getMinWashCount() : "-"%> lần</p>
                                        </div>
                                    </div>
                                    <div class="text-slate-400 font-bold bg-white px-3 py-1 rounded-full border border-slate-200 shadow-sm">HOẶC</div>
                                    <div class="flex flex-col items-center">
                                        <div class="relative w-28 h-28">
                                            <svg class="w-full h-full transform -rotate-90">
                                            <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-slate-200" />
                                            <circle cx="56" cy="56" r="44" stroke="currentColor" stroke-width="8" fill="transparent" class="text-orange-500 transition-all duration-1000" stroke-dasharray="276" stroke-dashoffset="<%= loyalty.getSpentOffset()%>" stroke-linecap="round" />
                                            </svg>
                                            <div class="absolute inset-0 flex flex-col items-center justify-center"><span class="text-2xl font-bold text-slate-800"><%= loyalty.getSpentPercent()%>%</span></div>
                                        </div>
                                        <div class="text-center mt-3">
                                            <p class="font-bold text-slate-700"><i class="fa-solid fa-coins text-orange-500 mr-1"></i> Chi tiêu</p>
                                            <p class="text-sm text-slate-500"><%= String.format("%,d", (int) loyalty.getTotalSpent())%> / <%= (nextTier != null) ? String.format("%,d", (int) nextTier.getMinTotalSpent()) : "-"%> VNĐ</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex-1 flex flex-col">
                                <div class="flex-1 overflow-y-auto pr-2 space-y-4 max-h-[220px]">

                                    <% if (upcomingBookings != null && !upcomingBookings.isEmpty()) { %>

                                    <% for (Booking b : upcomingBookings) {%>

                                    <div class="border border-slate-200 rounded-xl p-4 bg-slate-50">

                                        <div class="flex justify-between items-start">

                                            <div>

                                                <h4 class="font-bold text-slate-800">
                                                    <i class="fa-solid fa-car text-blue-500 mr-2"></i>
                                                    <%= b.getLicensePlate()%>
                                                </h4>

                                                <p class="text-sm text-slate-500 mt-1">
                                                    <%= b.getVehicleBrand()%>
                                                    -
                                                    <%= b.getVehicleModel()%>
                                                </p>

                                            </div>

                                            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-700">
                                                <%= b.getBookingStatus()%>
                                            </span>

                                        </div>

                                        <div class="mt-3 text-sm text-slate-600">

                                            <p>
                                                <i class="fa-solid fa-soap text-emerald-500 mr-2"></i>
                                                <%= b.getServiceName()%>
                                            </p>

                                            <p class="mt-1">
                                                <i class="fa-regular fa-calendar mr-2"></i>
                                                <%= b.getBookingDate()%>
                                            </p>

                                            <%
                                                int slot = b.getSlotNumber();

                                                int startHour = 8 + ((slot - 1) * 30) / 60;
                                                int startMinute = ((slot - 1) * 30) % 60;

                                                int endHour = 8 + (slot * 30) / 60;
                                                int endMinute = (slot * 30) % 60;

                                                String timeLabel = String.format(
                                                        "%02d:%02d - %02d:%02d",
                                                        startHour,
                                                        startMinute,
                                                        endHour,
                                                        endMinute
                                                );
                                            %>

                                            <p class="mt-1">
                                                <i class="fa-regular fa-clock mr-2"></i>
                                                Slot <%= slot%> (<%= timeLabel%>)
                                            </p>

                                        </div>

                                    </div>

                                    <% } %>

                                    <% } else {%>

                                    <div class="flex flex-col items-center justify-center h-full py-4">

                                        <img src="https://cdn-icons-png.flaticon.com/512/7470/7470876.png"
                                             alt="No Appointment"
                                             class="w-16 opacity-50 mb-2">

                                        <p class="text-slate-500 text-sm font-medium mb-3">
                                            Bạn chưa có lịch hẹn nào sắp tới.
                                        </p>

                                        <a href="<%=request.getContextPath()%>/MainController?action=customerBookingPage"
                                           class="bg-[#464BE5] hover:bg-blue-700 text-white text-xs font-semibold py-2 px-4 rounded-lg shadow-md transition-colors flex items-center gap-2">

                                            <i class="fa-regular fa-calendar-plus"></i>
                                            Đặt lịch rửa xe ngay

                                        </a>

                                    </div>

                                    <% }%>

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