# Giải pháp GitHub Org IaC cho phạm vi công ty

## Mục tiêu và trạng thái

`xbrain-org-poc` là sandbox riêng để chứng minh luồng. Chưa có tên org công ty, inventory repo, danh sách owner/team, IdP hay backend state được phê duyệt. Vì vậy blueprint trong repo là **thiết kế có mã tham chiếu**; không đại diện cho cấu hình đã áp dụng ở công ty.

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
    │   └── repositories/sandbox/       # State riêng cho nhóm repo sandbox
    └── <org-cong-ty>/                  # Chỉ tạo khi biết org đích
        ├── org-policies/               # State và quyền quản trị org riêng
        ├── identity/                   # Chỉ khi không do IdP quản lý
        ├── access/                     # Team và quyền vào repo
        └── repositories/<nhom-owner>/  # Một root/state cho mỗi nhóm vận hành
```

Mỗi root có state riêng. Chia `repositories/` theo owner, quyền vận hành và nhịp thay đổi; nhiều repo cùng nhóm dùng `for_each`/module. Ruleset cấp org đặt chính sách nền; ruleset cấp repo chỉ dùng khi cần yêu cầu chặt hơn hoặc ngoại lệ được duyệt. Nếu IdP/SCIM là nguồn quản lý membership, `identity/` không đồng thời ghi các membership đó.

## Luồng thay đổi dự kiến

1. Xác định owner và nhóm của repo; nhập repo vào cấu hình nhóm. Repo đã tồn tại phải import vào đúng state trước.
2. PR chạy format/validate và plan theo thư mục thay đổi. Người chịu trách nhiệm nhóm xem plan, đặc biệt các hành động delete, replace, đổi visibility và đổi quyền.
3. Sau review, apply dùng credential giới hạn quyền và backend remote có locking. Quyền apply `org-policies/`, `access/` và từng nhóm repo được tách.
4. Đối chiếu API GitHub sau apply, lưu log/plan theo thay đổi; chạy plan định kỳ để phát hiện drift.

Hiện `.github/workflows/` chưa chạy plan/apply vì thiếu backend, credential và người duyệt thật. Không sử dụng local state hoặc token cá nhân làm cơ chế vận hành chung.

## Lộ trình từ PoC sang org công ty

1. Kiểm kê org: repo, visibility, settings, rulesets, team access, owner và ngoại lệ; xác định gói GitHub và IdP.
2. Chốt nhóm owner, chính sách nền và backend có locking; đặt CODEOWNERS và người duyệt cho từng đường dẫn.
3. Sao chép root mẫu vào `live/<org-cong-ty>/`; nhập các resource hiện hữu vào state theo từng nhóm. Plan đầu phải được review đến khi không có thay đổi ngoài ý muốn.
4. Pilot trên một nhóm repo ít rủi ro, rồi rollout theo đợt. Không chuyển đồng loạt các repo hoặc xóa ruleset cũ trước khi rule mới có hiệu lực.

## Điều kiện để gọi là sẵn sàng áp dụng toàn công ty

- Có inventory repo và owner được xác nhận; mỗi resource chỉ có một nơi quản lý/state.
- Có backend remote với locking, quyền truy cập state và phương án khôi phục.
- Có credential tự động hóa giới hạn quyền, review theo owner và cổng phê duyệt apply.
- Có plan/import cho từng nhóm và kết quả pilot; không còn resource bị đề xuất tạo lại/xóa ngoài chủ ý.
- Đã kiểm tra gói GitHub hỗ trợ chính sách cấp org; trường hợp không hỗ trợ có phương án ruleset cấp repo.

## Tài liệu tham chiếu

- [HashiCorp: chia workspace/state theo trách nhiệm và quyền](https://developer.hashicorp.com/terraform/enterprise/workspaces/best-practices)
- [HashiCorp: lưu state ở backend remote](https://developer.hashicorp.com/terraform/language/state)
- [GitHub: organization rulesets và phạm vi repository](https://docs.github.com/en/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization)
- [GitHub: team membership đồng bộ từ IdP](https://docs.github.com/en/enterprise-cloud%40latest/organizations/organizing-members-into-teams/synchronizing-a-team-with-an-identity-provider-group)
