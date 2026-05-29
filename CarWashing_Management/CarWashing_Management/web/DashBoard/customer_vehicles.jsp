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
        body { font-family: 'Inter', sans-serif; }
        .mesh-gradient-header {
            background-color: #0f172a;
            background-image: radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
        }
    </style>
</head>
<body class="bg-[#F8FAFC] text-gray-800">

    <div class="flex h-screen overflow-hidden relative">
        
        <aside class="w-64 bg-[#1E293B] text-white flex flex-col justify-between z-10">
            <div>
                <div class="h-20 flex items-center justify-center border-b border-slate-700">
                    <img src="<%=request.getContextPath()%>/image/logo-fpt.png" alt="SmartWash" class="h-10">
                </div>
                <nav class="mt-6 flex flex-col gap-1 px-3">
                    <a href="dashboard" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-slate-700 transition-colors"><i class="fa-solid fa-chart-pie w-5"></i><span>Tổng Quan</span></a>
                    <a href="booking" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-slate-700 transition-colors"><i class="fa-solid fa-calendar-check w-5"></i><span>Đặt Lịch</span></a>
                    <a href="my-vehicles" class="flex items-center gap-3 px-4 py-3 rounded-lg bg-emerald-500 text-white font-semibold transition-colors"><i class="fa-solid fa-car w-5"></i><span>Xe Của Tôi</span></a>
                    <a href="history" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-slate-700 transition-colors"><i class="fa-solid fa-clock-rotate-left w-5"></i><span>Lịch Sử</span></a>
                </nav>
            </div>
            <div class="px-3 mb-6">
                <a href="logout" class="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-300 hover:bg-red-500/20 hover:text-red-400 transition-colors border-t border-slate-700 mt-4"><i class="fa-solid fa-arrow-right-from-bracket w-5"></i><span>Đăng Xuất</span></a>
            </div>
        </aside>

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

                    <div class="vehicle-card bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative">
                        <div class="p-6">
                            <div class="flex items-center gap-4 mb-4 border-b border-slate-100 pb-4">
                                <div class="w-16 h-16 bg-slate-50 rounded-xl border border-slate-100 flex items-center justify-center p-2">
                                    <img src="https://cdn-icons-png.flaticon.com/512/3204/3204005.png" class="w-full h-full object-contain opacity-80">
                                </div>
                                <div>
                                    <h3 class="val-plate font-mono text-2xl font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded border border-slate-300 inline-block">51H-123.41</h3>
                                </div>
                            </div>
                            <div class="space-y-2 mb-6 text-sm">
                                <div class="flex justify-between"><span class="text-slate-500">Hãng xe:</span><span class="val-brand font-semibold text-slate-800">VinFast</span></div>
                                <div class="flex justify-between"><span class="text-slate-500">Dòng xe:</span><span class="val-model font-semibold text-slate-800">VF8 (5 Chỗ)</span></div>
                                <div class="flex justify-between"><span class="text-slate-500">Màu sắc:</span><span class="val-color font-semibold text-slate-800">Xanh Dương</span></div>
                            </div>
                            <div class="flex gap-3">
                                <button onclick="openModal('edit', this)" class="flex-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-emerald-200"><i class="fa-solid fa-pen"></i> Sửa</button>
                                <button onclick="deleteVehicle(this)" class="flex-1 bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-red-200"><i class="fa-solid fa-trash-can"></i> Xóa</button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>

        <div id="vehicleModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-slate-900/50 backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden relative">
                
                <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                    <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Thêm Xe Mới</h3>
                    <button onclick="closeModal()" class="text-slate-400 hover:text-slate-700"><i class="fa-solid fa-xmark text-xl"></i></button>
                </div>

                <div class="p-6 space-y-4">
                    <input type="hidden" id="modalMode"> <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe *</label>
                        <input type="text" id="inpPlate" placeholder="VD: 51H-999.99" class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none uppercase font-mono">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Hãng xe</label>
                        <input type="text" id="inpBrand" placeholder="VD: Toyota, Mazda..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe (Model)</label>
                        <input type="text" id="inpModel" placeholder="VD: Vios, CX-5..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc</label>
                        <input type="text" id="inpColor" placeholder="VD: Đỏ, Đen, Trắng..." class="w-full px-4 py-2 rounded-lg bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                    </div>
                </div>

                <div class="px-6 py-4 bg-slate-50 border-t border-slate-100 flex justify-end gap-3">
                    <button onclick="closeModal()" class="px-5 py-2 rounded-lg font-medium text-slate-600 hover:bg-slate-200 transition">Hủy</button>
                    <button onclick="saveVehicle()" class="px-5 py-2 rounded-lg font-medium bg-emerald-500 text-white hover:bg-emerald-600 transition shadow-sm flex items-center gap-2">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu Thông Tin
                    </button>
                </div>
            </div>
        </div>

    </div>

    <script>
        const modal = document.getElementById('vehicleModal');
        let currentEditCard = null; // Biến nhớ thẻ xe đang được bấm sửa

        // 1. Hàm XÓA XE: Biến mất ngay lập tức
        function deleteVehicle(btnElement) {
            const card = btnElement.closest('.vehicle-card'); // Tìm cái thẻ div to nhất bọc cái nút này
            const plate = card.querySelector('.val-plate').innerText;
            if(confirm('Bạn có chắc chắn muốn xóa phương tiện [' + plate + '] ngay lập tức?')) {
                card.remove(); // Lệnh xóa ngay lập tức khỏi màn hình
            }
        }

        // 2. Hàm MỞ MODAL (Dùng chung cho cả Thêm và Sửa)
        function openModal(mode, btnElement = null) {
            document.getElementById('modalMode').value = mode;
            modal.classList.remove('hidden');

            if (mode === 'add') {
                document.getElementById('modalTitle').innerText = 'Thêm Xe Mới';
                // Làm rỗng các ô input
                document.getElementById('inpPlate').value = '';
                document.getElementById('inpBrand').value = '';
                document.getElementById('inpModel').value = '';
                document.getElementById('inpColor').value = '';
            } 
            else if (mode === 'edit') {
                document.getElementById('modalTitle').innerText = 'Sửa Thông Tin Xe';
                currentEditCard = btnElement.closest('.vehicle-card'); // Lưu lại thẻ đang sửa
                
                // Lấy chữ từ thẻ cũ nhét vào Modal
                document.getElementById('inpPlate').value = currentEditCard.querySelector('.val-plate').innerText;
                document.getElementById('inpBrand').value = currentEditCard.querySelector('.val-brand').innerText;
                document.getElementById('inpModel').value = currentEditCard.querySelector('.val-model').innerText;
                document.getElementById('inpColor').value = currentEditCard.querySelector('.val-color').innerText;
            }
        }

        // 3. Hàm ĐÓNG MODAL
        function closeModal() {
            modal.classList.add('hidden');
            currentEditCard = null;
        }

        // 4. Hàm LƯU THÔNG TIN (Ảo thuật cập nhật thẻ)
        function saveVehicle() {
            const mode = document.getElementById('modalMode').value;
            
            // Lấy dữ liệu người dùng vừa gõ
            const plate = document.getElementById('inpPlate').value.toUpperCase();
            const brand = document.getElementById('inpBrand').value || 'Chưa cập nhật';
            const model = document.getElementById('inpModel').value || 'Chưa cập nhật';
            const color = document.getElementById('inpColor').value || 'Chưa cập nhật';

            if(plate.trim() === '') {
                alert('Vui lòng nhập Biển số xe!');
                return;
            }

            if (mode === 'edit' && currentEditCard) {
                // SỬA: Đổi dòng chữ ngay trên thẻ cũ
                currentEditCard.querySelector('.val-plate').innerText = plate;
                currentEditCard.querySelector('.val-brand').innerText = brand;
                currentEditCard.querySelector('.val-model').innerText = model;
                currentEditCard.querySelector('.val-color').innerText = color;
            } 
            else if (mode === 'add') {
                // THÊM: Sinh ra 1 thẻ HTML mới cứng và nhét vào Lưới
                const newCardHTML = `
                    <div class="vehicle-card bg-white rounded-2xl shadow-sm border border-emerald-300 overflow-hidden relative">
                        <div class="p-6">
                            <div class="flex items-center gap-4 mb-4 border-b border-slate-100 pb-4">
                                <div class="w-16 h-16 bg-slate-50 rounded-xl border border-slate-100 flex items-center justify-center p-2">
                                    <img src="https://cdn-icons-png.flaticon.com/512/3204/3204005.png" class="w-full h-full object-contain opacity-80">
                                </div>
                                <div><h3 class="val-plate font-mono text-2xl font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded border border-slate-300 inline-block">`+plate+`</h3></div>
                            </div>
                            <div class="space-y-2 mb-6 text-sm">
                                <div class="flex justify-between"><span class="text-slate-500">Hãng xe:</span><span class="val-brand font-semibold text-slate-800">`+brand+`</span></div>
                                <div class="flex justify-between"><span class="text-slate-500">Dòng xe:</span><span class="val-model font-semibold text-slate-800">`+model+`</span></div>
                                <div class="flex justify-between"><span class="text-slate-500">Màu sắc:</span><span class="val-color font-semibold text-slate-800">`+color+`</span></div>
                            </div>
                            <div class="flex gap-3">
                                <button onclick="openModal('edit', this)" class="flex-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-emerald-200"><i class="fa-solid fa-pen"></i> Sửa</button>
                                <button onclick="deleteVehicle(this)" class="flex-1 bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-2 rounded-lg transition flex items-center justify-center gap-2 border border-red-200"><i class="fa-solid fa-trash-can"></i> Xóa</button>
                            </div>
                        </div>
                    </div>`;
                document.getElementById('vehicle-grid').insertAdjacentHTML('afterbegin', newCardHTML);
            }

            closeModal(); // Lưu xong thì tắt form
        }
    </script>
</body>
</html>