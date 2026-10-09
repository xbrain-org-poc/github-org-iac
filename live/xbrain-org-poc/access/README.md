# Team và quyền truy cập repository

Thư mục này dành cho cấu hình team, team membership và quyền team trên repository. Chưa đưa resource vào đây vì PoC team chưa được bàn giao; không suy đoán team, thành viên hoặc quyền trên org thật.

Khi tích hợp, xác định chủ sở hữu từng phần Terraform state và import resource đã tồn tại trước khi apply. Không để `identity/` và `access/` cùng quản lý một `github_membership`.
