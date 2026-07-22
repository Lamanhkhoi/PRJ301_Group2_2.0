<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="dto.RewardRedemption"%>
<%@page import="dao.RewardRedemptionDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: VOUCHER CỦA TÔI (Customer) - customer_vouchers.jsp
    Bố cục: 3 tab Khả dụng / Đã dùng / Hết hạn -> Lưới voucher kiểu "vé xé" (mã code + nút copy)

    ĐÃ GẮN BACKEND THẬT - không còn mock data.

    LƯU Ý QUAN TRỌNG - việc còn thiếu ở tầng hệ thống (không thuộc phạm vi trang này):
    Bảng RewardRedemptions KHÔNG có cột ngày hết hạn cho voucher (khác với điểm
    thưởng có ExpiresAt).

    Vì số lượng voucher của 1 khách thường không nhiều (không như lịch sử điểm
    có thể hàng trăm dòng/năm), trang này tải hết 1 lần rồi lọc tab bằng JS
    phía client cho mượt, không cần phân trang server như customer_loyalty.jsp.
    ============================================================
--%>
<%@ include file="../includes/auth-check.jsp" %>
<%
    request.setAttribute("ACTIVE_TAB", "vouchercuatoi");

    int customerId = cus.getCustomerId();

    RewardRedemptionDAO redemptionDAO = new RewardRedemptionDAO();
    List<RewardRedemption> vouchers = redemptionDAO.getMyRedemptions(customerId, "ALL");

    int cntAvail = 0, cntUsed = 0, cntExpired = 0;
    for (RewardRedemption rr : vouchers) {
        if ("Available".equals(rr.getStatus())) cntAvail++;
        else if ("Used".equals(rr.getStatus())) cntUsed++;
        else if ("Expired".equals(rr.getStatus())) cntExpired++;
    }

    SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Voucher Của Tôi - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; }
            /* Đường răng cưa vé xé */
            .ticket-divider { border-left: 2px dashed #CBD5E1; position: relative; }
            .ticket-divider::before, .ticket-divider::after {
                content: ''; position: absolute; left: -9px; width: 16px; height: 16px;
                background: #F8FAFC; border-radius: 9999px; border: 1px solid #E2E8F0;
            }
            .ticket-divider::before { top: -9px; border-top: none; }
            .ticket-divider::after { bottom: -9px; border-bottom: none; }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="../includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-5xl mx-auto">

                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-800">Voucher Của Tôi</h1>
                                <p class="text-sm text-slate-500 mt-1">Voucher bạn đã đổi từ điểm thưởng. Đưa mã cho nhân viên khi sử dụng.</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/MainController?action=customerRewardsDashboard"
                               class="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 transition text-white text-sm font-bold px-5 py-2.5 rounded-xl shadow-sm shadow-emerald-500/30">
                                <i class="fa-solid fa-plus"></i> Đổi thêm voucher
                            </a>
                        </div>

                        <%-- ===== TABS TRẠNG THÁI ===== --%>
                        <div class="flex gap-6 border-b border-slate-200 mb-8" id="voucherTabs">
                            <button data-tab="Available" class="v-tab pb-3 text-sm font-bold border-b-2 border-emerald-500 text-slate-800 transition">
                                Khả dụng <span class="ml-1 bg-emerald-100 text-emerald-700 text-xs font-bold px-2 py-0.5 rounded-full"><%= cntAvail %></span>
                            </button>
                            <button data-tab="Used" class="v-tab pb-3 text-sm font-semibold border-b-2 border-transparent text-slate-400 hover:text-slate-600 transition">
                                Đã dùng <span class="ml-1 bg-slate-100 text-slate-500 text-xs font-bold px-2 py-0.5 rounded-full"><%= cntUsed %></span>
                            </button>
                            
                        </div>

                        <%-- ===== LƯỚI VOUCHER "VÉ XÉ" ===== --%>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6" id="voucherGrid">
                            <% if (vouchers.isEmpty()) { %>
                                <%-- Không render gì - để khối empty state bên dưới tự hiện qua JS --%>
                            <% } %>
                            <% for (RewardRedemption rr : vouchers) {
                                boolean avail = "Available".equals(rr.getStatus());
                                boolean used = "Used".equals(rr.getStatus());
                                String timeLabel = avail
                                        ? "Đổi lúc: " + dateFmt.format(rr.getRedeemedAt())
                                        : used
                                            ? "Đã dùng lúc: " + (rr.getUsedAt() != null ? dateFmt.format(rr.getUsedAt()) : dateFmt.format(rr.getRedeemedAt()))
                                            : "Đổi lúc: " + dateFmt.format(rr.getRedeemedAt());
                            %>
                            <div class="voucher-item <%= avail ? "" : "hidden" %>" data-status="<%= rr.getStatus() %>">
                                <div class="flex bg-white rounded-2xl border <%= avail ? "border-slate-200 shadow-sm hover:shadow-md" : "border-slate-100 grayscale opacity-60" %> transition overflow-hidden relative">
                                    <% if (!avail) { %>
                                    <span class="absolute top-3 right-3 z-10 text-[10px] font-extrabold uppercase tracking-wider px-2 py-1 rounded border <%= used ? "text-slate-400 border-slate-300" : "text-red-400 border-red-300" %> rotate-6">
                                        <%= used ? "Đã dùng" : "Hết hạn" %>
                                    </span>
                                    <% } %>
                                    <div class="flex-1 p-5">
                                        <span class="text-xs font-bold px-2.5 py-1 rounded-full bg-blue-100 text-blue-700">
                                            Giảm <%= new java.text.DecimalFormat("0.#").format(rr.getDiscountPercent()) %>% &middot; Tối đa <%= String.format("%,.0f", rr.getMaxDiscountAmount()) %>đ
                                        </span>
                                        <h3 class="font-bold text-slate-800 mt-3"><%= rr.getRewardName() %></h3>
                                        <p class="text-xs text-slate-500 mt-1.5"><i class="fa-regular fa-clock mr-1"></i><%= timeLabel %></p>
                                    </div>
                                    <div class="ticket-divider w-36 bg-slate-50 flex flex-col items-center justify-center gap-2 p-3">
                                        <p class="text-[10px] uppercase tracking-widest text-slate-400 font-bold">Mã voucher</p>
                                        <p class="font-mono font-bold text-slate-700 <%= avail ? "" : "line-through" %>"><%= rr.getVoucherCode() %></p>
                                        <% if (avail) { %>
                                        <button onclick="copyCode(this, '<%= rr.getVoucherCode() %>')"
                                                class="copy-btn text-xs font-bold text-emerald-600 border border-emerald-300 hover:bg-emerald-50 rounded-lg px-3 py-1.5 transition">
                                            <i class="fa-regular fa-copy mr-1"></i>Copy
                                        </button>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <%-- Empty state khi tab không có voucher (kể cả khi tổng khách chưa đổi gì) --%>
                        <div id="voucherEmpty" class="<%= cntAvail > 0 ? "hidden" : "" %> text-center py-16 text-slate-400">
                            <i class="fa-solid fa-ticket text-4xl mb-3 block"></i>
                            <p class="text-sm font-medium">Không có voucher nào trong mục này</p>
                            <a href="${pageContext.request.contextPath}/MainController?action=customerRewardsDashboard" class="inline-block mt-3 text-sm font-bold text-emerald-600 hover:text-emerald-700">
                                Đổi điểm lấy voucher ngay <i class="fa-solid fa-arrow-right ml-1"></i>
                            </a>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <script>
            // ===== Chuyển tab trạng thái (client-side, dữ liệu đã tải hết 1 lần) =====
            const tabs = document.querySelectorAll('.v-tab');
            const items = document.querySelectorAll('.voucher-item');
            const empty = document.getElementById('voucherEmpty');
            const ACTIVE = 'v-tab pb-3 text-sm font-bold border-b-2 border-emerald-500 text-slate-800 transition';
            const IDLE = 'v-tab pb-3 text-sm font-semibold border-b-2 border-transparent text-slate-400 hover:text-slate-600 transition';

            tabs.forEach(tab => tab.addEventListener('click', () => {
                tabs.forEach(t => t.className = IDLE);
                tab.className = ACTIVE;
                let visible = 0;
                items.forEach(it => {
                    const show = it.dataset.status === tab.dataset.tab;
                    it.classList.toggle('hidden', !show);
                    if (show) visible++;
                });
                empty.classList.toggle('hidden', visible > 0);
            }));

            // ===== Copy mã voucher =====
            function copyCode(btn, code) {
                navigator.clipboard.writeText(code).then(() => {
                    const old = btn.innerHTML;
                    btn.innerHTML = '<i class="fa-solid fa-check mr-1"></i>Đã copy';
                    btn.classList.add('bg-emerald-500', 'text-white', 'border-emerald-500');
                    setTimeout(() => {
                        btn.innerHTML = old;
                        btn.classList.remove('bg-emerald-500', 'text-white', 'border-emerald-500');
                    }, 1500);
                });
            }
        </script>
    </body>
</html>
