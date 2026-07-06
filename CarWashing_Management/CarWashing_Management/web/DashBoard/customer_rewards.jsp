<%@page import="java.util.*"%>
<%@page import="dto.Reward"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: ĐỔI THƯỞNG (Customer) - customer_rewards.jsp
    Vào từ: nút "Xem tất cả" ở trang Ưu Đãi + nút "Đổi thưởng" trên thẻ thành viên
    (trang này KHÔNG có mục sidebar riêng theo quyết định của nhóm)
    Bố cục: Thanh điểm hiện có -> Filter theo loại -> Lưới card reward -> Modal xác nhận đổi
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include auth-check bên dưới khi gắn Controller.
      2. Thay MOCK DATA: rewards -> RewardDAO.getActiveRewards(); currentPoints -> loyalty.
      3. Nút "Xác nhận đổi" trong modal: submit form POST tới Controller đổi thưởng,
         backend trừ điểm + sinh mã voucher rồi redirect qua customer_vouchers.jsp.
    ============================================================
--%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_TAB", "uudai");

    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    int currentPoints = 1250; // loyalty.getCurrentPoints()

    List<Reward> rewards = new ArrayList<>();
    // Dùng đúng DTO Reward có sẵn của project cho đồng bộ (rewardType: DISCOUNT / FREE_SERVICE / GIFT)
    String[][] seed = {
        // {id, tên, mô tả, điểm cần, loại, giá trị giảm}
        {"1", "Phiếu mua hàng 10.000 VNĐ", "Trừ trực tiếp vào hóa đơn rửa xe bất kỳ", "1000", "DISCOUNT", "10000"},
        {"2", "Phiếu mua hàng 20.000 VNĐ", "Trừ trực tiếp vào hóa đơn rửa xe bất kỳ", "2000", "DISCOUNT", "20000"},
        {"3", "Miễn phí wax xe", "Tặng 1 lần wax bóng thân xe kèm gói rửa", "300", "FREE_SERVICE", "0"},
        {"4", "Nâng cấp gói Deluxe", "Nâng miễn phí từ gói Basic lên Deluxe", "3000", "FREE_SERVICE", "0"},
        {"5", "Rửa xe miễn phí gói Basic", "1 lần rửa xe Basic hoàn toàn miễn phí", "5000", "FREE_SERVICE", "0"},
        {"6", "Bình nước giữ nhiệt SmartWash", "Quà tặng thương hiệu, nhận tại quầy", "1500", "GIFT", "0"}
    };
    for (String[] s : seed) {
        Reward r = new Reward();
        r.setRewardId(Integer.parseInt(s[0]));
        r.setRewardName(s[1]);
        r.setDescription(s[2]);
        r.setRequiredPoints(Integer.parseInt(s[3]));
        r.setRewardType(s[4]);
        r.setDiscount(Integer.parseInt(s[5]));
        r.setIsActive(true);
        rewards.add(r);
    }
    // ====================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đổi Thưởng - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="../includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-7xl mx-auto">

                        <%-- ===== HEADER + ĐIỂM HIỆN CÓ ===== --%>
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <a href="<%=request.getContextPath()%>/DashBoard/customer_promotions.jsp" class="text-sm text-slate-400 hover:text-emerald-600 transition">
                                    <i class="fa-solid fa-arrow-left mr-1"></i> Ưu Đãi
                                </a>
                                <h1 class="text-2xl font-bold text-slate-800 mt-1">Đổi Điểm Nhận Thưởng</h1>
                            </div>
                            <div class="inline-flex items-center gap-2 bg-amber-100 rounded-full px-5 py-2.5 text-amber-700 font-bold shadow-sm">
                                <i class="fa-solid fa-coins"></i> Bạn đang có <span id="pointDisplay"><%= String.format("%,d", currentPoints) %></span> P
                            </div>
                        </div>

                        <%-- ===== FILTER THEO LOẠI REWARD ===== --%>
                        <div class="flex flex-wrap gap-2 mb-6" id="typeFilter">
                            <button data-filter="ALL" class="type-chip px-4 py-2 rounded-xl text-sm font-semibold transition bg-emerald-500 text-white shadow-sm">Tất cả</button>
                            <button data-filter="DISCOUNT" class="type-chip px-4 py-2 rounded-xl text-sm font-semibold transition bg-white border border-slate-200 text-slate-600 hover:border-emerald-400"><i class="fa-solid fa-ticket mr-1.5"></i>Giảm giá</button>
                            <button data-filter="FREE_SERVICE" class="type-chip px-4 py-2 rounded-xl text-sm font-semibold transition bg-white border border-slate-200 text-slate-600 hover:border-emerald-400"><i class="fa-solid fa-spray-can-sparkles mr-1.5"></i>Dịch vụ miễn phí</button>
                            <button data-filter="GIFT" class="type-chip px-4 py-2 rounded-xl text-sm font-semibold transition bg-white border border-slate-200 text-slate-600 hover:border-emerald-400"><i class="fa-solid fa-gift mr-1.5"></i>Quà tặng</button>
                        </div>

                        <%-- ===== LƯỚI CARD REWARD ===== --%>
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6" id="rewardGrid">
                            <% for (Reward r : rewards) {
                                boolean enough = currentPoints >= r.getRequiredPoints();
                                String typeIcon = "DISCOUNT".equals(r.getRewardType()) ? "fa-ticket"
                                                : "GIFT".equals(r.getRewardType()) ? "fa-gift" : "fa-spray-can-sparkles";
                                String typeLabel = "DISCOUNT".equals(r.getRewardType()) ? "Giảm giá"
                                                 : "GIFT".equals(r.getRewardType()) ? "Quà tặng" : "Dịch vụ miễn phí";
                                String typeBadge = "DISCOUNT".equals(r.getRewardType()) ? "bg-blue-100 text-blue-700"
                                                 : "GIFT".equals(r.getRewardType()) ? "bg-pink-100 text-pink-700" : "bg-purple-100 text-purple-700";
                            %>
                            <div class="reward-card bg-white rounded-2xl border border-slate-200 shadow-sm p-5 flex flex-col transition hover:shadow-md <%= enough ? "" : "opacity-60" %>"
                                 data-type="<%= r.getRewardType() %>">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="w-14 h-14 rounded-2xl bg-slate-100 flex items-center justify-center">
                                        <i class="fa-solid <%= typeIcon %> text-2xl text-slate-400"></i>
                                    </div>
                                    <span class="text-xs font-bold px-2.5 py-1 rounded-full <%= typeBadge %>"><%= typeLabel %></span>
                                </div>
                                <h3 class="font-bold text-slate-800"><%= r.getRewardName() %></h3>
                                <p class="text-sm text-slate-500 mt-1 mb-4"><%= r.getDescription() %></p>
                                <div class="mt-auto flex items-center justify-between">
                                    <span class="inline-flex items-center gap-1.5 text-amber-600 font-extrabold">
                                        <i class="fa-solid fa-coins"></i> <%= String.format("%,d", r.getRequiredPoints()) %> P
                                    </span>
                                    <% if (enough) { %>
                                    <button onclick="openRedeemModal('<%= r.getRewardName() %>', <%= r.getRequiredPoints() %>)"
                                            class="bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-bold px-5 py-2 rounded-xl transition shadow-sm shadow-emerald-500/30">
                                        Đổi ngay
                                    </button>
                                    <% } else { %>
                                    <span class="text-xs font-bold text-red-500 bg-red-50 px-3 py-1.5 rounded-lg">
                                        Thiếu <%= String.format("%,d", r.getRequiredPoints() - currentPoints) %> P
                                    </span>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                        </div>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL XÁC NHẬN ĐỔI THƯỞNG (pattern giống tierInfoModal của dashboard) ===== --%>
            <div id="redeemModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="redeemContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="p-8 text-center">
                        <div class="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
                            <i class="fa-solid fa-gift text-2xl text-emerald-500"></i>
                        </div>
                        <h3 class="text-lg font-bold text-slate-800">Xác nhận đổi thưởng?</h3>
                        <p class="text-sm text-slate-500 mt-2">
                            Bạn sắp đổi <span id="rdName" class="font-bold text-slate-700"></span>
                        </p>
                        <div class="bg-slate-50 rounded-xl p-4 mt-5 text-sm space-y-2">
                            <div class="flex justify-between"><span class="text-slate-500">Điểm hiện có</span><span class="font-bold text-slate-700"><%= String.format("%,d", currentPoints) %> P</span></div>
                            <div class="flex justify-between"><span class="text-slate-500">Điểm cần đổi</span><span class="font-bold text-red-500" id="rdCost"></span></div>
                            <div class="border-t border-slate-200 pt-2 flex justify-between"><span class="text-slate-500">Số dư sau khi đổi</span><span class="font-bold text-emerald-600" id="rdAfter"></span></div>
                        </div>
                    </div>
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                        <button onclick="closeRedeemModal()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <%-- TODO BACKEND: đổi button này thành <form method="post"> submit rewardId lên Controller --%>
                        <button onclick="fakeRedeem()" class="flex-1 px-4 py-2.5 rounded-xl bg-emerald-500 text-white font-bold hover:bg-emerald-600 transition">Xác nhận đổi</button>
                    </div>
                </div>
            </div>

            <%-- Toast thông báo thành công (demo UI, backend thay bằng redirect + flash message) --%>
            <div id="toast" class="fixed bottom-6 right-6 z-[9999] hidden bg-slate-900 text-white text-sm font-medium px-5 py-3.5 rounded-xl shadow-lg flex items-center gap-2">
                <i class="fa-solid fa-circle-check text-emerald-400"></i> Đổi thưởng thành công! Xem tại Voucher Của Tôi.
            </div>
        </div>

        <script>
            // ===== Filter theo loại reward =====
            const typeChips = document.querySelectorAll('.type-chip');
            const cards = document.querySelectorAll('.reward-card');
            typeChips.forEach(chip => chip.addEventListener('click', () => {
                typeChips.forEach(c => c.className = c.className
                        .replace('bg-emerald-500 text-white shadow-sm', 'bg-white border border-slate-200 text-slate-600 hover:border-emerald-400'));
                chip.className = chip.className
                        .replace('bg-white border border-slate-200 text-slate-600 hover:border-emerald-400', 'bg-emerald-500 text-white shadow-sm');
                const f = chip.dataset.filter;
                cards.forEach(c => c.classList.toggle('hidden', f !== 'ALL' && c.dataset.type !== f));
            }));

            // ===== Modal xác nhận đổi =====
            const modal = document.getElementById('redeemModal');
            const content = document.getElementById('redeemContent');
            const myPoints = <%= currentPoints %>;

            function openRedeemModal(name, cost) {
                document.getElementById('rdName').textContent = name;
                document.getElementById('rdCost').textContent = '-' + cost.toLocaleString('vi-VN') + ' P';
                document.getElementById('rdAfter').textContent = (myPoints - cost).toLocaleString('vi-VN') + ' P';
                modal.classList.remove('hidden');
                setTimeout(() => { modal.classList.remove('opacity-0'); content.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closeRedeemModal() {
                modal.classList.add('opacity-0');
                content.classList.replace('scale-100', 'scale-95');
                setTimeout(() => modal.classList.add('hidden'), 300);
            }
            modal.addEventListener('click', e => { if (e.target === modal) closeRedeemModal(); });

            // Demo UI: hiện toast giả lập. Backend sẽ thay bằng submit form thật.
            function fakeRedeem() {
                closeRedeemModal();
                const t = document.getElementById('toast');
                t.classList.remove('hidden');
                setTimeout(() => t.classList.add('hidden'), 3000);
            }
        </script>
    </body>
</html>
