# Commit Message Convention

Use Conventional Commits without a scope for future Git commit messages.

Format:

```text
<type>: <description>
```

Examples:

```text
chore: initialize ESP32-S3 ESP-IDF PlatformIO project
feat: add BLE remote command parser
fix: handle I2C timeout recovery
docs: document motor control wiring notes
```

Prefer these types:

- `feat`: user-visible feature or new project capability
- `fix`: bug fix or behavioral correction
- `chore`: project setup, tooling, maintenance, or non-feature work
- `docs`: documentation-only change
- `refactor`: code structure change without behavior change
- `test`: test-only change

Do not add a scope in parentheses unless the repository convention changes.
