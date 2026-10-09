# Bàn giao PoC Team vào repo tổng hợp

Ngày: **09/10/2026**. Repo nhận: `xbrain-org-poc/github-org-iac`, thư mục `live/xbrain-org-poc/access/`.

## Review và quyết định tích hợp

- Repo có các Terraform root độc lập: `identity/`, `access/`, `repositories/`, `org-policies/`. `access/` ban đầu chỉ có README chờ bàn giao.
- `identity/` quản lý organization membership; code Team chỉ đọc membership để kiểm tra trạng thái active. Không có `resource github_membership` trong `access/`.
- `repositories/` quản lý repository settings/rulesets. Chưa có `github_team_repository` trong phần Team; cần chọn owner/state trước khi nối Team với Repository.
- Credential Git trên máy xác thực là `phuc-do-v2`, API repo báo quyền `admin: true`, `push: true`. `git push --dry-run` lên một tên branch mới thành công và không tạo remote branch.
- Kiểm tra tại thời điểm review: `main` không được bảo vệ và branch rules trả danh sách trống. Bàn giao qua branch/PR để nhóm review thay đổi cùng nhau.

## Nội dung bàn giao

Code, lock file, 12 mocked plan tests và workbook được sao chép từ [repo nguồn tại 85a99fb](https://github.com/phuc-do-v2/github-org-iac-po/tree/85a99fb). Giữ nguyên resource address và biến đầu vào của PoC để không tạo migration tài nguyên ngoài ý muốn.

Bổ sung README tiếng Việt, sample cấu hình rỗng, cập nhật runbook/link và tài liệu migration. Research và live evidence giữ ngày gốc **01/10/2026**. Workbook được giữ nguyên; đây là tài liệu lộ trình, không phải cấu hình triển khai.

State cuối PoC đã trống sau cleanup. Không sao chép state, tfvars local, binary plan, token, provider binary hoặc raw evidence chưa rà soát.

## Kiểm tra sau chuyển

Runtime: Terraform **1.16.4**, provider **6.13.0**.

| Kiểm tra | Kết quả |
| --- | --- |
| Init root mới | Thành công; dùng provider cache cục bộ và lock file chỉ đọc |
| `terraform fmt -check -recursive` tại access | Đạt |
| `terraform validate` tại access | Đạt |
| `terraform test -no-color` tại access | **12 passed, 0 failed**; tất cả dùng mock và plan |
| Đối chiếu nguồn | Hash code, tests, lock file và workbook khớp PoC gốc |
| Tài liệu và Git exclusions | Link Markdown nội bộ hoạt động; tfvars/state/plan/token/raw evidence bị ignore |

Sandbox của công cụ chặn provider plugin phản hồi khi validate/test; chạy lại ngoài sandbox thành công. Kiểm tra này không phải live test auth/API và không thực hiện Terraform apply. Các báo cáo live trong thư mục này thuộc PoC gốc, không được tính là lần chạy mới sau tích hợp.

Trước khi dùng chung để apply: chọn backend có locking, credential automation, import tài nguyên hiện hữu nếu có và review saved plan. Trước destructive apply phải kiểm kê child team, inherited access và team-to-repository relationships ngoài state.
