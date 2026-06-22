# PlatformIO 工具链发现

> 非生效译文：本文件只是 `.agents/platformio-toolchain-discovery.md` 的同目录中文翻译。
> 代理应以原始 `.agents/platformio-toolchain-discovery.md` 为准，本译文不作为规则来源。

在操作这个 PlatformIO 项目，或诊断缺失的编译器、框架、包、上传工具、监视工具、PlatformIO Core 路径之前，使用此流程。

## 权威规则

将当前活动的 VS Code 主机视为权威来源。

- 在本地 VS Code 工作区中，使用本地 VS Code PlatformIO 扩展初始化的 PlatformIO Core。
- 在 VS Code Remote SSH、WSL、容器或任何远程 VS Code Server 中，使用该活动远程主机上初始化的 PlatformIO Core。
- 不要使用独立安装、全局安装或无关的本地 PlatformIO。
- 不要信任 `PATH` 中的 `pio` 或 `platformio`，除非它解析到当前主机的 VS Code 扩展提供的 PlatformIO Core。
- 不要混用本地 VS Code 扩展路径和远程 VS Code Server 路径。
- 除非 PlatformIO 诊断证明必要，否则不要直接调用编译器二进制文件。

## 确认项目根目录

先找到 `platformio.ini`，并使用它所在目录作为项目根目录。

PowerShell：

```powershell
Get-ChildItem -Recurse -Filter platformio.ini -Depth 3
```

Bash：

```bash
find . -maxdepth 3 -name platformio.ini
```

选择环境、框架、上传端口或目标前，先读取 `platformio.ini`。

## 定位 VS Code PlatformIO 扩展

在当前活动的 VS Code 主机上检查扩展目录。

本地 VS Code：

```text
Windows: ~/.vscode/extensions/platformio.platformio-ide-*
Linux/macOS: ~/.vscode/extensions/platformio.platformio-ide-*
```

VS Code Remote SSH、WSL 或容器：

```text
~/.vscode-server/extensions/platformio.platformio-ide-*
~/.vscode-server-insiders/extensions/platformio.platformio-ide-*
```

如果活动主机上缺少该扩展，报告 VS Code PlatformIO 扩展未在该主机安装。不要回退到独立 PlatformIO 安装。

## 定位扩展提供的 PlatformIO Core

VS Code PlatformIO 扩展会在与扩展相同主机的当前用户 `.platformio/penv` 目录下初始化 PlatformIO Core。

Windows：

```powershell
$env:USERPROFILE\.platformio\penv\Scripts\pio.exe
$env:USERPROFILE\.platformio\penv\Scripts\platformio.exe
```

Linux、macOS、SSH、WSL 或容器：

```bash
~/.platformio/penv/bin/pio
~/.platformio/penv/bin/platformio
```

PlatformIO 命令必须使用这些精确的二进制路径。两者都存在时优先使用 `pio`。

如果 `PATH` 中包含 `pio` 或 `platformio`，使用前先确认它指向相同的 `.platformio/penv` 位置。

PowerShell：

```powershell
Get-Command pio -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
Get-Command platformio -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
```

Bash：

```bash
command -v pio
command -v platformio
```

如果 VS Code 扩展存在，但 `.platformio/penv` 缺失，报告扩展已安装但 PlatformIO Core 尚未在活动主机上初始化。

## 定位包、平台和工具链

PlatformIO 通常将已解析的包存放在同一活动主机当前用户的 `.platformio` 目录下。

```text
~/.platformio/packages
~/.platformio/platforms
```

优先使用 PlatformIO 诊断，而不是手动假设路径：

```bash
<pio> system info
<pio> pkg list
<pio> run -t envdump
```

当 `PATH` 中的 `pio` 尚未验证时，将 `<pio>` 替换为扩展提供的精确 `pio` 可执行文件路径。

## 标准操作

除非有明确原因，否则从项目根目录运行命令。

构建所有默认环境：

```bash
<pio> run
```

构建单个环境：

```bash
<pio> run -e <env>
```

常用目标：

```bash
<pio> run -t clean
<pio> run -t upload
<pio> device monitor
<pio> test
```

选择 `<env>` 前，先读取 `platformio.ini` 中的 `[env:*]` 段落。

## 失败处理

找不到 PlatformIO 时：

1. 确认 `platformio.ini` 存在，并识别项目根目录。
2. 检查 VS Code PlatformIO 扩展是否安装在活动 VS Code 主机上。
3. 检查活动主机的 `.platformio/penv` 路径。
4. 如果 `PATH` 中有 `pio` 或 `platformio`，先确认它指向相同的 `.platformio/penv` 路径。
5. 报告确切缺失层级：项目文件、VS Code 扩展、扩展初始化的 Core 虚拟环境、包、平台或工具链。
6. 除非用户明确要求，否则不要安装、升级、移除或使用独立/全局 PlatformIO 工具。

当构建因缺少包或框架失败时，先运行 PlatformIO 诊断，并让扩展提供的 PlatformIO Core 通过 `<pio> run` 解析依赖，再考虑手动编辑包目录。

## 输出要求

向用户报告结果时，包括：

- 包含 `platformio.ini` 的项目根目录。
- 使用的 VS Code 扩展提供的 PlatformIO 可执行文件的精确路径。
- 环境是否为本地 VS Code、Remote SSH、WSL、容器或其它可检测的 VS Code Server。
- 运行的命令，以及相关成功或失败行。
- 需要用户执行的下一步，例如连接开发板或选择上传端口。
