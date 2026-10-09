# PoC quản lý GitHub Org Teams bằng Terraform

**Organization:** `xbrain-org-poc` · **Người thực hiện:** Phúc · **Ngày chạy live:** 01/10/2026 · **Ngày tích hợp:** 09/10/2026.

Mã và báo cáo được chuyển từ [github-org-iac-po](https://github.com/phuc-do-v2/github-org-iac-po/tree/85a99fb). Terraform quản lý **team và direct team membership**. PoC đã hoàn tất create/update/delete team và add/change-role/remove direct membership; tài nguyên thử nghiệm đã được dọn sạch, state cuối trống.

## Kết quả và evidence

| Luồng | Kết quả đã kiểm chứng |
| --- | --- |
| Create team | Tạo `poc-devops`, ID `19806617`, cùng owner membership |
| Update team | Đổi thành `poc-infra-maintainers`, cập nhật description/notification tại chỗ, giữ numeric ID |
| Add member | Thêm `phuc776` với team role `member`, org role vẫn `member` |
| Change team role | Đổi `member` → `maintainer` tại chỗ |
| Remove membership | Xóa direct relationship, user vẫn là active org member |
| Delete team | Review plan `0 add / 0 change / 2 destroy`, xóa owner membership và team |
| Hội tụ và cleanup | Plan sau từng bước không đổi; state cuối trống; team API trả `404` |

[Bộ evidence](docs/evidence/README.md) chứa log plan/apply/no-change và các summary API/state đã kiểm tra. [Evidence Jira](docs/jira-task-b-live-evidence-vi.md) ghi các trích đoạn cùng kết quả xác minh. [Báo cáo phạm vi](docs/task-b-scope-report-vi.md) phân biệt live evidence với mocked tests và phần chưa thử; [kết quả chi tiết](docs/team-poc-results.md) giữ lịch sử PoC. Đây là evidence lịch sử từ repo nguồn, không phải một lần apply mới trong repo tổng hợp. Raw state, binary plan và log chưa rà soát không được bàn giao qua Git.

## Ranh giới với hai phần còn lại

- `identity/` sở hữu `github_membership` để invite, đổi org role và remove org member.
- `access/` sở hữu `github_team` và `github_team_membership`; `data.github_membership.existing` chỉ đọc và yêu cầu org member đã `active`.
- `repositories/` sở hữu repository settings và repository rulesets.
- `github_team_repository` chưa được triển khai trong PoC Team. Nhóm cần chốt owner/state của quan hệ cấp quyền team vào repo trước khi bổ sung.

Không quản lý cùng một GitHub object trong hai state. Invitation được xử lý ở `identity/`; user phải accept trước khi tạo plan Team mới. Credential, backend và thời điểm apply của từng root vẫn độc lập.

## Kiểm tra cục bộ

Chạy tại thư mục này, Terraform **1.7+**, provider được pin **6.13.0**:

```powershell
terraform init -backend=false -input=false -lockfile=readonly
terraform fmt -check -recursive
terraform validate
terraform test -no-color
```

12 test dùng mocked provider và `command = plan`; không authenticate hoặc thay đổi GitHub. Xem [test source](tests/task-b.tftest.hcl).

## Chạy lại trên sandbox

1. Dùng credential đã được org chấp thuận: fine-grained PAT/GitHub App với **Members: write**, hoặc classic PAT với **admin:org**. Chỉ đưa token vào `GITHUB_TOKEN` của terminal.
2. Xóa override `GITHUB_OWNER`, `GITHUB_ORGANIZATION`, `GITHUB_BASE_URL` khỏi environment của terminal như [runbook](RUNBOOK.md). Root này dành cho GitHub.com.
3. Copy `terraform.tfvars.example` thành `terraform.tfvars`, thay org và user đã được chấp thuận. Example có placeholder, không phải cấu hình để chạy trực tiếp.
4. Nếu team/membership tương ứng đã tồn tại, import theo runbook trước. Code này không tự nhận diện quyền sở hữu các team tạo ngoài state.

```powershell
terraform init -input=false -lockfile=readonly
terraform plan -input=false -out=task-b.tfplan
# Chỉ chạy sau khi plan thành công:
terraform show -no-color task-b.tfplan
# Chỉ apply sau khi review đúng saved plan, đặc biệt destroy/replace:
terraform apply task-b.tfplan
terraform output
terraform plan -detailed-exitcode
```

Đối chiếu GitHub API/UI và state sau apply. Plan exit `0` là không đổi, `2` là có thay đổi, `1` là lỗi. Apply saved plan vẫn cần token; tạo plan mới nếu GitHub đã thay đổi từ lúc plan.

Để kiểm tra root trống sau cleanup, copy `terraform.empty.tfvars.example` thành `terraform.tfvars`. **`teams = {}` đề xuất xóa tất cả team/membership thuộc state nếu state đang có tài nguyên**; luôn review plan trước apply.

## Giới hạn và tài liệu

- Direct membership có tính additive: user thêm tay ngoài cấu hình vẫn không do resource này quản lý.
- Nested team, inherited membership, drift recovery và import chưa được kiểm chứng live; có validation/mock tests và [kế hoạch kiểm thử mở rộng](docs/edge-case-test-plan-vi.md).
- Parent deletion có thể ảnh hưởng child hoặc repository access ngoài state; phải kiểm kê trước destroy.
- Giữ map key ổn định; đổi key hoặc chuyển root/child cần migration state có review.
- Local state, không có locking dùng chung, CI plan/apply hoặc production rollout.

[Research provider/permission](docs/provider-research.md) được kiểm tra ngày 01/10/2026 cho provider 6.13.0. [Runbook đầy đủ](RUNBOOK.md) có hướng dẫn auth, import, cleanup và relinquish management. [Workbook tiếng Việt](docs/github-org-iac-future-rollout-vi.xlsx) giải thích thuật ngữ, so sánh UI và lộ trình áp dụng; workbook được giữ nguyên từ PoC nguồn.
