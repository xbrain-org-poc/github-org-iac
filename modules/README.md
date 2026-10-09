# Modules

[`repository/`](repository/) là module tham chiếu để dùng lại cấu hình trong từng Terraform root của mỗi repo. Blueprint công ty gọi module một lần cho mỗi root.

PoC hiện giữ địa chỉ resource cũ trong các root dưới `live/xbrain-org-poc/repositories/` để bảo toàn state và đối chiếu evidence. Chuyển PoC sang module sau này cần `moved` block hoặc chuyển state được review trước khi apply.
