# Modules

[`repository/`](repository/) là module tham chiếu cho các nhóm repo có cùng cấu trúc cài đặt. Blueprint công ty dùng module này với `for_each`.

PoC hiện giữ địa chỉ resource cũ trong `live/xbrain-org-poc/repositories/sandbox/` để bảo toàn state và đối chiếu evidence. Chuyển PoC sang module sau này cần `moved` block hoặc chuyển state được review trước khi apply.
