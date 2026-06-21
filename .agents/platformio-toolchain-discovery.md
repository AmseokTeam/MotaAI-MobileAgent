# PlatformIO Toolchain Discovery

Use this workflow before operating on this PlatformIO project or diagnosing missing compilers, frameworks, packages, upload tools, monitor tools, or PlatformIO Core paths.

## Authority Rule

Treat the active VS Code host as authoritative.

- In a local VS Code workspace, use the PlatformIO Core initialized by the local VS Code PlatformIO extension.
- In VS Code Remote SSH, WSL, containers, or any remote VS Code server, use the PlatformIO Core initialized on that active remote host.
- Do not use a standalone, globally installed, or unrelated local PlatformIO installation.
- Do not trust `pio` or `platformio` from `PATH` unless it resolves to the VS Code extension-provisioned PlatformIO Core for the active host.
- Do not mix local VS Code extension paths with remote VS Code server paths.
- Do not call compiler binaries directly unless PlatformIO diagnostics prove it is necessary.

## Confirm the Project Root

Find `platformio.ini` first and use its directory as the project root.

PowerShell:

```powershell
Get-ChildItem -Recurse -Filter platformio.ini -Depth 3
```

Bash:

```bash
find . -maxdepth 3 -name platformio.ini
```

Read `platformio.ini` before selecting environments, frameworks, upload ports, or targets.

## Locate the VS Code PlatformIO Extension

Check the extension directory on the active VS Code host.

Local VS Code:

```text
Windows: ~/.vscode/extensions/platformio.platformio-ide-*
Linux/macOS: ~/.vscode/extensions/platformio.platformio-ide-*
```

VS Code Remote SSH, WSL, or containers:

```text
~/.vscode-server/extensions/platformio.platformio-ide-*
~/.vscode-server-insiders/extensions/platformio.platformio-ide-*
```

If the extension is missing on the active host, report that the VS Code PlatformIO extension is not installed for that host. Do not fall back to a standalone PlatformIO installation.

## Locate the Extension-Provisioned PlatformIO Core

The VS Code PlatformIO extension initializes PlatformIO Core under the active user's `.platformio/penv` directory on the same host as the extension.

Windows:

```powershell
$env:USERPROFILE\.platformio\penv\Scripts\pio.exe
$env:USERPROFILE\.platformio\penv\Scripts\platformio.exe
```

Linux, macOS, SSH, WSL, or containers:

```bash
~/.platformio/penv/bin/pio
~/.platformio/penv/bin/platformio
```

Use these exact binaries for PlatformIO commands. Prefer `pio` when both `pio` and `platformio` exist.

If `PATH` contains `pio` or `platformio`, verify that it points to the same `.platformio/penv` location before using it.

PowerShell:

```powershell
Get-Command pio -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
Get-Command platformio -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
```

Bash:

```bash
command -v pio
command -v platformio
```

If `.platformio/penv` is missing while the VS Code extension exists, report that the extension is installed but PlatformIO Core has not been initialized for the active host.

## Locate Packages, Platforms, and Toolchains

PlatformIO normally stores resolved packages under the active user's `.platformio` directory on the same host.

```text
~/.platformio/packages
~/.platformio/platforms
```

Prefer PlatformIO diagnostics over manual path assumptions:

```bash
<pio> system info
<pio> pkg list
<pio> run -t envdump
```

Replace `<pio>` with the exact extension-provisioned `pio` executable path when `pio` from `PATH` has not been verified.

## Standard Operations

Run commands from the project root unless there is a clear reason not to.

Build all default environments:

```bash
<pio> run
```

Build one environment:

```bash
<pio> run -e <env>
```

Common targets:

```bash
<pio> run -t clean
<pio> run -t upload
<pio> device monitor
<pio> test
```

Read the `[env:*]` sections in `platformio.ini` before choosing `<env>`.

## Failure Handling

When PlatformIO cannot be found:

1. Confirm `platformio.ini` exists and identify the project root.
2. Check whether the VS Code PlatformIO extension is installed on the active VS Code host.
3. Check the active host's `.platformio/penv` path.
4. If `pio` or `platformio` is on `PATH`, verify that it points to the same `.platformio/penv` path before using it.
5. Report the exact missing layer: project file, VS Code extension, extension-initialized Core virtual environment, package, platform, or toolchain.
6. Do not install, upgrade, remove, or use standalone/global PlatformIO tooling unless the user explicitly asks.

When a build fails because of missing packages or frameworks, run PlatformIO diagnostics first and let the extension-provisioned PlatformIO Core resolve dependencies through `<pio> run` before manually editing package directories.

## Output Expectations

When reporting results to the user, include:

- The project root containing `platformio.ini`.
- The exact VS Code extension-provisioned PlatformIO executable used.
- Whether the environment is local VS Code, Remote SSH, WSL, container, or another VS Code server when detectable.
- The command run and the relevant success or failure lines.
- Any next action needed from the user, such as connecting a board or selecting an upload port.
