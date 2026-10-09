# Evidence Jira – Task 2 GitHub Org Teams

Ngày chạy: **2026-10-01**

Sandbox: `xbrain-org-poc`

Terraform: `1.16.4`

GitHub Provider: `integrations/github 6.13.0`

## Kết quả

| Flow | Kết quả | Evidence chính |
| --- | --- | --- |
| Create team | Đạt | Team `poc-devops`, ID `19806617` được tạo bằng Terraform |
| Update team | Đạt | Update tại chỗ thành `poc-infra-maintainers`, giữ ID `19806617` |
| Add ordinary member | Đạt | `phuc776` được thêm trực tiếp với team role `member` |
| Change team role | Đạt | `phuc776`: `member` → `maintainer`, update tại chỗ |
| Remove team membership | Đạt | Relationship bị xóa; `phuc776` vẫn active/member trong organization |
| Delete team | Đạt | Owner membership và team bị xóa theo plan đã review |
| Final convergence | Đạt | Terraform state trống; plan exit code `0`; team API trả `404` |

## Update team

```text
# github_team.root["devops"] will be updated in-place
name                 = "poc-devops" -> "poc-infra-maintainers"
notification_setting = "notifications_enabled" -> "notifications_disabled"

Plan: 0 to add, 1 to change, 0 to destroy.
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

GitHub API và Terraform state cùng trả:

```text
team_id              = 19806617
slug                 = poc-infra-maintainers
privacy              = closed
notification_setting = notifications_disabled
```

Plan sau apply: `No changes`, detailed exit code `0`.

## Team membership

### Add member

```text
github_team_membership.member["devops:phuc776"] will be created
Plan: 1 to add, 0 to change, 0 to destroy.
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

API sau apply: organization `active/member`, team `active/member`. Plan kế tiếp không đổi.

### Change team role

```text
github_team_membership.member["devops:phuc776"] will be updated in-place
role = "member" -> "maintainer"
Plan: 0 to add, 1 to change, 0 to destroy.
```

API sau apply: organization role vẫn là `member`, team role là `maintainer`. Plan kế tiếp không đổi.

### Remove direct membership

```text
github_team_membership.member["devops:phuc776"] will be destroyed
Plan: 0 to add, 0 to change, 1 to destroy.
Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
```

API sau apply: team membership trả `404`; organization membership vẫn `active/member`. Plan kế tiếp không đổi.

## Delete team

Fresh saved plan sau membership tests:

```text
github_team_membership.member["devops:phuc-do-v2"] will be destroyed
github_team.root["devops"] will be destroyed
Plan: 0 to add, 0 to change, 2 to destroy.
```

Plan được review trước khi apply.

```text
Apply complete! Resources: 0 added, 0 changed, 2 destroyed.
team_memberships = {}
teams = {}
```

Xác minh cuối:

```text
Team API                    = 404
Terraform state list        = empty
phuc-do-v2 organization     = active/admin
phuc776 organization        = active/member
Final plan detailed exit    = 0
```

## Invitation bằng IaC

Provider 6.13.0 hỗ trợ resource `github_membership`. Khi apply với một username chưa thuộc organization, provider gọi organization membership API và gửi invitation. User ở trạng thái `pending` cho đến khi accept.

Điều kiện:

- Credential thuộc organization owner.
- Fine-grained PAT hoặc GitHub App có organization permission `Members: write`; classic PAT dùng `admin:org`.
- Destroy mặc định hủy pending invitation hoặc remove active member khỏi organization. `downgrade_on_destroy = true` chỉ phù hợp với trường hợp hạ owner xuống member, không phải giữ nguyên mọi membership.

PoC Task 2 không tạo resource này. Invitation của `phuc776` được thực hiện ngoài state Task 2, sau đó Task 2 chỉ đọc prerequisite và quản lý team membership.

Nguồn:

- https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/membership.md
- https://docs.github.com/en/rest/orgs/members#set-organization-membership-for-a-user

## Screenshot cho Jira

Plan/apply, GitHub API và Terraform state là evidence chính. Screenshot UI chỉ là evidence bổ sung nếu reviewer yêu cầu. Không chụp token, state file hoặc cửa sổ có credential.
