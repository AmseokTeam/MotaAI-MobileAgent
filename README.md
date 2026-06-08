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

<table>
  <tr>
    <td width="58%">
      <img src="assets/github-star-demo.gif" alt="GitHub star demo" width="100%" />
    </td>
    <td width="42%" align="center">
      <strong>如果你对我们的项目感兴趣，欢迎点击 Star。</strong>
    </td>
  </tr>
</table>

---

## Project Structure

```text
Mota
├── LICENSE                         # Project license.
├── README.md                       # Repository overview and structure notes.
├── assets/                         # Repository-level visual assets used by docs and branding.
└── MobileApplication/              # Flutter mobile client.
    ├── analysis_options.yaml       # Dart analyzer and lint configuration.
    ├── pubspec.yaml                # Flutter package metadata, dependencies, and asset entries.
    ├── README.md                   # Mobile app specific notes.
    ├── android/                    # Android platform project for emulator/device builds.
    ├── ios/                        # iOS platform project generated and maintained by Flutter.
    ├── assets/                     # Mobile runtime assets.
    │   ├── animations/             # Animation resources.
    │   ├── icons/                  # App and feature icons.
    │   └── images/                 # Image resources.
    ├── test/                       # Flutter widget and behavior tests.
    └── lib/                        # Dart source code.
        ├── main.dart               # Flutter entry point.
        └── app/
            ├── app.dart            # Root app state: tab routing, robot mood, connection state, settings state.
            ├── core/               # Platform and hardware-facing services.
            │   ├── BT_HardwareDrive/
            │   │   ├── bluetooth_device_info.dart       # Bluetooth device value object.
            │   │   └── bluetooth_discovery_service.dart # Bluetooth discovery boundary and mock scan data.
            │   ├── network/        # Reserved for network/API clients.
            │   └── nfc/            # Reserved for NFC integrations.
            ├── features/           # Feature modules grouped by user workflow.
            │   ├── bluetooth/      # Bluetooth scan and connection UI.
            │   │   ├── models/     # Connection state enum and display text.
            │   │   └── pages/      # Bluetooth page and scan result presentation.
            │   ├── bot_control/    # Movement command experience.
            │   │   ├── models/     # Robot movement command definitions.
            │   │   └── pages/      # Movement control page.
            │   ├── guide/          # Beginner guide content.
            │   │   └── pages/      # Guide page.
            │   ├── robot_face/     # Robot face, mood, and home interaction experience.
            │   │   ├── models/     # Mood enum and mood metadata.
            │   │   ├── pages/      # Home page and immersive robot face page.
            │   │   └── widgets/    # Face canvas, hero card, header, and mood grid.
            │   └── settings/       # Settings and preferences experience.
            │       ├── models/     # Settings state and fixed settings copy.
            │       ├── pages/      # Settings page composition.
            │       └── widgets/    # Settings header, rows, switches, status pill, and connection card.
            ├── router/             # Bottom tab route definitions.
            └── shared/             # Reusable UI primitives and app-wide styling.
                ├── theme/          # Colors and Material theme setup.
                └── widgets/        # Shared cards, titles, bottom bar, and menu components.
                    └── menu/       # Profile/privacy menu models and panels.
```

## Mobile Application

Flutter client: [`MobileApplication`](MobileApplication).

---

## Star History

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&theme=dark&legend=top-left" />
  <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&legend=top-left" />
  <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=IwakuraRin/Mota.DeskAgentBot&type=date&legend=top-left" />
</picture>

[Live chart](https://www.star-history.com/IwakuraRin/Mota.DeskAgentBot)
