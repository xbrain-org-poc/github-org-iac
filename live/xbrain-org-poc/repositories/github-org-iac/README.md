# Quản lý repository GitHub Org IaC

Terraform root này quản lý **chính repository chứa mã IaC** [`github-org-iac`](https://github.com/xbrain-org-poc/github-org-iac). Organization và repository được tạo thủ công ban đầu; repository hiện hữu phải được import vào state trước khi apply. Mỗi repo có state riêng theo [mô hình quản lý repository](../README.md).

## Cấu hình mong muốn

- Public; giữ Issues, Projects, Wiki và description hiện tại.
- Chỉ squash merge và tự xóa nhánh sau merge.
- Ruleset active trên nhánh mặc định: thay đổi qua PR, cần một approval, hủy approval cũ khi có commit mới; không cấu hình bypass.
- `prevent_destroy` trên `github_repository` để chặn xóa repo do thay đổi Terraform ngoài ý muốn.

## Kết quả kiểm chứng (09/10/2026)

Repository hiện hữu đã được import vào state riêng. Terraform apply thành công: **1 ruleset được tạo, 1 repository được cập nhật, 0 tài nguyên bị xóa**. [PR mã nguồn #10](https://github.com/xbrain-org-poc/github-org-iac/pull/10) · [Settings từ GitHub API](docs/evidence/repository-settings.json) · [Ruleset từ GitHub API](docs/evidence/default-branch-ruleset.json) · [Plan sau apply: No changes](docs/evidence/post-apply-plan.txt).

## Vận hành và import trên máy mới

Chạy tại thư mục này, trên máy có Terraform và GitHub CLI với quyền quản trị repo:

```powershell
$env:GITHUB_TOKEN = gh auth token
terraform init
terraform state list
```

State local không có trong Git. Trên máy clone mới, import **chỉ các resource chưa có trong state** trước khi chạy plan/apply:

```powershell
terraform import github_repository.iac github-org-iac
terraform import github_repository_ruleset.default_branch 'github-org-iac:24772690'
```

Sau khi đã có đúng hai resource trong state, review plan rồi apply:

```powershell
terraform plan '-out=change.tfplan'
terraform apply change.tfplan
terraform plan
```

ID ruleset trên được ghi nhận ngày 09/10/2026; nếu ruleset được tạo lại, lấy ID hiện tại bằng `gh api repos/xbrain-org-poc/github-org-iac/rulesets`. Không import cùng repo vào hai state. State và binary plan lưu cục bộ, không commit; trước khi nhiều người cùng vận hành cần backend remote có locking.

Sau khi ruleset active, mọi PR vào `main` (kể cả PR thay đổi repo IaC này) cần reviewer khác người tạo PR approve. Không có tài khoản bypass trong cấu hình.
