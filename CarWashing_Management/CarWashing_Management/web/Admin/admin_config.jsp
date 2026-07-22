<%@page import="java.util.*"%>
<%@page import="dto.LoyaltyTier"%>
<%@page import="dto.TierChangeRecord"%>
<%@page import="service.LoyaltyService"%>
<%@page import="dao.TierChangeLogDAO"%>
<%@page import="java.net.URLEncoder"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: CẤU HÌNH HỆ THỐNG (Admin) - admin_config.jsp
    Bố cục: Card cấu hình chung (point rate, hạn điểm, chu kỳ xét hạng)
            -> Card "Xét Lại Hạng Thành Viên" (THẬT - gọi LoyaltyService.recalculateAllTiers())
            -> Bảng 4 hạng thành viên (LoyaltyTier), nút Sửa mở modal chỉnh giá trị quy đổi
    Trang này được nạp qua MainController?action=adminConfig -> AdminConfigController
    (KHÔNG còn vào thẳng URL JSP như trước) - đọc dữ liệu qua request attribute.
    (Card "Xét Lại Hạng Thành Viên" thuộc Loyalty Engine - không cần đụng vào khi
     chỉnh sửa các phần khác của trang.)
    ============================================================
--%>
<%-- <%@ include file="../includes/admin-auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_ADMIN", "cauhinh");

    // ===== XỬ LÝ "XÉT LẠI HẠNG THỦ CÔNG" - phải nằm TRƯỚC mọi output HTML vì có sendRedirect =====
    // Post-Redirect-Get: tránh chạy lại (đổi hạng thêm 1 lần nữa) nếu Admin lỡ bấm F5 sau khi submit.
    // Redirect qua MainController (không redirect thẳng về admin_config.jsp) để trang tải lại
    // ĐẦY ĐỦ dữ liệu thật (bảng tier, cấu hình chung) qua đúng AdminConfigController,
    // tránh trang hiện trống vì thiếu request attribute LOYALTY_LIST/PointExpiryMonths...
    if ("POST".equalsIgnoreCase(request.getMethod()) && "recalcTier".equals(request.getParameter("action"))) {
        int windowMonths;
        try {
            windowMonths = Integer.parseInt(request.getParameter("windowMonths"));
        } catch (Exception e) {
            windowMonths = 12;
        }
        LoyaltyService loyaltyService = new LoyaltyService();
        int changed = loyaltyService.recalculateAllTiers(windowMonths);
        String tierMsg = (changed < 0)
                ? "ERR:Có lỗi khi chạy - xem log server (Output/console) để biết chi tiết."
                : "OK:Đã xét lại xong. Số tài khoản đổi hạng (lên hoặc xuống): " + changed
                        + " (nhìn lại " + windowMonths + " tháng gần đây).";
        response.sendRedirect(request.getContextPath()
                + "/MainController?action=adminConfig&tierMsg=" + URLEncoder.encode(tierMsg, "UTF-8"));
        return;
    }

    String tierMsgRaw = request.getParameter("tierMsg");
    boolean tierMsgIsError = tierMsgRaw != null && tierMsgRaw.startsWith("ERR:");
    String tierMsgText = tierMsgRaw != null ? tierMsgRaw.substring(tierMsgRaw.indexOf(':') + 1) : null;

    List<TierChangeRecord> tierChanges = new TierChangeLogDAO().getRecentChanges(20);

    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    List<LoyaltyTier> tiers
            = (List<LoyaltyTier>) request.getAttribute("LOYALTY_LIST");

    if (tiers == null) {
        tiers = new ArrayList<>();
    }

    String pointExpiryMonths
            = (String) request.getAttribute("PointExpiryMonths");

    String tierReviewCycle
            = (String) request.getAttribute("TierReviewCycle");

    if (pointExpiryMonths == null) {
        pointExpiryMonths = "";
    }

    if (tierReviewCycle == null) {
        tierReviewCycle = "";
    }
    String[] tierIcons = {
        "fa-seedling",
        "fa-medal",
        "fa-crown",
        "fa-gem"
    };

    String[] tierIconColors = {
        "text-green-500",
        "text-blue-500",
        "text-amber-500",
        "text-purple-500"
    };
    Double basePointRate
            = (Double) request.getAttribute("BasePointRate");
    if (basePointRate == null) {
        basePointRate = 0.0;
    }

    // ====================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Cấu Hình Hệ Thống - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body {
                font-family: 'Inter', sans-serif;
                background-color: #F1F5F9;
            }</style>
    </head>
    <body class="text-slate-800 relative">

        <div class="flex h-screen overflow-hidden relative">

            <jsp:include page="/includes/sidebar_admin.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="max-w-6xl mx-auto">

                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-800">Cấu Hình Hệ Thống</h1>
                                <p class="text-sm text-slate-500 mt-1">Point rate, điều kiện lên hạng và đặc quyền của chương trình khách hàng thân thiết</p>
                            </div>
                        </div>

                        <%-- ===== BANNER CẢNH BÁO ===== --%>
                        <div class="flex items-start gap-3 bg-amber-50 border border-amber-200 text-amber-800 rounded-2xl px-5 py-4 mb-6 text-sm">
                            <i class="fa-solid fa-triangle-exclamation mt-0.5"></i>
                            <p>Thay đổi cấu hình sẽ ảnh hưởng đến <b>toàn bộ khách hàng</b> và cách hệ thống tính điểm, xét hạng từ chu kỳ tiếp theo. Hãy kiểm tra kỹ trước khi lưu.</p>
                        </div>

                        <%-- ===== CARD CẤU HÌNH CHUNG ===== --%>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
                            <div class="flex items-center justify-between mb-5">
                                <h2 class="text-lg font-bold text-slate-800"><i class="fa-solid fa-sliders text-blue-500 mr-2"></i>Cấu hình chung</h2>
                                <%-- TODO BACKEND: submit form update SystemConfig --%>
                                <form method="post"action="<%=request.getContextPath()%>/MainController">

                                    <input type="hidden"
                                           name="action"
                                           value="adminConfig">

                                    <input type="hidden"
                                           name="configAction"
                                           value="updateSystem">

                                    <button class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2 rounded-xl transition">
                                        <i class="fa-solid fa-floppy-disk"></i> Lưu
                                    </button>
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-5 text-sm">
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Point rate cơ bản</label>
                                    <div class="flex items-center gap-2">
                                        <span class="text-slate-500 font-medium whitespace-nowrap">1 P =</span>
                                        <input
                                            type="number"
                                            step="1"
                                            name="BasePointRate"
                                            value="<%= basePointRate%>"
                                            min="1"
                                            class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">                                        
                                        <span class="text-slate-500 font-medium">VNĐ</span>
                                    </div>
                                </div>
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Hạn sử dụng điểm (tháng)</label>
                                    <input type="number" name="PointExpiryMonths" value="<%=pointExpiryMonths%>" min="1" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                </div>
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Chu kỳ xét hạng (auto up/down)</label>
                                    <select name="TierReviewCycle" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                        <option value="Monthly"
                                                <%= "Monthly".equals(tierReviewCycle) ? "selected" : ""%>>
                                            Hàng tháng
                                        </option>

                                        <option value="Quarterly"
                                                <%= "Quarterly".equals(tierReviewCycle) ? "selected" : ""%>>
                                            Hàng quý
                                        </option>

                                        <option value="Yearly"
                                                <%= "Yearly".equals(tierReviewCycle) ? "selected" : ""%>>
                                            Hàng năm
                                        </option>
                                    </select>
                                </div>
                            </div>
                            </form>
                        </div>

                        <%-- ===== CARD "XÉT LẠI HẠNG THÀNH VIÊN" - ĐÃ GẮN BACKEND THẬT (Loyalty Engine) ===== --%>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
                            <h2 class="text-lg font-bold text-slate-800 mb-2">
                                <i class="fa-solid fa-ranking-star text-blue-500 mr-2"></i>Xét Lại Hạng Thành Viên
                            </h2>
                            <p class="text-sm text-slate-500 mb-4">
                                Tính lại hạng cho <b>toàn bộ khách hàng</b> dựa trên số lần rửa + chi tiêu thật
                                (Booking đã Completed, đã thanh toán) trong N tháng gần nhất. Áp dụng
                                <b>ngay lập tức</b> khi bấm - cả lên hạng lẫn xuống hạng cùng lúc.
                            </p>

                            <% if (tierMsgText != null) { %>
                            <div class="mb-4 rounded-xl px-4 py-3 text-sm font-semibold flex items-center gap-2
                                        <%= tierMsgIsError ? "bg-red-50 text-red-700 border border-red-200" : "bg-emerald-50 text-emerald-700 border border-emerald-200" %>">
                                <i class="fa-solid <%= tierMsgIsError ? "fa-circle-exclamation" : "fa-circle-check" %>"></i> <%= tierMsgText %>
                            </div>
                            <% } %>

                            <form method="post" action="<%=request.getContextPath()%>MainController?action=adminConfig" class="flex flex-wrap items-end gap-3">
                                <input type="hidden" name="action" value="recalcTier">
                                <div>
                                    <label class="block text-xs font-semibold text-slate-600 mb-1.5">Số tháng nhìn lại</label>
                                    <input type="number" name="windowMonths" value="12" min="0"
                                           class="w-40 px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                </div>
                                <button type="submit" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2.5 rounded-xl transition">
                                    <i class="fa-solid fa-play"></i> Chạy xét lại ngay
                                </button>
                                <p class="text-xs text-slate-400 basis-full mt-1">
                                    Mặc định 12 tháng (khớp quy ước vận hành thật). Demo nhanh có thể để 0 hoặc số nhỏ.
                                </p>
                            </form>

                            <%-- ===== LỊCH SỬ ĐỔI HẠNG - để Admin biết CHÍNH XÁC ai đổi, từ đâu sang đâu ===== --%>
                            <% if (!tierChanges.isEmpty()) { %>
                            <div class="mt-5 pt-5 border-t border-slate-100">
                                <p class="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Lịch sử đổi hạng gần đây</p>
                                <div class="space-y-2 max-h-64 overflow-y-auto">
                                    <% for (TierChangeRecord r : tierChanges) { %>
                                    <div class="flex items-center justify-between text-sm bg-slate-50 rounded-lg px-3 py-2">
                                        <span class="text-slate-700 font-medium"><%= r.getAccountName() %></span>
                                        <span class="flex items-center gap-1.5">
                                            <span class="text-slate-500"><%= r.getOldTierName() %></span>
                                            <i class="fa-solid fa-arrow-right text-[10px] <%= r.isUpgrade() ? "text-emerald-500" : "text-red-400" %>"></i>
                                            <span class="font-bold <%= r.isUpgrade() ? "text-emerald-600" : "text-red-500" %>"><%= r.getNewTierName() %></span>
                                        </span>
                                        <span class="text-xs text-slate-400 whitespace-nowrap"><%= r.getChangedAt() %></span>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                        </div>

                        <%-- ===== BẢNG HẠNG THÀNH VIÊN ===== --%>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                            <div class="px-6 py-5 border-b border-slate-100">
                                <h2 class="text-lg font-bold text-slate-800"><i class="fa-solid fa-ranking-star text-blue-500 mr-2"></i>Hạng thành viên &amp; giá trị quy đổi</h2>
                            </div>
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500">
                                        <th class="py-3 px-6 font-bold">Hạng</th>
                                        <th class="py-3 px-4 font-bold">Điều kiện lên hạng</th>
                                        <th class="py-3 px-4 font-bold text-center">Bonus điểm</th>
                                        <th class="py-3 px-4 font-bold text-center">Đặt lịch trước</th>
                                        <th class="py-3 px-4 font-bold">Đặc quyền tháng</th>
                                        <th class="py-3 px-6 font-bold text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="text-sm">
                                    <% for (int i = 0;
                                                i < tiers.size();
                                                i++) {
                                            LoyaltyTier t = tiers.get(i);
                                            int bonusPct = (int) Math.round(t.getBonusPointRate() * 100);
                                    %>
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                                        <td class="py-4 px-6 font-bold text-slate-700 whitespace-nowrap">
                                            <i class="fa-solid <%= tierIcons[i]%> <%= tierIconColors[i]%> mr-2"></i><%= t.getTierName()%>
                                        </td>
                                        <td class="py-4 px-4 text-slate-600">
                                            <% if (i == 0) { %>Đăng ký + 1 lần rửa xe<% } else {%>
                                            <%= t.getMinWashCount()%> lần rửa <span class="text-slate-400 font-semibold text-xs mx-1">HOẶC</span> <%= String.format("%,.0f", t.getMinTotalSpent())%> VNĐ
                                            <% }%>
                                        </td>
                                        <td class="py-4 px-4 text-center font-bold <%= bonusPct > 0 ? "text-emerald-600" : "text-slate-400"%>">+<%= bonusPct%>%</td>
                                        <td class="py-4 px-4 text-center text-slate-600 font-medium"><%= t.getBookingWindowDays()%> ngày</td>
                                        <td class="py-4 px-4">
                                            <% if (t.isFreeWashMonthly()) { %><span class="text-xs font-bold px-2.5 py-1 rounded-full bg-purple-100 text-purple-700 mr-1">1 lần rửa free</span><% } %>
                                            <% if (t.isFreeUpgradeMonthly()) { %><span class="text-xs font-bold px-2.5 py-1 rounded-full bg-amber-100 text-amber-700">Free nâng cấp</span><% } %>
                                            <% if (!t.isFreeWashMonthly() && !t.isFreeUpgradeMonthly()) { %><span class="text-xs text-slate-400">—</span><% }%>
                                        </td>
                                        <td class="py-4 px-6 text-right">
                                            <button onclick="openTierModal(
                                                    <%=t.getTierId()%>,
                                                            '<%=t.getTierName()%>',
                                                    <%=t.getMinWashCount()%>,
                                                    <%= (long) t.getMinTotalSpent()%>,
                                                    <%=bonusPct%>,
                                                    <%=t.getBookingWindowDays()%>,
                                                    <%=t.isFreeUpgradeMonthly()%>,
                                                    <%=t.isFreeWashMonthly()%>)"
                                                    class="inline-flex items-center gap-1.5 text-sm font-bold text-blue-600 border border-blue-200 hover:bg-blue-50 rounded-lg px-4 py-1.5 transition">
                                                <i class="fa-solid fa-pen-to-square text-xs"></i> Sửa
                                            </button>
                                        </td>
                                    </tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL SỬA HẠNG ===== --%>
            <div id="tierModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">

                <div id="tierModalContent"
                     class="bg-white rounded-2xl shadow-2xl w-full max-w-xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300">

                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">

                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                                <i class="fa-solid fa-ranking-star"></i>
                            </div>

                            <h3 class="text-lg font-bold text-slate-800">
                                Sửa hạng
                                <span id="tName" class="text-blue-600"></span>
                            </h3>
                        </div>

                        <button type="button"
                                onclick="closeTierModal()"
                                class="text-slate-400 hover:text-red-500 transition">
                            <i class="fa-solid fa-xmark text-2xl"></i>
                        </button>

                    </div>

                    <form method="post"
                          action="<%=request.getContextPath()%>/MainController">

                        <input type="hidden"
                               name="action"
                               value="adminConfig">

                        <input type="hidden"
                               name="configAction"
                               value="updateTier">

                        <input type="hidden"
                               id="tierId"
                               name="tierId">

                        <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-5 text-sm">

                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Số lần rửa tối thiểu
                                </label>

                                <input id="tWash"
                                       name="minWashCount"
                                       type="number"
                                       min="0"
                                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200">
                            </div>

                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Chi tiêu tối thiểu (VNĐ)
                                </label>

                                <input id="tSpent"
                                       name="minTotalSpent"
                                       type="number"
                                       min="0"
                                       step="1000"
                                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200">
                            </div>

                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Bonus điểm (%)
                                </label>

                                <input id="tBonus"
                                       name="bonusPointRate"
                                       type="number"
                                       min="0"
                                       max="100"
                                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200">
                            </div>

                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Đặt lịch trước (ngày)
                                </label>

                                <input id="tWindow"
                                       name="bookingWindowDays"
                                       type="number"
                                       min="1"
                                       max="30"
                                       class="w-full px-4 py-2.5 rounded-xl border border-slate-200">
                            </div>

                            <div class="md:col-span-2 flex flex-wrap gap-6 pt-1">

                                <label class="inline-flex items-center gap-2.5 cursor-pointer font-medium text-slate-600">
                                    <input id="tUpgrade"
                                           name="freeUpgradeMonthly"
                                           type="checkbox"
                                           class="w-4 h-4 rounded accent-blue-600">

                                    Miễn phí nâng cấp dịch vụ hàng tháng
                                </label>

                                <label class="inline-flex items-center gap-2.5 cursor-pointer font-medium text-slate-600">
                                    <input id="tFreeWash"
                                           name="freeWashMonthly"
                                           type="checkbox"
                                           class="w-4 h-4 rounded accent-blue-600">

                                    1 lần rửa xe miễn phí hàng tháng
                                </label>

                            </div>

                        </div>

                        <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end gap-3">

                            <button type="button"
                                    onclick="closeTierModal()"
                                    class="px-6 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">
                                Hủy
                            </button>

                            <button type="submit"
                                    class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition">
                                <i class="fa-solid fa-check mr-1"></i>
                                Lưu thay đổi
                            </button>

                        </div>

                    </form>

                </div>

            </div>
        </div>

        <script>

            // ===== Modal sửa hạng =====

            const tModal = document.getElementById("tierModal");
            const tContent = document.getElementById("tierModalContent");

            function openTierModal(
                    id,
                    name,
                    wash,
                    spent,
                    bonus,
                    windowDay,
                    upgrade,
                    freeWash) {

                document.getElementById("tierId").value = id;

                document.getElementById("tName").innerHTML = name;

                document.getElementById("tWash").value = wash;

                document.getElementById("tSpent").value = spent;

                document.getElementById("tBonus").value = bonus;

                document.getElementById("tWindow").value = windowDay;

                document.getElementById("tUpgrade").checked = upgrade;

                document.getElementById("tFreeWash").checked = freeWash;

                tModal.classList.remove("hidden");

                setTimeout(function () {

                    tModal.classList.remove("opacity-0");

                    tContent.classList.remove("scale-95");

                    tContent.classList.add("scale-100");

                }, 10);

            }

            function closeTierModal() {

                tModal.classList.add("opacity-0");

                tContent.classList.remove("scale-100");

                tContent.classList.add("scale-95");

                setTimeout(function () {

                    tModal.classList.add("hidden");

                }, 300);

            }

            tModal.addEventListener("click", function (e) {

                if (e.target === tModal) {

                    closeTierModal();

                }

            });

        </script>
    </body>
</html>
