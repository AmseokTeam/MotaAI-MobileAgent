# MotaAI Flutter 文件结构说明

## 入口层

- `lib/main.dart`
  - Flutter 启动入口，只负责启动 `MiloAiApp`。
- `lib/app/app.dart`
  - 应用根组件，集中管理当前页面、机器人表情、蓝牙状态、菜单开关、全屏机器人开关。
- `lib/app/router/app_router.dart`
  - 底部导航 Tab 定义，包括图标和文案。

## 主题与通用组件

- `lib/app/shared/theme/app_colors.dart`
  - 全局颜色，页面、按钮、机器人屏幕颜色都从这里取。
- `lib/app/shared/theme/app_theme.dart`
  - Flutter 全局主题。
- `lib/app/shared/widgets/floating_bottom_bar.dart`
  - 底部悬浮导航栏和点击震动反馈。
- `lib/app/shared/widgets/page_title.dart`
  - 页面标题组件。
- `lib/app/shared/widgets/soft_cards.dart`
  - 首页/设置/活动卡片等柔和卡片组件。

## 菜单模块

- `lib/app/shared/widgets/app_menu_overlay.dart`
  - 菜单模块导出入口，兼容旧 import。
- `lib/app/shared/widgets/menu/app_menu_button.dart`
  - 右上角三条杠菜单按钮。
- `lib/app/shared/widgets/menu/app_menu_overlay.dart`
  - 菜单弹层、遮罩和过渡动画。
- `lib/app/shared/widgets/menu/app_menu_models.dart`
  - 菜单分段状态、个人主页头像/昵称状态模型。
- `lib/app/shared/widgets/menu/profile_menu_panel.dart`
  - 个人主页面板，负责昵称、头像预览、表情头像、相册头像选择。
- `lib/app/shared/widgets/menu/privacy_menu_panel.dart`
  - 隐私政策面板。

## 首页与机器人屏幕

- `lib/app/pages/home/home_page.dart`
  - 首页页面编排，组合机器人预览、聊天记录和输入框。
- `lib/app/pages/home/widgets/robot_face_canvas.dart`
  - 机器人脸部和首页机器人预览的绘制逻辑。
- `lib/app/pages/home/models/companion_bot_mood.dart`
  - 机器人表情枚举、表情颜色、标题文案。

## PC 连接与 AI 对话

- `lib/app/core/pc_bridge/`
  - MotaLink Agent WebSocket 协议、连接控制、项目文件和 Git diff 能力。
- `lib/app/core/llm/`
  - 自定义大模型配置存储和 Chat Completions 请求。
- `lib/app/pages/home/controllers/mota_chat_controller.dart`
  - 管理 Mota 文本对话发送状态和回复流。

## 控制与设置

- `lib/app/pages/creative_workshop/creative_workshop_page.dart`
  - 创意工坊页面。
- `lib/app/pages/set/set_page.dart`
  - Settings 页面。

## 平台目录

- `android/`
  - Android 平台工程壳，模拟器和真机运行用。
- `ios/`
  - iOS 平台工程壳，后续需要 macOS + Xcode 才能真机构建。
- `test/widget_test.dart`
  - Flutter 基础启动测试。
