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
        <style>
            body { font-family: 'Inter', sans-serif; }
            
            /* --- CSS BỌT NƯỚC RỬA XE VUI NHỘN --- */
            .soap-water-container {
                position: relative;
                overflow: hidden;
                background: linear-gradient(180deg, #e0f2fe 0%, #bae6fd 100%);
            }
            .bubble {
                position: absolute;
                background: rgba(255, 255, 255, 0.7);
                border-radius: 50%;
                animation: floatUp infinite ease-in;
            }
            .bubble-1 { width: 25px; height: 25px; left: 15%; bottom: -30px; animation-duration: 2.5s; }
            .bubble-2 { width: 15px; height: 15px; left: 40%; bottom: -20px; animation-duration: 3s; animation-delay: 0.5s; }
            .bubble-3 { width: 35px; height: 35px; left: 70%; bottom: -40px; animation-duration: 4s; animation-delay: 1s; }
            .bubble-4 { width: 10px; height: 10px; left: 85%; bottom: -15px; animation-duration: 2s; animation-delay: 0.2s; }
            
            @keyframes floatUp {
                0% { transform: translateY(0) translateX(0) scale(1); opacity: 1; }
                50% { transform: translateY(-40px) translateX(10px) scale(1.1); }
                100% { transform: translateY(-80px) translateX(-10px) scale(1.3); opacity: 0; }
            }

            /* --- HIỆU ỨNG NÚT BỎ CHẠY --- */
            .runaway-btn {
                transition: transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1); /* Nảy nhẹ khi di chuyển */
                z-index: 10;
            }

            /* --- KHUNG PHÁT SÁNG CHO PRIORITY QUEUE --- */
            .glowing-frame {
                border: 2px solid #FBBF24 !important;
                box-shadow: 0 0 20px rgba(251, 191, 36, 0.4), inset 0 0 10px rgba(251, 191, 36, 0.1);
                animation: pulseGlow 2s infinite;
            }
            @keyframes pulseGlow {
                0% { box-shadow: 0 0 15px rgba(251, 191, 36, 0.3); }
                50% { box-shadow: 0 0 25px rgba(251, 191, 36, 0.6); }
                100% { box-shadow: 0 0 15px rgba(251, 191, 36, 0.3); }
            }
        </style>
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
                                // [MOCK DATA] 3 Kịch bản để test 3 tính năng của bạn:
                                // 1: PENDING, còn hơn 1 ngày (>24h) -> Hủy bình thường.
                                // 2: PENDING, sát giờ (<24h) -> Nút hủy trêu ngươi + bọt nước.
                                // 3: WAITING -> Có khung phát sáng đặc biệt (Priority Queue).
                                
                                String[][] mockActive = {
                                    {"14/06/2026", "09:00", "51H-123.45", "Honda Civic", "Combo Phủ Sáp", "PENDING", "true"},  // true = Hủy bình thường
                                    {"10/06/2026", "14:30", "51G-987.65", "Mazda 3", "Rửa tiêu chuẩn", "PENDING", "false"}, // false = Dưới 24h, Nút bỏ chạy
                                    {"09/06/2026", "10:00", "51A-555.55", "Toyota Camry", "Rửa VIP", "WAITING", "false"}    // Đang chờ xếp lốt
                                };

                                for(int idx = 0; idx < mockActive.length; idx++) {
                                    String[] item = mockActive[idx];
                                    String date = item[0]; String time = item[1];
                                    String plate = item[2]; String car = item[3];
                                    String service = item[4]; String status = item[5];
                                    boolean canCancel = Boolean.parseBoolean(item[6]);

                                    // Thiết lập bước hiện tại cho Thanh Tiến Trình (Mini Stepper)
                                    int currentStep = 1;
                                    if(status.equals("CHECKED_IN")) currentStep = 2;
                                    if(status.equals("WAITING")) currentStep = 3;
                                    if(status.equals("WASHING")) currentStep = 4;
                            %>

                            <div class="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm relative <%= status.equals("WAITING") ? "glowing-frame" : "" %>">
                                
                                <% if(status.equals("WAITING")) { %>
                                    <div class="absolute -top-3 right-6 bg-amber-500 text-white text-[10px] font-bold uppercase px-3 py-1 rounded-full shadow-md animate-bounce">
                                        <i class="fa-solid fa-star mr-1"></i> Ưu tiên cao
                                    </div>
                                <% } %>

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
                                        
                                        <div class="relative pt-2 mb-6">
                                            <div class="absolute top-1/2 left-0 w-full h-1 bg-slate-100 -translate-y-1/2 rounded-full z-0"></div>
                                            <div class="absolute top-1/2 left-0 h-1 bg-[#464BE5] -translate-y-1/2 rounded-full z-0 transition-all duration-500" style="width: <%= (currentStep-1)*33.33 %>%"></div>
                                            
                                            <div class="relative z-10 flex justify-between">
                                                <div class="flex flex-col items-center">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 1 ? "bg-[#464BE5] text-white ring-4 ring-blue-50" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-calendar-check"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 <%= currentStep >= 1 ? "text-[#464BE5]" : "text-slate-400" %>">CHỜ XÁC NHẬN</span>
                                                </div>
                                                <div class="flex flex-col items-center">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 2 ? "bg-[#464BE5] text-white ring-4 ring-blue-50" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-clipboard-user"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 <%= currentStep >= 2 ? "text-[#464BE5]" : "text-slate-400" %>">ĐÃ ĐẾN TIỆM</span>
                                                </div>
                                                <div class="flex flex-col items-center">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 3 ? "bg-amber-500 text-white ring-4 ring-amber-50" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-hourglass-half"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 <%= currentStep >= 3 ? "text-amber-600" : "text-slate-400" %>">CHỜ XẾP LỐT</span>
                                                </div>
                                                <div class="flex flex-col items-center">
                                                    <div class="w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold <%= currentStep >= 4 ? "bg-purple-500 text-white ring-4 ring-purple-50" : "bg-slate-200 text-slate-400" %>"><i class="fa-solid fa-shower"></i></div>
                                                    <span class="text-[10px] font-bold mt-2 <%= currentStep >= 4 ? "text-purple-600" : "text-slate-400" %>">ĐANG RỬA</span>
                                                </div>
                                            </div>
                                        </div>

                                        <% if(status.equals("PENDING")) { %>
                                            <% if(canCancel) { %>
                                                <div class="flex justify-end">
                                                    <button onclick="openConfirmModal('<%= date %> <%= time %>')" class="px-5 py-2 rounded-xl text-sm font-bold text-red-500 bg-red-50 hover:bg-red-500 hover:text-white transition-colors border border-red-100">
                                                        <i class="fa-solid fa-trash-can mr-1"></i> Hủy lịch hẹn
                                                    </button>
                                                </div>
                                            <% } else { %>
                                                <div class="soap-water-container h-14 rounded-xl border border-sky-200 flex items-center justify-center shadow-inner group">
                                                    <div class="bubble bubble-1"></div>
                                                    <div class="bubble bubble-2"></div>
                                                    <div class="bubble bubble-3"></div>
                                                    <div class="bubble bubble-4"></div>
                                                    
                                                    <span class="absolute text-[11px] font-semibold text-sky-800 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                                                        Không thể hủy lịch do còn dưới 24h!
                                                    </span>

                                                    <button onmouseover="runAwayButton(this)" class="runaway-btn absolute px-5 py-1.5 rounded-lg text-sm font-bold bg-slate-400 text-white shadow cursor-not-allowed">
                                                        <i class="fa-solid fa-xmark mr-1"></i> Hủy lịch
                                                    </button>
                                                </div>
                                            <% } %>
                                        <% } else { %>
                                            <div class="bg-slate-50 rounded-xl p-2.5 text-center border border-slate-100">
                                                <p class="text-xs font-semibold text-slate-500"><i class="fa-solid fa-lock text-slate-400 mr-1"></i> Xe đang trong tiến trình xử lý, không thể hủy lịch lúc này.</p>
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
            // 1. LOGIC NÚT BỎ CHẠY TRONG BỌT NƯỚC VUI NHỘN
            function runAwayButton(btn) {
                // Kích thước của vùng nước chứa nút
                const containerWidth = 250; // Ước chừng theo UI
                const containerHeight = 40; 
                
                // Random tọa độ X, Y trong một khoảng ngắn để nút nảy tưng tưng
                const randomX = (Math.random() - 0.5) * 180; // Dịch trái phải
                const randomY = (Math.random() - 0.5) * 20;  // Dịch lên xuống

                // Áp dụng CSS transform để nút bay đi chỗ khác
                btn.style.transform = `translate(${randomX}px, ${randomY}px)`;
            }

            // 2. LOGIC MODAL XÁC NHẬN HỦY BÌNH THƯỜNG
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
