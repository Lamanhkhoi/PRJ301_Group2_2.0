<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: QUẢN LÝ KHUYẾN MÃI (Admin) - admin_promotion.jsp
    Bố cục: Toolbar (search + filter + nút Tạo) -> Bảng danh sách -> Modal Tạo/Sửa -> Modal Xóa
    LƯU Ý: Banner ở trang Ưu Đãi của Customer lấy từ field "Ảnh banner" của chương trình này.
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include admin-auth-check bên dưới khi gắn Controller.
      2. DB đang làm lại nên CHƯA có DTO Promotion -> mock bằng mảng String bên dưới.
         Khi có DTO Promotion thì thay bằng List<Promotion> từ PromotionDAO.
      3. Form trong modal: gắn action POST tới Controller (create/update),
         toggle -> Controller đổi isActive, nút xóa -> Controller delete (nên soft delete).
    ============================================================
--%>
<%-- <%@ include file="../includes/admin-auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_ADMIN", "khuyenmai");

    // ================= MOCK DATA - THAY BẰNG List<Promotion> KHI CÓ DTO =================
    // {id, Tên, Mô tả, Loại (PERCENT/AMOUNT/POINT), Giá trị, Hạng áp dụng, Từ ngày, Đến ngày, Đang bật, URL banner}
    String[][] promos = {
        {"1", "Giảm 20% mùa hè", "Áp dụng mọi gói rửa xe", "PERCENT", "20", "Silver+", "2026-07-01", "2026-07-31", "true", "banner_summer.png"},
        {"2", "Tặng 50 P sinh nhật", "Quà sinh nhật cho khách thân thiết", "POINT", "50", "Gold+", "2026-01-01", "2026-12-31", "false", ""},
        {"3", "Combo rửa + wax -15%", "Tuần lễ vàng, áp dụng mọi hạng", "PERCENT", "15", "Tất cả", "2026-07-10", "2026-07-20", "true", "banner_combo.png"},
        {"4", "Giảm 30.000đ gói Premium", "Chỉ áp dụng thứ 2 - thứ 4", "AMOUNT", "30000", "Platinum", "2026-08-01", "2026-08-31", "true", ""}
    };
    // =====================================================================================
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Khuyến Mãi - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>body { font-family: 'Inter', sans-serif; background-color: #F1F5F9; }</style>
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
                                    <% for (String[] p : promos) {
                                        boolean on = "true".equals(p[8]);
                                        String valueLabel = "PERCENT".equals(p[3]) ? "Giảm " + p[4] + "%"
                                                          : "AMOUNT".equals(p[3]) ? "Giảm " + String.format("%,d", Integer.parseInt(p[4])) + "đ"
                                                          : "Tặng " + p[4] + " P";
                                        String tierBadge = "Tất cả".equals(p[5]) ? "bg-slate-100 text-slate-600"
                                                         : p[5].startsWith("Silver") ? "bg-blue-100 text-blue-700"
                                                         : p[5].startsWith("Gold") ? "bg-amber-100 text-amber-700" : "bg-purple-100 text-purple-700";
                                    %>
                                    <tr class="promo-row border-b border-slate-100 hover:bg-slate-50 transition" data-name="<%= p[1].toLowerCase() %>" data-on="<%= on %>">
                                        <td class="py-4 px-6">
                                            <p class="font-bold text-slate-800"><%= p[1] %></p>
                                            <p class="text-xs text-slate-400 mt-0.5"><%= p[2] %></p>
                                        </td>
                                        <td class="py-4 px-4 font-semibold text-slate-700"><%= valueLabel %></td>
                                        <td class="py-4 px-4"><span class="text-xs font-bold px-2.5 py-1 rounded-full <%= tierBadge %>"><%= p[5] %></span></td>
                                        <td class="py-4 px-4 text-slate-500 text-xs whitespace-nowrap"><%= p[6] %> <i class="fa-solid fa-arrow-right-long mx-1 text-slate-300"></i> <%= p[7] %></td>
                                        <td class="py-4 px-4 text-center">
                                            <%-- TODO BACKEND: onclick gọi Controller đổi isActive rồi reload --%>
                                            <button onclick="toggleActive(this)" class="toggle-btn relative inline-flex h-6 w-11 items-center rounded-full transition <%= on ? "bg-emerald-500" : "bg-slate-300" %>">
                                                <span class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition <%= on ? "translate-x-6" : "translate-x-1" %>"></span>
                                            </button>
                                        </td>
                                        <td class="py-4 px-6 text-right whitespace-nowrap">
                                            <button onclick='openPromoModal(<%= "[\"" + String.join("\",\"", p) + "\"]" %>)'
                                                    class="w-9 h-9 rounded-lg text-blue-600 hover:bg-blue-50 transition" title="Sửa">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </button>
                                            <button onclick="openDeleteModal('<%= p[1] %>')" class="w-9 h-9 rounded-lg text-red-500 hover:bg-red-50 transition" title="Xóa">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <% } %>
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
            <div id="promoModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="promoModalContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600"><i class="fa-solid fa-bullhorn"></i></div>
                            <h3 id="promoModalTitle" class="text-lg font-bold text-slate-800">Tạo khuyến mãi mới</h3>
                        </div>
                        <button onclick="closePromoModal()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-2xl"></i></button>
                    </div>

                    <%-- TODO BACKEND: bọc <form method="post" action="..."> và thêm input hidden promoId --%>
                    <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-5 text-sm">
                        <div class="md:col-span-2">
                            <label class="block font-semibold text-slate-600 mb-1.5">Tên chương trình <span class="text-red-500">*</span></label>
                            <input id="fName" type="text" placeholder="VD: Giảm 20% mùa hè" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div class="md:col-span-2">
                            <label class="block font-semibold text-slate-600 mb-1.5">Mô tả</label>
                            <textarea id="fDesc" rows="2" placeholder="Mô tả ngắn hiển thị trên banner của khách" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition resize-none"></textarea>
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Loại ưu đãi <span class="text-red-500">*</span></label>
                            <select id="fType" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                <option value="PERCENT">Giảm theo %</option>
                                <option value="AMOUNT">Giảm số tiền (VNĐ)</option>
                                <option value="POINT">Tặng điểm thưởng</option>
                            </select>
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Giá trị <span class="text-red-500">*</span></label>
                            <input id="fValue" type="number" min="0" placeholder="VD: 20" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Áp dụng cho hạng</label>
                            <select id="fTier" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                <option>Tất cả</option>
                                <option>Silver+</option>
                                <option>Gold+</option>
                                <option>Platinum</option>
                            </select>
                        </div>
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">Từ ngày</label>
                                <input id="fStart" type="date" class="w-full px-3 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 text-slate-600">
                            </div>
                            <div>
                                <label class="block font-semibold text-slate-600 mb-1.5">Đến ngày</label>
                                <input id="fEnd" type="date" class="w-full px-3 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 text-slate-600">
                            </div>
                        </div>
                        <div class="md:col-span-2">
                            <label class="block font-semibold text-slate-600 mb-1.5">Ảnh banner (hiển thị ở trang Ưu Đãi của khách)</label>
                            <input id="fBanner" type="text" placeholder="URL hoặc tên file ảnh, VD: banner_summer.png" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                    </div>

                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end gap-3">
                        <button onclick="closePromoModal()" class="px-6 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <button onclick="closePromoModal()" class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition"><i class="fa-solid fa-check mr-1"></i> Lưu chương trình</button>
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
                        <h3 class="text-lg font-bold text-slate-800">Xóa chương trình?</h3>
                        <p class="text-sm text-slate-500 mt-2">Bạn sắp xóa <span id="delName" class="font-bold text-slate-700"></span>. Hành động này không thể hoàn tác.</p>
                    </div>
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                        <button onclick="closeDeleteModal()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <%-- TODO BACKEND: submit form xóa (khuyến nghị soft delete: set isDeleted = 1) --%>
                        <button onclick="closeDeleteModal()" class="flex-1 px-4 py-2.5 rounded-xl bg-red-500 text-white font-bold hover:bg-red-600 transition">Xóa</button>
                    </div>
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
                    if (show) visible++;
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

            function openPromoModal(data) {
                const isEdit = Array.isArray(data);
                document.getElementById('promoModalTitle').textContent = isEdit ? 'Sửa khuyến mãi' : 'Tạo khuyến mãi mới';
                document.getElementById('fName').value = isEdit ? data[1] : '';
                document.getElementById('fDesc').value = isEdit ? data[2] : '';
                document.getElementById('fType').value = isEdit ? data[3] : 'PERCENT';
                document.getElementById('fValue').value = isEdit ? data[4] : '';
                document.getElementById('fTier').value = isEdit ? data[5] : 'Tất cả';
                document.getElementById('fStart').value = isEdit ? data[6] : '';
                document.getElementById('fEnd').value = isEdit ? data[7] : '';
                document.getElementById('fBanner').value = isEdit ? data[9] : '';
                pModal.classList.remove('hidden');
                setTimeout(() => { pModal.classList.remove('opacity-0'); pContent.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closePromoModal() {
                pModal.classList.add('opacity-0');
                pContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => pModal.classList.add('hidden'), 300);
            }
            pModal.addEventListener('click', e => { if (e.target === pModal) closePromoModal(); });

            // ===== Modal Xóa =====
            const dModal = document.getElementById('deleteModal');
            const dContent = document.getElementById('deleteModalContent');
            function openDeleteModal(name) {
                document.getElementById('delName').textContent = name;
                dModal.classList.remove('hidden');
                setTimeout(() => { dModal.classList.remove('opacity-0'); dContent.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closeDeleteModal() {
                dModal.classList.add('opacity-0');
                dContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => dModal.classList.add('hidden'), 300);
            }
            dModal.addEventListener('click', e => { if (e.target === dModal) closeDeleteModal(); });
        </script>
    </body>
</html>
