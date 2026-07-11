<%@page import="java.util.*"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="dto.Reward"%>
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dao.RewardDAO"%>
<%@page import="dao.CustomerLoyaltyDAO"%>
<%@page import="service.LoyaltyService"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: ĐỔI THƯỞNG (Customer) - customer_rewards.jsp
    Vào từ: nút "Xem tất cả" ở trang Ưu Đãi + nút "Đổi thưởng" trên thẻ thành viên
    (trang này KHÔNG có mục sidebar riêng theo quyết định của nhóm)
    Bố cục: Thanh điểm hiện có -> Lưới card reward -> Modal xác nhận đổi

    ĐÃ GẮN BACKEND THẬT - không còn mock data.
    LƯU Ý: DB thật KHÔNG có khái niệm "loại reward" (Giảm giá/Dịch vụ miễn
    phí/Quà tặng) như bản thiết kế UI ban đầu - mọi Reward đều là voucher
    giảm % (DiscountPercent + MinBillAmount + MaxDiscountAmount), nên đã
    bỏ hẳn bộ lọc theo loại, thay bằng hiển thị chi tiết mức giảm ngay
    trên card.

    Xử lý đổi thưởng theo mẫu Post-Redirect-Get: submit POST lên chính
    trang này -> gọi LoyaltyService.redeemReward() (kiểm tra + trừ điểm
    + tạo voucher, đã test kỹ ở LoyaltyService) -> redirect lại bằng GET
    kèm ?msg=... để tránh submit trùng khi khách bấm F5.
    ============================================================
