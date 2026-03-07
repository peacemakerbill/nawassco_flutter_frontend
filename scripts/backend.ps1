# powershell-setup.ps1
New-Item -ItemType Directory -Force -Path "src/config"
New-Item -ItemType Directory -Force -Path "src/controllers"
New-Item -ItemType Directory -Force -Path "src/middlewares"
New-Item -ItemType Directory -Force -Path "src/models"
New-Item -ItemType Directory -Force -Path "src/routes"
New-Item -ItemType Directory -Force -Path "src/services"
New-Item -ItemType Directory -Force -Path "src/utils"
New-Item -ItemType Directory -Force -Path "src/views/templates"
New-Item -ItemType Directory -Force -Path "src/types"
New-Item -ItemType Directory -Force -Path "src/validators"

$files = @(
    "src/config/cloudinary.config.ts",
    "src/config/db.config.ts",
    "src/config/env.config.ts",
    "src/config/nodemailer.config.ts",
    "src/controllers/auth.controller.ts",
    "src/controllers/profile.controller.ts",
    "src/controllers/user.controller.ts",
    "src/middlewares/auth.middleware.ts",
    "src/middlewares/error.middleware.ts",
    "src/middlewares/upload.middleware.ts",
    "src/middlewares/validation.middleware.ts",
    "src/models/User.model.ts",
    "src/models/Token.model.ts",
    "src/routes/auth.routes.ts",
    "src/routes/profile.routes.ts",
    "src/routes/user.routes.ts",
    "src/services/auth.service.ts",
    "src/services/email.service.ts",
    "src/services/profile.service.ts",
    "src/services/token.service.ts",
    "src/utils/catchAsync.ts",
    "src/utils/generateToken.ts",
    "src/utils/hashPassword.ts",
    "src/utils/validateEnv.ts",
    "src/views/templates/activate-account.html",
    "src/views/templates/reset-password.html",
    "src/types/express.d.ts",
    "src/validators/auth.validator.ts",
    "src/validators/profile.validator.ts",
    "src/app.ts",
    "src/server.ts",
    ".env.example",
    ".gitignore",
    "package.json",
    "tsconfig.json",
    "README.md"
)

foreach ($file in $files) {
    New-Item -ItemType File -Path $file -Force
    Write-Host "Created: $file"
}

Write-Host "Project structure created successfully!"