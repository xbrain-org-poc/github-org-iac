# Ghi chú chuyển sang repo IaC chung

- Code và evidence được **sao chép** từ hai repo PoC; repo cũ giữ nguyên để các link trong Jira và lịch sử demo tiếp tục truy cập được.
- `repositories/sandbox/` giữ nguyên địa chỉ Terraform của bốn resource. Local `terraform.tfstate` đã được chuyển cùng cấu hình vào root này trên máy thực hiện và bị `.gitignore` loại khỏi Git. Không chạy `apply` từ repo cũ và repo mới song song.
- Người clone repo mới không nhận được state local. Trước khi `plan/apply`, import các GitHub resource đang tồn tại theo [`huong-dan-chay.md`](../live/xbrain-org-poc/repositories/sandbox/docs/huong-dan-chay.md); đối chiếu ID ruleset hiện tại từ GitHub API.
- `identity/` không có active membership trong state cuối PoC; không sao chép state cũ. Chỉ thêm username đã được chấp thuận vào tfvars local sau khi kiểm tra org hiện tại.
- `access/` chưa có code team được bàn giao. Không chạy Terraform trong thư mục này.
- `org-policies/` là Terraform root riêng. Ruleset cấp org được khai báo nhưng chưa tạo được vì org đang dùng GitHub Free; không chia sẻ state với `repositories/`.
- Pipeline PR plan/apply cần remote backend có locking, credential giới hạn quyền và chính sách approval. Thư mục workflow hiện chỉ ghi trạng thái này, chưa tự động thực thi.
