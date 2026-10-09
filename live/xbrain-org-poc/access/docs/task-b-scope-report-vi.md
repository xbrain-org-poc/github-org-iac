# Báo cáo phạm vi và kết quả Task 2 – Org Teams

Ngày cập nhật: **2026-10-01**. Người thực hiện Task 2: **Phúc**. Lifecycle yêu cầu gốc đã hoàn tất trên sandbox.

## Phạm vi yêu cầu gốc

| Task | Owner | Phạm vi |
| --- | --- | --- |
| Task 1 – Org Members | Hoàng | Research auth/permission; invite/add, đổi organization role và remove organization member |
| Task 2 – Org Teams | Phúc | Research team/team membership; create/update/delete team; add/remove member khỏi team; đổi role trong team; verify bằng plan/apply, state và GitHub |

Code trong repository chỉ tạo `github_team` và `github_team_membership`. Data source `github_membership` chỉ đọc trạng thái organization member để chặn user chưa active. Task 2 không mời user, đổi organization role hoặc xóa user khỏi organization.

## Bằng chứng hiện có

| Hạng mục | Mức bằng chứng | Kết quả |
| --- | --- | --- |
| Research provider và permission | Tài liệu chính thức | Đã ghi tại [provider-research.md](provider-research.md) |
| Create team + direct membership | Live plan/apply + GitHub API + state | Đạt: 2 add, team `poc-devops` ID `19806617`, owner có team role `maintainer` |
| Hội tụ sau apply | Live plan | Đạt: plan kế tiếp exit code `0`, không có thay đổi |
| Update team | Live plan/apply + API + state | Đạt: update tại chỗ thành `poc-infra-maintainers`, giữ ID `19806617` |
| Add và đổi role user thường | Live plan/apply + API | Đạt: `phuc776` được add với `member`, đổi tại chỗ sang `maintainer`; org role vẫn `member` |
| Remove direct membership | Live plan/apply + API | Đạt: team membership trả 404; org membership vẫn `active/member` |
| Delete team và cleanup | Live plan/apply + API + state | Đạt: 2 destroy đã review; team trả 404; state trống; final plan exit `0` |
| Thiếu provider token | Live apply | Quan sát HTTP 401 trước mutation |
| User chưa thuộc organization | Live plan | Lookup trả 404 và plan dừng; Task 2 không tự gửi invitation |
| Guard và validation | Mocked plan tests | 12 test đạt; đây là bằng chứng logic cục bộ, không thay thế live lifecycle |

## Phần mở rộng chưa được chứng minh live

- Nested team và inherited membership.
- Manual drift/reconciliation.
- Import team và membership có sẵn.
- Remote backend, locking, CI/CD và GitHub App cho production.

## Điều chỉnh kết luận

Kết quả hiện tại chứng minh Terraform có thể quản lý lifecycle tối thiểu của **Org Teams** trong sandbox: create, update, delete team; add, update role và remove direct team membership; đối chiếu bằng plan/apply, GitHub API, state và plan hội tụ.

Kết luận này không bao gồm organization-member lifecycle và chưa chứng minh production readiness. Việc invite, accept, đổi organization role và remove organization member vẫn thuộc Task 1.

## Việc cần làm nếu triển khai sau PoC

1. Chọn remote backend có locking và bảo vệ state.
2. Dùng GitHub App hoặc credential chuyên dụng có least privilege.
3. Chạy plan trong CI, bắt buộc PR review cho destroy/replace.
4. Import từng team hiện hữu và kiểm tra direct/inherited membership.
5. Quy định break-glass UI và cách reconcile thay đổi về code.

Evidence chi tiết để dùng trong Jira nằm tại [jira-task-b-live-evidence-vi.md](jira-task-b-live-evidence-vi.md).
