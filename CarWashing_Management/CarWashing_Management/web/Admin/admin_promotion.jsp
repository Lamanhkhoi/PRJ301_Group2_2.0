<%@page import="java.util.*"%>
<%@page import="dto.Promotion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%--
    ============================================================
    TRANG: QUẢN LÝ KHUYẾN MÃI (Admin) - admin_promotion.jsp
    Bố cục: Toolbar (search + filter + nút Tạo) -> Bảng danh sách -> Modal Tạo/Sửa 

    LƯU Ý:
    Banner ở trang Ưu Đãi của Customer lấy từ field "Ảnh banner"
    của chương trình này.

    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include admin-auth-check bên dưới khi gắn Controller.
      2. Form trong modal:
            + create
            + update
      3. Toggle:
            + đổi IsActive
      
    ============================================================
--%>

<%-- <%@ include file="../includes/admin-auth-check.jsp" %> --%>

<%
    request.setAttribute("ACTIVE_ADMIN", "khuyenmai");

    List<Promotion> promos
            = (List<Promotion>) request.getAttribute("PROMOTION_LIST");

    if (promos == null) {
        promos = new ArrayList<>();
    }
    String promoError = (String) session.getAttribute("PROMO_ERROR");
    if (promoError != null) {
        session.removeAttribute("PROMO_ERROR");
    }

    java.text.SimpleDateFormat sdf
            = new java.text.SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Khuyến Mãi - SmartWash</title>
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
                    <div class="max-w-7xl mx-auto">

                        <%-- ===== HEADER + NÚT TẠO ===== --%>
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-800">Quản Lý Khuyến Mãi</h1>
                                <p class="text-sm text-slate-500 mt-1">Tạo và điều hành các chương trình ưu đãi gửi tới khách hàng theo hạng</p>
                            </div>
                            <button onclick="openPromoModal()" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2.5 rounded-xl transition shadow-md shadow-blue-600/20">
                                <i class="fa-solid fa-plus"></i> Tạo khuyến mãi
                            </button>
                        </div>

                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">

                            <%-- ===== TOOLBAR: SEARCH + FILTER ===== --%>
                            <div class="px-6 py-4 border-b border-slate-100 flex flex-wrap gap-3">
                                <div class="relative flex-1 min-w-[220px]">
                                    <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                                    <input id="promoSearch" onkeyup="filterTable()" type="text" placeholder="Tìm theo tên chương trình..."
                                           class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                </div>
                                <select id="promoStatus" onchange="filterTable()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-sm text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                    <option value="ALL">Tất cả trạng thái</option>
                                    <option value="ON">Đang chạy</option>
                                    <option value="OFF">Đang tắt</option>
                                </select>
                            </div>

                            <%-- ===== BẢNG DANH SÁCH ===== --%>
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500">
                                        <th class="py-3 px-6 font-bold">Tên chương trình</th>
                                        <th class="py-3 px-4 font-bold">Ưu đãi</th>
                                        <th class="py-3 px-4 font-bold">Áp dụng cho</th>
                                        <th class="py-3 px-4 font-bold">Thời gian</th>
                                        <th class="py-3 px-4 font-bold text-center">Trạng thái</th>
                                        <th class="py-3 px-6 font-bold text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="text-sm" id="promoBody">

                                    <%
                                        for (Promotion p : promos) {

                                            boolean on = p.isActive();

                                            String valueLabel
                                                    = "Giảm " + p.getDiscountPercent() + "%";

                                            String tierBadge
                                                    = "bg-slate-100 text-slate-600";

                                            String start
                                                    = sdf.format(p.getStartDate());

                                            String end
                                                    = sdf.format(p.getEndDate());

                                            String name
                                                    = p.getPromotionName()
                                                            .replace("'", "\\'");

                                            String desc
                                                    = p.getDescription() == null
                                                    ? ""
                                                    : p.getDescription()
                                                            .replace("'", "\\'");
                                    %>
                                    <tr class="promo-row border-b border-slate-100 hover:bg-slate-50 transition"
                                        data-name="<%=name.toLowerCase()%>"
                                        data-on="<%=on%>">

                                        <td class="py-4 px-6">

                                            <p class="font-bold text-slate-800">
                                                <%=p.getPromotionName()%>
                                            </p>

                                            <p class="text-xs text-slate-400 mt-0.5">
                                                <%=p.getDescription()%>
                                            </p>

                                        </td>

                                        <td class="py-4 px-4 font-semibold text-slate-700">
                                            <%=valueLabel%>
                                        </td>

                                        <td class="py-4 px-4">

                                            <span class="text-xs font-bold px-2.5 py-1 rounded-full <%=tierBadge%>">
                                                Áp dụng chung
                                            </span>

                                        </td>

                                        <td class="py-4 px-4 text-slate-500 text-xs whitespace-nowrap">

                                            <%=start%>

                                            <i class="fa-solid fa-arrow-right-long mx-1 text-slate-300"></i>

                                            <%=end%>

                                        </td>

                                        <td class="py-4 px-4 text-center">

                                            <button
                                                onclick="location.href = '<%=request.getContextPath()%>/MainController?action=promotionManagement&promotionAction=toggle&id=<%=p.getPromotionId()%>'"
                                                class="relative inline-flex h-6 w-11 items-center rounded-full transition
                                                <%=on ? "bg-emerald-500" : "bg-slate-300"%>">

                                                <span
                                                    class="inline-block h-4 w-4 rounded-full bg-white shadow transition
                                                    <%=on ? "translate-x-6" : "translate-x-1"%>">
                                                </span>

                                            </button>

                                        </td>

                                        <td class="py-4 px-6 text-right whitespace-nowrap">

                                            <button
                                                onclick="openPromoModal([
                                                            '<%=p.getPromotionId()%>',
                                                            '<%=name%>',
                                                            '<%=desc%>',
                                                            '<%=p.getDiscountPercent()%>',
                                                            '<%=p.getMinBillAmount()%>',
                                                            '<%=p.getMaxDiscountAmount()%>',
                                                            '<%=start%>',
                                                            '<%=end%>'
                                                        ])"
                                                class="w-9 h-9 rounded-lg text-blue-600 hover:bg-blue-50 transition"
                                                title="Sửa">

                                                <i class="fa-solid fa-pen-to-square"></i>

                                            </button>

                                        </td>

                                    </tr>

                                    <%
                                        }
                                    %>
                                    <tr id="promoEmpty" class="hidden">
                                        <td colspan="6" class="py-12 text-center text-slate-400 text-sm">
                                            <i class="fa-regular fa-folder-open text-2xl block mb-2"></i> Không tìm thấy chương trình phù hợp
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL TẠO / SỬA KHUYẾN MÃI ===== --%>

            <div id="promoModal"
                 class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">

                <div id="promoModalContent"
                     class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300">

                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">

                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                                <i class="fa-solid fa-bullhorn"></i>
                            </div>

                            <h3 id="promoModalTitle"
                                class="text-lg font-bold text-slate-800">
                                Tạo khuyến mãi mới
                            </h3>
                        </div>

                        <button type="button"
                                onclick="closePromoModal()"
                                class="text-slate-400 hover:text-red-500 transition">
                            <i class="fa-solid fa-xmark text-2xl"></i>
                        </button>

                    </div>

                    <form method="post" action="<%=request.getContextPath()%>/MainController">

                        <input type="hidden"
                               name="action"
                               value="promotionManagement">

                        <input type="hidden"
                               name="promotionAction"
                               id="promoAction"
                               value="create">

                        <input type="hidden"
                               name="promotionId"
                               id="promotionId">

                        <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-5 text-sm">

                            <div class="md:col-span-2">

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Tên chương trình
                                </label>

                                <input
                                    id="fName"
                                    name="promotionName"
                                    type="text"
                                    required
                                    class="w-full px-4 py-2.5 rounded-xl border border-slate-200">

                            </div>

                            <div class="md:col-span-2">

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Mô tả
                                </label>

                                <textarea
                                    id="fDesc"
                                    name="description"
                                    rows="3"
                                    class="w-full px-4 py-2.5 rounded-xl border border-slate-200"></textarea>

                            </div>

                            <div>

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    % Giảm
                                </label>

                                <input
                                    id="fValue"
                                    name="discountPercent"
                                    type="number"
                                    min="1"
                                    max="100"
                                    required
                                    class="w-full px-4 py-2.5 rounded-xl border border-slate-200">

                            </div>

                            <div>

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Hóa đơn tối thiểu
                                </label>

                                <input
                                    id="fMinBill"
                                    name="minBillAmount"
                                    type="number"
                                    value="0"
                                    class="w-full px-4 py-2.5 rounded-xl border border-slate-200">

                            </div>

                            <div>

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Giảm tối đa
                                </label>

                                <input
                                    id="fMaxDiscount"
                                    name="maxDiscountAmount"
                                    type="number"
                                    required
                                    class="w-full px-4 py-2.5 rounded-xl border border-slate-200">

                            </div>

                            <div>

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Từ ngày
                                </label>

                                <input
                                    id="fStart"
                                    name="startDate"
                                    type="date"
                                    required
                                    class="w-full px-3 py-2.5 rounded-xl border border-slate-200">

                            </div>

                            <div>

                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Đến ngày
                                </label>

                                <input
                                    id="fEnd"
                                    name="endDate"
                                    type="date"
                                    required
                                    class="w-full px-3 py-2.5 rounded-xl border border-slate-200">

                            </div>

                        </div>

                        <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end gap-3">

                            <button
                                type="button"
                                onclick="closePromoModal()"
                                class="px-6 py-2.5 rounded-xl border border-slate-300">

                                Hủy

                            </button>

                            <button
                                id="btnSavePromotion"
                                type="submit"
                                class="px-6 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold transition">

                                <i class="fa-solid fa-check mr-1"></i>

                                <span id="btnSaveText">
                                    Lưu chương trình
                                </span>

                            </button>

                        </div>

                    </form>

                </div>

            </div>

            
        </div>

        <script>
            // ===== Search + filter trạng thái (client-side trên mock data) =====
            function filterTable() {
                const kw = document.getElementById('promoSearch').value.toLowerCase();
                const st = document.getElementById('promoStatus').value;
                let visible = 0;
                document.querySelectorAll('.promo-row').forEach(r => {
                    const okName = r.dataset.name.includes(kw);
                    const okStatus = st === 'ALL' || (st === 'ON') === (r.dataset.on === 'true');
                    const show = okName && okStatus;
                    r.classList.toggle('hidden', !show);
                    if (show)
                        visible++;
                });
                document.getElementById('promoEmpty').classList.toggle('hidden', visible > 0);
            }

            // ===== Toggle bật/tắt (demo UI - backend sẽ gọi Controller thật) =====
            function toggleActive(btn) {
                const knob = btn.querySelector('span');
                const on = btn.classList.contains('bg-emerald-500');
                btn.classList.toggle('bg-emerald-500', !on);
                btn.classList.toggle('bg-slate-300', on);
                knob.classList.toggle('translate-x-6', !on);
                knob.classList.toggle('translate-x-1', on);
                btn.closest('tr').dataset.on = String(!on);
            }

            // ===== Modal Tạo / Sửa =====

            const pModal = document.getElementById('promoModal');
            const pContent = document.getElementById('promoModalContent');

            function clearForm() {

                document.getElementById("promoAction").value = "create";

                document.getElementById("promotionId").value = "";

                document.getElementById("promoModalTitle").innerHTML =
                        "Tạo khuyến mãi mới";

                document.getElementById("btnSaveText").innerHTML =
                        "Lưu chương trình";

                document.getElementById("fName").value = "";

                document.getElementById("fDesc").value = "";

                document.getElementById("fValue").value = "";

                document.getElementById("fMinBill").value = "0";

                document.getElementById("fMaxDiscount").value = "";

                document.getElementById("fStart").value = "";

                document.getElementById("fEnd").value = "";

            }

            function openPromoModal(data) {

                clearForm();

                if (Array.isArray(data)) {

                    document.getElementById("promoAction").value = "update";

                    document.getElementById("promotionId").value = data[0];

                    document.getElementById("promoModalTitle").innerHTML =
                            "Cập nhật khuyến mãi";

                    document.getElementById("btnSaveText").innerHTML =
                            "Cập nhật";

                    document.getElementById("fName").value = data[1];

                    document.getElementById("fDesc").value = data[2];

                    document.getElementById("fValue").value = data[3];

                    document.getElementById("fMinBill").value = data[4];

                    document.getElementById("fMaxDiscount").value = data[5];

                    document.getElementById("fStart").value = data[6];

                    document.getElementById("fEnd").value = data[7];
                }

                pModal.classList.remove("hidden");

                setTimeout(function () {

                    pModal.classList.remove("opacity-0");

                    pContent.classList.remove("scale-95");

                    pContent.classList.add("scale-100");

                }, 10);

            }

            function closePromoModal() {

                pModal.classList.add("opacity-0");

                pContent.classList.remove("scale-100");

                pContent.classList.add("scale-95");

                setTimeout(function () {

                    pModal.classList.add("hidden");

                }, 300);

            }

            pModal.addEventListener("click", function (e) {

                if (e.target === pModal) {

                    closePromoModal();

                }

            });
            document.querySelector('#promoModal form').addEventListener('submit', function (e) {
                const start = document.getElementById('fStart').value;
                const end = document.getElementById('fEnd').value;
                if (start && end && start === end) {
                    e.preventDefault();
                    alert('Không thể tạo khuyến mãi có thời hạn chỉ trong 1 ngày! Vui lòng chọn "Từ ngày" và "Đến ngày" khác nhau.');
                }
            });
            <% if (promoError != null) {%>
            window.addEventListener('DOMContentLoaded', function () {
                alert('<%= promoError.replace("'", "\\'")%>');
            });
            <% }%>
        </script>
    </body>
</html>
