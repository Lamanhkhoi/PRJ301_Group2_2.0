<%-- 
    Document   : customer_upcoming.jsp
    Created on : Jun 9, 2026, 11:30:16 PM
    Author     : Admin
--%>

<%@ include file="../includes/auth-check.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Lịch Đã Hẹn - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">

        <div class="flex h-screen overflow-hidden relative">
            <% request.setAttribute("activeTab", "lichdahen"); %>
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-5xl mx-auto">
                        
                        <div class="mb-8">
                            <h2 class="text-2xl font-bold text-slate-800">Lịch đã hẹn & Đang xử lý</h2>
                            <p class="text-sm text-slate-500 mt-1">Theo dõi tiến trình rửa xe của bạn theo thời gian thực.</p>
                        </div>

                        <div class="flex flex-col gap-6">
                            
                            <% 
                                // [MOCK DATA] Đã thay đổi data mồi cho phù hợp với UI tối giản
                                String[][] mockActive = {
                                    {"14/06/2026", "09:00", "51H-123.45", "Honda Civic", "Combo Phủ Sáp", "PENDING", "true"},
                                    {"10/06/2026", "14:30", "51G-987.65", "Mazda 3", "Rửa tiêu chuẩn", "PENDING", "false"},
                                    {"09/06/2026", "10:00", "51A-555.55", "Toyota Camry", "Rửa VIP", "WAITING", "false"}
                                };

                                for(int idx = 0; idx < mockActive.length; idx++) {
                                    String[] item = mockActive[idx];
                                    String date = item[0]; String time = item[1];
                                    String plate = item[2]; String car = item[3];
                                    String service = item[4]; String status = item[5];
                                    boolean canCancel = Boolean.parseBoolean(item[6]);

                                    int currentStep = 1;
                                    if(status.equals("CHECKED_IN")) currentStep = 2;
                                    if(status.equals("WAITING")) currentStep = 3;
                                    if(status.equals("WASHING")) currentStep = 4;
                            %>

                            <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm relative">
                                <div class="flex flex-col md:flex-row gap-6">
                                    
                                    <div class="md:w-1/3 border-b md:border-b-0 md:border-r border-slate-100 pr-6 pb-4 md:pb-0">
                                        <div class="flex items-center gap-3 mb-4">
                                            <div class="w-12 py-2 rounded-xl bg-slate-50 flex flex-col items-center justify-center border border-slate-200">
                                                <span class="text-xs font-bold text-slate-800"><%= date.substring(0, 5) %></span>
                                                <div class="w-8 h-[1px] bg-slate-200 my-1"></div>
                                                <span class="text-xs font-bold text-[#464BE5]"><%= time %></span>
                                            </div>
                                            <div>
                                                <h4 class="text-base font-bold text-slate-800"><%= car %></h4>
                                                <p class="text-xs font-semibold text-slate-500 mt-0.5"><i class="fa-solid fa-hashtag text-[10px] mr-1"></i><%= plate %></p>
                                            </div>
                                        </div>
                                        <div class="bg-slate-50 p-3 rounded-xl border border-slate-100">
                                            <p class="text-xs text-slate-500 mb-1">Gói dịch vụ</p>
                                            <p class="text-sm font-semibold text-slate-800"><i class="fa-solid fa-hands-bubbles text-[#464BE5] mr-1.5"></i><%= service %></p>
                                        </div>
                                    </div>

                                    <div class="md:w-2/3 flex flex-col justify-between">
                                        
                                        <div class="relative mb-6">
                                            <div class="absolute top-5 left-8 right-8 -translate-y-1/2 z-0">
                                                <div class="absolute left-0 top-0 w-full h-1 bg-slate-100 rounded-full"></div>
                                                <div class="absolute left-0 top-0 h-1 bg-[#464BE5] rounded-full transition-all duration-500" style="width: <%= (currentStep-1)*33.33 %>%"></div>
                                            </div>
                                            
                                            <div class="relative z-10 flex justify-between pt-2">
                                                <div class="flex flex-col items-center w-16">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 1 ? "bg-[#464BE5] text-white" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-calendar-check"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 text-center <%= currentStep >= 1 ? "text-[#464BE5]" : "text-slate-400" %>">CHỜ<br>XÁC NHẬN</span>
                                                </div>
                                                <div class="flex flex-col items-center w-16">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 2 ? "bg-[#464BE5] text-white" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-clipboard-user"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 text-center <%= currentStep >= 2 ? "text-[#464BE5]" : "text-slate-400" %>">ĐÃ ĐẾN<br>TIỆM</span>
                                                </div>
                                                <div class="flex flex-col items-center w-16">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 3 ? "bg-amber-500 text-white" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-hourglass-half"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 text-center <%= currentStep >= 3 ? "text-amber-600" : "text-slate-400" %>">CHỜ TỚI<br>LƯỢT</span>
                                                </div>
                                                <div class="flex flex-col items-center w-16">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 4 ? "bg-purple-500 text-white" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-shower"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 text-center <%= currentStep >= 4 ? "text-purple-600" : "text-slate-400" %>">ĐANG<br>RỬA</span>
                                                </div>
                                            </div>
                                        </div>

                                        <% if(status.equals("PENDING")) { %>
                                            <% if(canCancel) { %>
                                                <div class="flex justify-end">
                                                    <button onclick="openConfirmModal('<%= date %> <%= time %>')" class="px-5 py-2.5 rounded-xl text-sm font-bold text-red-500 bg-red-50 hover:bg-red-500 hover:text-white transition-colors border border-red-100 shadow-sm">
                                                        <i class="fa-solid fa-trash-can mr-1"></i> Hủy lịch hẹn
                                                    </button>
                                                </div>
                                            <% } else { %>
                                                <div class="flex justify-end items-center gap-3">
                                                    <span class="text-[11px] font-semibold text-red-500"><i class="fa-solid fa-circle-info mr-1"></i>Không thể hủy do < 24h</span>
                                                    <button disabled class="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-400 bg-slate-100 border border-slate-200 cursor-not-allowed">
                                                        <i class="fa-solid fa-trash-can mr-1"></i> Hủy lịch hẹn
                                                    </button>
                                                </div>
                                            <% } %>
                                        <% } else { %>
                                            <div class="bg-slate-50 rounded-xl p-2.5 text-center border border-slate-100">
                                                <p class="text-xs font-semibold text-slate-500"><i class="fa-solid fa-lock text-slate-400 mr-1"></i> Xe đang trong tiến trình xử lý, không thể thao tác.</p>
                                            </div>
                                        <% } %>

                                    </div>
                                </div>
                            </div>
                            
                            <% } %>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <div id="confirmModal" class="fixed inset-0 z-[2000] hidden flex items-center justify-center">
            <div id="confirmBackdrop" class="absolute inset-0 bg-gray-900 bg-opacity-60 transition-opacity opacity-0" onclick="closeConfirmModal()"></div>
            
            <div id="confirmContent" class="bg-white rounded-3xl shadow-2xl w-full max-w-sm mx-4 p-6 relative transform scale-95 opacity-0 transition-all duration-300 ease-out z-10 text-center">
                <div class="w-16 h-16 bg-red-100 text-red-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <h3 class="text-lg font-bold text-slate-800 mb-2">Xác nhận hủy lịch</h3>
                <p class="text-sm text-slate-500 mb-6">Bạn có chắc chắn muốn hủy lịch hẹn lúc <strong id="cancelTimeTarget" class="text-slate-700"></strong> không? Hành động này không thể hoàn tác.</p>
                
                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" class="flex-1 px-4 py-2.5 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition">Giữ lại</button>
                    <form action="MainController?action=cancelBooking" method="POST" class="flex-1">
                        <input type="hidden" name="bookingId" id="cancelBookingId" value="">
                        <button type="submit" class="w-full px-4 py-2.5 bg-red-500 text-white font-bold rounded-xl hover:bg-red-600 transition shadow-md shadow-red-500/30">Hủy lịch</button>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function openConfirmModal(timeTarget) {
                document.getElementById('cancelTimeTarget').innerText = timeTarget;
                
                const modal = document.getElementById('confirmModal');
                const backdrop = document.getElementById('confirmBackdrop');
                const content = document.getElementById('confirmContent');
                
                modal.classList.remove('hidden');
                setTimeout(() => {
                    backdrop.classList.remove('opacity-0');
                    content.classList.remove('opacity-0', 'scale-95');
                }, 10);
            }

            function closeConfirmModal() {
                const modal = document.getElementById('confirmModal');
                const backdrop = document.getElementById('confirmBackdrop');
                const content = document.getElementById('confirmContent');
                
                backdrop.classList.add('opacity-0');
                content.classList.add('opacity-0', 'scale-95');
                setTimeout(() => { modal.classList.add('hidden'); }, 300);
            }
        </script>
    </body>
</html>
