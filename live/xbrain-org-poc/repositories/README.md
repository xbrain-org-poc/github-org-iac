# Quản lý GitHub repositories bằng Terraform

Thư mục này là phần **quản lý repository** trong repo IaC chung [`github-org-iac`](https://github.com/xbrain-org-poc/github-org-iac): tạo hoặc import repo, cấu hình visibility, Issues, Wiki, cách merge và ruleset riêng của repo. [`org-policies/`](../org-policies/) dành cho chính sách áp dụng ở cấp organization; team, member và quyền truy cập thuộc các phạm vi khác.

## Mô hình quản lý

```text
github-org-iac/                         # Nguồn cấu hình IaC chung
└── live/xbrain-org-poc/repositories/
    ├── README.md                       # Mô hình quản lý repository
    └── sandbox/                        # Một Terraform root và một state
        ├── main.tf                     # Repo iac-repository-management-poc
        ├── demo.tf                     # Repo repository-demo
        └── docs/evidence/              # Log và ảnh kiểm chứng PoC
```

| Repository trên GitHub | Vai trò trong PoC | Nơi khai báo hiện tại |
| --- | --- | --- |
| [`repository-demo`](https://github.com/xbrain-org-poc/repository-demo) | Repo để thử cập nhật cấu hình, drift và ruleset bảo vệ nhánh | [`sandbox/demo.tf`](sandbox/demo.tf) |
| [`iac-repository-management-poc`](https://github.com/xbrain-org-poc/iac-repository-management-poc) | Repo PoC ban đầu, được giữ để tra cứu lịch sử và evidence | [`sandbox/main.tf`](sandbox/main.tf) |

Repo `iac-repository-management-poc` **vẫn tồn tại và vẫn là một repository được Terraform quản lý**, nhưng mã Terraform bên trong repo đó không còn là nơi vận hành. Từ sau tái cấu trúc, mọi thay đổi cấu hình hai repo trên được thực hiện tại `sandbox/` trong `github-org-iac`; không chạy `apply` từ repo PoC cũ.

## Khi quản lý thêm repository

Một nhóm repo có cùng owner, quyền apply và nhịp thay đổi có thể dùng **chung một Terraform root/state**; không cần tạo một thư mục hay state cho từng repo. Khi nhóm vận hành hoặc quyền apply khác nhau, tách thành root/state riêng dưới `repositories/`. Mỗi repo chỉ được khai báo và import vào **một** state.

[Blueprint cho nhóm repo](../../../blueprints/company-org/repositories/group/) minh họa cách khai báo nhiều repo bằng `for_each` và [`modules/repository/`](../../../modules/repository/). Đây là **mẫu tham chiếu**, chưa áp dụng vào org công ty. Root `sandbox/` đang khai báo trực tiếp hai repo để giữ nguyên state và bằng chứng PoC hiện có.

## Luồng thay đổi và bằng chứng

1. Xác định repo thuộc nhóm vận hành nào. Với repo đã tồn tại, import vào đúng state trước khi apply.
2. Sửa cấu hình trong root của nhóm, chạy `terraform plan` và review chính xác repo nào sẽ đổi.
3. Sau khi code được review, chạy `terraform apply` bằng cùng state; đối chiếu cấu hình trên GitHub và chạy lại `plan` để xác nhận hội tụ.

Trong sandbox, PoC đã chứng minh việc tạo/cập nhật `repository-demo`, phát hiện và khôi phục drift, cùng ruleset yêu cầu PR và một approval. [README, ảnh và log kiểm chứng](sandbox/README.md) ghi kết quả chi tiết. GitHub Free hiện chưa cho áp dụng ruleset cấp organization trong PoC này; phần thử nghiệm nằm ở [`org-policies/`](../org-policies/README.md).

State của sandbox hiện lưu **cục bộ**, không nằm trong Git. Người clone mới cần [import các tài nguyên đã tồn tại](sandbox/docs/huong-dan-chay.md) trước khi apply; không chạy từ state rỗng. Để vận hành nhiều người hoặc qua CI, cần backend remote có locking và quyền apply được kiểm soát như mô tả trong [giải pháp mô phỏng org công ty](../../../docs/company-org-solution.md).
