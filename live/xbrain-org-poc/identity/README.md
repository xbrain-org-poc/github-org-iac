# GitHub Org Members bằng Terraform

PoC này quản lý trực tiếp một tập thành viên GitHub Organization bằng `github_membership`: mời, đổi role, và xóa. Đã chạy trên GitHub.com với provider `integrations/github` 6.13.0 và Terraform 1.16.3.

**Kết quả:** lifecycle đã PASS trên `xbrain-org-poc` / `hofang42-xbrain`. Terraform tạo invitation, giữ state khi invitation pending, cập nhật `member ↔ admin` tại chỗ, phát hiện drift, import state và xóa active member. Bằng chứng ngắn cùng sáu ảnh GitHub UI nằm trong [`evidence/README.md`](evidence/README.md).

## Chạy PoC

Terraform chạy local trong Ubuntu/WSL và gọi GitHub API. Cần Python 3.9+, Terraform 1.5+ và PAT của một organization owner. Tạo fine-grained PAT giới hạn resource owner là org thử nghiệm với **Organization permissions → Members: Read and write**; tuân theo yêu cầu approval/SSO của org. Không commit PAT.

```bash
cp terraform.tfvars.json.example terraform.tfvars.json
# Điền org, API URL và username đã được chấp thuận.
```

Tạo `.env` local (file đã bị gitignore), đặt `GITHUB_TOKEN='PAT'`, rồi chạy:

```bash
python3 scripts/poc.py validate
python3 scripts/poc.py preflight --username TEST_USER
python3 scripts/poc.py verify --username TEST_USER --state absent
python3 scripts/poc.py plan --expect-exit 2
# Review plan.txt/actions.json trong evidence run trước khi apply.
python3 scripts/poc.py apply --plan evidence/RUN_ID-plan/change.tfplan
python3 scripts/poc.py verify --username TEST_USER --state pending --role member
```

Người nhận phải tự accept invitation. Xác minh lại với `--state active`. Thay map `members` để nâng/hạ role; xóa username khỏi map để remove. Dùng plan/apply như trên cho mỗi thay đổi. Script lưu bằng chứng vào `evidence/` và dừng nếu kết quả API/plan khác mong đợi.

```bash
python3 scripts/lifecycle.py roles-and-drift
# Khi tài khoản active; demo mutates role và dùng API trực tiếp để tạo drift.
python3 scripts/lifecycle.py final-remove
```

Hai lệnh cuối là kịch bản live cố định cho org/username trong kết quả PoC; đừng chạy vào org khác. Chi tiết giới hạn, auth và state behavior có trong [`evidence/README.md`](evidence/README.md).

## Ranh giới với các phạm vi khác

`identity/` là state duy nhất có `resource "github_membership"`: ai có mặt trong org, role `member`/`admin` và invitation. Phạm vi khác chỉ đọc qua `data "github_membership"` như [`access/`](../access/README.md); không khai báo lại resource này.

| Đối tượng GitHub | Phạm vi sở hữu |
| --- | --- |
| Org membership, org role, invitation | `identity/` |
| Team, team membership | `access/` |
| Repository, repository ruleset | `repositories/` |
| Quyền team trên repo, outside collaborator | Chưa chốt; không đặt trong `identity/` |

**Thứ tự apply.** Thêm người: `identity` (invite) → người nhận accept → `access` → `repositories`. Xóa người: theo chiều ngược lại, gỡ khỏi `access` trước khi xóa trong `identity`; nếu không, GitHub tự gỡ team membership và plan tiếp theo của `access` lỗi vì không còn org membership. Nâng ai lên `admin` thì cùng lúc đổi team role của họ trong `access` thành `maintainer` (precondition của `access`).

**Không tự khóa org.**
- Không đưa tài khoản sở hữu PAT vào `members`. `poc.py preflight` và `poc.py plan` dừng nếu có.
- Giữ ít nhất hai Owner ngoài state này để khôi phục khi IaC lỗi.
- Owner/member đã tồn tại phải `terraform import` (`ORG:USERNAME`) trước khi thêm vào `members`; không apply từ state rỗng.

**Trước khi dùng ngoài PoC.**
- Commit danh sách `members` để review qua PR. Hiện danh sách nằm trong `terraform.tfvars.json` bị gitignore, và `poc.py` từ chối `*.auto.tfvars*`, nên cần cập nhật script khi đổi cách khai báo.
- Chuyển state sang remote backend có locking, với key riêng cho `identity/`.
- Dùng credential chỉ có quyền Members cho phạm vi này, và yêu cầu approval cho mọi thay đổi role `admin`.
- Thống nhất tên biến org giữa các phạm vi (`identity/` và `repositories/` dùng `organization`, `access/` dùng `github_org`).
- Nếu org chuyển sang SSO/SCIM (EMU), IdP sẽ quản lý membership; khi đó ngừng `identity/`, không chạy song song.

## Lưu ý

- `admin` trong resource tương đương Organization owner.
- Resource không phân biệt `pending` và `active`; đối chiếu membership/invitations qua API như script.
- `members = {}` chỉ xóa member được quản lý bởi state này. Dùng local state riêng cho PoC; không chạy đồng thời.
- `.env`, tfvars local, state, plan binary, browser profile và ZIP bàn giao không được commit.
