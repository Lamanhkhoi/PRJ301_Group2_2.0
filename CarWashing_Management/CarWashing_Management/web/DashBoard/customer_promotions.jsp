<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: ƯU ĐÃI (Customer) - customer_promotions.jsp
    Bố cục: Header (hạng + điểm) -> Carousel banner khuyến mãi -> Đổi điểm nhận voucher (preview)
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include auth-check bên dưới khi gắn Controller.
      2. Thay toàn bộ khối MOCK DATA bằng dữ liệu thật:
         - promos    -> List<Promotion> (DTO Promotion tạo sau khi DB mới xong)
         - rewards   -> RewardDAO.getActiveRewards() (lấy 4 cái nổi bật)
         - loyalty   -> CustomerLoyaltyDAO.getLoyaltyProfileByAccountId(...)
      3. Đổi link "Xem tất cả" và sidebar sang MainController?action=... khi có action.
    ============================================================
--%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_TAB", "uudai");

    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    // Banner khuyến mãi do Admin tạo: {Tên, Mô tả, Thời gian, Hạng áp dụng, class màu nền}
    String[][] promos = {
        {"GIẢM 20% MÙA HÈ", "Áp dụng mọi gói rửa xe cho khách hạng Bạc trở lên", "01/07 - 31/07/2026", "Silver+", "from-emerald-600 to-teal-500"},
        {"COMBO RỬA + WAX -15%", "Đặt combo trong tuần lễ vàng, áp dụng mọi hạng", "10/07 - 20/07/2026", "Tất cả", "from-blue-700 to-indigo-500"},
        {"TẶNG 50 ĐIỂM SINH NHẬT", "Quà sinh nhật dành riêng cho khách hạng Vàng trở lên", "Cả năm 2026", "Gold+", "from-amber-500 to-orange-500"}
    };
    // Reward nổi bật: {Tên, Điểm cần, Hạn đổi, icon FontAwesome}
    String[][] hotRewards = {
        {"Phiếu mua hàng 20.000 VNĐ", "2000", "31/07/2026", "fa-ticket"},
        {"Phiếu mua hàng 10.000 VNĐ", "1000", "31/07/2026", "fa-ticket"},
        {"Miễn phí wax xe", "300", "31/08/2026", "fa-spray-can-sparkles"},
        {"Nâng cấp gói Deluxe", "3000", "30/09/2026", "fa-arrow-up-right-dots"}
    };
    int currentPoints = 1250;          // loyalty.getCurrentPoints()
    String currentTierName = "Bạc";    // loyalty.getCurrentTierDetails().getTierName()
    // ====================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Ưu Đãi - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; }
            .scrollbar-hide::-webkit-scrollbar { display: none; }
            .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="../includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-7xl mx-auto">

                        <%-- ===== HEADER: tiêu đề + badge hạng + điểm ===== --%>
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-800">Ưu Đãi &amp; Đặc Quyền</h1>
                                <p class="text-sm text-slate-500 mt-1">Khuyến mãi đang diễn ra và quà đổi điểm dành cho bạn</p>
                            </div>
                            <div class="flex items-center gap-3">
                                <span class="inline-flex items-center gap-2 bg-white border border-slate-200 rounded-full px-4 py-2 text-sm font-medium text-slate-700 shadow-sm">
                                    <i class="fa-solid fa-shield-halved text-slate-400"></i> Thành viên <%= currentTierName %>
                                </span>
                                <a href="<%=request.getContextPath()%>/DashBoard/customer_loyalty.jsp"
                                   class="inline-flex items-center gap-2 bg-amber-100 hover:bg-amber-200 transition rounded-full px-4 py-2 text-sm font-bold text-amber-700 shadow-sm">
                                    <i class="fa-solid fa-coins"></i> <%= String.format("%,d", currentPoints) %> P
                                </a>
                            </div>
                        </div>

                        <%-- ===== SECTION 1: CAROUSEL BANNER KHUYẾN MÃI ===== --%>
                        <div class="flex items-center gap-2 mb-3">
                            <i class="fa-solid fa-gift text-emerald-500"></i>
                            <h2 class="text-lg font-bold text-slate-800">Ưu đãi đỉnh cao</h2>
                        </div>

                        <div id="promoCarousel" class="flex gap-4 overflow-x-auto scrollbar-hide snap-x snap-mandatory scroll-smooth pb-2">
                            <% for (int i = 0; i < promos.length; i++) { %>
                            <div class="snap-start shrink-0 w-full md:w-[calc(100%-6rem)] lg:w-[720px]">
                                <%-- TODO BACKEND: thay div gradient bằng <img src banner của Promotion> nếu Admin có upload ảnh --%>
                                <div class="relative h-52 rounded-2xl bg-gradient-to-r <%= promos[i][4] %> text-white p-8 flex flex-col justify-between overflow-hidden shadow-md">
                                    <i class="fa-solid fa-car-side absolute -right-6 -bottom-6 text-[10rem] opacity-10"></i>
                                    <div>
                                        <span class="inline-block bg-white/20 backdrop-blur-sm text-xs font-bold px-3 py-1 rounded-full mb-3">
                                            <i class="fa-solid fa-users mr-1"></i> Áp dụng: <%= promos[i][3] %>
                                        </span>
                                        <h3 class="text-3xl font-extrabold tracking-tight"><%= promos[i][0] %></h3>
                                        <p class="text-white/80 mt-2 text-sm max-w-md"><%= promos[i][1] %></p>
                                    </div>
                                    <p class="text-xs font-semibold text-white/90"><i class="fa-regular fa-clock mr-1"></i> <%= promos[i][2] %></p>
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <%-- Chấm điều hướng carousel --%>
                        <div class="flex justify-center gap-2 mt-3 mb-10" id="promoDots">
                            <% for (int i = 0; i < promos.length; i++) { %>
                            <button onclick="scrollToPromo(<%= i %>)" data-dot="<%= i %>"
                                    class="promo-dot h-1.5 rounded-full transition-all duration-300 <%= i == 0 ? "w-6 bg-emerald-500" : "w-2.5 bg-slate-300 hover:bg-slate-400" %>"></button>
                            <% } %>
                        </div>

                        <%-- ===== SECTION 2: ĐỔI ĐIỂM NHẬN VOUCHER (PREVIEW) ===== --%>
                        <div class="flex items-center justify-between mb-4">
                            <div class="flex items-center gap-2">
                                <i class="fa-solid fa-hand-holding-heart text-emerald-500"></i>
                                <h2 class="text-lg font-bold text-slate-800">Đổi điểm nhận voucher</h2>
                            </div>
                            <a href="<%=request.getContextPath()%>/DashBoard/customer_rewards.jsp"
                               class="text-sm font-semibold text-emerald-600 hover:text-emerald-700 transition">
                                Xem tất cả <i class="fa-solid fa-arrow-right ml-1"></i>
                            </a>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                            <% for (String[] r : hotRewards) {
                                int cost = Integer.parseInt(r[1]);
                                boolean enough = currentPoints >= cost;
                            %>
                            <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-4 flex flex-col transition hover:shadow-md <%= enough ? "" : "opacity-60" %>">
                                <div class="h-24 rounded-xl bg-slate-100 flex items-center justify-center mb-3">
                                    <i class="fa-solid <%= r[3] %> text-3xl text-slate-400"></i>
                                </div>
                                <span class="self-start inline-flex items-center gap-1 bg-amber-100 text-amber-700 text-xs font-bold px-2.5 py-1 rounded-full mb-2">
                                    <i class="fa-solid fa-coins"></i> <%= String.format("%,d", cost) %> P
                                </span>
                                <p class="font-semibold text-slate-800 text-sm leading-snug"><%= r[0] %></p>
                                <p class="text-xs mt-1 mb-3 <%= enough ? "text-emerald-600" : "text-red-500 font-medium" %>">
                                    <%= enough ? "Hạn đổi " + r[2] : "Thiếu " + String.format("%,d", (cost - currentPoints)) + " P" %>
                                </p>
                                <a href="<%=request.getContextPath()%>/DashBoard/customer_rewards.jsp"
                                   class="mt-auto text-center text-sm font-bold rounded-xl py-2 transition <%= enough ? "bg-emerald-500 hover:bg-emerald-600 text-white" : "bg-slate-100 text-slate-400 cursor-not-allowed pointer-events-none" %>">
                                    Đổi ngay
                                </a>
                            </div>
                            <% } %>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <script>
            // Carousel: cập nhật chấm theo vị trí cuộn + cho phép bấm chấm để nhảy banner
            const carousel = document.getElementById('promoCarousel');
            const dots = document.querySelectorAll('.promo-dot');

            function scrollToPromo(i) {
                const item = carousel.children[i];
                if (item) carousel.scrollTo({ left: item.offsetLeft - carousel.offsetLeft, behavior: 'smooth' });
            }

            carousel.addEventListener('scroll', () => {
                let idx = 0, min = Infinity;
                [...carousel.children].forEach((el, i) => {
                    const d = Math.abs(el.offsetLeft - carousel.offsetLeft - carousel.scrollLeft);
                    if (d < min) { min = d; idx = i; }
                });
                dots.forEach((dot, i) => {
                    dot.className = 'promo-dot h-1.5 rounded-full transition-all duration-300 ' +
                        (i === idx ? 'w-6 bg-emerald-500' : 'w-2.5 bg-slate-300 hover:bg-slate-400');
                });
            });

            // Tự động trượt banner mỗi 5 giây
            let autoIdx = 0;
            setInterval(() => {
                autoIdx = (autoIdx + 1) % <%= promos.length %>;
                scrollToPromo(autoIdx);
            }, 5000);
        </script>
    </body>
</html>
