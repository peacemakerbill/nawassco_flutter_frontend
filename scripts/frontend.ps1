# powershell-setup.ps1
New-Item -ItemType Directory -Force -Path "lib/core/constants"
New-Item -ItemType Directory -Force -Path "lib/core/services"
New-Item -ItemType Directory -Force -Path "lib/core/utils"
New-Item -ItemType Directory -Force -Path "lib/features/auth/presentation"
New-Item -ItemType Directory -Force -Path "lib/features/auth/providers"
New-Item -ItemType Directory -Force -Path "lib/features/profile/presentation"
New-Item -ItemType Directory -Force -Path "lib/features/profile/providers"
New-Item -ItemType Directory -Force -Path "lib/features/admin/presentation"
New-Item -ItemType Directory -Force -Path "lib/features/admin/providers"
New-Item -ItemType Directory -Force -Path "lib/shared/widgets"
New-Item -ItemType Directory -Force -Path "lib/shared/theme"
New-Item -ItemType Directory -Force -Path "assets"

$files = @(
    "lib/core/constants/app_constants.dart",
    "lib/core/services/api_service.dart",
    "lib/core/services/storage_service.dart",
    "lib/core/utils/helpers.dart",
    "lib/features/auth/presentation/login_screen.dart",
    "lib/features/auth/presentation/register_screen.dart",
    "lib/features/auth/presentation/verify_email_screen.dart",
    "lib/features/auth/presentation/forgot_password_screen.dart",
    "lib/features/auth/presentation/reset_password_screen.dart",
    "lib/features/auth/providers/auth_provider.dart",
    "lib/features/profile/presentation/profile_screen.dart",
    "lib/features/profile/presentation/edit_profile_screen.dart",
    "lib/features/profile/providers/profile_provider.dart",
    "lib/features/admin/presentation/admin_dashboard.dart",
    "lib/features/admin/presentation/user_list_screen.dart",
    "lib/features/admin/presentation/user_form_screen.dart",
    "lib/features/admin/presentation/user_detail_screen.dart",
    "lib/features/admin/providers/admin_provider.dart",
    "lib/shared/widgets/custom_button.dart",
    "lib/shared/widgets/custom_textfield.dart",
    "lib/shared/widgets/profile_completion_bar.dart",
    "lib/shared/widgets/loading_widget.dart",
    "lib/shared/theme/app_theme.dart",
    "lib/main.dart",
    "lib/app.dart",
    "pubspec.yaml",
    "README.md"
)

foreach ($file in $files) {
    New-Item -ItemType File -Path $file -Force
}