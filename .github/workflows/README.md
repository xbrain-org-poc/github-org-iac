# GitHub Actions

Chưa bật plan/apply tự động: các PoC dùng local state; blueprint chưa có org đích, backend và người duyệt thật. Khi các thông tin này được chốt, workflow PR chạy fmt, validate và plan theo Terraform root thay đổi; apply dùng credential giới hạn quyền, backend có locking và cổng phê duyệt trên commit đã review. Xem [giải pháp vận hành](../../docs/company-org-solution.md).
