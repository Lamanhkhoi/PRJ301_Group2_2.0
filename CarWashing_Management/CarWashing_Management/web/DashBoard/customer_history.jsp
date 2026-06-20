<%@page import="dto.BookingHistory"%>
<%@page import="java.util.List"%>
<%@ include file="../includes/auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Lịch Sử Rửa Xe - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body {
                font-family: 'Inter', sans-serif;
            }</style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">

        <div class="flex h-screen overflow-hidden relative">
            <% request.setAttribute("activeTab", "lichsu"); %>
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-6xl mx-auto">

                        <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8">
                            <div>
                                <h2 class="text-2xl font-bold text-slate-800">Lịch sử rửa xe</h2>
                                <p class="text-sm text-slate-500 mt-1">Xem lại các dịch vụ đã hoàn tất hoặc bị hủy trong quá khứ.</p>
                            </div>

                            <form class="flex items-center bg-white p-1 rounded-xl shadow-sm border border-slate-100">
                                <select class="bg-transparent border-none text-sm font-medium text-slate-600 focus:ring-0 cursor-pointer outline-none px-4 py-2">
                                    <option value="ALL">Tất cả trạng thái</option>
                                    <option value="COMPLETED">Đã hoàn thành</option>
                                    <option value="CANCELLED">Đã hủy</option>
                                    <option value="NO_SHOW">Vắng mặt</option>
                                </select>
                                <div class="w-[1px] h-6 bg-slate-200"></div>
                                <select class="bg-transparent border-none text-sm font-medium text-slate-600 focus:ring-0 cursor-pointer outline-none px-4 py-2">
                                    <option value="30">30 ngày qua</option>
                                    <option value="90">3 tháng qua</option>
                                    <option value="ALL">Từ trước đến nay</option>
                                </select>
                            </form>
                        </div>

                        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">

                            <%
                                List<BookingHistory> historyList = (List<BookingHistory>) request.getAttribute("HISTORY_LIST");

                                if (historyList != null && !historyList.isEmpty()) {

                                    // Viết vòng lặp for của Java
                                    for (BookingHistory item : historyList) {

                                        // Khởi tạo các biến chứa class CSS và Text
                                        String statusText = "";
                                        String statusClass = "";
                                        String statusIcon = "";
                                        String borderColor = "";

                                        // Xử lý logic if-else của Java
                                        String status = item.getStatus();
                                        if ("Completed".equals(status)) {
                                            statusText = "Hoàn thành";
                                            statusClass = "bg-emerald-100 text-emerald-700";
                                            statusIcon = "fa-check-circle";
                                            borderColor = "bg-emerald-400";
                                        } else if ("Cancelled".equals(status)) {
                                            statusText = "Đã hủy";
                                            statusClass = "bg-red-100 text-red-700";
                                            statusIcon = "fa-xmark-circle";
                                            borderColor = "bg-red-400";
                                        } else if ("NoShow".equals(status)) {
                                            statusText = "Vắng mặt";
                                            statusClass = "bg-slate-200 text-slate-600";
                                            statusIcon = "fa-user-slash";
                                            borderColor = "bg-slate-300";
                                        }
                            %>

                            <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm hover:shadow-md transition-shadow relative overflow-hidden group">
                                <div class="absolute left-0 top-0 bottom-0 w-1.5 <%= borderColor %>"></div>

                                <div class="flex justify-between items-start mb-5 pl-2 border-b border-slate-100 pb-4">
                                    <div class="flex items-center gap-4">
                                        <div class="w-14 py-2 rounded-xl bg-slate-50 flex flex-col items-center justify-center border border-slate-200 shadow-sm">
                                            <span class="text-sm font-bold text-slate-800"><%= item.getBookingDate()%></span>
                                            <div class="w-6 h-[1px] bg-slate-200 my-1"></div>
                                            <span class="text-[11px] font-bold text-[#464BE5]"><%= item.getTime()%></span>
                                        </div>
                                        <div>
                                            <h4 class="text-sm font-bold text-slate-800"><%= item.getBrand()%> <%= item.getModel()%></h4>
                                            <p class="text-xs font-semibold text-slate-500 mt-0.5"><i class="fa-solid fa-hashtag text-[10px] mr-1"></i><%= item.getLicensePlate()%></p>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] uppercase font-bold <%= statusClass%>">
                                        <i class="fa-solid <%= statusIcon%>"></i> <%= statusText%>
                                    </div>
                                </div>

                                <div class="pl-2 mb-6">
                                    <div class="flex items-start gap-3 mb-4">
                                        <i class="fa-solid fa-hands-bubbles text-[#464BE5] mt-1"></i>
                                        <div class="flex-1">
                                            <p class="text-xs text-slate-500">Gói dịch vụ</p>
                                            <p class="text-sm font-semibold text-slate-800"><%= item.getServiceName()%></p>
                                        </div>
                                    </div>
                                    <div class="bg-slate-50 rounded-xl p-3 flex justify-between items-center border border-slate-100">
                                        <div>
                                            <p class="text-xs text-slate-500 mb-0.5">Tổng thanh toán</p>
                                            <p class="text-sm font-bold <%= "Completed".equals(status) ? "text-slate-800" : "text-slate-400 line-through"%>"><%= item.getTotalAmount()%> VNĐ</p>
                                        </div>

                                    </div>
                                </div>

                                <div class="pl-2 flex gap-3 pt-4 border-t border-slate-100">
                                    <button type="button" 
                                            onclick="openHistoryModal(this)"
                                            data-date="<%= item.getBookingDate()%>" data-time="<%= item.getTime()%>"
                                            data-plate="<%= item.getLicensePlate()%>" data-brand="<%= item.getBrand()%>"
                                            data-model="<%= item.getModel()%>" data-color="<%= item.getColor()%>"
                                            data-service="<%= item.getServiceName()%>" data-price="<%= item.getTotalAmount()%>" data-points="0"
                                            data-stext="<%= statusText%>" data-sclass="<%= statusClass%>" data-sicon="<%= statusIcon%>"
                                            class="flex-1 px-4 py-2 bg-slate-100 text-slate-600 text-sm font-semibold rounded-xl hover:bg-slate-200 transition">
                                        Xem chi tiết
                                    </button>
                                </div>
                            </div>

                            <%
                                    } 
                                } else { 
                            %>
                            
                                <div class="col-span-1 lg:col-span-2 flex flex-col items-center justify-center py-16 text-slate-400">
                                    <i class="fa-solid fa-clock-rotate-left text-5xl mb-4 text-slate-300"></i>
                                    <p class="text-lg font-medium">Bạn chưa có lịch sử đặt rửa xe nào.</p>
                                </div>

                            <%
                                } 
                            %>
                            
                        </div>
                        <div class="flex items-center justify-between bg-white px-4 py-3 border border-slate-100 rounded-xl shadow-sm">
                            <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
                                <div>
                                    <p class="text-sm text-slate-500">
                                        Hiển thị từ <span class="font-bold text-slate-800">1</span> đến <span class="font-bold text-slate-800">10</span> trong số <span class="font-bold text-slate-800">45</span> kết quả
                                    </p>
                                </div>
                                <div>
                                    <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
                                        <a href="#" class="relative inline-flex items-center rounded-l-md px-2 py-2 text-slate-400 ring-1 ring-inset ring-slate-200 hover:bg-slate-50">
                                            <i class="fa-solid fa-chevron-left h-4 w-4"></i>
                                        </a>
                                        <a href="#" aria-current="page" class="relative z-10 inline-flex items-center bg-[#464BE5] px-4 py-2 text-sm font-semibold text-white">1</a>
                                        <a href="#" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-slate-900 ring-1 ring-inset ring-slate-200 hover:bg-slate-50">2</a>
                                        <a href="#" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-slate-900 ring-1 ring-inset ring-slate-200 hover:bg-slate-50">3</a>
                                        <span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-slate-700 ring-1 ring-inset ring-slate-200">...</span>
                                        <a href="#" class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-slate-900 ring-1 ring-inset ring-slate-200 hover:bg-slate-50">5</a>
                                        <a href="#" class="relative inline-flex items-center rounded-r-md px-2 py-2 text-slate-400 ring-1 ring-inset ring-slate-200 hover:bg-slate-50">
                                            <i class="fa-solid fa-chevron-right h-4 w-4"></i>
                                        </a>
                                    </nav>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <div id="historyModal" class="fixed inset-0 z-[2000] hidden flex items-center justify-center">
            <div id="historyBackdrop" class="absolute inset-0 bg-gray-900 bg-opacity-60 transition-opacity opacity-0" onclick="closeHistoryModal()"></div>

            <div id="historyContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 relative transform scale-95 opacity-0 transition-all duration-300 ease-out z-10 overflow-hidden">
                <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                    <h3 class="font-bold text-slate-800">Chi tiết dịch vụ</h3>
                    <button onclick="closeHistoryModal()" class="text-slate-400 hover:text-slate-600 transition">
                        <i class="fa-solid fa-xmark text-lg"></i>
                    </button>
                </div>

                <div class="p-6">
                    <div class="flex justify-between items-start mb-6">
                        <div>
                            <p class="text-xs text-slate-500 mb-1">Thời gian thực hiện</p>
                            <p class="font-bold text-slate-800"><span id="md-time"></span> - <span id="md-date"></span></p>
                        </div>
                        <div id="md-status-container" class="px-3 py-1.5 rounded-full text-xs font-bold">
                            <i id="md-status-icon" class="fa-solid mr-1"></i> <span id="md-status-text"></span>
                        </div>
                    </div>

                    <div class="w-full border-t border-dashed border-slate-200 my-4"></div>

                    <h4 class="text-xs font-bold text-slate-400 uppercase mb-3">Thông tin phương tiện</h4>
                    <div class="space-y-3 mb-6 bg-slate-50 p-4 rounded-xl border border-slate-100">
                        <div class="flex justify-between">
                            <span class="text-sm text-slate-500">Hãng & Dòng xe:</span>
                            <span id="md-brand-model" class="text-sm font-bold text-slate-800 text-right"></span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-sm text-slate-500">Biển số xe:</span>
                            <span id="md-plate" class="text-sm font-bold text-slate-800 text-right"></span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-sm text-slate-500">Màu sắc:</span>
                            <span id="md-color" class="text-sm font-bold text-slate-800 text-right"></span>
                        </div>
                    </div>

                    <h4 class="text-xs font-bold text-slate-400 uppercase mb-3">Dịch vụ sử dụng</h4>
                    <div class="space-y-4 mb-6">
                        <div class="flex justify-between">
                            <span class="text-sm text-slate-500">Gói đã chọn:</span>
                            <span id="md-service" class="text-sm font-semibold text-[#464BE5] text-right"></span>
                        </div>
                    </div>

                    <div class="bg-blue-50/50 rounded-xl p-4 border border-blue-100">
                        <div class="flex justify-between items-center mb-2">
                            <span class="text-sm font-bold text-slate-700">Tổng thanh toán:</span>
                            <span id="md-price" class="text-lg font-bold text-[#464BE5]"></span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-xs text-slate-500">Điểm thưởng tích lũy:</span>
                            <span id="md-points" class="text-sm font-bold text-amber-500"><i class="fa-solid fa-coins mr-1 text-xs"></i></span>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        
        <script>
            function openHistoryModal(button) {
                const date = button.getAttribute('data-date');
                const time = button.getAttribute('data-time');
                const plate = button.getAttribute('data-plate');
                const brand = button.getAttribute('data-brand');
                const model = button.getAttribute('data-model');
                const color = button.getAttribute('data-color');
                const service = button.getAttribute('data-service');
                const price = button.getAttribute('data-price');
                const points = button.getAttribute('data-points');
                const sText = button.getAttribute('data-stext');
                const sClass = button.getAttribute('data-sclass');
                const sIcon = button.getAttribute('data-sicon');

                // Bơm dữ liệu vào Modal
                document.getElementById('md-date').innerText = date;
                document.getElementById('md-time').innerText = time;
                document.getElementById('md-brand-model').innerText = brand + ' ' + model;
                document.getElementById('md-plate').innerText = plate;
                document.getElementById('md-color').innerText = color;
                document.getElementById('md-service').innerText = service;
                document.getElementById('md-price').innerText = price;
                document.getElementById('md-points').innerHTML = '<i class="fa-solid fa-coins mr-1 text-xs"></i>' + points;

                const statusContainer = document.getElementById('md-status-container');
                statusContainer.className = "px-3 py-1.5 rounded-full text-xs font-bold " + sClass;
                document.getElementById('md-status-icon').className = "fa-solid mr-1 " + sIcon;
                document.getElementById('md-status-text').innerText = sText;

                // Hiển thị Modal
                const modal = document.getElementById('historyModal');
                const backdrop = document.getElementById('historyBackdrop');
                const content = document.getElementById('historyContent');

                modal.classList.remove('hidden');
                setTimeout(() => {
                    backdrop.classList.remove('opacity-0');
                    content.classList.remove('opacity-0', 'scale-95');
                }, 10);
            }

            function closeHistoryModal() {
                const modal = document.getElementById('historyModal');
                const backdrop = document.getElementById('historyBackdrop');
                const content = document.getElementById('historyContent');

                backdrop.classList.add('opacity-0');
                content.classList.add('opacity-0', 'scale-95');

                setTimeout(() => {
                    modal.classList.add('hidden');
                }, 300);
            }
        </script>

    </body>
</html>