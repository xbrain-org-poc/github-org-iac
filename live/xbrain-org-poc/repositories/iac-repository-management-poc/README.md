# Repository PoC ban đầu

Terraform root này quản lý cấu hình và ruleset cấp repository của [`iac-repository-management-poc`](https://github.com/xbrain-org-poc/iac-repository-management-poc). Repo GitHub đó được giữ để tra cứu mã và evidence của PoC ban đầu; **code Terraform ở đây** là nguồn cấu hình đang được duy trì sau khi tái cấu trúc.

- [`main.tf`](main.tf): repository settings và ruleset bảo vệ nhánh mặc định.
- [`variables.tf`](variables.tf), [`outputs.tf`](outputs.tf): tham số và URL repo.
- [Evidence bootstrap](docs/evidence/bootstrap/): ảnh và kết quả kiểm chứng ban đầu.

Hai resource của repo này đã được chuyển từ state PoC dùng chung sang state riêng tại thư mục này. State lưu cục bộ và không commit vào Git. Trên máy clone mới, import repository và ruleset hiện hữu trước khi apply; xem [hướng dẫn](docs/huong-dan-chay.md). Không chạy Terraform từ repo PoC cũ hoặc từ state rỗng đối với tài nguyên đã tồn tại.
