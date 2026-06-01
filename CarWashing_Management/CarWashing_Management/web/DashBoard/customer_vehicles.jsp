<%@ include file="/includes/auth-check.jsp" %>
<%@page import="java.util.List"%>
<%@page import="dto.Vehicle"%>
<%@page import="dao.CustomerVehicleDAO"%>
<%@page import="dto.Customer"%>
<%@page import="dto.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Xe Của Tôi - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .mesh-gradient-header {
                background-color: #0f172a;
                background-image: radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            }
            
            /* CSS ĐIỀU KHIỂN HIỆU ỨNG TRƯỢT CỦA TOAST ALERT */
            #toastBox {
                transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease;
                transform: translateX(120%);
                opacity: 0;
            }
            #toastBox.show {
                transform: translateX(0);
                opacity: 1;
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">
        <%
            String alertType = (String) request.getAttribute("ALERT_TYPE");
            String alertMsg = (String) request.getAttribute("ALERT_MSG");
        %>

        <%-- 1. HỆ THỐNG TOAST ALERT --%>
        <% if (alertMsg != null) { %>
        <div id="toastBox" class="fixed top-6 right-6 z-50 flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border max-w-sm bg-white border-slate-100">
            <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg <%= "success".equals(alertType) ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600" %>">
                <i class="<%= "success".equals(alertType) ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation" %>"></i>
            </div>
            <div class="flex-1">
                <h4 class="font-bold text-slate-800 text-sm"><%= "success".equals(alertType) ? "Thành công" : "Thông báo lỗi" %></h4>
                <p class="text-slate-500 text-xs mt-0.5"><%= alertMsg %></p>
            </div>
            <button onclick="closeToast()" class="text-slate-400 hover:text-slate-600 transition ml-2">
                <i class="fa-solid fa-xmark text-sm"></i>
            </button>
        </div>
        <% } %>

        <div class="flex h-screen overflow-hidden relative">

            <%-- SIDEBAR DASHBOARD --%>
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />
            
            <%
                // Lấy danh sách xe thực tế qua ID của khách hàng
                CustomerVehicleDAO vehicleDAO = new CustomerVehicleDAO();
                List<Vehicle> vehicleList = vehicleDAO.getAllVehicles(cus.getCustomerId());
            %>
            
            <main class="flex-1 flex flex-col overflow-hidden relative">
                
                <%-- 2. THANH TIÊU ĐỀ TOPBAR --%>
                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">
                    
                    <%-- THANH ĐIỀU HƯỚNG CHỨC NĂNG --%>
                    <div class="flex justify-between items-center mb-8">
                        <div class="flex items-center gap-4">
                            <button onclick="openAdvancedFilter()" class="w-12 h-12 rounded-full bg-white border border-slate-200 text-slate-600 hover:text-[#464BE5] hover:border-[#464BE5] shadow-sm flex items-center justify-center transition-all group" title="Tìm kiếm & Lọc xe">
                                <i class="fa-solid fa-magnifying-glass text-lg group-hover:scale-110 transition-transform"></i>
                            </button>
                        </div>
                        
                        <button onclick="openModal('add')" class="bg-[#464BE5] hover:bg-blue-700 text-white font-semibold py-2.5 px-6 rounded-xl shadow-md transition-colors flex items-center gap-2">
                            <i class="fa-solid fa-plus"></i> Thêm Xe Mới
                        </button>
                    </div>

                    <%-- 3. GRID DANH SÁCH XE DỮ LIỆU THỰC TẾ --%>
                    <div id="vehicle-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <% 
                            if (vehicleList != null && !vehicleList.isEmpty()) {
                                for (Vehicle v : vehicleList) {
                                    if (v.getIsActive()) {
                        %>
                        <div class="vehicle-card bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative hover:shadow-md transition-shadow" data-id="<%= v.getVehicleId()%>">
                            <div class="p-6">
                                <div class="flex items-center gap-4 mb-4 border-b border-slate-100 pb-4">
                                    <div class="w-16 h-16 bg-slate-50 rounded-xl border border-slate-100 flex items-center justify-center p-2">
                                        <img src="https://cdn-icons-png.flaticon.com/512/3204/3204005.png" class="w-full h-full object-contain opacity-80">
                                    </div>
                                    <div>
                                        <h3 class="val-plate font-mono text-2xl font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded border border-slate-300 inline-block"><%= v.getLicensePlate()%></h3>
                                    </div>
                                </div>
                                <div class="space-y-2 mb-6 text-sm">
                                    <div class="flex justify-between"><span class="text-slate-500">Hãng xe:</span><span class="val-brand font-semibold text-slate-800"><%= v.getBrand()%></span></div>
                                    <div class="flex justify-between"><span class="text-slate-500">Dòng xe:</span><span class="val-model font-semibold text-slate-800"><%= v.getModel()%></span></div>
                                    <div class="flex justify-between"><span class="text-slate-500">Màu sắc:</span><span class="val-color font-semibold text-slate-800"><%= v.getColor()%></span></div>
                                </div>
                                <div class="flex gap-3">
                                    <button type="button" onclick="openModal('edit', this)" class="flex-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 border border-emerald-200">
                                        <i class="fa-solid fa-pen"></i> Sửa
                                    </button>

                                    <form action="<%= request.getContextPath() %>/VehicleController" method="POST" class="flex-1 m-0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phương tiện này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="vehicleId" value="<%= v.getVehicleId()%>">
                                        <button type="submit" class="w-full bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 border border-red-200">
                                            <i class="fa-solid fa-trash-can"></i> Xóa
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <%          }
                                }
                            } else { 
                        %>
                            <div class="col-span-full text-center py-12 text-slate-400 font-medium">Bạn chưa đăng ký phương tiện nào.</div>
                        <%  } %>
                    </div>
                </div>
            </main>

            <%-- MODAL BỘ LỌC TÌM KIẾM NÂNG CAO (ĐÃ ĐỔI THÀNH INPUT TEXT) --%>
            <div id="advancedFilterModal" class="fixed inset-0 z-[100] hidden flex items-center justify-center bg-[#111827]/60 backdrop-blur-sm transition-all duration-300 opacity-0">
                <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md mx-4 relative overflow-hidden transform scale-95 transition-transform duration-300" id="filterModalContent">
                    <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                        <h3 class="text-lg font-bold text-slate-800 flex items-center gap-2"><i class="fa-solid fa-sliders text-[#464BE5]"></i> Tìm Kiếm & Bộ Lọc</h3>
                        <button onclick="closeAdvancedFilter()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-xl"></i></button>
                    </div>

                    <form action="customer_vehicles.jsp" method="GET" class="p-6 space-y-4">
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe / Từ khóa</label>
                            <div class="relative">
                                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <i class="fa-solid fa-magnifying-glass text-slate-400"></i>
                                </div>
                                <input type="text" name="searchQuery" placeholder="VD: 51H-123.45..." class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Hãng xe</label>
                                <input type="text" name="filterBrand" placeholder="VD: VinFast, Mazda..." class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe</label>
                                <input type="text" name="filterModel" placeholder="VD: VF8, CX-5..." class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc (Vehicle Color)</label>
                            <input type="text" name="filterColor" placeholder="VD: Đỏ, Trắng..." class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                        </div>

                        <div class="pt-2 flex gap-3">
                            <button type="reset" class="flex-1 py-3 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition">Xóa trắng</button>
                            <button type="submit" class="flex-1 py-3 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition shadow-md shadow-blue-500/30">Áp dụng lọc</button>
                        </div>
                    </form>
                </div>
            </div>

            <%-- MODAL THÊM / SỬA THÔNG TIN XE --%>
            <div id="vehicleModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-slate-900/50 backdrop-blur-sm transition-opacity">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden relative">

                    <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                        <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Thêm Xe Mới</h3>
                        <button onclick="closeModal()" class="text-slate-400 hover:text-slate-700"><i class="fa-solid fa-xmark text-xl"></i></button>
                    </div>

                    <form id="vehicleForm" action="<%= request.getContextPath() %>/VehicleController" method="POST">
                        <input type="hidden" id="action" name="action">
                        <div class="p-6 space-y-4">
                            <input type="hidden" id="inpVehicleId" name="vehicleId">
                            <input type="hidden" id="inpOldPlate" name="oldPlate"> 

                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe *</label>
                                <input type="text" id="inpPlate" name="plate" value="${plate}" placeholder="VD: 51H-999.99" required class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none uppercase font-mono">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Hãng xe</label>
                                <input type="text" id="inpBrand" name="brand" value="${brand}" placeholder="VD: Toyota, Mazda..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe (Model)</label>
                                <input type="text" id="inpModel" name="model" value="${model}" placeholder="VD: Vios, CX-5..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc</label>
                                <input type="text" id="inpColor" name="color" value="${color}" placeholder="VD: Đỏ, Đen, Trắng..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                        </div>
                        <div class="px-6 py-4 bg-slate-50 border-t border-slate-100 flex justify-end gap-3">
                            <button type="button" onclick="closeModal()" class="px-5 py-2.5 rounded-xl font-medium text-slate-600 hover:bg-slate-200 transition">Hủy</button>
                            <button type="submit" class="px-5 py-2.5 rounded-xl font-bold bg-emerald-500 text-white hover:bg-emerald-600 transition shadow-sm flex items-center gap-2">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu Thông Tin
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>

        <script>
            const modal = document.getElementById('vehicleModal');
            const form = document.getElementById('vehicleForm');
            const toast = document.getElementById('toastBox');

            // XỬ LÝ HOẠT ẢNH TRƯỢT VÀO VÀ TỰ BIẾN MẤT CỦA TOAST ALERT
            if (toast) {
                setTimeout(function() {
                    toast.classList.add('show');
                }, 100);

                setTimeout(function() {
                    closeToast();
                }, 3100);
            }

            function closeToast() {
                if (toast) {
                    toast.classList.remove('show');
                    setTimeout(function() {
                        toast.remove();
                    }, 400);
                }
            }

            // ĐIỀU KHIỂN OPEN/CLOSE MODAL THÊM, SỬA
            function openModal(mode, btnElement = null) {
                modal.classList.remove('hidden');

                if (mode === 'add') {
                    document.getElementById('modalTitle').innerText = 'Thêm Xe Mới';
                    document.getElementById("action").value = "add";

                    if (!document.getElementById("inpPlate").value) {
                        form.reset();
                    }
                    document.getElementById('inpVehicleId').value = '';
                    document.getElementById('inpOldPlate').value = '';
                } else if (mode === 'edit') {
                    document.getElementById('modalTitle').innerText = 'Sửa Thông Tin Xe';
                    document.getElementById("action").value = "update";
                    
                    const card = btnElement.closest('.vehicle-card');
                    const currentPlate = card.querySelector('.val-plate').innerText;

                    document.getElementById('inpVehicleId').value = card.dataset.id;
                    document.getElementById('inpPlate').value = currentPlate;
                    document.getElementById('inpOldPlate').value = currentPlate; 
                    document.getElementById('inpBrand').value = card.querySelector('.val-brand').innerText;
                    document.getElementById('inpModel').value = card.querySelector('.val-model').innerText;
                    document.getElementById('inpColor').value = card.querySelector('.val-color').innerText;
                }
            }

            function closeModal() {
                modal.classList.add('hidden');
            }

            // ĐIỀU KHIỂN OPEN/CLOSE MODAL BỘ LỌC TÌM KIẾM
            const filterModal = document.getElementById('advancedFilterModal');
            const filterContent = document.getElementById('filterModalContent');

            function openAdvancedFilter() {
                filterModal.classList.remove('hidden');
                setTimeout(() => {
                    filterModal.classList.remove('opacity-0');
                    filterContent.classList.remove('scale-95');
                    filterContent.classList.add('scale-100');
                }, 10);
            }

            function closeAdvancedFilter() {
                filterModal.classList.add('opacity-0');
                filterContent.classList.remove('scale-100');
                filterContent.classList.add('scale-95');
                setTimeout(() => {
                    filterModal.classList.add('hidden');
                }, 300);
            }
        </script>
        
        <%-- BẬT LẠI MODAL NẾU FORM BỊ LỖI SERVER TRẢ VỀ --%>
        <%
            String mode = (String) request.getAttribute("MODE");
            if (mode != null) {
        %>
        <script>
            window.onload = function () {
                openModal('<%= mode.toLowerCase() %>');
            };
        </script>
        <%}%>
    </body>
</html>