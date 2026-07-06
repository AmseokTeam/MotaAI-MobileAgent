# Project Structure

```text
Mota
├── LICENSE                         # Project license.
├── README.md                       # Repository overview and structure notes.
├── analysis_options.yaml           # Dart analyzer and lint configuration.
├── pubspec.yaml                    # Flutter package metadata, dependencies, and asset entries.
├── android/                        # Android platform project for emulator/device builds.
├── ios/                            # iOS platform project generated and maintained by Flutter.
├── assets/                         # Documentation and mobile runtime assets.
│   ├── asr_models/                 # Local ASR model placeholder and downloaded payload location.
│   ├── fonts/                      # App font files.
│   ├── icons/                      # App icon assets.
│   └── quick-preview/              # README preview media.
├── docs/                           # Project documentation.
├── test/                           # Flutter widget and behavior tests.
└── lib/                            # Dart source code.
    ├── main.dart                   # Flutter entry point.
    └── app/
        ├── app.dart                # Root app state and tab routing host.
        ├── core/                   # Platform, storage, LLM, ASR, and PC bridge services.
        ├── pages/                  # Feature pages grouped by current user workflow.
        ├── router/                 # Bottom tab route definitions.
        └── shared/                 # Reusable UI primitives and app-wide styling.
```
