# Ruleset cấp organization

Terraform root này khai báo **một ruleset cấp org** bảo vệ nhánh mặc định của `github-org-iac` và `repository-demo`: thay đổi qua PR, ít nhất một approval, chỉ squash merge. `target_repositories` có thể thêm repo khác mà không tạo thêm resource ruleset.

**Trạng thái (09/10/2026): chưa tạo được trên GitHub.** `terraform fmt -check` và `terraform validate` thành công. Plan chỉ đề xuất `1 to add, 0 to change, 0 to destroy`, nhắm đúng hai repo. Apply trả `POST /orgs/xbrain-org-poc/rulesets: 404 Not Found`; state không ghi nhận ruleset. Org đang dùng GitHub Free, trong khi [GitHub Docs](https://docs.github.com/en/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization) yêu cầu Team/Enterprise cho tính năng này. Token CLI hiện cũng thiếu `admin:org`, nên lỗi 404 không tách biệt được ảnh hưởng của gói và quyền token.

[Ghi nhận lần thử](evidence/2026-10-09-attempt.md).

Khi org có gói phù hợp và credential đủ quyền quản lý ruleset cấp org:

```powershell
$env:GITHUB_TOKEN = gh auth token
terraform init
terraform plan '-out=org-ruleset.tfplan'
terraform apply org-ruleset.tfplan
```

Xem plan trước khi apply. Nếu ruleset đã được tạo ngoài Terraform, import ID hiện có vào `github_organization_ruleset.default_branch` thay vì tạo trùng. State của root này phải được lưu riêng và chuyển sang backend có locking trước khi nhiều người cùng vận hành.
