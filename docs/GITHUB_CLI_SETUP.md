# GitHub CLI (gh) 安装与配置指南

为了实现完全自动化的发布流程，推荐安装 GitHub CLI 工具。

## 1. 安装

在您的电脑上，打开终端（PowerShell 或 CMD）并运行以下命令：

```powershell
winget install GitHub.cli
```

*注意：安装完成后，您可能需要**重启终端**（或重启电脑）以使命令生效。*

## 2. 登录配置

安装完成后，运行以下命令进行登录：

```bash
gh auth login
```

按照提示操作：
1.  **Account**: 选择 `GitHub.com`
2.  **Protocol**: 选择 `HTTPS`
3.  **Authenticate**: 选择 `Login with a web browser`
4.  复制显示的验证码 (ONE-TIME CODE)
5.  按回车打开浏览器，粘贴验证码并授权

## 3. 验证

运行以下命令检查是否成功：

```bash
gh auth status
```

如果显示 "Logged in to github.com as [您的用户名]"，说明配置成功。

---

## 自动化效果

配置完成后，再次运行发布脚本：

```powershell
.\.agent\skills\publish_skill\scripts\publish.bat 1.0.6
```

脚本将自动检测到 `gh` 工具，并自动完成：
- 创建 GitHub Release
- 设置版本号 (Tag)
- 上传 ZIP 文件
- 填写发布说明

全程无需人工干预！
