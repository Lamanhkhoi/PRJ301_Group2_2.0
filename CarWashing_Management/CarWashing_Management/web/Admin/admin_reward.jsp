<%@page import="java.util.*"%>
<%@page import="dto.Reward"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%--
    ============================================================
    TRANG: QUẢN LÝ VOUCHER / REWARD (Admin) - admin_reward.jsp
    Catalog đổi điểm mà khách thấy ở trang Đổi Thưởng. Layout dùng chung pattern với admin_promotion.jsp.
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include admin-auth-check bên dưới khi gắn Controller.
      2. Thay MOCK DATA: rewards -> RewardDAO.getAllRewards() (dùng lại DTO Reward có sẵn).
      3. Modal Tạo/Sửa submit lên Controller; toggle đổi isActive; xóa nên là soft delete
         (voucher khách đã đổi từ reward này vẫn phải dùng được).
    ============================================================
--%>
<%-- <%@ include file="../includes/admin-auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_ADMIN", "voucherreward");

    List<Reward> rewards
            = (List<Reward>) request.getAttribute("rewardList");

    if (rewards == null) {
        rewards = new ArrayList<>();
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Voucher &amp; Reward - SmartWash</title>
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

                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <h1 class="text-2xl font-bold text-slate-800">Quản Lý Voucher &amp; Reward</h1>
                                <p class="text-sm text-slate-500 mt-1">Catalog quà đổi điểm hiển thị ở trang Đổi Thưởng của khách hàng</p>
                            </div>
                            <button onclick="openRewardModal()" class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2.5 rounded-xl transition shadow-md shadow-blue-600/20">
                                <i class="fa-solid fa-plus"></i> Tạo reward
                            </button>
                        </div>

                        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">

                            <div class="px-6 py-4 border-b border-slate-100 flex flex-wrap gap-3">
                                <div class="relative flex-1 min-w-[220px]">
                                    <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
                                    <input id="rwSearch" onkeyup="filterTable()" type="text" placeholder="Tìm theo tên reward..."
                                           class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                </div>
                                <select id="rwType" onchange="filterTable()" class="px-4 py-2.5 rounded-xl border border-slate-200 text-sm text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                    <option value="ALL">Tất cả loại</option>
                                    <option value="DISCOUNT">Giảm giá</option>
                                    <option value="FREE_SERVICE">Dịch vụ miễn phí</option>
                                    <option value="GIFT">Quà tặng</option>
                                </select>
                            </div>

                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500">
                                        <th class="py-3 px-6 font-bold">Tên Reward</th>
                                        <th class="py-3 px-4 font-bold text-right">Điểm đổi</th>
                                        <th class="py-3 px-4 font-bold text-right">% Giảm</th>
                                        <th class="py-3 px-4 font-bold text-right">HĐ tối thiểu</th>
                                        <th class="py-3 px-4 font-bold text-right">Giảm tối đa</th>
                                        <th class="py-3 px-4 font-bold text-center">Trạng thái</th>
                                        <th class="py-3 px-6 font-bold text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="text-sm">
                                    <%
                                        for (Reward r : rewards) {

                                            boolean on = r.isActive();
                                    %>

                                    <tr class="reward-row border-b border-slate-100 hover:bg-slate-50">

                                        <td class="py-4 px-6">

                                            <p class="font-bold text-slate-800">
                                                <%= r.getRewardName()%>
                                            </p>

                                            <p class="text-xs text-slate-400 mt-1">
                                                <%= r.getDescription()%>
                                            </p>

                                        </td>

                                        <td class="py-4 px-4 text-right font-bold text-amber-600">

                                            <i class="fa-solid fa-coins mr-1"></i>

                                            <%= String.format("%,d", r.getPointsRequired())%>

                                        </td>

                                        <td class="py-4 px-4 text-right">

                                            <%= r.getDiscountPercent()%>%

                                        </td>

                                        <td class="py-4 px-4 text-right">

                                            <%= String.format("%,.0f", r.getMinBillAmount())%> đ

                                        </td>

                                        <td class="py-4 px-4 text-right">

                                            <%= String.format("%,.0f", r.getMaxDiscountAmount())%> đ

                                        </td>

                                        <td class="py-4 px-4 text-center">

                                            <button
                                                onclick="toggleActive(this)"
                                                class="toggle-btn relative inline-flex h-6 w-11 items-center rounded-full transition
                                                <%= on ? "bg-emerald-500" : "bg-slate-300"%>">

                                                <span class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition
                                                      <%= on ? "translate-x-6" : "translate-x-1"%>">
                                                </span>

                                            </button>

                                        </td>

                                        <td class="py-4 px-6 text-right">

                                            <button
                                                class="w-9 h-9 rounded-lg text-blue-600 hover:bg-blue-50">

                                                <i class="fa-solid fa-pen-to-square"></i>

                                            </button>

                                        </td>

                                    </tr>

                                    <%
                                        }
                                    %>
                                    <tr id="rwEmpty" class="hidden">
                                        <td colspan="6" class="py-12 text-center text-slate-400 text-sm">
                                            <i class="fa-regular fa-folder-open text-2xl block mb-2"></i> Không tìm thấy reward phù hợp
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL TẠO / SỬA REWARD ===== --%>
            <div id="rewardModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="rewardModalContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600"><i class="fa-solid fa-gift"></i></div>
                            <h3 id="rewardModalTitle" class="text-lg font-bold text-slate-800">Tạo reward mới</h3>
                        </div>
                        <button onclick="closeRewardModal()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-2xl"></i></button>
                    </div>

                    <%-- TODO BACKEND: bọc <form method="post"> map đúng field của DTO Reward --%>
                    <form method="post"action="${pageContext.request.contextPath}/RewardManagementController">
                        <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-5 text-sm">
                            <div class="md:col-span-2">
                                <label class="block font-semibold text-slate-600 mb-1.5">Tên reward <span class="text-red-500">*</span></label>
                                <input id="rName" name="rewardName" type="text" required placeholder="VD: Phiếu mua hàng 20.000 VNĐ" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                            </div>
                            <div class="md:col-span-2">
                                <label class="block font-semibold text-slate-600 mb-1.5">Mô tả</label>
                                <input id="rDesc" name="description" type="text" placeholder="Mô tả ngắn hiển thị trên card của khách" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                            </div>
                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">Loại reward <span class="text-red-500">*</span></label>
                                <select id="rType" onchange="toggleDiscountField()" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                    <option value="DISCOUNT">Giảm giá (voucher tiền)</option>
                                    <option value="FREE_SERVICE">Dịch vụ miễn phí</option>
                                    <option value="GIFT">Quà tặng hiện vật</option>
                                </select>
                            </div>
                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">Điểm cần đổi <span class="text-red-500">*</span></label>
                                <input id="rPoints"name="pointsRequired" type="number" min="1" required value="100"class="w-full px-4 py-2.5 rounded-xl border border-slate-200">
                            </div>
                            <div id="discountField">
                                <label class="block font-semibold text-slate-600 mb-1.5">Phần trăm giảm (%)</label>
                                <input id="rDiscount" name="discountPercent" type="number" min="0" placeholder="VD: 10 , 20,..." class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                            </div>
                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Hóa đơn tối thiểu
                                </label>

                                <input
                                    name="minBillAmount"
                                    type="number"
                                    min="0"
                                    placeholder="VD: 100000"
                                    class="w-full px-4 py-2.5 rounded-xl border">
                            </div>

                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">
                                    Giảm tối đa
                                </label>

                                <input
                                    name="maxDiscountAmount"
                                    type="number"
                                    min="0"
                                    placeholder="VD: 50000"
                                    class="w-full px-4 py-2.5 rounded-xl border">
                            </div>
                        </div>

                        <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end gap-3">
                            <button type="button" onclick="closeRewardModal()"class="px-6 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                            <button type="submit" class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition"><i class="fa-solid fa-check mr-1"></i> Lưu reward</button>
                        </div>
                </div>
            </div>

            <%-- ===== MODAL XÁC NHẬN XÓA ===== --%>
            <div id="deleteModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="deleteModalContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-sm mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="p-8 text-center">
                        <div class="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                            <i class="fa-solid fa-triangle-exclamation text-2xl text-red-500"></i>
                        </div>
                        <h3 class="text-lg font-bold text-slate-800">Xóa reward?</h3>
                        <p class="text-sm text-slate-500 mt-2">Bạn sắp xóa <span id="delName" class="font-bold text-slate-700"></span>. Voucher khách đã đổi trước đó vẫn cần dùng được (khuyến nghị soft delete).</p>
                    </div>
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                        <button onclick="closeDeleteModal()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <button onclick="closeDeleteModal()" class="flex-1 px-4 py-2.5 rounded-xl bg-red-500 text-white font-bold hover:bg-red-600 transition">Xóa</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // ===== Search + filter loại =====
            function filterTable() {
                const kw = document.getElementById('rwSearch').value.toLowerCase();
                const tp = document.getElementById('rwType').value;
                let visible = 0;
                document.querySelectorAll('.reward-row').forEach(r => {
                    const show = r.dataset.name.includes(kw) && (tp === 'ALL' || r.dataset.type === tp);
                    r.classList.toggle('hidden', !show);
                    if (show)
                        visible++;
                });
                document.getElementById('rwEmpty').classList.toggle('hidden', visible > 0);
            }

            // ===== Toggle bật/tắt (demo UI) =====
            function toggleActive(btn) {
                const knob = btn.querySelector('span');
                const on = btn.classList.contains('bg-emerald-500');
                btn.classList.toggle('bg-emerald-500', !on);
                btn.classList.toggle('bg-slate-300', on);
                knob.classList.toggle('translate-x-6', !on);
                knob.classList.toggle('translate-x-1', on);
            }

            // ===== Modal Tạo / Sửa =====
            const rModal = document.getElementById('rewardModal');
            const rContent = document.getElementById('rewardModalContent');

            function toggleDiscountField() {
                document.getElementById('discountField').style.visibility =
                        document.getElementById('rType').value === 'DISCOUNT' ? 'visible' : 'hidden';
            }

            function openRewardModal(
                    name,
                    desc,
                    points,
                    discount,
                    minBill,
                    maxDiscount) {
                const isEdit = name !== undefined;
                document.getElementById('rewardModalTitle').textContent = isEdit ? 'Sửa reward' : 'Tạo reward mới';
                document.getElementById('rName').value = isEdit ? name : '';
                document.getElementById('rDesc').value = isEdit ? desc : '';
//                document.getElementById('rType').value = isEdit ? type : 'DISCOUNT';
                document.getElementById('rPoints').value = isEdit ? points : '';
                document.getElementById('rDiscount').value = isEdit ? discount : '';
                toggleDiscountField();
                rModal.classList.remove('hidden');
                setTimeout(() => {
                    rModal.classList.remove('opacity-0');
                    rContent.classList.replace('scale-95', 'scale-100');
                }, 10);
            }
            function closeRewardModal() {
                rModal.classList.add('opacity-0');
                rContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => rModal.classList.add('hidden'), 300);
            }
            rModal.addEventListener('click', e => {
                if (e.target === rModal)
                    closeRewardModal();
            });

            // ===== Modal Xóa =====
            const dModal = document.getElementById('deleteModal');
            const dContent = document.getElementById('deleteModalContent');
            function openDeleteModal(name) {
                document.getElementById('delName').textContent = name;
                dModal.classList.remove('hidden');
                setTimeout(() => {
                    dModal.classList.remove('opacity-0');
                    dContent.classList.replace('scale-95', 'scale-100');
                }, 10);
            }
            function closeDeleteModal() {
                dModal.classList.add('opacity-0');
                dContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => dModal.classList.add('hidden'), 300);
            }
            dModal.addEventListener('click', e => {
                if (e.target === dModal)
                    closeDeleteModal();
            });
        </script>
    </body>
</html>
