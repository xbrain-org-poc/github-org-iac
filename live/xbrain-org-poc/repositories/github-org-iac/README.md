# Quản lý repository GitHub Org IaC

Terraform root này quản lý **chính repository chứa mã IaC** [`github-org-iac`](https://github.com/xbrain-org-poc/github-org-iac). Organization và repository được tạo thủ công ban đầu; repository hiện hữu phải được import vào state trước khi apply. Mỗi repo có state riêng theo [mô hình quản lý repository](../README.md).

## Cấu hình mong muốn

- Public; giữ Issues, Projects, Wiki và description hiện tại.
- Chỉ squash merge và tự xóa nhánh sau merge.
- Ruleset active trên nhánh mặc định: thay đổi qua PR, cần một approval, hủy approval cũ khi có commit mới; không cấu hình bypass.
- `prevent_destroy` trên `github_repository` để chặn xóa repo do thay đổi Terraform ngoài ý muốn.

## Áp dụng lần đầu

Chạy tại thư mục này, trên máy có Terraform và GitHub CLI với quyền quản trị repo:

```powershell
$env:GITHUB_TOKEN = gh auth token
terraform init
terraform import github_repository.iac github-org-iac
terraform plan '-out=change.tfplan'
terraform apply change.tfplan
terraform plan
```

Kiểm tra `terraform state list` trước khi import; không import cùng repo vào hai state. Ruleset chưa tồn tại trên GitHub trước lần apply đầu, nên Terraform sẽ tạo mới. Review plan và merge thay đổi mã trước khi apply. State và binary plan lưu cục bộ, không commit; trước khi nhiều người cùng vận hành cần backend remote có locking.

Sau khi ruleset active, mọi PR vào `main` (kể cả PR thay đổi repo IaC này) cần reviewer khác người tạo PR approve. Không có tài khoản bypass trong cấu hình.
