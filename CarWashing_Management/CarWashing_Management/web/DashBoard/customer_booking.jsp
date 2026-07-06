<%-- 
    Document   : customer_booking.jsp
    Created on : Jun 9, 2026, 11:50:12 AM
    Author     : Admin
--%>

<%@page import="java.time.ZoneId"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalTime"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.ArrayList"%>
<%@page import="dto.TimeSlot"%>
<%@page import="dto.WashService"%>
<%@page import="java.util.List"%>
<%@page import="dto.Vehicle"%>
<%@page import="dao.WashServiceDAO"%>
<%@page import="dao.CustomerVehicleDAO"%>
<%@page import="dto.LoyaltyTier"%>
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dao.CustomerLoyaltyDAO"%>
<%@ include file="../includes/auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đặt Lịch Rửa Xe - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .custom-scrollbar::-webkit-scrollbar {
                height: 6px;
                width: 6px;
            }
            .custom-scrollbar::-webkit-scrollbar-track {
                background: #f1f5f9;
                border-radius: 10px;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb {
                background: #cbd5e1;
                border-radius: 10px;
            }
            .custom-scrollbar::-webkit-scrollbar-thumb:hover {
                background: #94a3b8;
            }
            /* ĐIỀU CHỈNH CSS CHO CÁC BƯỚC */
            .step-content {
                display: none; /* Mặc định ẩn tất cả */
                animation: fadeIn 0.4s ease-in-out;
            }
            .step-content.active {
                display: block; /* Chỉ hiện thằng nào có class active */
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .priority-slot {
                background: linear-gradient(135deg, #FFFAF0 0%, #FFF5E1 100%);
                border: 2px solid #FBBF24 !important;
                box-shadow: 0 4px 15px rgba(251, 191, 36, 0.2);
            }
            /* CSS HIỆU ỨNG TOAST ALERT */
            #toastBox {
                transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease;
                transform: translateX(120%);
                opacity: 0;
            }
            #toastBox.show {
                transform: translateX(0);
                opacity: 1;
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">

        <%            
            // Xử lý thông báo Toast từ Server
            String alertType = (String) request.getAttribute("ALERT_TYPE");
            String alertMsg = (String) request.getAttribute("ALERT_MSG");
            if (alertMsg == null) {
                alertType = (String) session.getAttribute("ALERT_TYPE");
                alertMsg = (String) session.getAttribute("ALERT_MSG");
                if (alertMsg != null) {
                    session.removeAttribute("ALERT_TYPE");
                    session.removeAttribute("ALERT_MSG");
                }
            }
        %>

        <%-- GIAO DIỆN TOAST ALERT TỪ SERVER ĐÃ ĐƯỢC CHIA 3 TRẠNG THÁI --%>
        <% if (alertMsg != null) {
            String bgColor = "bg-slate-100 text-slate-600";
            String iconClass = "fa-solid fa-bell";
            String title = "Thông báo";

            if ("success".equals(alertType)) {
                bgColor = "bg-green-100 text-green-600";
                iconClass = "fa-solid fa-circle-check";
                title = "Thành công";
            } else if ("fail".equals(alertType)) {
                bgColor = "bg-amber-100 text-amber-600";
                iconClass = "fa-solid fa-triangle-exclamation";
                title = "Cảnh báo";
            } else if ("error".equals(alertType)) {
                bgColor = "bg-red-100 text-red-600";
                iconClass = "fa-solid fa-circle-xmark";
                title = "Lỗi hệ thống";
            }
        %>
        <div id="toastBox" class="fixed top-6 right-6 z-[2000] flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border max-w-sm bg-white border-slate-100">
            <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg <%= bgColor %>">
                <i class="<%= iconClass %>"></i>
            </div>
            <div class="flex-1">
                <h4 class="font-bold text-slate-800 text-sm"><%= title %></h4>
                <p class="text-slate-500 text-xs mt-0.5"><%= alertMsg %></p>
            </div>
            <button onclick="closeToast()" class="text-slate-400 hover:text-slate-600 transition ml-2"><i class="fa-solid fa-xmark text-sm"></i></button>
        </div>
        <% } %>

        <%
            
            LoyaltyTier curentTier = (LoyaltyTier) request.getAttribute("TIER");

            String currentTier = curentTier.getTierName();
            int maxDaysAhead = 7;
            boolean isPriority = false;

            if ("Silver".equalsIgnoreCase(currentTier)) {
                maxDaysAhead = 10;
            } else if ("Gold".equalsIgnoreCase(currentTier)) {
                maxDaysAhead = 12;
                isPriority = true;
            } else if ("Platinum".equalsIgnoreCase(currentTier)) {
                maxDaysAhead = 14;
                isPriority = true;
            }

            
            List<Vehicle> mockVehicles = (List) request.getAttribute("VEHICLE_LIST");
            List<WashService> mockServices = (List) request.getAttribute("SERVICE_LIST");

            // Xử lý lấy ngày, giờ hiện tại (múi giờ VN)
            ZoneId vnZone = ZoneId.of("Asia/Ho_Chi_Minh");
            LocalDate today = LocalDate.now(vnZone);
            LocalTime now = LocalTime.now(vnZone);

            // Đọc ngày từ thanh URL
            String currentSelectedDate = request.getParameter("date");
            if (currentSelectedDate == null || currentSelectedDate.trim().isEmpty()) {
                currentSelectedDate = today.toString();
            }
        %>

        <div class="flex h-screen overflow-hidden relative">
            <% request.setAttribute("activeTab", "datlich");%>
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-4xl mx-auto">

                        <div class="mb-8">
                            <h2 class="text-2xl font-bold text-slate-800">Đặt Lịch Rửa Xe</h2>
                            <p class="text-sm text-slate-500 mt-1">Hoàn thành các bước dưới đây để giữ chỗ nhanh chóng.</p>
                        </div>

                        <div class="mb-10">
                            <div class="flex items-center justify-between relative">
                                <div class="absolute top-5 left-5 right-5 -translate-y-1/2 z-0">
                                    <div class="absolute left-0 top-0 w-full h-1 bg-slate-200 rounded-full"></div>
                                    <div id="progress-line" class="absolute left-0 top-0 w-0 h-1 bg-[#464BE5] rounded-full transition-all duration-500"></div>
                                </div>
                                <div class="relative z-10 flex flex-col items-center">
                                    <div id="icon-step-1" class="w-10 h-10 rounded-full bg-[#464BE5] text-white flex items-center justify-center font-bold shadow-md transition-colors duration-300">1</div>
                                    <span class="text-xs font-semibold text-[#464BE5] mt-2">Chọn xe</span>
                                </div>
                                <div class="relative z-10 flex flex-col items-center">
                                    <div id="icon-step-2" class="w-10 h-10 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold transition-colors duration-300">2</div>
                                    <span id="text-step-2" class="text-xs font-semibold text-slate-400 mt-2">Dịch vụ</span>
                                </div>
                                <div class="relative z-10 flex flex-col items-center">
                                    <div id="icon-step-3" class="w-10 h-10 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold transition-colors duration-300">3</div>
                                    <span id="text-step-3" class="text-xs font-semibold text-slate-400 mt-2">Thời gian</span>
                                </div>
                                <div class="relative z-10 flex flex-col items-center">
                                    <div id="icon-step-4" class="w-10 h-10 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold transition-colors duration-300">4</div>
                                    <span id="text-step-4" class="text-xs font-semibold text-slate-400 mt-2">Hoàn tất</span>
                                </div>
                            </div>
                        </div>

                        <form id="bookingForm" action="<%= request.getContextPath()%>/MainController?action=processBooking" method="POST" class="bg-white rounded-3xl shadow-sm border border-slate-100 p-8 relative">

                            <div id="step-1" class="step-content active">
                                <h3 class="text-lg font-bold text-slate-800 mb-6"><i class="fa-solid fa-car text-[#464BE5] mr-2"></i>Chọn xe bạn muốn rửa</h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <% for (Vehicle v : mockVehicles) {%>
                                    <label class="relative block cursor-pointer">
                                        <input type="radio" name="vehicleId" value="<%= v.getVehicleId()%>" class="peer sr-only"> 
                                        <div class="p-5 rounded-2xl border-2 border-slate-100 hover:border-[#464BE5]/50 peer-checked:border-[#464BE5] peer-checked:bg-blue-50/30 transition-all">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center gap-4">
                                                    <div class="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center text-slate-500 peer-checked:text-[#464BE5]"><i class="fa-solid fa-car-side text-xl"></i></div>
                                                    <div>
                                                        <h4 class="font-bold text-slate-800"><%= v.getLicensePlate()%></h4>
                                                        <p class="text-sm text-slate-500"><%= v.getBrand() + " " + v.getModel()%></p>
                                                    </div>
                                                </div>
                                                <i class="fa-solid fa-circle-check text-2xl text-[#464BE5] opacity-0 peer-checked:opacity-100 transition-opacity"></i>
                                            </div>
                                        </div>
                                    </label>
                                    <% } %>
                                </div>
                                <div class="mt-8 flex justify-end">
                                    <button type="button" onclick="goToStep(2)" class="px-6 py-2.5 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition">Tiếp tục <i class="fa-solid fa-arrow-right ml-2"></i></button>
                                </div>
                            </div>

                            <div id="step-2" class="step-content">
                                <h3 class="text-lg font-bold text-slate-800 mb-6"><i class="fa-solid fa-hands-bubbles text-[#464BE5] mr-2"></i>Chọn gói dịch vụ</h3>
                                <div class="space-y-4">
                                    <% for (WashService s : mockServices) {%>
                                    <label class="relative block cursor-pointer">
                                        <input type="radio" name="serviceId" value="<%= s.getServiceId()%>" data-price="<%= s.getPrice()%>" class="peer sr-only"> 
                                        <div class="p-5 rounded-2xl border-2 border-slate-100 hover:border-[#464BE5]/50 peer-checked:border-[#464BE5] peer-checked:bg-blue-50/30 transition-all">
                                            <div class="flex items-center justify-between">
                                                <div>
                                                    <h4 class="font-bold text-slate-800"><%= s.getServiceName()%></h4>
                                                    <p class="text-sm text-slate-500 mt-1"><i class="fa-regular fa-clock mr-1"></i> Ước tính: <%= s.getEstimateMinutes()%> phút</p>
                                                </div>         
                                                <div class="text-right">
                                                    <p class="text-lg font-black text-[#464BE5]"><%= String.format("%,.0f", s.getPrice()) %> VNĐ</p>
                                                </div>
                                            </div>
                                        </div>
                                    </label>
                                    <% } %>
                                </div>
                                <div class="mt-8 flex justify-between">
                                    <button type="button" onclick="goToStep(1)" class="px-6 py-2.5 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition"><i class="fa-solid fa-arrow-left mr-2"></i> Quay lại</button>
                                    <button type="button" onclick="goToStep(3)" class="px-6 py-2.5 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition">Tiếp tục <i class="fa-solid fa-arrow-right ml-2"></i></button>
                                </div>
                            </div>

                            <div id="step-3" class="step-content">
                                <h3 class="text-lg font-bold text-slate-800 mb-2"><i class="fa-regular fa-calendar text-[#464BE5] mr-2"></i>Chọn ngày và khung giờ</h3>

                                <% if (isPriority) {%>
                                <div class="mb-6 px-4 py-3 bg-amber-50 border border-amber-200 rounded-xl flex items-start gap-3">
                                    <i class="fa-solid fa-crown text-amber-500 mt-1 text-lg"></i>
                                    <div>
                                        <p class="font-bold text-amber-800 text-sm">Đặc quyền hạng <%= currentTier%></p>
                                        <p class="text-amber-700 text-xs mt-0.5">Bạn được phép đặt lịch trước tối đa <%= maxDaysAhead%> ngày và được ưu tiên xếp khoang rửa nhanh nhất!</p>
                                    </div>
                                </div>
                                <% } else {%>
                                <p class="text-sm text-slate-500 mb-6">Bạn đang ở hạng <%= currentTier%>. Có thể đặt trước tối đa <%= maxDaysAhead%> ngày.</p>
                                <% }%>

                                <div class="mb-6">
                                    <label class="block text-sm font-bold text-slate-700 mb-2">Ngày dự kiến đến</label>
                                    <input type="date" name="bookingDate" id="bookingDate" data-max-days="<%= maxDaysAhead%>" onchange="handleDateChange(this.value)" required class="w-full md:w-1/2 px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:border-[#464BE5] outline-none font-medium text-slate-700">
                                </div>

                                <label class="block text-sm font-bold text-slate-700 mb-3">Khung giờ (Mỗi slot 30 phút)</label>
                                <input type="hidden" id="selectedSlotNumber" name="slotNumber" value="">
                                <div id="slotsContainer" class="grid grid-cols-2 md:grid-cols-4 gap-3 max-h-48 overflow-y-auto custom-scrollbar pr-2 pb-2">
                                    <%
                                        List<TimeSlot> slots = (ArrayList<TimeSlot>) request.getAttribute("slots");
                                        if (slots != null && !slots.isEmpty()) {
                                            for (TimeSlot t : slots) {
                                                boolean isFull = t.isIsFull();
                                                boolean isPastOrTooClose = t.isIsPast();

                                                String labelClass = "relative block ";
                                                String boxClass = "p-3 rounded-xl border text-center transition-all ";
                                                String clickHandler = "";

                                                if (isPastOrTooClose) {
                                                    labelClass += "cursor-not-allowed opacity-50 select-none";
                                                    boxClass += "bg-slate-100 border-slate-200 text-slate-400 pointers-disabled";
                                                    clickHandler = "onclick=\"return false;\"";
                                                } else if (isFull) {
                                                    labelClass += "cursor-not-allowed opacity-70 select-none";
                                                    boxClass += "bg-red-50 border-red-200 text-red-500 pointers-disabled";
                                                    clickHandler = "onclick=\"return false;\"";
                                                } else {
                                                    labelClass += "cursor-pointer group";
                                                    boxClass += "bg-white border-slate-200 text-slate-600 hover:border-[#464BE5] peer-checked:bg-[#464BE5] peer-checked:border-[#464BE5] peer-checked:text-white";
                                                    if (isPriority && t.isIsPriority()) {
                                                        boxClass = "p-3 rounded-xl text-center transition-all cursor-pointer peer-checked:bg-amber-500 peer-checked:text-white priority-slot text-amber-700 font-bold";
                                                    }
                                                }
                                                String onClickAction = (!isPastOrTooClose && !isFull) ? "onclick=\"selectSlot('" + t.getSlotNumber() + "')\"" : "";
                                    %>

                                    <label class="<%= labelClass%>" <%= clickHandler%> style="<%= (isPastOrTooClose || isFull) ? "pointer-events: none;" : ""%>"<%= onClickAction%>>
                                        <input type="radio" name="timeSlot" value="<%= t.getStartTime().substring(0, 5)+ "-" + t.getEndTime().substring(0, 5)%>" class="peer sr-only" <%= (isPastOrTooClose || isFull) ? "disabled" : ""%>>
                                        <div class="<%= boxClass%>" style="<%= (isPastOrTooClose || isFull) ? "pointer-events: none;" : ""%>">
                                            <span class="text-sm font-semibold"><%= t.getStartTime().substring(0, 5)+ "-" + t.getEndTime().substring(0, 5)%></span>
                                            <% if (isPastOrTooClose) { %>
                                            <div class="text-[10px] uppercase font-bold mt-1">Hết hạn</div>
                                            <% } else if (isFull) { %>
                                            <div class="text-[10px] uppercase font-bold mt-1">Đã kín (3/3)</div>
                                            <% } else if (isPriority && t.isIsPriority()) { %>
                                            <div class="text-[10px] uppercase font-bold mt-1"><i class="fa-solid fa-star text-amber-500 peer-checked:text-white"></i> Ưu tiên</div>
                                            <% } else {%>
                                            <div class="text-[10px] text-slate-400 peer-checked:text-blue-100 mt-1">Còn trống <%= 3 - t.getBookedCount()%>/3</div>
                                            <% } %>
                                        </div>
                                    </label>
                                    <% }
                                    } else { %>
                                    <p class="text-sm text-slate-400 col-span-4">Không tìm thấy khung giờ hoạt động.</p>
                                    <% }%>
                                </div>

                                <div class="mt-8 flex justify-between">
                                    <button type="button" onclick="goToStep(2)" class="px-6 py-2.5 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition"><i class="fa-solid fa-arrow-left mr-2"></i> Quay lại</button>
                                    <button type="button" onclick="goToStep(4)" class="px-6 py-2.5 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition">Tiếp tục <i class="fa-solid fa-arrow-right ml-2"></i></button>
                                </div>
                            </div>

                            <div id="step-4" class="step-content">
                                <div class="text-center mb-6">
                                    <div class="w-16 h-16 bg-blue-100 text-[#464BE5] rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                                        <i class="fa-solid fa-clipboard-check"></i>
                                    </div>
                                    <h3 class="text-xl font-bold text-slate-800">Xác nhận thông tin đặt lịch</h3>
                                    <p class="text-sm text-slate-500 mt-1">Vui lòng kiểm tra lại thông tin trước khi xác nhận.</p>
                                </div>

                                <div class="bg-slate-50 rounded-2xl p-6 border border-slate-100 space-y-4 mb-8">
                                    <div class="flex justify-between border-b border-slate-200 pb-3">
                                        <span class="text-slate-500 text-sm">Phương tiện:</span>
                                        <span class="font-bold text-slate-800 text-sm" id="summary-vehicle">Chưa chọn xe</span>
                                    </div>
                                    <div class="flex justify-between border-b border-slate-200 pb-3">
                                        <span class="text-slate-500 text-sm">Dịch vụ:</span>
                                        <span class="font-bold text-slate-800 text-sm" id="summary-service">Chưa chọn dịch vụ</span>
                                    </div>
                                    <div class="flex justify-between border-b border-slate-200 pb-3">
                                        <span class="text-slate-500 text-sm">Thời gian:</span>
                                        <span class="font-bold text-slate-800 text-sm" id="summary-time">Chưa chọn ngày giờ</span>
                                    </div>
                                    <div class="flex justify-between items-center pt-1">
                                        <span class="text-slate-700 font-bold text-sm">Tổng thanh toán:</span>
                                        <span class="font-black text-xl text-[#464BE5]" id="summary-price">0 VNĐ</span>
                                    </div>
                                </div>

                                <div class="flex justify-between">
                                    <button type="button" onclick="goToStep(3)" class="px-6 py-2.5 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition"><i class="fa-solid fa-arrow-left mr-2"></i> Quay lại</button>
                                    <button type="submit" id="btnSubmit" class="px-8 py-2.5 bg-emerald-500 text-white font-bold rounded-xl hover:bg-emerald-600 transition shadow-md shadow-emerald-500/30 flex items-center gap-2">
                                        <span>Hoàn tất Đặt lịch</span>
                                        <i class="fa-solid fa-spinner fa-spin hidden" id="loadingIcon"></i>
                                    </button>
                                </div>
                            </div>
                        </form> 

                    </div>
                </div>
            </main>
        </div>

        <script>
            // HỆ THỐNG ĐIỀU KHIỂN TOAST ALERT
            const serverToast = document.getElementById('toastBox');

            // Xử lý Toast từ Server render ra
            if (serverToast) {
                setTimeout(() => serverToast.classList.add('show'), 100);
                setTimeout(() => closeToast(), 3100);
            }

            function closeToast() {
                const t = document.getElementById('toastBox');
                if (t) {
                    t.classList.remove('show');
                    setTimeout(() => t.remove(), 400);
                }
            }

            // Hàm tạo Toast động bằng JavaScript dùng cho Fetch API
            function showDynamicToast(type, message) {
                // Xóa toast cũ nếu có để tránh đè lên nhau
                const oldToast = document.getElementById('toastBox');
                if (oldToast) oldToast.remove();

                let bgColor = "bg-slate-100 text-slate-600";
                let iconClass = "fa-solid fa-bell";
                let title = "Thông báo";

                if (type === "success") { bgColor = "bg-green-100 text-green-600"; iconClass = "fa-solid fa-circle-check"; title = "Thành công"; }
                else if (type === "fail") { bgColor = "bg-amber-100 text-amber-600"; iconClass = "fa-solid fa-triangle-exclamation"; title = "Cảnh báo"; }
                else if (type === "error") { bgColor = "bg-red-100 text-red-600"; iconClass = "fa-solid fa-circle-xmark"; title = "Lỗi hệ thống"; }

                // NỐI CHUỖI BẰNG DẤU + ĐỂ TRÁNH TOMCAT DỊCH NHẦM JSP EL
                const toastHtml = 
                    '<div id="toastBox" class="fixed top-6 right-6 z-[2000] flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border max-w-sm bg-white border-slate-100" style="transform: translateX(120%); opacity: 0; transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease;">' +
                        '<div class="w-10 h-10 rounded-full flex items-center justify-center text-lg ' + bgColor + '">' +
                            '<i class="' + iconClass + '"></i>' +
                        '</div>' +
                        '<div class="flex-1">' +
                            '<h4 class="font-bold text-slate-800 text-sm">' + title + '</h4>' +
                            '<p class="text-slate-500 text-xs mt-0.5">' + message + '</p>' +
                        '</div>' +
                        '<button onclick="closeToast()" class="text-slate-400 hover:text-slate-600 transition ml-2"><i class="fa-solid fa-xmark text-sm"></i></button>' +
                    '</div>';
                    
                document.body.insertAdjacentHTML('beforeend', toastHtml);
                
                const newToast = document.getElementById('toastBox');
                setTimeout(() => {
                    newToast.style.transform = 'translateX(0)';
                    newToast.style.opacity = '1';
                    newToast.classList.add('show');
                }, 10);

                setTimeout(() => closeToast(), 3100);
            }

            // HỆ THỐNG ĐIỀU KHIỂN CÁC BƯỚC (STEPS)
            function goToStep(step) {
                if (step === 2) {
                    const selectedVehicle = document.querySelector('input[name="vehicleId"]:checked');
                    if (!selectedVehicle) {
                        showDynamicToast('fail', 'Vui lòng chọn xe của bạn trước khi tiếp tục!');
                        return;
                    }
                }
                if (step === 3) {
                    const selectedService = document.querySelector('input[name="serviceId"]:checked');
                    if (!selectedService) {
                        showDynamicToast('fail', 'Vui lòng chọn gói dịch vụ trước khi tiếp tục!');
                        return;
                    }
                }
                if (step === 4) {
                    const selectedTimeSlot = document.querySelector('input[name="timeSlot"]:checked');
                    if (!selectedTimeSlot) {
                        showDynamicToast('fail', 'Vui lòng chọn khung giờ hẹn trước khi tiếp tục!');
                        return;
                    }
                }

                // Ẩn tất cả các bước
                document.querySelectorAll('.step-content').forEach(el => {
                    el.classList.remove('active');
                });

                // Cập nhật thanh Progress Bar
                const progressLineWidths = ['0%', '33%', '66%', '100%'];
                document.getElementById('progress-line').style.width = progressLineWidths[step - 1];

                // Cập nhật màu các con số 1 2 3 4
                for (let i = 1; i <= 4; i++) {
                    const icon = document.getElementById('icon-step-' + i);
                    const text = document.getElementById('text-step-' + i);
                    if (i <= step) {
                        icon.className = "w-10 h-10 rounded-full bg-[#464BE5] text-white flex items-center justify-center font-bold shadow-md transition-colors duration-300";
                        if (text)
                            text.className = "text-xs font-semibold text-[#464BE5] mt-2";
                    } else {
                        icon.className = "w-10 h-10 rounded-full bg-slate-200 text-slate-400 flex items-center justify-center font-bold transition-colors duration-300";
                        if (text)
                            text.className = "text-xs font-semibold text-slate-400 mt-2";
                    }
                }

                if (step === 4) {
                    updateSummary();
                }

                // Kích hoạt hiển thị bước được chọn
                const targetStep = document.getElementById('step-' + step);
                targetStep.classList.add('active');
            }

            function updateSummary() {
                const selectedVehicle = document.querySelector('input[name="vehicleId"]:checked');
                const selectedService = document.querySelector('input[name="serviceId"]:checked');
                const date = document.getElementById('bookingDate').value;
                const timeSlot = document.querySelector('input[name="timeSlot"]:checked');

                if (selectedVehicle) {
                    const label = selectedVehicle.closest('label').querySelector('h4').innerText;
                    document.getElementById('summary-vehicle').innerText = label;
                }
                
                if (selectedService) {
                    const label = selectedService.closest('label').querySelector('h4').innerText;
                    document.getElementById('summary-service').innerText = label;
                    
                    // Lấy giá tiền từ thuộc tính data-price và format theo chuẩn Việt Nam
                    const priceValue = selectedService.getAttribute('data-price');
                    if (priceValue) {
                        const formattedPrice = parseInt(priceValue).toLocaleString('vi-VN');
                        document.getElementById('summary-price').innerText = formattedPrice + " VNĐ";
                    }
                }
                
                let timeText = "Chưa chọn giờ";
                if (timeSlot) {
                    timeText = timeSlot.closest('label').querySelector('span').innerText;
                }
                const timeStr = (date ? date + " | " : "") + timeText;
                document.getElementById('summary-time').innerText = timeStr;
            }
            
            function selectSlot(slotNumber) {
                document.getElementById('selectedSlotNumber').value = slotNumber;
                console.log("Đã chọn Slot số: " + slotNumber);
            }
            
            document.getElementById('bookingForm').addEventListener('submit', function (e) {
                const btnSubmit = document.getElementById('btnSubmit');
                const loadingIcon = document.getElementById('loadingIcon');
                if (btnSubmit.disabled) {
                    e.preventDefault();
                    return;
                }
                btnSubmit.disabled = true;
                btnSubmit.classList.add('opacity-80', 'cursor-not-allowed');
                loadingIcon.classList.remove('hidden');
            });


            // FETCH API: TẢI KHUNG GIỜ
            function handleDateChange(selectedDate) {
                if (!selectedDate)
                    return;

                const container = document.getElementById('slotsContainer');
                container.innerHTML = '<p class="text-sm text-slate-400 col-span-4 text-center py-4"><i class="fa-solid fa-spinner fa-spin mr-2"></i>Đang tải khung giờ...</p>';

                const fetchUrl = '<%= request.getContextPath()%>/MainController?action=customerBookingPage&date=' + selectedDate;

                fetch(fetchUrl)
                        .then(response => response.text())
                        .then(html => {
                            const parser = new DOMParser();
                            const doc = parser.parseFromString(html, 'text/html');
                            const newSlots = doc.getElementById('slotsContainer');

                            if (newSlots) {
                                container.innerHTML = newSlots.innerHTML;
                            } else {
                                container.innerHTML = '<p class="text-sm text-red-500 col-span-4 text-center py-4">Lỗi tải dữ liệu khung giờ.</p>';
                                showDynamicToast('error', 'Không thể bóc tách dữ liệu khung giờ từ Server!');
                            }
                        })
                        .catch(err => {
                            console.error("Lỗi:", err);
                            container.innerHTML = '<p class="text-sm text-red-500 col-span-4 text-center py-4">Mất kết nối với máy chủ!</p>';
                            showDynamicToast('error', 'Mất kết nối mạng! Vui lòng kiểm tra lại Internet.');
                        });
            }

            window.onload = function () {
                const dateInput = document.getElementById('bookingDate');
                const maxDaysAllowed = parseInt(dateInput.getAttribute("data-max-days")) || 7;

                const today = new Date();
                const maxDate = new Date();
                maxDate.setDate(today.getDate() + maxDaysAllowed);

                function formatDate(date) {
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0');
                    const day = String(date.getDate()).padStart(2, '0');
                    return year + '-' + month + '-' + day;
                }

                const todayStr = formatDate(today);
                const maxDateStr = formatDate(maxDate);

                dateInput.value = "<%= currentSelectedDate%>";
                dateInput.min = todayStr;
                dateInput.max = maxDateStr;

                dateInput.addEventListener('change', function () {
                    if (!this.value) {
                        this.value = todayStr;
                        handleDateChange(this.value);
                    }
                });
            };
        </script>
    </body>
</html>