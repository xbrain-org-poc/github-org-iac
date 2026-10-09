# Bằng chứng mở rộng repository-demo

Terraform plan dự kiến thêm 3 resource, cập nhật topics trên repo hiện hữu và không xóa resource: [plan.txt](plan.txt). Lệnh apply hoàn tất với kết quả `3 added, 1 changed, 0 destroyed`.

Đối chiếu sau apply qua GitHub API:

- [Repository và topics](repository.json): `github-iac`, `poc`, `terraform`.
- [Actions permissions](actions-permissions.json) và [selected actions](selected-actions.json): Actions bật; cho phép Actions/workflow nội bộ organization và GitHub-owned actions, không chọn verified third-party actions hoặc pattern bổ sung.
- [Environment](environments.json): có `dev`, chưa cấu hình protection rules.
- [Variable của `dev`](dev-variables.json): `POC_ENVIRONMENT=dev`, không phải secret.
- [Plan sau apply](post-apply-plan.txt): `No changes` (exit code 0).

Các file JSON là phản hồi API đã lọc để không chứa token. Chưa chạy workflow hoặc deployment thực tế.
