<%-- 
    Document   : customer_booking.jsp
    Created on : Jun 9, 2026, 11:50:12 AM
    Author     : Admin
--%>

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
            /* Custom Scrollbar cho các danh sách dài */
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

            /* Hiệu ứng chuyển bước mượt mà */
            .step-content {
                transition: all 0.4s ease-in-out;
                opacity: 0;
                transform: translateY(10px);
                display: none;
            }
            .step-content.active {
                opacity: 1;
                transform: translateY(0);
                display: block;
            }

            /* Hàng đợi ưu tiên (Priority Queue) cho Gold/Platinum */
            .priority-slot {
                background: linear-gradient(135deg, #FFFAF0 0%, #FFF5E1 100%);
                border: 2px solid #FBBF24 !important;
                box-shadow: 0 4px 15px rgba(251, 191, 36, 0.2);
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">

        <%            // =========================================================
            // [BACKEND TODO]: KHU VỰC BƠM DỮ LIỆU (DATA BINDING)
            // =========================================================
            // 1. Lấy hạng thành viên để tính số ngày được đặt trước
            String currentTier = "Gold"; // Thay bằng: session.getAttribute("TIER_NAME")
            int maxDaysAhead = 7; // Mặc định Member
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

            // 2. Dữ liệu mồi (Mock data) cho xe và dịch vụ
            // Tương lai thay bằng vòng lặp <c:forEach items="${VEHICLE_LIST}">
            String[] mockVehicles = {"51H-123.45 - Honda Civic", "51G-987.65 - Mazda 3"};
            String[] mockServices = {"Rửa bọt tuyết tiêu chuẩn (150k)", "Combo Cao Cấp + Phủ Sáp (350k)"};
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

                        <form id="bookingForm" action="<%= request.getContextPath()%>/MainController?action=processBooking" method="POST" class="bg-white rounded-3xl shadow-sm border border-slate-100 p-8 min-h-[400px] relative">

                            <div id="step-1" class="step-content active">
                                <h3 class="text-lg font-bold text-slate-800 mb-6"><i class="fa-solid fa-car text-[#464BE5] mr-2"></i>Chọn xe bạn muốn rửa</h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <% for (int i = 0; i < mockVehicles.length; i++) {%>
                                    <label class="relative block cursor-pointer">
                                        <input type="radio" name="vehicleId" value="<%= i%>" class="peer sr-only" <%= i == 0 ? "checked" : ""%>>
                                        <div class="p-5 rounded-2xl border-2 border-slate-100 hover:border-[#464BE5]/50 peer-checked:border-[#464BE5] peer-checked:bg-blue-50/30 transition-all">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center gap-4">
                                                    <div class="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center text-slate-500 peer-checked:text-[#464BE5]">
                                                        <i class="fa-solid fa-car-side text-xl"></i>
                                                    </div>
                                                    <div>
                                                        <h4 class="font-bold text-slate-800"><%= mockVehicles[i].split(" - ")[0]%></h4>
                                                        <p class="text-sm text-slate-500"><%= mockVehicles[i].split(" - ")[1]%></p>
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
                                    <% for (int i = 0; i < mockServices.length; i++) {%>
                                    <label class="relative block cursor-pointer">
                                        <input type="radio" name="serviceId" value="<%= i%>" class="peer sr-only" <%= i == 0 ? "checked" : ""%>>
                                        <div class="p-5 rounded-2xl border-2 border-slate-100 hover:border-[#464BE5]/50 peer-checked:border-[#464BE5] peer-checked:bg-blue-50/30 transition-all">
                                            <div class="flex items-center justify-between">
                                                <div>
                                                    <h4 class="font-bold text-slate-800"><%= mockServices[i]%></h4>
                                                    <p class="text-sm text-slate-500 mt-1"><i class="fa-regular fa-clock mr-1"></i> Ước tính: <%= (i + 1) * 30%> phút</p>
                                                </div>
                                                <div class="h-6 w-6 rounded-full border-2 border-slate-300 peer-checked:border-[6px] peer-checked:border-[#464BE5] transition-all"></div>
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
                                <% } %>

                                <div class="mb-6">
                                    <label class="block text-sm font-bold text-slate-700 mb-2">Ngày dự kiến đến</label>
                                    <input type="date" name="bookingDate" id="bookingDate" required class="w-full md:w-1/2 px-4 py-3 rounded-xl bg-slate-50 border border-slate-200 focus:border-[#464BE5] outline-none font-medium text-slate-700">
                                </div>

                                <label class="block text-sm font-bold text-slate-700 mb-3">Khung giờ (Mỗi slot 30 phút)</label>
                                <div class="grid grid-cols-2 md:grid-cols-4 gap-3 max-h-48 overflow-y-auto custom-scrollbar pr-2 pb-2">

                                    <%
                                        // Mock Data cho Slots (Giả lập Backend gửi xuống danh sách slot: Còn trống, Đã đầy)
                                        String[] slots = {"08:00 - 08:30", "08:30 - 09:00", "09:00 - 09:30", "09:30 - 10:00", "10:00 - 10:30", "10:30 - 11:00"};
                                        boolean[] isFullList = {false, true, false, false, true, false}; // true = Slot đó đã có >= 3 xe

                                        for (int i = 0; i < slots.length; i++) {
                                            boolean isFull = isFullList[i];
                                            // Xử lý logic hiển thị
                                            String labelClass = "relative block ";
                                            String boxClass = "p-3 rounded-xl border text-center transition-all ";

                                            if (isFull) {
                                                // Slot bị kín: Màu đỏ dịu, tắt tương tác
                                                labelClass += "cursor-not-allowed opacity-70";
                                                boxClass += "bg-red-50 border-red-200 text-red-500";
                                            } else {
                                                labelClass += "cursor-pointer group";
                                                boxClass += "bg-white border-slate-200 text-slate-600 hover:border-[#464BE5] peer-checked:bg-[#464BE5] peer-checked:border-[#464BE5] peer-checked:text-white";

                                                if (isPriority && i == 0) {
                                                    // Giả lập UI Slot ưu tiên cho hạng cao
                                                    boxClass = "p-3 rounded-xl text-center transition-all cursor-pointer peer-checked:bg-amber-500 peer-checked:text-white priority-slot text-amber-700 font-bold";
                                                }
                                            }
                                    %>
                                    <label class="<%= labelClass%>">
                                        <input type="radio" name="timeSlot" value="<%= slots[i]%>" class="peer sr-only" <%= isFull ? "disabled" : ""%>>
                                        <div class="<%= boxClass%>">
                                            <span class="text-sm font-semibold"><%= slots[i]%></span>
                                            <% if (isFull) { %>
                                            <div class="text-[10px] uppercase font-bold mt-1">Đã kín (3/3)</div>
                                            <% } else if (isPriority && i == 0) { %>
                                            <div class="text-[10px] uppercase font-bold mt-1"><i class="fa-solid fa-star text-amber-500 peer-checked:text-white"></i> Ưu tiên</div>
                                            <% } else { %>
                                            <div class="text-[10px] text-slate-400 peer-checked:text-blue-100 mt-1">Còn trống</div>
                                            <% } %>
                                        </div>
                                    </label>
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
                                        <span class="font-bold text-slate-800 text-sm" id="summary-vehicle">Honda Civic (51H-123.45)</span>
                                    </div>
                                    <div class="flex justify-between border-b border-slate-200 pb-3">
                                        <span class="text-slate-500 text-sm">Dịch vụ:</span>
                                        <span class="font-bold text-slate-800 text-sm" id="summary-service">Rửa bọt tuyết (150k)</span>
                                    </div>
                                    <div class="flex justify-between">
                                        <span class="text-slate-500 text-sm">Thời gian:</span>
                                        <span class="font-bold text-[#464BE5] text-sm" id="summary-time">Chưa chọn ngày giờ</span>
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
            // Logic điều hướng Step-by-Step
            function goToStep(step) {
                // Ẩn tất cả nội dung bước
                document.querySelectorAll('.step-content').forEach(el => {
                    el.classList.remove('active');
                    setTimeout(() => el.style.display = 'none', 300); // Đợi CSS transition fade out
                });

                // Cập nhật giao diện thanh tiến trình (Progress Bar)
                const progressLineWidths = ['0%', '33%', '66%', '100%'];
                document.getElementById('progress-line').style.width = progressLineWidths[step - 1];

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

                // Cập nhật thông tin Summary nếu đang ở bước 4
                if (step === 4) {
                    updateSummary();
                }

                // Hiện thị bước được gọi
                const targetStep = document.getElementById('step-' + step);
                setTimeout(() => {
                    targetStep.style.display = 'block';
                    // setTimeout lồng nhau để trigger transition sau khi display block
                    setTimeout(() => targetStep.classList.add('active'), 10);
                }, 300);
            }

            // Logic cập nhật thông tin tổng kết (Summary)
            function updateSummary() {
                // Lấy thông tin từ các input radio đã chọn
                const selectedVehicle = document.querySelector('input[name="vehicleId"]:checked');
                const selectedService = document.querySelector('input[name="serviceId"]:checked');
                const date = document.getElementById('bookingDate').value;
                const timeSlot = document.querySelector('input[name="timeSlot"]:checked');

                // Lấy text hiển thị. 
                // Thực tế nên lấy innerText của thẻ label thay vì value, code dưới đây mô phỏng đơn giản.
                if (selectedVehicle) {
                    const label = selectedVehicle.closest('label').querySelector('h4').innerText;
                    document.getElementById('summary-vehicle').innerText = label;
                }
                if (selectedService) {
                    const label = selectedService.closest('label').querySelector('h4').innerText;
                    document.getElementById('summary-service').innerText = label;
                }

                const timeStr = (date ? date + " | " : "") + (timeSlot ? timeSlot.value : "Chưa chọn giờ");
                document.getElementById('summary-time').innerText = timeStr;
            }

            // Xử lý sự kiện Submit Form (NFR-02)
            document.getElementById('bookingForm').addEventListener('submit', function (e) {
                // 1. Chặn submit nhiều lần (Loading state)
                const btnSubmit = document.getElementById('btnSubmit');
                const loadingIcon = document.getElementById('loadingIcon');

                if (btnSubmit.disabled) {
                    e.preventDefault();
                    return;
                } // Nếu đang submit thì không làm gì cả

                btnSubmit.disabled = true;
                btnSubmit.classList.add('opacity-80', 'cursor-not-allowed');
                loadingIcon.classList.remove('hidden');

                // NFR-02: Backend sẽ tiếp nhận xử lý trong thời gian thực.
                // Ở đây là Front-End nên form sẽ tự động gửi qua action url.
            });

            // Gán ngày hiện tại cho date picker và xử lý format
            window.onload = function () {
                const dateInput = document.getElementById('bookingDate');
                const today = new Date();
                const dd = String(today.getDate()).padStart(2, '0');
                const mm = String(today.getMonth() + 1).padStart(2, '0');
                const yyyy = today.getFullYear();
                dateInput.value = yyyy + '-' + mm + '-' + dd;
                dateInput.min = yyyy + '-' + mm + '-' + dd;
            };
        </script>
    </body>
</html>
