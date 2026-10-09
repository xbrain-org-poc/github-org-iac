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
├── README.md       # Phạm vi và quy trình quản lý repository
└── sandbox/        # Terraform root/state cho nhóm repo PoC
```

Mỗi thư mục con là một **Terraform root và state** cho nhóm repo có cùng owner, quyền apply và nhịp thay đổi. Một root có thể quản lý nhiều repo; không cần tạo state riêng cho từng repo. Chỉ tách nhóm khi ranh giới trách nhiệm hoặc quyền vận hành khác nhau. Mỗi resource `github_repository` chỉ được một state sở hữu.

Root [`sandbox/`](sandbox/) đang dùng các resource khai báo trực tiếp để giữ nguyên state của PoC. [Blueprint nhóm repo](../../../blueprints/company-org/repositories/group/) minh họa `for_each` kết hợp [`modules/repository/`](../../../modules/repository/) khi mở rộng cho nhiều repo; blueprint này chưa được áp dụng vào org công ty.

## Luồng quản lý

1. Xác định owner và nhóm vận hành của repo; thêm cấu hình vào root tương ứng. Repo đã tồn tại phải được import vào đúng state.
2. Tạo pull request và chạy `terraform plan` để xem chính xác repo, thuộc tính và ruleset nào sẽ thay đổi.
3. Sau khi review, chạy `terraform apply` với cùng state và quyền GitHub phù hợp.
4. Đối chiếu cấu hình trên GitHub, rồi chạy lại `plan` để xác nhận không còn thay đổi ngoài dự kiến.

[README và evidence của sandbox](sandbox/README.md) ghi kết quả PoC về tạo/cập nhật repo, phát hiện và khôi phục drift, cùng kiểm tra ruleset bằng thao tác thật.

State sandbox hiện lưu cục bộ, không commit vào Git. Người clone mới cần [import tài nguyên hiện hữu](sandbox/docs/huong-dan-chay.md) trước khi apply. Trước khi vận hành chung hoặc qua CI, cần backend remote có locking và phân quyền apply; xem [đề xuất cho org công ty](../../../docs/company-org-solution.md).
