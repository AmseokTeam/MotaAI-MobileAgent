<p align="center">
  <img src="assets/logo-rounded.png" alt="Mota logo" width="160" />
</p>

<h1 align="center">Mota「DeskAgentBot」</h1>

<p align="center">
  <a href="https://github.com/IwakuraRin/Mota.DeskAgentBot">
    <img src="https://img.shields.io/badge/version-1.0.0%2B1-orange?style=flat-square" alt="Version 1.0.0+1" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="GPL-3.0 license" />
  </a>
  <a href="https://github.com/IwakuraRin/Mota.DeskAgentBot/stargazers">
    <img src="https://img.shields.io/github/stars/IwakuraRin/Mota.DeskAgentBot?style=flat-square&logo=github" alt="GitHub stars" />
  </a>
</p>

<p align="center">
  A desktop companion robot app with agent-ready control, connection, and interaction flows.
</p>

---

## Project Structure

```text
Mota
├── LICENSE
├── README.md
├── MobileApplication
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   ├── README.md
│   ├── android/
│   ├── assets/
│   │   ├── animations/
│   │   ├── icons/
│   │   └── images/
│   ├── ios/
│   └── lib/
│       ├── main.dart
│       └── app/
│           ├── app.dart
│           ├── core/
│           │   ├── BT_HardwareDrive/
│           │   │   ├── bluetooth_device_info.dart
│           │   │   └── bluetooth_discovery_service.dart
│           │   ├── network/
│           │   └── nfc/
│           ├── features/
│           │   ├── bluetooth/
│           │   │   ├── models/
│           │   │   └── pages/
│           │   ├── bot_control/
│           │   │   ├── models/
│           │   │   └── pages/
│           │   ├── guide/
│           │   │   └── pages/
│           │   ├── robot_face/
│           │   │   ├── models/
│           │   │   ├── pages/
│           │   │   └── widgets/
│           │   └── settings/
│           │       └── pages/
│           ├── router/
│           └── shared/
│               ├── theme/
│               └── widgets/
└── assets/
```

## Mobile Application

The mobile client lives in [`MobileApplication`](MobileApplication) and is built with Flutter.

---

## Star History

仓库的 Star 历史图表：

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&theme=dark&legend=top-left" />
  <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&legend=top-left" />
  <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&legend=top-left" />
</picture>

[查看实时图表](https://www.star-history.com/IwakuraRin/Mota.DeskAgentBot)