--%>
<%@ include file="../includes/auth-check.jsp" %>
<%
    request.setAttribute("ACTIVE_TAB", "uudai");

    int accountId = userAcc.getAccountID();
    int customerId = cus.getCustomerId();

    // ===== XỬ LÝ ĐỔI THƯỞNG THẬT - phải nằm TRƯỚC mọi output HTML vì có sendRedirect =====
    if ("POST".equalsIgnoreCase(request.getMethod()) && "redeem".equals(request.getParameter("action"))) {
        int rewardId = Integer.parseInt(request.getParameter("rewardId"));
        LoyaltyService loyaltyService = new LoyaltyService();
        String result = loyaltyService.redeemReward(accountId, customerId, rewardId);
        response.sendRedirect("customer_rewards.jsp?msg=" + URLEncoder.encode(result, "UTF-8"));
        return;
    }

    // ===== Dữ liệu thật cho phần hiển thị (GET) =====
    CustomerLoyaltyDAO loyaltyDAO = new CustomerLoyaltyDAO();
    CustomerLoyalty loyalty = loyaltyDAO.getLoyaltyProfileByAccountId(accountId);
    int currentPoints = loyalty.getCurrentPoints();

    RewardDAO rewardDAO = new RewardDAO();
    List<Reward> rewards = rewardDAO.getActiveRewards();

    String msg = request.getParameter("msg");
    boolean isSuccess = "OK".equals(msg);
    DecimalFormat percentFmt = new DecimalFormat("0.#");
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

                        <%-- ===== BANNER KẾT QUẢ (sau khi redirect từ POST đổi thưởng) ===== --%>
                        <% if (msg != null) { %>
                        <div class="mb-6 rounded-xl px-5 py-3 text-sm font-semibold flex items-center gap-2
                                    <%= isSuccess ? "bg-emerald-50 text-emerald-700 border border-emerald-200" : "bg-red-50 text-red-700 border border-red-200" %>">
                            <% if (isSuccess) { %>
                                <i class="fa-solid fa-circle-check"></i> Đổi thưởng thành công! Xem voucher tại mục "Voucher Của Tôi".
                            <% } else { %>
                                <i class="fa-solid fa-circle-exclamation"></i> <%= msg %>
                            <% } %>
                        </div>
                        <% } %>

                        <%-- ===== LƯỚI CARD REWARD ===== --%>
                        <% if (rewards.isEmpty()) { %>
                        <div class="text-center py-20 text-slate-400">
                            <i class="fa-regular fa-gift text-4xl mb-3 block"></i>
                            <p class="text-sm font-medium">Hiện chưa có phần thưởng nào để đổi</p>
                        </div>
                        <% } else { %>
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6" id="rewardGrid">
                            <% for (Reward r : rewards) {
                                boolean enough = currentPoints >= r.getPointsRequired();
                                String applyCondition = r.getMinBillAmount() > 0
                                        ? "Áp dụng hóa đơn từ " + String.format("%,.0f", r.getMinBillAmount()) + "đ"
                                        : "Áp dụng mọi hóa đơn";
                            %>
                            <div class="reward-card bg-white rounded-2xl border border-slate-200 shadow-sm p-5 flex flex-col transition hover:shadow-md <%= enough ? "" : "opacity-60" %>">
                                <div class="flex items-start justify-between mb-4">
                                    <div class="w-14 h-14 rounded-2xl bg-slate-100 flex items-center justify-center">
                                        <i class="fa-solid fa-ticket text-2xl text-slate-400"></i>
                                    </div>
                                    <span class="text-xs font-bold px-2.5 py-1 rounded-full bg-blue-100 text-blue-700">
                                        Giảm <%= percentFmt.format(r.getDiscountPercent()) %>%
                                    </span>
                                </div>
                                <h3 class="font-bold text-slate-800"><%= r.getRewardName() %></h3>
                                <p class="text-sm text-slate-500 mt-1"><%= r.getDescription() %></p>
                                <p class="text-xs text-slate-400 mt-2 mb-4">
                                    <i class="fa-solid fa-circle-info mr-1"></i>
                                    Tối đa <%= String.format("%,.0f", r.getMaxDiscountAmount()) %>đ &middot; <%= applyCondition %>
                                </p>
                                <div class="mt-auto flex items-center justify-between">
                                    <span class="inline-flex items-center gap-1.5 text-amber-600 font-extrabold">
                                        <i class="fa-solid fa-coins"></i> <%= String.format("%,d", r.getPointsRequired()) %> P
                                    </span>
                                    <% if (enough) { %>
                                    <button onclick="openRedeemModal(<%= r.getRewardId() %>, '<%= r.getRewardName().replace("'", "\\'") %>', <%= r.getPointsRequired() %>)"
                                            class="bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-bold px-5 py-2 rounded-xl transition shadow-sm shadow-emerald-500/30">
                                        Đổi ngay
                                    </button>
                                    <% } else { %>
                                    <span class="text-xs font-bold text-red-500 bg-red-50 px-3 py-1.5 rounded-lg">
                                        Thiếu <%= String.format("%,d", r.getPointsRequired() - currentPoints) %> P
                                    </span>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL XÁC NHẬN ĐỔI THƯỞNG - form POST THẬT, không còn JS giả lập ===== --%>
            <div id="redeemModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="redeemContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <form method="post" action="customer_rewards.jsp">
                        <input type="hidden" name="action" value="redeem">
                        <input type="hidden" name="rewardId" id="rdRewardId" value="">

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
                            <p class="text-xs text-slate-400 mt-3">
                                <i class="fa-solid fa-circle-info mr-1"></i> Hệ thống sẽ kiểm tra lại điểm thật trước khi trừ, tránh trường hợp dữ liệu trên màn hình chưa cập nhật kịp.
                            </p>
                        </div>
                        <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                            <button type="button" onclick="closeRedeemModal()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                            <button type="submit" class="flex-1 px-4 py-2.5 rounded-xl bg-emerald-500 text-white font-bold hover:bg-emerald-600 transition">Xác nhận đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            // ===== Modal xác nhận đổi =====
            const modal = document.getElementById('redeemModal');
            const content = document.getElementById('redeemContent');
            const myPoints = <%= currentPoints %>;

            function openRedeemModal(rewardId, name, cost) {
                document.getElementById('rdRewardId').value = rewardId;
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
        </script>
    </body>
</html>
