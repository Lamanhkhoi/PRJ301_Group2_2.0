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
        
        <jsp:include page="/includes/sidebar_DashBoard.jsp" />

        <main class="flex-1 flex flex-col overflow-hidden relative">
            
            <jsp:include page="/includes/topbar.jsp"/>

            <div class="flex-1 overflow-y-auto p-8">
                
                <div class="flex justify-between items-center mb-8">
                    <button onclick="openAdvancedFilter()" class="w-12 h-12 rounded-full bg-white border border-slate-200 text-slate-600 hover:text-[#464BE5] hover:border-[#464BE5] shadow-sm flex items-center justify-center transition-all group" title="Tìm kiếm & Lọc xe">
                        <i class="fa-solid fa-magnifying-glass text-lg group-hover:scale-110 transition-transform"></i>
                    </button>
                    
                    <button onclick="openModal('add')" class="bg-[#464BE5] hover:bg-blue-700 text-white font-semibold py-2.5 px-6 rounded-xl shadow-md transition-colors flex items-center gap-2">
                        <i class="fa-solid fa-plus"></i> Thêm Xe Mới
                    </button>
                </div>

                <div id="vehicle-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div class="vehicle-card bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden relative hover:shadow-md transition-shadow">
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
                                <button type="button" onclick="openModal('edit', this)" class="flex-1 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 border border-emerald-200">
                                    <i class="fa-solid fa-pen"></i> Sửa
                                </button>
                                <form action="deleteVehicle" method="POST" class="flex-1 m-0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa phương tiện này?');">
                                    <input type="hidden" name="plate" value="51H-123.41">
                                    <button type="submit" class="w-full bg-red-50 hover:bg-red-100 text-red-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 border border-red-200">
                                        <i class="fa-solid fa-trash-can"></i> Xóa
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <div id="advancedFilterModal" class="fixed inset-0 z-[100] hidden flex items-center justify-center bg-[#111827]/60 backdrop-blur-sm transition-all duration-300 opacity-0">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md mx-4 relative overflow-hidden transform scale-95 transition-transform duration-300" id="filterModalContent">
                
                <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                    <h3 class="text-lg font-bold text-slate-800 flex items-center gap-2"><i class="fa-solid fa-sliders text-[#464BE5]"></i> Tìm Kiếm & Bộ Lọc</h3>
                    <button onclick="closeAdvancedFilter()" class="text-slate-400 hover:text-red-500 transition"><i class="fa-solid fa-xmark text-xl"></i></button>
                </div>

                <form action="customer_vehicles.jsp" method="GET" class="p-6 space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe</label>
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
                            <select name="filterBrand" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition cursor-pointer text-slate-700">
                                <option value="">-- Tất cả --</option>
                                <option value="VinFast">VinFast</option>
                                <option value="Toyota">Toyota</option>
                                <option value="Mazda">Mazda</option>
                                <option value="Honda">Honda</option>
                                <option value="Hyundai">Hyundai</option>
                                <option value="Ford">Ford</option>
                                <option value="Kia">Kia</option>
                                <option value="Mercedes">Mercedes</option>
                                <option value="BMW">BMW</option>
                                <option value="Khác">Hãng khác...</option>
                            </select>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe</label>
                            <input type="text" name="filterModel" placeholder="VD: VF8, CX-5..." class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc (Vehicle Color)</label>
                        <select name="filterColor" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition cursor-pointer text-slate-700">
                            <option value="">-- Tất cả màu --</option>
                            <option value="Trắng">Trắng (White)</option>
                            <option value="Đen">Đen (Black)</option>
                            <option value="Bạc">Bạc (Silver)</option>
                            <option value="Xám">Xám (Grey)</option>
                            <option value="Đỏ">Đỏ (Red)</option>
                            <option value="Xanh dương">Xanh dương (Blue)</option>
                            <option value="Xanh lá">Xanh lá (Green)</option>
                            <option value="Nâu">Nâu (Brown)</option>
                            <option value="Vàng">Vàng (Yellow)</option>
                            <option value="Khác">Màu khác...</option>
                        </select>
                    </div>

                    <div class="pt-2 flex gap-3">
                        <button type="reset" class="flex-1 py-3 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition">Xóa trắng</button>
                        <button type="submit" class="flex-1 py-3 bg-[#464BE5] text-white font-bold rounded-xl hover:bg-blue-700 transition shadow-md shadow-blue-500/30">Áp dụng lọc</button>
                    </div>
                </form>
            </div>
        </div>

        <div id="vehicleModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-slate-900/50 backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden relative">
                <div class="bg-slate-50 px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                    <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Thêm Xe Mới</h3>
                    <button onclick="closeModal()" class="text-slate-400 hover:text-slate-700"><i class="fa-solid fa-xmark text-xl"></i></button>
                </div>
                <form id="vehicleForm" action="addVehicle" method="POST">
                    <div class="p-6 space-y-4">
                        <input type="hidden" id="inpOldPlate" name="oldPlate"> 
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Biển số xe *</label>
                            <input type="text" id="inpPlate" name="plate" placeholder="VD: 51H-999.99" required class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none uppercase font-mono">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Hãng xe</label>
                            <input type="text" id="inpBrand" name="brand" placeholder="VD: Toyota, Mazda..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Dòng xe (Model)</label>
                            <input type="text" id="inpModel" name="model" placeholder="VD: Vios, CX-5..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-600 mb-1">Màu sắc</label>
                            <input type="text" id="inpColor" name="color" placeholder="VD: Đỏ, Đen, Trắng..." class="w-full px-4 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:border-emerald-500 outline-none">
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
        // Logic Modal Thêm/Sửa
        const modal = document.getElementById('vehicleModal');
        const form = document.getElementById('vehicleForm');

        function openModal(mode, btnElement = null) {
            modal.classList.remove('hidden');
            if (mode === 'add') {
                document.getElementById('modalTitle').innerText = 'Thêm Xe Mới';
                form.action = 'addVehicle'; 
                form.reset(); 
                document.getElementById('inpOldPlate').value = '';
            } else if (mode === 'edit') {
                document.getElementById('modalTitle').innerText = 'Sửa Thông Tin Xe';
                form.action = 'updateVehicle'; 
                const card = btnElement.closest('.vehicle-card');
                const currentPlate = card.querySelector('.val-plate').innerText;
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

        // Logic Modal Lọc/Tìm kiếm
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
</body>
</html>