# Quản lý GitHub repository bằng Terraform

Thư mục `repositories/` khai báo trạng thái mong muốn của các repository trong GitHub Organization. Thay đổi cấu hình được review qua code, xem trước bằng `terraform plan`, áp dụng bằng `terraform apply` và kiểm tra lại trên GitHub.

## Phạm vi quản lý

- **Vòng đời repository:** tạo repo mới hoặc import repo đã tồn tại vào Terraform state.
- **Cấu hình từng repo:** tên, mô tả, visibility, Issues, Wiki, Projects và các cách merge được phép.
- **Bảo vệ ở cấp repo:** ruleset cho nhánh, yêu cầu pull request và approval khi phù hợp với gói GitHub đang dùng.
- **Phát hiện drift:** `plan` chỉ ra thay đổi thực hiện ngoài IaC; sau khi review, cập nhật code hoặc `apply` để đưa cấu hình về trạng thái mong muốn.

Chính sách dùng chung ở cấp organization được khai báo tại [`org-policies/`](../org-policies/); quyền team/member thuộc các Terraform root tương ứng.

## Tổ chức nhiều repository

```text
repositories/
├── README.md           # Phạm vi và quy trình quản lý repository
└── <ten-repository>/   # Một Terraform root/state cho mỗi repo
```

Mỗi thư mục con mang tên GitHub repository tương ứng và có **Terraform root/state riêng**. Cấu hình, ruleset và bằng chứng của repo nằm cùng chỗ; PR và `plan` cho một repo có phạm vi rõ ràng. Khi số lượng repo tăng, dùng module để tái sử dụng cấu hình chung thay vì sao chép logic vào mọi thư mục. Mỗi resource `github_repository` chỉ được một state sở hữu.

[Root PoC cho một repository](repository-demo/) cho thấy cấu hình và evidence hiện có. [Blueprint cho một repository](../../../blueprints/company-org/repositories/repository/) minh họa cách gọi [`modules/repository/`](../../../modules/repository/) để mở rộng; blueprint này chưa được áp dụng vào org công ty.

## Luồng quản lý

1. Tạo thư mục mang tên repo và xác định owner vận hành; repo đã tồn tại phải được import vào state của thư mục đó.
2. Tạo pull request và chạy `terraform plan` để xem chính xác repo, thuộc tính và ruleset nào sẽ thay đổi.
3. Sau khi review, chạy `terraform apply` với cùng state và quyền GitHub phù hợp.
4. Đối chiếu cấu hình trên GitHub, rồi chạy lại `plan` để xác nhận không còn thay đổi ngoài dự kiến.

[README và evidence của PoC](repository-demo/README.md) ghi kết quả tạo/cập nhật repo, phát hiện và khôi phục drift, cùng kiểm tra ruleset bằng thao tác thật.

State PoC hiện lưu cục bộ, không commit vào Git. Người clone mới cần [import tài nguyên hiện hữu](repository-demo/docs/huong-dan-chay.md) trước khi apply. Trước khi vận hành chung hoặc qua CI, cần backend remote có locking và phân quyền apply; xem [đề xuất cho org công ty](../../../docs/company-org-solution.md).
