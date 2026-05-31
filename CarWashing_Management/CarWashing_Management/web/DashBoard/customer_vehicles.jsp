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

            <jsp:include page="/includes/sidebar_DashBoard.jsp" />
            <%
                // 1. Kiểm tra Session đăng nhập bảo vệ hệ thống
                Account userAcc = (Account) session.getAttribute("USER");
                Customer cus = (Customer) session.getAttribute("CUSTOMER");
                if (userAcc == null || cus == null) {
                    response.sendRedirect(request.getContextPath() + "/home.jsp");
                    return;
                }

                // 2. Lấy danh sách xe thực tế qua ID của khách hàng
                CustomerVehicleDAO vehicleDAO = new CustomerVehicleDAO();
                List<Vehicle> vehicleList = vehicleDAO.getAllVehicles(cus.getCustomerId());
            %>
            <main class="flex-1 flex flex-col overflow-hidden">
                <header class="h-20 mesh-gradient-header flex items-center justify-between px-8 shadow-md z-10">
                    <div class="flex items-center"><h2 class="text-xl font-bold text-white drop-shadow-md tracking-wide">Quản lý <span class="text-emerald-300">Xe Của Tôi</span> 🚘</h2></div>
                    <div class="w-10 h-10 rounded-full bg-emerald-500 flex items-center justify-center font-bold text-white border-2 border-white/20 cursor-pointer">A</div>
                </header>

                <div class="flex-1 overflow-y-auto p-8">
                    <div class="flex justify-between items-center mb-8">
                        <p class="text-slate-500 font-medium">Bạn có thể quản lý tối đa 5 phương tiện.</p>
                        <button onclick="openModal('add')" class="bg-[#464BE5] hover:bg-blue-700 text-white font-semibold py-2 px-6 rounded-lg shadow-md transition-colors flex items-center gap-2">
                            <i class="fa-solid fa-plus"></i> Thêm Xe Mới
                        </button>
                    </div>

                    <div id="vehicle-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <% if (vehicleList != null && !vehicleList.isEmpty()) {
                                for (Vehicle v : vehicleList) {
                                    if (v.getIsActive()) {
                        %>
                        <div class="vehicle-card bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative" data-id="<%= v.getVehicleId()%>">
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
                                    <button type="button" onclick="openModal('edit', this)" class="flex-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-emerald-200">
                                        <i class="fa-solid fa-pen"></i> Sửa
                                    </button>

                                    <form action="<%= request.getContextPath() %>/VehicleController" method="POST" class="flex-1 m-0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phương tiện này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="vehicleId" value="<%= v.getVehicleId()%>">
                                        <button type="submit" class="w-full bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-red-200">
                                            <i class="fa-solid fa-trash-can"></i> Xóa
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <%}%>
                        <%}%>
                        <%}%>
                    </div>
                </div>
            </main>

            <div id="vehicleModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-slate-900/50 backdrop-blur-sm transition-opacity">
                <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden relative">

                    <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                        <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Thêm Xe Mới</h3>
                        <button onclick="closeModal()" class="text-slate-400 hover:text-slate-700"><i class="fa-solid fa-xmark text-xl"></i></button>
                    </div>

                    <form id="vehicleForm" action="<%= request.getContextPath() %>/VehicleController" method="post">
                        <input type="hidden" id="action" name="action">
                        <div class="p-6 space-y-4">
                            <input type="hidden" id="inpVehicleId" name="vehicleId">
                            <input type="hidden" id="inpOldPlate" name="oldPlate"> 

                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe *</label>
                                <input type="text" id="inpPlate" name="plate" value="${plate}" placeholder="VD: 51H-999.99" required class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none uppercase font-mono">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Hãng xe</label>
                                <input type="text" id="inpBrand" name="brand" value="${brand}" placeholder="VD: Toyota, Mazda..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe (Model)</label>
                                <input type="text" id="inpModel" name="model" value="${model}" placeholder="VD: Vios, CX-5..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc</label>
                                <input type="text" id="inpColor" name="color" value="${color}" placeholder="VD: Đỏ, Đen, Trắng..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                            </div>
                        </div>
                        <div class="px-6 py-4 bg-slate-50 border-t border-slate-100 flex justify-end gap-3">
                            <button type="button" onclick="openModal('close')" class="px-5 py-2 rounded-lg font-medium text-slate-600 hover:bg-slate-200 transition">Hủy</button>
                            <button type="submit" class="px-5 py-2 rounded-lg font-medium bg-emerald-500 text-white hover:bg-emerald-600 transition shadow-sm flex items-center gap-2">
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
                // Đợi HTML render xong rồi kích hoạt hiệu ứng trượt vào (Slide-in)
                setTimeout(function() {
                    toast.classList.add('show');
                }, 100);

                // Tự động đóng sau đúng 3000ms (3 giây)
                setTimeout(function() {
                    closeToast();
                }, 3100);
            }

            function closeToast() {
                if (toast) {
                    toast.classList.remove('show');
                    // Chờ hiệu ứng trượt ẩn hoàn tất rồi xóa hẳn khỏi DOM
                    setTimeout(function() {
                        toast.remove();
                    }, 400);
                }
            }

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
        </script>
        <%
            String mode = (String) request.getAttribute("MODE");
            if (mode != null) {
        %>
        <script>
            window.onload = function () {
                document.getElementById("vehicleModal").classList.remove("hidden");
            };
        </script>
        <%}%>
    </body>
</html>