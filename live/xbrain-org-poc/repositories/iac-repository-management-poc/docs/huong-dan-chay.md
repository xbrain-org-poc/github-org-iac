# Hướng dẫn quản lý repository PoC ban đầu

Chạy tại `live/xbrain-org-poc/repositories/iac-repository-management-poc/` với Terraform >= 1.5, GitHub CLI và tài khoản có quyền quản lý repo trong `xbrain-org-poc`.

```powershell
$env:GITHUB_TOKEN = gh auth token
terraform init
terraform state list
```

Nếu clone mới chưa có state, import **chỉ những resource chưa có trong state** trước khi plan:

```powershell
terraform import github_repository.poc iac-repository-management-poc
terraform import 'github_repository_ruleset.default_branch[0]' 'iac-repository-management-poc:24238381'
terraform plan
```

ID ruleset trên là ID tại thời điểm PoC. Nếu ruleset được tạo lại, lấy ID hiện tại bằng `gh api repos/xbrain-org-poc/iac-repository-management-poc/rulesets`. Không apply từ state rỗng hoặc cùng lúc từ hai nơi quản lý một repo.

Sau khi sửa code qua PR và review, chạy `terraform plan '-out=change.tfplan'`, kiểm tra diff, rồi `terraform apply change.tfplan`. Đối chiếu cấu hình trên GitHub và chạy lại `terraform plan`.
