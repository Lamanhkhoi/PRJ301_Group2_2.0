<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: ĐIỂM THƯỞNG (Customer) - customer_loyalty.jsp
    Bố cục: Thẻ thành viên lớn (logo theo tier) -> Lịch sử cộng/trừ điểm (filter + bảng)
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include auth-check bên dưới khi gắn Controller.
      2. Thay MOCK DATA:
         - loyalty (điểm, hạng, tên, biển số) -> CustomerLoyaltyDAO + Customer trong session
         - pointHistory -> bảng PointTransaction trong DB mới (chưa có DTO, tạo sau)
      3. Filter hiện chạy bằng JS trên mock data; khi có backend có thể giữ nguyên JS
         (lọc client-side) hoặc chuyển thành query param cho Controller.
    ============================================================
--%>
<%-- <%@ include file="../includes/auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_TAB", "diemthuong");

    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    String customerName = "Nguyễn Văn Lâm";  // cus.getFullName()
    String plateNumber = "51G-123.45";       // vehicle.getPlateNumber()
    String tierName = "Bạc";                 // loyalty.getCurrentTierDetails().getTierName()
    String tierIcon = "fa-shield-halved";    // logo theo tier: Member fa-user | Bạc fa-shield-halved | Vàng fa-crown | Bạch Kim fa-gem
    int currentPoints = 1250;                // loyalty.getCurrentPoints()
    int expiringSoon = 120;                  // số điểm sắp hết hạn trong 30 ngày (query riêng)

    // Lịch sử điểm: {Ngày, Nội dung, Điểm thay đổi, Số dư sau GD, loại: EARN/REDEEM/EXPIRE}
    Object[][] pointHistory = {
        {"05/07/2026", "Rửa xe gói Deluxe (+10% ưu đãi hạng Bạc)", 165, 1250, "EARN"},
        {"28/06/2026", "Đổi voucher Phiếu mua hàng 20.000 VNĐ", -2000, 1085, "REDEEM"},
        {"20/06/2026", "Rửa xe gói Basic", 80, 3085, "EARN"},
        {"15/06/2026", "Điểm hết hạn (tích lũy từ 06/2025)", -40, 3005, "EXPIRE"},
        {"02/06/2026", "Rửa xe gói Premium (+10% ưu đãi hạng Bạc)", 220, 3045, "EARN"},
        {"25/05/2026", "Đổi voucher Miễn phí wax xe", -300, 2825, "REDEEM"},
        {"18/05/2026", "Khuyến mãi tặng điểm sinh nhật", 50, 3125, "EARN"},
        {"10/05/2026", "Rửa xe gói Deluxe", 150, 3075, "EARN"}
    };
    // ====================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Điểm Thưởng - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; }
            /* Nền thẻ thành viên: dùng lại mesh gradient tối của dashboard cho đồng bộ */
            .member-card-bg {
                background-color: #0f172a;
                background-image:
                    radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%),
                    radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%),
                    radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="../includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-5xl mx-auto">

                        <h1 class="text-2xl font-bold text-slate-800 mb-6">Điểm Thưởng Của Tôi</h1>

                        <%-- ===== THẺ THÀNH VIÊN ===== --%>
                        <div class="member-card-bg rounded-3xl p-8 text-white shadow-lg relative overflow-hidden mb-3">
                            <i class="fa-solid <%= tierIcon %> absolute -right-8 -bottom-10 text-[11rem] opacity-[0.07]"></i>
                            <div class="flex flex-wrap items-center justify-between gap-6 relative">
                                <div class="flex items-center gap-5">
                                    <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/10">
                                        <i class="fa-solid <%= tierIcon %> text-3xl text-slate-200"></i>
                                    </div>
                                    <div>
                                        <p class="text-xs uppercase tracking-widest text-slate-400 font-semibold">Hạng hiện tại</p>
                                        <h2 class="text-2xl font-extrabold mt-0.5">Thành viên <%= tierName %></h2>
                                        <p class="text-sm text-slate-400 mt-1">
                                            <i class="fa-regular fa-user mr-1"></i><%= customerName %>
                                            <span class="mx-2 text-slate-600">|</span>
                                            <i class="fa-solid fa-car mr-1"></i><%= plateNumber %>
                                        </p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-extrabold text-amber-300 tracking-tight"><%= String.format("%,d", currentPoints) %> <span class="text-xl">P</span></p>
                                    <p class="text-xs text-slate-400 mt-1">Điểm khả dụng</p>
                                    <a href="<%=request.getContextPath()%>/DashBoard/customer_rewards.jsp"
                                       class="inline-flex items-center gap-2 mt-3 bg-emerald-500 hover:bg-emerald-600 transition text-white text-sm font-bold px-5 py-2 rounded-xl shadow-md shadow-emerald-500/30">
                                        <i class="fa-solid fa-gift"></i> Đổi thưởng
                                    </a>
                                </div>
                            </div>
                        </div>

                        <p class="text-xs text-slate-500 mb-8 flex flex-wrap gap-x-4 gap-y-1">
                            <span><i class="fa-solid fa-circle-info text-slate-400 mr-1"></i> Điểm hết hạn sau 12 tháng kể từ ngày tích lũy</span>
                            <span><i class="fa-solid fa-rotate text-slate-400 mr-1"></i> Hạng được xét lại hàng tháng</span>
                            <% if (expiringSoon > 0) { %>
                            <span class="text-amber-600 font-medium"><i class="fa-solid fa-hourglass-half mr-1"></i> <%= expiringSoon %> P sắp hết hạn trong 30 ngày tới</span>
                            <% } %>
                        </p>

                        <%-- ===== LỊCH SỬ ĐIỂM ===== --%>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                            <div class="px-6 py-5 border-b border-slate-100 flex flex-wrap items-center justify-between gap-3">
                                <h3 class="text-lg font-bold text-slate-800">Lịch sử điểm</h3>
                                <div class="flex gap-2" id="historyFilter">
                                    <button data-filter="ALL" class="filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-emerald-500 text-white">Tất cả</button>
                                    <button data-filter="EARN" class="filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-slate-100 text-slate-500 hover:bg-slate-200">Cộng điểm</button>
                                    <button data-filter="REDEEM" class="filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-slate-100 text-slate-500 hover:bg-slate-200">Trừ điểm</button>
                                    <button data-filter="EXPIRE" class="filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-slate-100 text-slate-500 hover:bg-slate-200">Hết hạn</button>
                                </div>
                            </div>

                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500">
                                        <th class="py-3 px-6 font-bold">Ngày</th>
                                        <th class="py-3 px-6 font-bold">Nội dung</th>
                                        <th class="py-3 px-6 font-bold text-right">Điểm</th>
                                        <th class="py-3 px-6 font-bold text-right">Số dư</th>
                                    </tr>
                                </thead>
                                <tbody class="text-sm" id="historyBody">
                                    <% for (Object[] h : pointHistory) {
                                        int delta = (Integer) h[2];
                                        String type = (String) h[4];
                                        String deltaClass = "EARN".equals(type) ? "text-emerald-600" : ("EXPIRE".equals(type) ? "text-slate-400" : "text-red-500");
                                        String iconClass = "EARN".equals(type) ? "fa-circle-plus text-emerald-400" : ("EXPIRE".equals(type) ? "fa-hourglass-end text-slate-300" : "fa-circle-minus text-red-400");
                                    %>
                                    <tr class="history-row border-b border-slate-100 hover:bg-slate-50 transition" data-type="<%= type %>">
                                        <td class="py-3.5 px-6 text-slate-500 whitespace-nowrap"><%= h[0] %></td>
                                        <td class="py-3.5 px-6 text-slate-700">
                                            <i class="fa-solid <%= iconClass %> mr-2"></i><%= h[1] %>
                                        </td>
                                        <td class="py-3.5 px-6 text-right font-bold <%= deltaClass %>"><%= (delta > 0 ? "+" : "") + String.format("%,d", delta) %></td>
                                        <td class="py-3.5 px-6 text-right text-slate-600 font-medium"><%= String.format("%,d", (Integer) h[3]) %></td>
                                    </tr>
                                    <% } %>
                                    <tr id="emptyRow" class="hidden">
                                        <td colspan="4" class="py-10 text-center text-slate-400 text-sm">
                                            <i class="fa-regular fa-folder-open text-2xl block mb-2"></i> Không có giao dịch nào trong mục này
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <%-- TODO BACKEND: phân trang thật (offset/limit). Hiện tại là UI tĩnh minh họa. --%>
                            <div class="px-6 py-4 flex items-center justify-end gap-1.5 text-sm">
                                <button class="w-8 h-8 rounded-lg border border-slate-200 text-slate-400 hover:bg-slate-50 transition"><i class="fa-solid fa-chevron-left text-xs"></i></button>
                                <button class="w-8 h-8 rounded-lg bg-emerald-500 text-white font-bold">1</button>
                                <button class="w-8 h-8 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition">2</button>
                                <button class="w-8 h-8 rounded-lg border border-slate-200 text-slate-400 hover:bg-slate-50 transition"><i class="fa-solid fa-chevron-right text-xs"></i></button>
                            </div>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <script>
            // Filter lịch sử điểm theo loại giao dịch (client-side trên mock data)
            const chips = document.querySelectorAll('.filter-chip');
            const rows = document.querySelectorAll('.history-row');
            const emptyRow = document.getElementById('emptyRow');

            chips.forEach(chip => chip.addEventListener('click', () => {
                chips.forEach(c => c.className = 'filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-slate-100 text-slate-500 hover:bg-slate-200');
                chip.className = 'filter-chip px-4 py-1.5 rounded-full text-xs font-semibold transition bg-emerald-500 text-white';

                const f = chip.dataset.filter;
                let visible = 0;
                rows.forEach(r => {
                    const show = (f === 'ALL' || r.dataset.type === f);
                    r.classList.toggle('hidden', !show);
                    if (show) visible++;
                });
                emptyRow.classList.toggle('hidden', visible > 0);
            }));
        </script>
    </body>
</html>
