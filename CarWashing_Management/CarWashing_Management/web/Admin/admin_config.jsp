<%@page import="java.util.*"%>
<%@page import="dto.LoyaltyTier"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%--
    ============================================================
    TRANG: CẤU HÌNH HỆ THỐNG (Admin) - admin_config.jsp
    Bố cục: Card cấu hình chung (point rate, hạn điểm, chu kỳ xét hạng)
            -> Bảng 4 hạng thành viên (LoyaltyTier), nút Sửa mở modal chỉnh giá trị quy đổi
            -> Nút Khôi phục mặc định + banner cảnh báo
    TODO BACKEND (người phụ trách chức năng):
      1. Mở comment dòng include admin-auth-check bên dưới khi gắn Controller.
      2. Thay MOCK DATA: tiers -> DAO đọc bảng LoyaltyTier (dùng lại DTO có sẵn).
         Cấu hình chung -> bảng SystemConfig trong DB mới (key-value).
      3. Nút "Lưu" của modal + card cấu hình chung: submit POST tới Controller update.
    ============================================================
--%>
<%-- <%@ include file="../includes/admin-auth-check.jsp" %> --%>
<%
    request.setAttribute("ACTIVE_ADMIN", "cauhinh");

    // ================= MOCK DATA - XÓA KHI GẮN BACKEND =================
    List<LoyaltyTier> tiers = new ArrayList<>();
    // {id, tên, số lần rửa tối thiểu, chi tiêu tối thiểu, bonus %, số ngày đặt trước, free upgrade, free wash}
    Object[][] seed = {
        {1, "Member", 1, 0d, 0d, 7, false, false},
        {2, "Silver", 5, 2000000d, 0.10d, 10, false, false},
        {3, "Gold", 15, 6000000d, 0.20d, 12, true, false},
        {4, "Platinum", 30, 15000000d, 0.30d, 14, true, true}
    };
    for (Object[] s : seed) {
        LoyaltyTier t = new LoyaltyTier();
        t.setTierId((Integer) s[0]);
        t.setTierName((String) s[1]);
        t.setMinWashCount((Integer) s[2]);
        t.setMinTotalSpent((Double) s[3]);
        t.setBonusPointRate((Double) s[4]);
        t.setBookingWindowDays((Integer) s[5]);
        t.setFreeUpgradeMonthly((Boolean) s[6]);
        t.setFreeWashMonthly((Boolean) s[7]);
        tiers.add(t);
    }
    String[] tierIcons = {"fa-user", "fa-shield-halved", "fa-crown", "fa-gem"};
    String[] tierIconColors = {"text-slate-400", "text-gray-500", "text-yellow-500", "text-purple-500"};
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
        <style>body { font-family: 'Inter', sans-serif; background-color: #F1F5F9; }</style>
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
                            <button onclick="openResetModal()" class="inline-flex items-center gap-2 bg-white border border-slate-300 hover:bg-slate-50 text-slate-600 text-sm font-bold px-5 py-2.5 rounded-xl transition">
                                <i class="fa-solid fa-rotate-left"></i> Khôi phục mặc định
                            </button>
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
                                <button class="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold px-5 py-2 rounded-xl transition">
                                    <i class="fa-solid fa-floppy-disk"></i> Lưu
                                </button>
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-5 text-sm">
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Point rate cơ bản</label>
                                    <div class="flex items-center gap-2">
                                        <span class="text-slate-500 font-medium whitespace-nowrap">1 P =</span>
                                        <input type="number" value="1000" min="0" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                        <span class="text-slate-500 font-medium">VNĐ</span>
                                    </div>
                                </div>
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Hạn sử dụng điểm (tháng)</label>
                                    <input type="number" value="12" min="1" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                                </div>
                                <div>
                                    <label class="block font-semibold text-slate-600 mb-1.5">Chu kỳ xét hạng (auto up/down)</label>
                                    <select class="w-full px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
                                        <option selected>Hàng tháng</option>
                                        <option>Hàng quý</option>
                                        <option>Hàng năm</option>
                                    </select>
                                </div>
                            </div>
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
                                    <% for (int i = 0; i < tiers.size(); i++) {
                                        LoyaltyTier t = tiers.get(i);
                                        int bonusPct = (int) Math.round(t.getBonusPointRate() * 100);
                                    %>
                                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                                        <td class="py-4 px-6 font-bold text-slate-700 whitespace-nowrap">
                                            <i class="fa-solid <%= tierIcons[i] %> <%= tierIconColors[i] %> mr-2"></i><%= t.getTierName() %>
                                        </td>
                                        <td class="py-4 px-4 text-slate-600">
                                            <% if (i == 0) { %>Đăng ký + 1 lần rửa xe<% } else { %>
                                            <%= t.getMinWashCount() %> lần rửa <span class="text-slate-400 font-semibold text-xs mx-1">HOẶC</span> <%= String.format("%,.0f", t.getMinTotalSpent()) %> VNĐ
                                            <% } %>
                                        </td>
                                        <td class="py-4 px-4 text-center font-bold <%= bonusPct > 0 ? "text-emerald-600" : "text-slate-400" %>">+<%= bonusPct %>%</td>
                                        <td class="py-4 px-4 text-center text-slate-600 font-medium"><%= t.getBookingWindowDays() %> ngày</td>
                                        <td class="py-4 px-4">
                                            <% if (t.isFreeWashMonthly()) { %><span class="text-xs font-bold px-2.5 py-1 rounded-full bg-purple-100 text-purple-700 mr-1">1 lần rửa free</span><% } %>
                                            <% if (t.isFreeUpgradeMonthly()) { %><span class="text-xs font-bold px-2.5 py-1 rounded-full bg-amber-100 text-amber-700">Free nâng cấp</span><% } %>
                                            <% if (!t.isFreeWashMonthly() && !t.isFreeUpgradeMonthly()) { %><span class="text-xs text-slate-400">—</span><% } %>
                                        </td>
                                        <td class="py-4 px-6 text-right">
                                            <button onclick="openTierModal('<%= t.getTierName() %>', <%= t.getMinWashCount() %>, <%= (long) t.getMinTotalSpent() %>, <%= bonusPct %>, <%= t.getBookingWindowDays() %>, <%= t.isFreeUpgradeMonthly() %>, <%= t.isFreeWashMonthly() %>)"
                                                    class="inline-flex items-center gap-1.5 text-sm font-bold text-blue-600 border border-blue-200 hover:bg-blue-50 rounded-lg px-4 py-1.5 transition">
                                                <i class="fa-solid fa-pen-to-square text-xs"></i> Sửa
                                            </button>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </main>

            <%-- ===== MODAL SỬA HẠNG ===== --%>
            <div id="tierModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="tierModalContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-xl mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="bg-slate-50 px-6 py-5 border-b border-slate-100 flex justify-between items-center">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600"><i class="fa-solid fa-ranking-star"></i></div>
                            <h3 class="text-lg font-bold text-slate-800">Sửa hạng <span id="tName" class="text-blue-600"></span></h3>
                        </div>
                        <button onclick="closeTierModal()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-2xl"></i></button>
                    </div>

                    <%-- TODO BACKEND: bọc <form method="post"> map đúng field LoyaltyTier + input hidden tierId --%>
                    <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-5 text-sm">
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Số lần rửa tối thiểu</label>
                            <input id="tWash" type="number" min="0" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Chi tiêu tối thiểu (VNĐ)</label>
                            <input id="tSpent" type="number" min="0" step="100000" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Bonus điểm (%)</label>
                            <input id="tBonus" type="number" min="0" max="100" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div>
                            <label class="block font-semibold text-slate-600 mb-1.5">Đặt lịch trước (ngày)</label>
                            <input id="tWindow" type="number" min="1" max="30" class="w-full px-4 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 transition">
                        </div>
                        <div class="md:col-span-2 flex flex-wrap gap-6 pt-1">
                            <label class="inline-flex items-center gap-2.5 cursor-pointer font-medium text-slate-600">
                                <input id="tUpgrade" type="checkbox" class="w-4 h-4 rounded accent-blue-600"> Miễn phí nâng cấp dịch vụ hàng tháng
                            </label>
                            <label class="inline-flex items-center gap-2.5 cursor-pointer font-medium text-slate-600">
                                <input id="tFreeWash" type="checkbox" class="w-4 h-4 rounded accent-blue-600"> 1 lần rửa xe miễn phí hàng tháng
                            </label>
                        </div>
                    </div>

                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex justify-end gap-3">
                        <button onclick="closeTierModal()" class="px-6 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <button onclick="closeTierModal()" class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-bold hover:bg-blue-700 transition"><i class="fa-solid fa-check mr-1"></i> Lưu thay đổi</button>
                    </div>
                </div>
            </div>

            <%-- ===== MODAL KHÔI PHỤC MẶC ĐỊNH ===== --%>
            <div id="resetModal" class="fixed inset-0 z-[9999] hidden flex items-center justify-center bg-slate-900/60 backdrop-blur-sm transition-opacity opacity-0">
                <div id="resetModalContent" class="bg-white rounded-2xl shadow-2xl w-full max-w-sm mx-4 overflow-hidden transform scale-95 transition-transform duration-300">
                    <div class="p-8 text-center">
                        <div class="w-16 h-16 rounded-full bg-amber-100 flex items-center justify-center mx-auto mb-4">
                            <i class="fa-solid fa-rotate-left text-2xl text-amber-500"></i>
                        </div>
                        <h3 class="text-lg font-bold text-slate-800">Khôi phục cấu hình mặc định?</h3>
                        <p class="text-sm text-slate-500 mt-2">Toàn bộ point rate, điều kiện lên hạng và đặc quyền sẽ quay về giá trị ban đầu theo đề bài.</p>
                    </div>
                    <div class="bg-slate-50 px-6 py-4 border-t border-slate-100 flex gap-3">
                        <button onclick="closeResetModal()" class="flex-1 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-100 transition">Hủy</button>
                        <button onclick="closeResetModal()" class="flex-1 px-4 py-2.5 rounded-xl bg-amber-500 text-white font-bold hover:bg-amber-600 transition">Khôi phục</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // ===== Modal sửa hạng: đổ dữ liệu hàng được chọn vào form =====
            const tModal = document.getElementById('tierModal');
            const tContent = document.getElementById('tierModalContent');

            function openTierModal(name, wash, spent, bonus, window_, upgrade, freeWash) {
                document.getElementById('tName').textContent = name;
                document.getElementById('tWash').value = wash;
                document.getElementById('tSpent').value = spent;
                document.getElementById('tBonus').value = bonus;
                document.getElementById('tWindow').value = window_;
                document.getElementById('tUpgrade').checked = upgrade;
                document.getElementById('tFreeWash').checked = freeWash;
                tModal.classList.remove('hidden');
                setTimeout(() => { tModal.classList.remove('opacity-0'); tContent.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closeTierModal() {
                tModal.classList.add('opacity-0');
                tContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => tModal.classList.add('hidden'), 300);
            }
            tModal.addEventListener('click', e => { if (e.target === tModal) closeTierModal(); });

            // ===== Modal khôi phục mặc định =====
            const rsModal = document.getElementById('resetModal');
            const rsContent = document.getElementById('resetModalContent');
            function openResetModal() {
                rsModal.classList.remove('hidden');
                setTimeout(() => { rsModal.classList.remove('opacity-0'); rsContent.classList.replace('scale-95', 'scale-100'); }, 10);
            }
            function closeResetModal() {
                rsModal.classList.add('opacity-0');
                rsContent.classList.replace('scale-100', 'scale-95');
                setTimeout(() => rsModal.classList.add('hidden'), 300);
            }
            rsModal.addEventListener('click', e => { if (e.target === rsModal) closeResetModal(); });
        </script>
    </body>
</html>
