# 2fa-bat

极简拖放式 Windows TOTP 验证码工具，单个 `.bat` 文件，无需安装。

## 功能

- 生成标准 6 位 TOTP 验证码（RFC 6238）
- 自动复制到剪贴板
- 窗口标题栏显示剩余有效时间
- 持续运行，关闭窗口即停止

## 使用方法

1. 将 Base32 密钥保存到文本文件（每个文件一个密钥，扩展名不限）
2. 把密钥文件拖放到 `totp.bat` 上
3. 验证码会显示在控制台并自动复制到剪贴板

## 如何获取密钥

启用两步验证时，在二维码附近找到手动输入选项：

- **GitHub**：Settings → Password and authentication → 在二维码下方点击 **"setup key"**
- **GitLab**：Edit profile → Account → Register authenticator → 密钥显示在二维码旁边

复制 Base32 密钥（A-Z 和 2-7 组成的字符串），保存到文本文件，例如 `github-junanchn.txt`。

## 系统要求

- Windows 10 或更高版本
- PowerShell 5.1+（Windows 自带）

## 工作原理

`totp.bat` 是一个混合文件：上半部分是批处理脚本，下半部分是 PowerShell 代码。运行时，批处理部分用 `more` 命令从自身提取 PowerShell 代码到临时文件，执行后自动删除。

PowerShell 代码从零实现 TOTP：Base32 解码 → HMAC-SHA1 → 动态截断 → 6 位验证码。
