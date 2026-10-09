# Kế hoạch kiểm thử mở rộng cho Task 2 – Org Teams

## Mục tiêu và mô hình thử nghiệm

Mục tiêu là kiểm tra thêm behavior và trường hợp biên sau khi hoàn tất lifecycle tối thiểu của Task 2. Các case chưa chạy là kế hoạch, không phải bằng chứng rằng Terraform đã thay thế thao tác UI hoặc đã sẵn sàng cho production.

Phạm vi vẫn chỉ gồm team và direct team membership. Invite, đổi organization role và remove organization member thuộc Task 1 của Hoàng.

Mô hình sandbox:

```text
xbrain-org-poc
└── poc-infra-maintainers (root, closed)
    └── poc-argocd-operators (child, closed)
```

- `poc-infra-maintainers`: team DevOps chịu trách nhiệm hạ tầng dùng chung.
- `poc-argocd-operators`: team con vận hành Argo CD. PoC không gán quyền repository; Argo CD chỉ là ngữ cảnh vận hành.
- `phuc-do-v2`: organization owner, phải có team role `maintainer`.
- `phuc776`: organization member bình thường; dùng để kiểm thử `member`/`maintainer`, pending invitation, removal và drift.

File local `edge-case.tfvars` mô tả trạng thái đích. Nó giữ key Terraform hiện tại là `devops` để đổi tên team `poc-devops` tại chỗ; đổi key sang `infra` sẽ đổi resource address và có thể tạo destroy/create ngoài ý muốn.

## Nguyên tắc chạy

1. Mỗi thay đổi phải tạo saved plan mới và xem bằng `terraform show`.
2. Không apply nếu plan có destroy/replace ngoài đúng case đang thử.
3. Sau mỗi apply phải kiểm tra GitHub API/UI và chạy plan lần hai; exit code `0` là hội tụ.
4. Không tái sử dụng saved plan sau khi remote hoặc membership thay đổi.
5. State, tfvars, plan và token chỉ nằm local và không được commit.
6. Các case xóa parent team phải kiểm kê child team và repository access ngoài state trước khi apply.

## Ma trận edge case

