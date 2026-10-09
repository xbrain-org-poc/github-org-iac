# GitHub Org IaC — xbrain-org-poc

Repository tập trung mã Terraform quản lý GitHub Organization `xbrain-org-poc`. Mỗi phạm vi có Terraform state riêng để thay đổi repository không tác động nhầm tới thành viên hoặc quyền truy cập.

| Thư mục | Quản lý | Trạng thái |
| --- | --- | --- |
| [`live/xbrain-org-poc/identity/`](live/xbrain-org-poc/identity/) | Thành viên org và role qua `github_membership` | Đã chuyển mã và bằng chứng PoC từ [`poc-member`](https://github.com/xbrain-org-poc/poc-member); hiện không quản lý thành viên nào |
| [`live/xbrain-org-poc/access/`](live/xbrain-org-poc/access/) | Team và direct team membership; quyền team trên repo chưa triển khai | Đã chuyển mã, 12 mocked tests và báo cáo live PoC từ [`github-org-iac-po`](https://github.com/phuc-do-v2/github-org-iac-po); state cuối PoC trống |
| [`live/xbrain-org-poc/org-policies/`](live/xbrain-org-poc/org-policies/) | Ruleset cấp organization nhắm tới nhiều repo | Đã khai báo và thử apply; GitHub từ chối, chưa có ruleset mới |
| [`live/xbrain-org-poc/repositories/`](live/xbrain-org-poc/repositories/) | Repository settings và repository rulesets | Đã chuyển mã, state local và bằng chứng PoC từ [`iac-repository-management-poc`](https://github.com/xbrain-org-poc/iac-repository-management-poc) |
| [`modules/`](modules/) | Module dùng lại khi nhiều resource có cùng chính sách | Chưa cần module trong PoC |

## Kết quả đã chứng minh

- **Repository:** Terraform tạo và cập nhật [`repository-demo`](https://github.com/xbrain-org-poc/repository-demo), phát hiện và khôi phục drift, áp dụng ruleset yêu cầu PR và một approval. [Code, ảnh và log](live/xbrain-org-poc/repositories/README.md).
- **Member:** Terraform đã thử invitation, thay đổi role, drift, import và xóa thành viên thử nghiệm. State cuối đã dọn sạch. [Code, ảnh và log](live/xbrain-org-poc/identity/README.md).
- **Team/access:** Terraform đã tạo/cập nhật/xóa team và thêm/đổi role/xóa direct team membership; org membership được giữ nguyên khi xóa team membership. Plan sau từng bước hội tụ; [code, tests và evidence lịch sử](live/xbrain-org-poc/access/README.md). Team-to-repository permission, drift/import/nested-team live tests còn ngoài phạm vi đã chứng minh.
- **Org ruleset:** Đã thêm [cấu hình và kết quả thử](live/xbrain-org-poc/org-policies/README.md) cho hai repo. GitHub từ chối request tạo ruleset; gói Free hiện tại không hỗ trợ tính năng này.

## Vận hành an toàn

Organization và repo IaC chung được bootstrap thủ công. Chạy Terraform trong từng thư mục dưới `live/xbrain-org-poc/`, không chạy tại root. Không commit token, `terraform.tfvars`, state hoặc binary plan. Các phạm vi hiện dùng **local state**; trước khi dùng CI để plan/apply hoặc có nhiều người cùng vận hành, cần chuyển từng state sang backend có locking và cấp quyền GitHub phù hợp. Không chạy `apply` từ state rỗng với resource GitHub đã tồn tại; xem [ghi chú chuyển cấu trúc](docs/migration.md), [hướng dẫn import repository](live/xbrain-org-poc/repositories/docs/huong-dan-chay.md) và [runbook Team](live/xbrain-org-poc/access/RUNBOOK.md).

Trên GitHub Free, repository ruleset trong PoC áp dụng cho repo **public**; org ruleset và repo private cần gói phù hợp. Chi tiết và bằng chứng nằm trong README của từng phạm vi.
