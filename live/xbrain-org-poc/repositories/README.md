# Repository theo nhóm vận hành

Mỗi thư mục con là một Terraform root và state riêng cho nhóm repo có cùng người chịu trách nhiệm, quyền apply và nhịp thay đổi. Không tách state chỉ vì thêm một repo mới.

- [`sandbox/`](sandbox/): hai repo trong PoC hiện tại. Terraform code và evidence được chuyển nguyên vẹn từ root `repositories/`; địa chỉ resource trong state không đổi.

Khi mô phỏng thêm nhóm khác, tạo root riêng từ [blueprint nhóm repo](../../../blueprints/company-org/repositories/group/) sau khi xác định owner và phạm vi repo. Không dùng tên nhóm giả để quản lý repo thật.