| ID | Tình huống | Cách thử | Kỳ vọng đạt |
| --- | --- | --- | --- |
| AUTH-01 | Apply saved plan không có token | Xóa `GITHUB_TOKEN`, chạy apply trong sandbox | HTTP 401 xảy ra trước mutation; state và remote không đổi. Đã quan sát thực tế. |
| AUTH-02 | Owner nhưng token thiếu scope mời member | Dùng credential có `repo, workflow, gist` để mời `phuc776` | GitHub trả 403; chứng minh role owner không thay thế token scope. Đã quan sát thực tế. |
| MEMBER-01 | User chưa thuộc organization | Plan với `phuc776` trong team | **Đạt thực tế:** read-only `github_membership` trả 404 và toàn bộ plan exit `1`; không lưu plan, tạo team/membership hoặc tự gửi invitation. Trước khi bị chặn, preview chỉ ra root update tại chỗ (giữ ID `19806617`) và một child create, không có destroy. |
| MEMBER-02 | Invitation đang pending | Owner mời `phuc776`, user chưa accept, chạy plan | Lookup thành công nhưng postcondition `state == active` chặn plan; không tạo team membership. |
| MEMBER-03 | Invitation đã accept | `phuc776` accept, tạo plan mới | **Đạt live:** add plan 1/0/0; API trả organization `active/member` và team `active/member`; plan sau apply exit `0`. |
| ROLE-01 | Org owner được cấu hình `member` | Đổi `phuc-do-v2` thành `member` trong team | Precondition chặn plan vì GitHub luôn báo owner là team maintainer. Mock test đã đạt. |
| ROLE-02 | Đổi role user thường | `phuc776`: `member` → `maintainer` | **Đạt live:** update tại chỗ; org role vẫn là member; plan sau apply exit `0`. |
| TEAM-01 | Đổi team name/slug | `poc-devops` → `poc-infra-maintainers`, giữ key `devops` | **Đạt live:** update tại chỗ, numeric team ID `19806617` được giữ; slug thay đổi; membership không bị recreate. |
| TEAM-02 | Update thuộc tính | Đổi description và notification setting | **Đạt live:** plan 0/1/0, API/state khớp và plan sau apply exit `0`. |
| NEST-01 | Tạo parent/child hợp lệ | Tạo `argocd` với `parent_key = devops`, cả hai `closed` | Parent được refresh/update trước, child nhận đúng parent ID; không có cycle. |
| NEST-02 | Child hoặc parent là `secret` | Đổi privacy một phía thành `secret` | Variable validation chặn trước API. Mock test đã đạt. |
| NEST-03 | Membership kế thừa | Chỉ cho `phuc776` vào child, đọc quyền/membership ở parent | Ghi rõ direct và inherited membership; Terraform chỉ sở hữu quan hệ direct đã khai báo. |
| MULTI-01 | Một user ở hai team | Thêm `phuc776` trực tiếp vào cả root và child | Hai địa chỉ state riêng; kiểm tra API không làm direct/inherited membership bị nhầm. |
| DRIFT-01 | Sửa team thủ công | Đổi description của team trên UI | Plan phát hiện và đề xuất khôi phục giá trị IaC; apply hội tụ. |
| DRIFT-02 | Sửa membership thủ công | Đổi/xóa direct role của `phuc776` trên UI | Plan đề xuất khôi phục đúng relationship/role; org membership không đổi. |
| ADDITIVE-01 | Thêm user ngoài cấu hình | Thêm một user khác thủ công vào team | Plan không xóa user đó vì `github_team_membership` là additive; ghi nhận đây là giới hạn quản trị. |
| REMOVE-01 | Xóa direct team membership | Bỏ `phuc776` khỏi map `members` | **Đạt live:** plan/apply chỉ destroy relationship; team membership trả 404; user vẫn `active/member` trong organization. |
| REMOVE-02 | Xóa child team | Bỏ key `argocd` | Plan xóa memberships do state quản lý rồi child; root còn nguyên. |
| DELETE-01 | Xóa parent có child | Chỉ lập plan, kiểm kê mọi child trước apply | Không apply nếu có unmanaged child; GitHub có thể cascade xóa ngoài những gì plan hiển thị. |
| IMPORT-01 | Import team có sẵn | Import bằng numeric ID vào cấu hình khớp | Plan chỉ import, không update/replace; plan kế tiếp không đổi. |
| IMPORT-02 | Import direct membership | Import `team-id:username` | Chỉ relationship được import; không import/xóa org membership. |
| STATE-01 | State không có nhưng remote có | Sao lưu state rồi thử trong thư mục cô lập | Plan muốn create và có thể gặp name conflict; chứng minh remote state/locking là bắt buộc cho production. |
| CONCURRENCY-01 | Hai admin cùng plan/apply | Mô phỏng bằng hai working copy với backend test có locking | Run thứ hai phải bị khóa hoặc tạo plan lại; local state hiện tại không đủ cho production. |

## Trình tự chạy đề xuất

1. `MEMBER-01` với `phuc776` chưa được mời.
2. Mời `phuc776` bằng UI hoặc token có `admin:org`; chạy `MEMBER-02` trước khi accept.
3. `phuc776` accept invitation; chạy `MEMBER-03`.
4. Chạy `TEAM-01`, `NEST-01`, `ROLE-02`, `MULTI-01`.
5. Chạy drift và additive cases.
6. Chạy import trên một team disposable riêng.
7. Chạy remove/child cleanup; chỉ đánh giá `DELETE-01`, không xóa parent khi chưa kiểm kê.
8. Chạy state/concurrency trong môi trường cô lập, không dùng state thật duy nhất của PoC.

## Tiêu chí kết luận

- **Go**: create/update/role/remove/import/drift đều tạo diff đúng; plan sau apply hội tụ; boundary org membership được giữ; không có mutation ngoài state ở các flow bình thường.
- **Go có điều kiện**: lifecycle cơ bản đạt nhưng cần GitHub App/PAT đúng quyền, remote state có locking, PR review và runbook cho nested-team deletion, inherited membership, IdP sync.
- **No-go**: provider tạo diff lặp lại không thể xử lý, role/direct membership không ổn định, import gây replace, hoặc thao tác team có side effect ngoài state không thể kiểm soát bằng review.

Kết luận cho yêu cầu Task 2 gốc là **đạt trong sandbox**: create/update/delete team và add/change-role/remove direct membership đều có live evidence và plan hội tụ. Ma trận này còn các phần mở rộng chưa chạy như nested team, drift, import, state locking và concurrency; vì vậy chưa kết luận production readiness.
