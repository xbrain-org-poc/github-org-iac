# Giải pháp GitHub Org IaC cho phạm vi công ty

## Mục tiêu và trạng thái

`xbrain-org-poc` là sandbox riêng để chứng minh luồng. PoC Team đã được tích hợp vào `access/`, nhưng phần cấp quyền team vào repo chưa có. Chưa có tên org công ty, inventory repo, danh sách owner/team, IdP hay backend state được phê duyệt. Vì vậy blueprint trong repo là **thiết kế có mã tham chiếu**; không đại diện cho cấu hình đã áp dụng ở công ty.

## Ranh giới quản lý

```text
github-org-iac/
├── modules/repository/                 # Cấu hình repo dùng lại
├── blueprints/company-org/             # Root mẫu; không apply trực tiếp
└── live/
    ├── xbrain-org-poc/                 # Sandbox PoC hiện tại
    │   ├── identity/
    │   ├── access/
    │   ├── org-policies/
    │   └── repositories/<ten-repo>/    # Mỗi repo PoC có root/state riêng
    └── <org-cong-ty>/                  # Chỉ tạo khi biết org đích
        ├── org-policies/               # State và quyền quản trị org riêng
        ├── identity/                   # Chỉ khi không do IdP quản lý
        ├── access/                     # Team và quyền vào repo
        └── repositories/<ten-repo>/    # Một root/state cho mỗi repository
```

Mỗi repository có thư mục và state riêng; dùng `modules/repository` để tái sử dụng cấu hình. Cách này cho phép review, plan và apply theo từng repo. Ruleset cấp org đặt chính sách nền; ruleset cấp repo chỉ dùng khi cần yêu cầu chặt hơn hoặc ngoại lệ được duyệt. Nếu IdP/SCIM là nguồn quản lý membership, `identity/` không đồng thời ghi các membership đó.

## Luồng thay đổi dự kiến

1. Xác định owner của repo và tạo root mang tên repo; repo đã tồn tại phải import vào đúng state trước.
2. PR chạy format/validate và plan theo thư mục repo thay đổi. Người chịu trách nhiệm xem plan, đặc biệt các hành động delete, replace, đổi visibility và đổi quyền.
3. Sau review, apply dùng credential giới hạn quyền và backend remote có locking. Quyền apply `org-policies/`, `access/` và từng repo được tách.
4. Đối chiếu API GitHub sau apply, lưu log/plan theo thay đổi; chạy plan định kỳ để phát hiện drift.

Hiện `.github/workflows/` chưa chạy plan/apply vì thiếu backend, credential và người duyệt thật. Không sử dụng local state hoặc token cá nhân làm cơ chế vận hành chung.

## Lộ trình từ PoC sang org công ty

1. Kiểm kê org: repo, visibility, settings, rulesets, team access, owner và ngoại lệ; xác định gói GitHub và IdP.
2. Chốt owner từng repo, chính sách nền và backend có locking; đặt CODEOWNERS và người duyệt cho từng đường dẫn.
3. Sao chép root mẫu vào `live/<org-cong-ty>/repositories/<ten-repo>/`; nhập các resource hiện hữu vào state từng repo. Plan đầu phải được review đến khi không có thay đổi ngoài ý muốn.
4. Pilot trên một vài repo ít rủi ro, rồi rollout theo đợt. Không chuyển đồng loạt các repo hoặc xóa ruleset cũ trước khi rule mới có hiệu lực.

## Điều kiện để gọi là sẵn sàng áp dụng toàn công ty

- Có inventory repo và owner được xác nhận; mỗi resource chỉ có một nơi quản lý/state.
- Có backend remote với locking, quyền truy cập state và phương án khôi phục.
- Có credential tự động hóa giới hạn quyền, review theo owner và cổng phê duyệt apply.
- Có plan/import cho từng repo và kết quả pilot; không còn resource bị đề xuất tạo lại/xóa ngoài chủ ý.
- Đã kiểm tra gói GitHub hỗ trợ chính sách cấp org; trường hợp không hỗ trợ có phương án ruleset cấp repo.

## Tài liệu tham chiếu

- [HashiCorp: chia workspace/state theo trách nhiệm và quyền](https://developer.hashicorp.com/terraform/enterprise/workspaces/best-practices)
- [HashiCorp: lưu state ở backend remote](https://developer.hashicorp.com/terraform/language/state)
- [GitHub: organization rulesets và phạm vi repository](https://docs.github.com/en/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization)
- [GitHub: team membership đồng bộ từ IdP](https://docs.github.com/en/enterprise-cloud%40latest/organizations/organizing-members-into-teams/synchronizing-a-team-with-an-identity-provider-group)
