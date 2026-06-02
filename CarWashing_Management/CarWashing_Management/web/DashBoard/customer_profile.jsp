<%@ include file="../includes/auth-check.jsp" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thông Tin Cá Nhân - SmartWash</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>

        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .mesh-gradient-header {
                background-color: #0f172a;
                background-image: radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%), radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%), radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            }
            input[type="file"] {
                display: none;
            }

            #toastBox {
                transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease;
                transform: translateX(120%);
                opacity: 0;
            }
            #toastBox.show {
                transform: translateX(0);
                opacity: 1;
            }
            /* Tùy chỉnh khung cắt ảnh Cropper thành hình tròn giống diện mạo Avatar */
            .cropper-view-box,
            .cropper-face {
                border-radius: 50%;
            }
        </style>
    </head>
    <body class="bg-[#F8FAFC] text-gray-800 relative">

        <%        
            // Biến userAcc và cus đã được khai báo và kiểm tra ở file auth-check.jsp phía trên
            String alertType = (String) request.getAttribute("ALERT_TYPE");
            String alertMsg = (String) request.getAttribute("ALERT_MSG");

            String username = userAcc.getUsername();
            String email = userAcc.getEmail() != null ? userAcc.getEmail() : "";
            String fullName = userAcc.getFullname() != null ? userAcc.getFullname() : "";
            String phone = cus.getPhone() != null ? cus.getPhone() : "";
            String address = cus.getAddress() != null ? cus.getAddress() : "";

            String gender = request.getParameter("gender");
            if (gender == null) {
                gender = (cus != null) ? cus.getGender() : "Other";
            }

            if ("Male".equalsIgnoreCase(gender) || "Nam".equalsIgnoreCase(gender)) {
                gender = "Nam";
            } else if ("Female".equalsIgnoreCase(gender) || "Nữ".equalsIgnoreCase(gender)) {
                gender = "Nữ";
            } else if ("Other".equalsIgnoreCase(gender) || "Khác".equalsIgnoreCase(gender)) {
                gender = "Khác";
            }

            String dobFormat = "";
            if (cus.getDob() != null) {
                dobFormat = new SimpleDateFormat("yyyy-MM-dd").format(cus.getDob());
            }

            String avatarChar = "";
            boolean hasAvatar = (userAcc.getAvaUrl() != null && !userAcc.getAvaUrl().trim().isEmpty());
            if (!hasAvatar) {
                String nameDisplay = fullName.trim().isEmpty() ? "K" : fullName.trim();
                String[] nameParts = nameDisplay.split(" ");
                avatarChar = nameParts[nameParts.length - 1].substring(0, 1).toUpperCase();
            }
        %>

        <%-- CONTAINER CHỨA TOAST ALERT ĐỘNG (Dùng chung cho cả Server và Client) --%>
        <div id="toastContainer" class="fixed top-6 right-6 z-50 flex flex-col gap-3 max-w-sm w-full">
            <% if (alertMsg != null) { %>
            <div id="toastBox" class="flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border bg-white border-slate-100 w-full">
                <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg <%= "success".equals(alertType) ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600"%>">
                    <i class="<%= "success".equals(alertType) ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation"%>"></i>
                </div>
                <div class="flex-1">
                    <h4 class="font-bold text-slate-800 text-sm"><%= "success".equals(alertType) ? "Thành công" : "Thông báo lỗi"%></h4>
                    <p class="text-slate-500 text-xs mt-0.5"><%= alertMsg%></p>
                </div>
                <button onclick="closeServerToast(this)" class="text-slate-400 hover:text-slate-600 transition ml-2">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>
            <% } %>
        </div>

        <div class="flex h-screen overflow-hidden relative">

            <% request.setAttribute("activeTab", "thongtincanhan");%>
            <jsp:include page="/includes/sidebar_DashBoard.jsp" />

            <main class="flex-1 flex flex-col overflow-hidden relative">

                <jsp:include page="/includes/topbar.jsp"/>

                <div class="flex-1 overflow-y-auto p-8">

                    <div class="max-w-5xl mx-auto space-y-6">

                        <div class="flex justify-between items-center mb-2">
                            <div>
                                <h2 class="text-2xl font-bold text-slate-800">Quản lý hồ sơ</h2>
                                <p class="text-sm text-slate-500 mt-1">Cập nhật thông tin cá nhân và cài đặt bảo mật của bạn.</p>
                            </div>
                        </div>

                        <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
                            <form id="formUpdateProfile" action="<%= request.getContextPath()%>/MainController?action=updateProfile" method="POST" enctype="multipart/form-data" class="p-8">
                                <input type="hidden" name="isDeleteAvatar" id="isDeleteAvatar" value="false">
                                
                                <div class="flex flex-col md:flex-row gap-10">

                                    <div class="flex flex-col items-center gap-4">
                                        <div class="relative w-32 h-32 rounded-full border-4 border-white shadow-xl overflow-hidden group/avatar bg-slate-200 flex items-center justify-center font-bold text-slate-700 text-4xl">

                                            <% if (hasAvatar) {%>
                                            <img src="${pageContext.request.contextPath}/<%= userAcc.getAvaUrl()%>?v=<%= System.currentTimeMillis()%>" alt="Avatar" id="avatarPreview" class="w-full h-full object-cover">
                                            <div id="avatarTextPlaceholder" class="hidden"><%= avatarChar%></div>

                                            <button type="button" id="btnDeleteAvatar" onclick="actionDeleteAvatar()" 
                                                    class="absolute inset-0 bg-black/50 text-white flex items-center justify-center opacity-0 group-hover/avatar:opacity-100 transition-opacity duration-200 cursor-pointer text-xl" title="Xóa ảnh đại diện">
                                                <i class="fa-solid fa-trash-can text-red-400"></i>
                                            </button>
                                            <% } else {%>
                                            <img src="" alt="Avatar" id="avatarPreview" class="w-full h-full object-cover hidden">
                                            <div id="avatarTextPlaceholder"><%= avatarChar%></div>

                                            <button type="button" id="btnDeleteAvatar" onclick="actionDeleteAvatar()" 
                                                    class="absolute inset-0 bg-black/50 text-white flex items-center justify-center opacity-0 transition-opacity duration-200 cursor-pointer text-xl hidden" title="Xóa ảnh đại diện">
                                                <i class="fa-solid fa-trash-can text-red-400"></i>
                                            </button>
                                            <% }%>
                                        </div>

                                        <label for="avatarFile" class="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-sm font-medium rounded-xl border border-slate-200 cursor-pointer transition shadow-sm">
                                            <i class="fa-solid fa-camera mr-2"></i>Thay ảnh mới
                                        </label>
                                        <input type="file" name="avatarFile" id="avatarFile" accept="image/*" class="hidden" onchange="initCropper(this)">
                                    </div>

                                    <div class="flex-1 grid grid-cols-1 md:grid-cols-2 gap-6">
                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Tên đăng nhập (Username)</label>
                                            <input type="text" name="username" value="<%= username%>" readonly class="w-full px-4 py-2.5 rounded-xl bg-slate-100 border border-slate-200 text-slate-500 cursor-not-allowed outline-none">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Họ và Tên</label>
                                            <input type="text" name="fullName" value="<%= fullName%>" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Email</label>
                                            <input type="email" name="email" value="<%= email%>" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Số điện thoại</label>
                                            <input type="tel" name="phoneNumber" value="<%= phone%>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Ngày sinh</label>
                                            <input type="date" name="dateOfBirth" value="<%= dobFormat%>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition text-slate-700">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Giới tính</label>
                                            <select name="gender" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition cursor-pointer text-slate-700">
                                                <option value="Male" <%= "Nam".equals(gender) ? "selected" : ""%>>Nam</option>
                                                <option value="Female" <%= "Nữ".equals(gender) ? "selected" : ""%>>Nữ</option>
                                                <option value="Other" <%= "Khác".equals(gender) ? "selected" : ""%>>Khác</option>
                                            </select>
                                        </div>

                                        <div class="md:col-span-2">
                                            <label class="block text-sm font-medium text-slate-600 mb-1">Địa chỉ (Address)</label>
                                            <input type="text" name="address" value="<%= address%>" class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-[#464BE5] focus:ring-2 focus:ring-[#464BE5]/20 outline-none transition">
                                        </div>
                                    </div>
                                </div>

                                <div class="mt-8 flex justify-end gap-3 pt-6 border-t border-slate-100">
                                    <button type="submit" class="px-6 py-2.5 rounded-xl font-bold bg-[#464BE5] text-white hover:bg-blue-700 transition shadow-md shadow-blue-500/30">Lưu Thay Đổi</button>
                                </div>
                            </form>
                        </div>

                        <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
                            <div class="px-8 py-5 border-b border-slate-100">
                                <h3 class="text-lg font-bold text-slate-800"><i class="fa-solid fa-shield-halved text-emerald-500 mr-2"></i>Bảo mật tài khoản</h3>
                            </div>
                            <form id="formChangePassword" action="<%= request.getContextPath()%>/MainController?action=changePassword" method="POST" onsubmit="return validatePasswordForm()" class="p-8">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl">
                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Mật khẩu hiện tại</label>
                                        <input type="password" id="oldPassword" name="oldPassword" placeholder="••••••••" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                    </div>
                                    <div class="hidden md:block"></div> 
                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Mật khẩu mới</label>
                                        <input type="password" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu mới" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-slate-600 mb-1">Xác nhận mật khẩu mới</label>
                                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" required class="w-full px-4 py-2.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition">
                                    </div>
                                </div>

                                <div class="mt-6">
                                    <button type="submit" class="px-6 py-2.5 rounded-xl font-bold bg-slate-800 text-white hover:bg-slate-900 transition shadow-md">Cập nhật mật khẩu</button>
                                </div>
                            </form>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <%-- MODAL CẮT ẢNH AVATAR CHUẨN ĐỒNG BỘ CROPPER.JS --%>
        <div id="cropModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center hidden backdrop-blur-sm">
            <div class="bg-white p-6 rounded-2xl max-w-lg w-full mx-4 shadow-2xl">
                <h3 class="text-lg font-bold text-slate-800 mb-4">Chỉnh sửa vùng hiển thị Avatar</h3>
                <div class="w-full max-h-[380px] overflow-hidden bg-slate-100 rounded-xl">
                    <img id="imageToCrop" class="max-w-full block" alt="Source">
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" onclick="closeCropModal()" class="px-4 py-2 text-sm font-medium text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-xl transition">Hủy</button>
                    <button type="button" onclick="saveCroppedImage()" class="px-4 py-2 text-sm font-bold text-white bg-[#464BE5] hover:bg-blue-700 rounded-xl transition shadow-md">Áp dụng vùng cắt</button>
                </div>
            </div>
        </div>

        <script>
            let cropper;
            const fileInput = document.getElementById('avatarFile');
            const imageToCrop = document.getElementById('imageToCrop');
            const cropModal = document.getElementById('cropModal');

            function initCropper(input) {
                if (input.files && input.files[0]) {
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        imageToCrop.src = e.target.result;
                        cropModal.classList.remove('hidden');

                        if (cropper) {
                            cropper.destroy();
                        }

                        cropper = new Cropper(imageToCrop, {
                            aspectRatio: 1,
                            viewMode: 1,
                            background: false,
                            autoCropArea: 0.8
                        });
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function saveCroppedImage() {
                if (!cropper) return;

                const canvas = cropper.getCroppedCanvas({
                    width: 400,
                    height: 400
                });

                const preview = document.getElementById('avatarPreview');
                const placeholder = document.getElementById('avatarTextPlaceholder');
                const btnDelete = document.getElementById('btnDeleteAvatar');

                preview.src = canvas.toDataURL('image/jpeg');
                preview.classList.remove('hidden');
                placeholder.classList.add('hidden');
                
                btnDelete.classList.remove('hidden');
                btnDelete.className = "absolute inset-0 bg-black/50 text-white flex items-center justify-center opacity-0 group-hover/avatar:opacity-100 transition-opacity duration-200 cursor-pointer text-xl";
                document.getElementById('isDeleteAvatar').value = "false";

                canvas.toBlob((blob) => {
                    const croppedFile = new File([blob], "avatar_cropped.jpg", { type: "image/jpeg" });

                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(croppedFile);
                    fileInput.files = dataTransfer.files;

                    closeCropModal();
                }, 'image/jpeg');
            }

            function closeCropModal() {
                cropModal.classList.add('hidden');
                if (!document.getElementById('avatarPreview').src || document.getElementById('avatarPreview').classList.contains('hidden')) {
                    fileInput.value = ""; 
                }
                if (cropper) {
                    cropper.destroy();
                }
            }

            function actionDeleteAvatar() {
                const preview = document.getElementById('avatarPreview');
                const placeholder = document.getElementById('avatarTextPlaceholder');
                const btnDelete = document.getElementById('btnDeleteAvatar');

                preview.src = "";
                preview.classList.add('hidden');
                placeholder.classList.remove('hidden');
                btnDelete.classList.add('hidden');
                fileInput.value = "";

                document.getElementById('isDeleteAvatar').value = "true";
            }

            // HỆ THỐNG XỬ LÝ TOAST ALERT ĐỒNG BỘ 100% CỦA SERVER VÀ CLIENT
            const serverToast = document.getElementById('toastBox');
            if (serverToast) {
                setTimeout(() => { serverToast.classList.add('show'); }, 100);
                setTimeout(() => { closeServerToast(serverToast); }, 3800);
            }

            function closeServerToast(element) {
                const toastItem = element.closest('#toastBox');
                if (toastItem) {
                    toastItem.classList.remove('show');
                    setTimeout(() => { toastItem.remove(); }, 400);
                }
            }

            // 💡 SỬA LỖI XUNG ĐỘT JSP BẰNG CÁCH THÊM DẤU GẠCH CHÉO NGƯỢC (\$) VÀO BIẾN JAVASCRIPT
            function showClientToast(type, title, message) {
                const container = document.getElementById('toastContainer');
                if (!container) return;

                const iconClass = type === "success" ? "fa-solid fa-circle-check" : "fa-solid fa-circle-exclamation";
                const bgIconColor = type === "success" ? "bg-green-100 text-green-600" : "bg-red-100 text-red-600";

                const toastHTML = `
                    <div class="flex items-center gap-3 px-5 py-4 rounded-xl shadow-2xl border bg-white border-slate-100 w-full" 
                         style="transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55), opacity 0.4s ease; transform: translateX(120%); opacity: 0;">
                        <div class="w-10 h-10 rounded-full flex items-center justify-center text-lg \${bgIconColor}">
                            <i class="\${iconClass}"></i>
                        </div>
                        <div class="flex-1">
                            <h4 class="font-bold text-slate-800 text-sm">\${title}</h4>
                            <p class="text-slate-500 text-xs mt-0.5">\${message}</p>
                        </div>
                        <button onclick="closeClientToast(this)" class="text-slate-400 hover:text-slate-600 transition ml-2">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                `;

                container.insertAdjacentHTML('beforeend', toastHTML);
                const newToast = container.lastElementChild;

                setTimeout(() => {
                    newToast.style.transform = "translateX(0)";
                    newToast.style.opacity = "1";
                }, 50);

                setTimeout(() => { closeClientToast(newToast.querySelector('button')); }, 3500);
            }

            function closeClientToast(buttonElement) {
                const toastItem = buttonElement.closest('div');
                if (toastItem) {
                    toastItem.style.transform = "translateX(120%)";
                    toastItem.style.opacity = "0";
                    setTimeout(() => { toastItem.remove(); }, 400);
                }
            }

            function validatePasswordForm() {
                const oldPass = document.getElementById('oldPassword').value;
                const newPass = document.getElementById('newPassword').value;
                const confirmPass = document.getElementById('confirmPassword').value;

                let errorMsg = "";

                if (newPass.length < 6) {
                    errorMsg = "Mật khẩu mới phải chứa từ 6 ký tự trở lên!";
                } else if (oldPass === newPass) {
                    errorMsg = "Mật khẩu mới không được trùng với mật khẩu hiện tại!";
                } else if (newPass !== confirmPass) {
                    errorMsg = "Xác nhận mật khẩu mới không trùng khớp!";
                }

                if (errorMsg !== "") {
                    showClientToast("error", "Thông báo lỗi", errorMsg);
                    return false; 
                }

                return true; 
            }
        </script>
    </body>
</html>