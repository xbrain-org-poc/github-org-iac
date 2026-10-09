# Blueprint cho một GitHub Organization của công ty

Đây là **mẫu tham chiếu**, chưa được apply vào org nào. Tên `ORG_DICH` và `example-service` trong các file `.example` là dữ liệu minh họa, không phải inventory công ty.

- [`repositories/repository/`](repositories/repository/): một Terraform root/state cho một repo; dùng `modules/repository` để tái sử dụng cấu hình chung.
- [`org-policies/`](org-policies/): Terraform root/state riêng cho ruleset nền cấp org. Chỉ dùng khi gói GitHub và quyền quản trị hỗ trợ.

Khi biết org đích và repo cần quản lý, sao chép root mẫu vào `live/<org>/repositories/<ten-repo>/`, đặt backend remote có locking, thiết lập quyền, rồi import repo/ruleset đã tồn tại trước khi apply. Root `org-policies/` được triển khai riêng. Không chạy Terraform trực tiếp trong `blueprints/`.

Ví dụ địa chỉ import cho một repo đã tồn tại:

```powershell
terraform import 'module.repository.github_repository.this' example-service
```

Module đặt `prevent_destroy` để chặn một số thao tác xóa do thay đổi cấu hình; vẫn cần review plan và quy trình phê duyệt riêng cho việc ngừng quản lý hoặc xóa repo.
