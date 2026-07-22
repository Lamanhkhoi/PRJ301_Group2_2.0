<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="dto.Account"%>
<%@page import="dto.Customer"%>
<%@page import="dto.CustomerLoyalty"%>
<%@page import="dto.LoyaltyTier"%>
<%@page import="dto.LoyaltyPointTransaction"%>
<%@page import="dao.CustomerLoyaltyDAO"%>
<%@page import="dao.LoyaltyPointTransactionDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: ĐIỂM THƯỞNG (Customer) - customer_loyalty.jsp
    Bố cục: Thẻ thành viên lớn (logo theo tier) -> Lịch sử cộng/trừ điểm (filter + phân trang)

    QUAN TRỌNG - đổi cách filter/phân trang hoạt động so với bản mock trước:
    Bản mock cũ lọc bằng JS trên 1 mảng cứng có sẵn (tức thời, không tải lại trang).
    Bản này lọc/phân trang THẬT qua DB (LoyaltyPointTransactionDAO dùng OFFSET/FETCH),
    nên các nút filter và số trang giờ là <a href> điều hướng qua query string
    (?filter=Earn&page=2), tức là SẼ TẢI LẠI TRANG mỗi lần bấm - không còn tức thời
    như JS nữa. Đây là đánh đổi cần thiết vì DB chỉ trả về đúng 1 trang dữ liệu
    mỗi lần gọi, không tải hết lịch sử về trình duyệt.
    ============================================================
