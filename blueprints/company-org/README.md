# Blueprint cho một GitHub Organization của công ty

Đây là **mẫu tham chiếu**, chưa được apply vào org nào. Tên `ORG_DICH` và `example-service` trong các file `.example` là dữ liệu minh họa, không phải inventory công ty.

- [`repositories/group/`](repositories/group/): một Terraform root cho một nhóm repo có cùng owner, quyền và lịch apply; dùng `modules/repository` để tạo hoặc quản lý nhiều repo bằng `for_each`.
- [`org-policies/`](org-policies/): Terraform root/state riêng cho ruleset nền cấp org. Chỉ dùng khi gói GitHub và quyền quản trị hỗ trợ.

Khi biết org đích và nhóm owner, sao chép từng root vào `live/<org>/repositories/<nhom>/` hoặc `live/<org>/org-policies/`, đặt backend remote có locking, thiết lập quyền, rồi import repo/ruleset đã tồn tại trước khi apply. Không chạy Terraform trực tiếp trong `blueprints/`.

Ví dụ địa chỉ import cho một repo đã tồn tại trong root nhóm:

```powershell
terraform import 'module.repository["example-service"].github_repository.this' example-service
```

Module đặt `prevent_destroy` để chặn một số thao tác xóa do thay đổi cấu hình; vẫn cần review plan và quy trình phê duyệt riêng cho việc ngừng quản lý hoặc xóa repo.
