import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../services/pack_manager.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import 'game_screen.dart';
import 'pack_creator_screen.dart';

class PackSelectScreen extends StatefulWidget {
  final int timeSeconds;
  final PackManager? manager;
  final Future<String?> Function()? pickPath;
  const PackSelectScreen(
      {super.key, required this.timeSeconds, this.manager, this.pickPath});
  @override
  State<PackSelectScreen> createState() => _PackSelectScreenState();
}

class _PackSelectScreenState extends State<PackSelectScreen> {
  bool _isLoading = true;
  String? _importMessage;
  bool _importSuccess = false;
  PackManager get _manager => widget.manager ?? PackManager();
  bool _busy = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    if (!mounted || _busy) return;
    _busy = true;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      await _manager.loadAllPacks();
      if (mounted) setState(() => _importMessage = null);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
          _importSuccess = false;
          _importMessage = 'Не удалось загрузить паки. Попробуйте ещё раз.';
        });
      }
    } finally {
      _busy = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _pickPath() async {
    if (widget.pickPath != null) return widget.pickPath!();
    final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['hmq'],
        allowMultiple: false);
    return result == null || result.files.isEmpty
        ? null
        : result.files.single.path;
  }

  Future<void> _importPack() async {
    if (_busy) return;
    _busy = true;
    setState(() => _isLoading = true);
    try {
      final path = await _pickPath();
      if (!mounted || path == null) return;
      final validation = await _manager.importPack(path);
      if (!mounted) return;
      setState(() {
        _importSuccess = validation.isValid;
        _importMessage = validation.isValid
            ? 'Пак "${validation.pack!.name}" успешно загружен!'
            : validation.errorMessage;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _importSuccess = false;
          _importMessage = 'Не удалось импортировать пак. Попробуйте ещё раз.';
        });
      }
    } finally {
      _busy = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createPack() async {
    if (_busy) return;
    setState(() => _busy = true);
    final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const PackCreatorScreen()));
    _busy = false;
    if (!mounted) return;
    setState(() {});
    if (saved != true) return;
    await _loadPacks();
    if (mounted && !_loadFailed) {
      setState(() {
        _importSuccess = true;
        _importMessage = 'Пак успешно сохранён!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final packs = _manager.packs;
    return StudioTheme(
        child: Scaffold(
      backgroundColor: GameplayTheme.background,
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 992),
        child: CustomScrollView(slivers: [
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              sliver: SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    StudioHeader(
                        title: 'ВЫБЕРИТЕ ПАК',
                        onBack: () => Navigator.pop(context)),
                    Text('Время на ответ: ${_formatTime(widget.timeSeconds)}',
                        style: const TextStyle(
                            fontSize: 16, color: GameplayTheme.secondary)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      OutlinedButton.icon(
                          onPressed: _busy ? null : _createPack,
                          icon: const Icon(Icons.add),
                          label: const Text('СОЗДАТЬ ПАК')),
                      OutlinedButton.icon(
                          onPressed: _busy ? null : _importPack,
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('ЗАГРУЗИТЬ ПАК')),
                    ]),
                    if (_importMessage != null) ...[
                      const SizedBox(height: 12),
                      StudioSurface(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Icon(
                                _importSuccess
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color: _importSuccess
                                    ? GameplayTheme.easy
                                    : GameplayTheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Semantics(
                                    liveRegion: true,
                                    child: Text(_importMessage!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.4,
                                            color: GameplayTheme.text)))),
                          ])),
                    ],
                    if (_loadFailed)
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: _isLoading ? null : _loadPacks,
                              child: const Text('Повторить'))),
                  ]))),
          if (_isLoading)
            const SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator())))
          else if (packs.isEmpty && !_loadFailed)
            const SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет доступных паков',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: GameplayTheme.secondary))))
          else
            SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.builder(
                    itemCount: packs.length,
                    itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PackCard(
                              pack: packs[index],
                              onTap: _busy
                                  ? null
                                  : () {
                                      if (_busy) return;
                                      PackManager().selectPack(packs[index]);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => GameScreen(
                                                  timeSeconds:
                                                      widget.timeSeconds)));
                                    }),
                        ))),
        ]),
      ))),
    ));
  }

  String _formatTime(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.onTap});
  final QuestionPack pack;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: GameplayTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GameplayTheme.outline)),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
            button: true,
            enabled: onTap != null,
            child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.quiz_outlined,
                                color: GameplayTheme.primary)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(pack.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: GameplayTheme.text)),
                              const SizedBox(height: 4),
                              Text(pack.description ?? 'Нет описания',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: GameplayTheme.secondary)),
                              const SizedBox(height: 8),
                              Text(
                                  'Лёгкие ${pack.easyQuestions.length} · Средние ${pack.mediumQuestions.length} · Сложные ${pack.hardQuestions.length}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: GameplayTheme.secondary)),
                            ])),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: GameplayTheme.secondary),
                      ]),
                ))),
      );
}