--%>
<%@ include file="../includes/auth-check.jsp" %>
<%
    request.setAttribute("ACTIVE_TAB", "diemthuong");

    int accountId = userAcc.getAccountID();
    String customerName = userAcc.getFullname(); // Tên nằm ở Account, KHÔNG phải Customer (Customer.java không có field tên)

    // ===== Hồ sơ loyalty thật: hạng + điểm hiện có =====
    CustomerLoyaltyDAO loyaltyDAO = new CustomerLoyaltyDAO();
    CustomerLoyalty loyalty = loyaltyDAO.getLoyaltyProfileByAccountId(accountId);
    LoyaltyTier currentTier = loyalty.getCurrentTierDetails();

    String tierName = (currentTier != null) ? currentTier.getTierName() : "Member";
    int currentPoints = loyalty.getCurrentPoints();

    // Map tên hạng (DB lưu tiếng Anh: Member/Silver/Gold/Platinum) sang icon + nhãn tiếng Việt hiển thị
    String tierIcon, tierLabel;
    switch (tierName) {
        case "Silver":   tierIcon = "fa-shield-halved"; tierLabel = "Bạc";       break;
        case "Gold":     tierIcon = "fa-crown";          tierLabel = "Vàng";      break;
        case "Platinum": tierIcon = "fa-gem";            tierLabel = "Bạch Kim";  break;
        default:         tierIcon = "fa-user";           tierLabel = "Member";
    }

    LoyaltyPointTransactionDAO txDAO = new LoyaltyPointTransactionDAO();

    // ===== Filter + phân trang lấy từ query string, có giá trị mặc định an toàn =====
    String filter = request.getParameter("filter");
    if (filter == null || filter.trim().isEmpty()) filter = "ALL";

    int pageNum = 1;
    try { pageNum = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {  }
    if (pageNum < 1) pageNum = 1;

    final int PAGE_SIZE = 5;
    List<LoyaltyPointTransaction> pointHistory = txDAO.getHistory(accountId, filter, pageNum, PAGE_SIZE);
    int totalRows = txDAO.countHistory(accountId, filter);
    int totalPages = (int) Math.ceil(totalRows / (double) PAGE_SIZE);
    if (totalPages < 1) totalPages = 1;
    if (pageNum > totalPages) pageNum = totalPages; 

    SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");
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
                                        <h2 class="text-2xl font-extrabold mt-0.5">Thành viên <%= tierLabel %></h2>
                                        <p class="text-sm text-slate-400 mt-1">
                                            <i class="fa-regular fa-user mr-1"></i><%= customerName %>
                                        </p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p class="text-4xl font-extrabold text-amber-300 tracking-tight"><%= String.format("%,d", currentPoints) %> <span class="text-xl">P</span></p>
                                    <p class="text-xs text-slate-400 mt-1">Điểm khả dụng</p>
                                    <a href="${pageContext.request.contextPath}/MainController?action=customerRewardsDashboard"
                                       class="inline-flex items-center gap-2 mt-3 bg-emerald-500 hover:bg-emerald-600 transition text-white text-sm font-bold px-5 py-2 rounded-xl shadow-md shadow-emerald-500/30">
                                        <i class="fa-solid fa-gift"></i> Đổi thưởng
                                    </a>
                                </div>
                            </div>
                        </div>

                        <p class="text-xs text-slate-500 mb-8 flex flex-wrap gap-x-4 gap-y-1">
                            
                            <span><i class="fa-solid fa-rotate text-slate-400 mr-1"></i> Hạng được xét lại hàng tháng</span>
                        </p>

                        <%-- ===== LỊCH SỬ ĐIỂM ===== --%>
                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                            <div class="px-6 py-5 border-b border-slate-100 flex flex-wrap items-center justify-between gap-3">
                                <h3 class="text-lg font-bold text-slate-800">Lịch sử điểm</h3>
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
                                <tbody class="text-sm">
                                    <% if (pointHistory.isEmpty()) { %>
                                    <tr>
                                        <td colspan="4" class="py-10 text-center text-slate-400 text-sm">
                                            <i class="fa-regular fa-folder-open text-2xl block mb-2"></i> Không có giao dịch nào trong mục này
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% for (LoyaltyPointTransaction t : pointHistory) {
                                        int delta = t.getPointsChange();
                                        String type = t.getTransactionType(); // "Earn" / "Redeem" 
                                        boolean isExpire = "Expire".equals(type);
                                        String deltaClass = (delta > 0 ? "text-emerald-600" : "text-red-500");
                                        String iconClass = (delta > 0 ? "fa-circle-plus text-emerald-400" : "fa-circle-minus text-red-400");
                                    %>
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                                        <td class="py-3.5 px-6 text-slate-500 whitespace-nowrap"><%= dateFmt.format(t.getCreatedAt()) %></td>
                                        <td class="py-3.5 px-6 text-slate-700">
                                            <i class="fa-solid <%= iconClass %> mr-2"></i><%= t.getDescription() %>
                                        </td>
                                        <td class="py-3.5 px-6 text-right font-bold <%= deltaClass %>"><%= (delta > 0 ? "+" : "") + String.format("%,d", delta) %></td>
                                        <td class="py-3.5 px-6 text-right text-slate-600 font-medium"><%= String.format("%,d", t.getBalanceAfter()) %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>

                            <%-- Phân trang thật - điều hướng qua query string, giữ nguyên filter đang chọn --%>
                            <div class="px-6 py-4 flex items-center justify-end gap-1.5 text-sm">
                                <% if (pageNum > 1) { %>
                                <a href="${pageContext.request.contextPath}/MainController?action=customerLoyaltyDashboard&<%= filter %>&page=<%= pageNum - 1 %>"
                                   class="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition"><i class="fa-solid fa-chevron-left text-xs"></i></a>
                                <% } else { %>
                                <span class="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-300"><i class="fa-solid fa-chevron-left text-xs"></i></span>
                                <% } %>

                                <% for (int p = 1; p <= totalPages; p++) { %>
                                    <% if (p == pageNum) { %>
                                    <span class="w-8 h-8 flex items-center justify-center rounded-lg bg-emerald-500 text-white font-bold"><%= p %></span>
                                    <% } else { %>
                                    <a href="${pageContext.request.contextPath}/MainController?action=customerLoyaltyDashboard&filter=<%= filter %>&page=<%= p %>"
                                       class="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition"><%= p %></a>
                                    <% } %>
                                <% } %>

                                <% if (pageNum < totalPages) { %>
                                <a href="${pageContext.request.contextPath}/MainController?action=customerLoyaltyDashboard&<%= filter %>&page=<%= pageNum + 1 %>"
                                   class="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition"><i class="fa-solid fa-chevron-right text-xs"></i></a>
                                <% } else { %>
                                <span class="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-300"><i class="fa-solid fa-chevron-right text-xs"></i></span>
                                <% } %>
                            </div>
                        </div>

                    </div>
                </div>
            </main>
        </div>
    </body>
</html>
