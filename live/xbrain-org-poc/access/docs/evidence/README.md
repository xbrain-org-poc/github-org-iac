# Evidence lịch sử – PoC Org Teams

**Ngày chạy:** 01/10/2026 · **Organization:** `xbrain-org-poc` · **Terraform:** 1.16.4 · **Provider:** 6.13.0.

Các file dưới [`2026-10-01/`](2026-10-01/) được sao chép từ bằng chứng local của PoC Team sau khi kiểm tra nội dung và quét credential. Việc bàn giao ngày 09/10/2026 chỉ chuyển file và tài liệu; không chạy Terraform plan/apply mới hoặc thay đổi GitHub resources.

| Luồng | Plan | Apply đã chạy trong PoC | Plan hội tụ |
| --- | --- | --- | --- |
| Update team name/description/notification | [Plan](2026-10-01/update-plan.txt) | [Apply](2026-10-01/update-apply.txt) | [No changes](2026-10-01/update-convergence-plan.txt) |
| Add direct member | [Plan](2026-10-01/member-add-plan.txt) | [Apply](2026-10-01/member-add-apply.txt) | [No changes](2026-10-01/member-add-convergence-plan.txt) |
| Change team role | [Plan](2026-10-01/member-role-plan.txt) | [Apply](2026-10-01/member-role-apply.txt) | [No changes](2026-10-01/member-role-convergence-plan.txt) |
| Remove direct membership | [Plan](2026-10-01/member-remove-plan.txt) | [Apply](2026-10-01/member-remove-apply.txt) | [No changes](2026-10-01/member-remove-convergence-plan.txt) |
| Delete team và cleanup | [Fresh final plan](2026-10-01/delete-final-plan.txt) | [Apply](2026-10-01/delete-final-apply.txt) | [Final no changes](2026-10-01/delete-final-convergence-plan.txt) |

Đối chiếu sau update: [GitHub API summary](2026-10-01/update-api.json) và [các thuộc tính được trích từ state](2026-10-01/update-state-summary.json). File sau chỉ là summary của một team, không phải raw Terraform state để restore/import.

[Outsider blocker](2026-10-01/member-plan-blocker.txt) ghi lookup org member trả `404`, plan dừng khi `phuc776` chưa thuộc organization.

## Giới hạn evidence

- Log create ban đầu và ảnh UI không có trong bộ evidence local còn lưu, nên không bổ sung hoặc tạo lại bằng chứng đó. Kết quả create được ghi trong [báo cáo PoC](../team-poc-results.md) và [bản tóm tắt Jira](../jira-task-b-live-evidence-vi.md).
- API/state observations cho role, remove membership và final cleanup nằm trong bản tóm tắt Jira; không có raw API response tương ứng trong bộ file này.
- Các dòng `terraform apply ...` xuất hiện trong plan text là hướng dẫn Terraform in ra từ lần chạy cũ. Binary saved plan không được commit và không được tái sử dụng.
- Không có token, tfvars local, full state, provider binary hoặc raw debug log trong bộ bàn giao.
- Drift, import, nested team và production rollout chưa có live evidence của Task Team.
