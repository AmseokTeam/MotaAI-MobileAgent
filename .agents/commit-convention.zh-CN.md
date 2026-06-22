# 提交信息约定

> 非生效译文：本文件只是 `.agents/commit-convention.md` 的同目录中文翻译。
> 代理应以原始 `.agents/commit-convention.md` 为准，本译文不作为规则来源。

未来的 Git 提交信息使用不带 scope 的 Conventional Commits。

格式：

```text
<type>: <description>
```

示例：

```text
chore: initialize ESP32-S3 ESP-IDF PlatformIO project
feat: add BLE remote command parser
fix: handle I2C timeout recovery
docs: document motor control wiring notes
```

优先使用这些类型：

- `feat`：用户可见功能或新的项目能力
- `fix`：缺陷修复或行为修正
- `chore`：项目搭建、工具、维护或非功能性工作
- `docs`：仅文档变更
- `refactor`：不改变行为的代码结构调整
- `test`：仅测试变更

除非仓库约定发生变化，否则不要在括号中添加 scope。
