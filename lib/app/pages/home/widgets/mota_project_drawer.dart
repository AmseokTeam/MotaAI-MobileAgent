// 文件作用：展示通过 MotaLink Agent 获取的项目文件树、代码内容和 Git diff。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../../core/pc_bridge/pc_bridge_controller.dart';
import '../../../core/pc_bridge/project_bridge_models.dart';
import '../../../shared/theme/app_colors.dart';
import 'project_code_language.dart';

class MotaProjectDrawer extends StatefulWidget {
  const MotaProjectDrawer({
    required this.bridgeController,
    super.key,
  });

  final PcBridgeController bridgeController;

  @override
  State<MotaProjectDrawer> createState() => _MotaProjectDrawerState();
}

class _MotaProjectDrawerState extends State<MotaProjectDrawer>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialProject());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.58,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              elevation: 14,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: widget.bridgeController,
                builder: (context, child) {
                  final controller = widget.bridgeController;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                        child: _ProjectHeader(controller: controller),
                      ),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.ink,
                        unselectedLabelColor: AppColors.muted,
                        indicatorColor: AppColors.orange,
                        indicatorWeight: 3,
                        onTap: (index) {
                          if (index == 1 && controller.projectDiff == null) {
                            controller.readGitDiff();
                          }
                        },
                        tabs: const [
                          Tab(text: '文件'),
                          Tab(text: 'Diff'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _ProjectFilesTab(
                              controller: controller,
                              scrollController: scrollController,
                            ),
                            _ProjectDiffTab(controller: controller),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _loadInitialProject() {
    final controller = widget.bridgeController;
    if (!mounted ||
        !controller.isConnected ||
        controller.projectEntriesByPath.containsKey('.')) {
      return;
    }
    controller.loadProjectRoot();
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.controller});

  final PcBridgeController controller;

  @override
  Widget build(BuildContext context) {
    final statusText = controller.isConnected ? '已连接' : '未连接';
    final statusColor =
        controller.isConnected ? AppColors.lime : AppColors.muted;
    return Row(
      children: [
        const Icon(Icons.account_tree_rounded, color: AppColors.orange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '项目文件',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                controller.settings.cwd.trim().isEmpty
                    ? '未设置工作目录'
                    : controller.settings.cwd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectFilesTab extends StatelessWidget {
  const _ProjectFilesTab({
    required this.controller,
    required this.scrollController,
  });

  final PcBridgeController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (!controller.isConnected) {
      return const _ProjectEmptyState(
        icon: Icons.link_off_rounded,
        title: '请先连接个人电脑 AI Agent',
        message: '连接 MotaLink Agent 后即可浏览当前工作目录',
      );
    }

    final rows = _flattenEntries(controller);
    return Row(
      children: [
        SizedBox(
          width: 156,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.cardSoft,
              border: Border(
                right: BorderSide(
                  color: AppColors.muted.withValues(alpha: 0.14),
                ),
              ),
            ),
            child: _ProjectFileTree(
              controller: controller,
              rows: rows,
              scrollController: scrollController,
            ),
          ),
        ),
        Expanded(
          child: _ProjectFilePreview(controller: controller),
        ),
      ],
    );
  }

  List<_ProjectTreeRow> _flattenEntries(PcBridgeController controller) {
    final rows = <_ProjectTreeRow>[];
    void append(String path, int depth) {
      final entries = controller.projectEntriesByPath[path] ?? const [];
      for (final entry in entries) {
        rows.add(_ProjectTreeRow(entry: entry, depth: depth));
        if (entry.isDirectory &&
            controller.expandedProjectPaths.contains(entry.path)) {
          append(entry.path, depth + 1);
        }
      }
    }

    append('.', 0);
    return rows;
  }
}

class _ProjectFileTree extends StatelessWidget {
  const _ProjectFileTree({
    required this.controller,
    required this.rows,
    required this.scrollController,
  });

  final PcBridgeController controller;
  final List<_ProjectTreeRow> rows;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (controller.loadingProjectPaths.contains('.') && rows.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.orange,
        ),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.loadProjectRoot,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('加载项目'),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return _ProjectTreeTile(
          row: row,
          selected: controller.selectedProjectFile?.path == row.entry.path,
          expanded: controller.expandedProjectPaths.contains(row.entry.path),
          loading: controller.loadingProjectPaths.contains(row.entry.path),
          onTap: () => controller.readProjectFile(row.entry),
        );
      },
    );
  }
}

class _ProjectTreeTile extends StatelessWidget {
  const _ProjectTreeTile({
    required this.row,
    required this.selected,
    required this.expanded,
    required this.loading,
    required this.onTap,
  });

  final _ProjectTreeRow row;
  final bool selected;
  final bool expanded;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final entry = row.entry;
    final icon = entry.isDirectory
        ? expanded
            ? Icons.folder_open_rounded
            : Icons.folder_rounded
        : Icons.description_rounded;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: EdgeInsets.only(
          left: 10 + row.depth * 12,
          right: 8,
        ),
        color: selected ? AppColors.orange.withValues(alpha: 0.12) : null,
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                icon,
                color: entry.isDirectory ? AppColors.orange : AppColors.muted,
                size: 18,
              ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.ink : AppColors.ink,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectFilePreview extends StatelessWidget {
  const _ProjectFilePreview({required this.controller});

  final PcBridgeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.readingProjectFile) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.orange,
        ),
      );
    }

    final errorText = controller.projectErrorText;
    if (errorText != null) {
      return _ProjectEmptyState(
        icon: Icons.error_outline_rounded,
        title: '读取失败',
        message: errorText,
      );
    }

    final file = controller.selectedProjectFile;
    if (file == null) {
      return const _ProjectEmptyState(
        icon: Icons.code_rounded,
        title: '选择一个文件',
        message: '左侧文件树会显示当前工作目录内的文本文件',
      );
    }

    return _ProjectCodeViewer(file: file);
  }
}

class _ProjectCodeViewer extends StatefulWidget {
  const _ProjectCodeViewer({required this.file});

  final ProjectFileContent file;

  @override
  State<_ProjectCodeViewer> createState() => _ProjectCodeViewerState();
}

class _ProjectCodeViewerState extends State<_ProjectCodeViewer> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = _createController(widget.file);
  }

  @override
  void didUpdateWidget(covariant _ProjectCodeViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path ||
        oldWidget.file.content != widget.file.content ||
        oldWidget.file.language != widget.file.language) {
      _codeController.dispose();
      _codeController = _createController(widget.file);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    return Column(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.muted.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      file.truncated ? '${file.language} · 已截断' : file.language,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '复制代码',
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: file.content),
                ),
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: CodeTheme(
              data: CodeThemeData(styles: githubTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  readOnly: true,
                  wrap: false,
                  minLines: 1,
                  maxLines: null,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  CodeController _createController(ProjectFileContent file) {
    return CodeController(
      text: file.content,
      language: projectCodeModeFor(file.language),
      readOnly: true,
    );
  }
}

class _ProjectDiffTab extends StatelessWidget {
  const _ProjectDiffTab({required this.controller});

  final PcBridgeController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isConnected) {
      return const _ProjectEmptyState(
        icon: Icons.link_off_rounded,
        title: '请先连接个人电脑 AI Agent',
        message: '连接 MotaLink Agent 后即可读取当前 Git 修改',
      );
    }

    if (controller.loadingProjectDiff) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.orange,
        ),
      );
    }

    final errorText = controller.projectErrorText;
    if (errorText != null) {
      return _ProjectEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Diff 读取失败',
        message: errorText,
      );
    }

    final diff = controller.projectDiff;
    if (diff == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: controller.readGitDiff,
          icon: const Icon(Icons.difference_rounded),
          label: const Text('读取 Git Diff'),
        ),
      );
    }

    final files = parseProjectDiff(diff);
    if (files.isEmpty) {
      return const _ProjectEmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: '暂无修改',
        message: '当前工作目录没有 Git diff 内容',
      );
    }

    return _ProjectDiffViewer(files: files);
  }
}

class _ProjectDiffViewer extends StatelessWidget {
  const _ProjectDiffViewer({required this.files});

  final List<ProjectDiffFile> files;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border:
                  Border.all(color: AppColors.muted.withValues(alpha: 0.18)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
                  child: Text(
                    file.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Divider(height: 1),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in file.lines) _ProjectDiffLineView(line),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectDiffLineView extends StatelessWidget {
  const _ProjectDiffLineView(this.line);

  final ProjectDiffLine line;

  @override
  Widget build(BuildContext context) {
    final color = switch (line.type) {
      ProjectDiffLineType.added => const Color(0xFFE9FBEF),
      ProjectDiffLineType.removed => const Color(0xFFFFEBEE),
      ProjectDiffLineType.hunk => const Color(0xFFEFF6FF),
      ProjectDiffLineType.header => AppColors.cardSoft,
      ProjectDiffLineType.context => Colors.white,
    };
    final textColor = switch (line.type) {
      ProjectDiffLineType.added => const Color(0xFF166534),
      ProjectDiffLineType.removed => const Color(0xFF991B1B),
      ProjectDiffLineType.hunk => const Color(0xFF1D4ED8),
      ProjectDiffLineType.header => AppColors.muted,
      ProjectDiffLineType.context => AppColors.ink,
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 520),
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Text(
        line.text.isEmpty ? ' ' : line.text,
        softWrap: false,
        style: TextStyle(
          color: textColor,
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProjectEmptyState extends StatelessWidget {
  const _ProjectEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.orange, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTreeRow {
  const _ProjectTreeRow({
    required this.entry,
    required this.depth,
  });

  final ProjectEntry entry;
  final int depth;
}
