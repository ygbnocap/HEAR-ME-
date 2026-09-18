// lib/screens/pack_select_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../services/pack_manager.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'game_screen.dart';
import 'pack_creator_screen.dart';

class PackSelectScreen extends StatefulWidget {
  final int timeSeconds;

  const PackSelectScreen({super.key, required this.timeSeconds});

  @override
  State<PackSelectScreen> createState() => _PackSelectScreenState();
}

class _PackSelectScreenState extends State<PackSelectScreen> {
  bool _isLoading = true;
  String? _importMessage;
  bool _importSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    await PackManager().loadAllPacks();
    setState(() => _isLoading = false);
  }

  Future<void> _importPack() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hmq'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.single.path == null) return;

    setState(() => _isLoading = true);

    final validation = await PackManager().importPack(result.files.single.path!);

    setState(() {
      _isLoading = false;
      _importSuccess = validation.isValid;
      _importMessage = validation.isValid
          ? 'Пак "${validation.pack!.name}" успешно загружен!'
          : validation.errorMessage;
    });

    if (validation.isValid) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _importMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packs = PackManager().packs;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getWidth(context, 0.04),
              vertical: Responsive.getHeight(context, 0.015),
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.muted, AppColors.highlight],
                  ).createShader(bounds),
                  child: Text(
                    'ВЫБЕРИТЕ ПАК',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 28),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.008)),
                Text(
                  'Время на ответ: ${_formatTime(widget.timeSeconds)}',
                  style: TextStyle(
                    color: AppColors.muted.withOpacity(0.6),
                    fontSize: Responsive.getFontSize(context, 14),
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.015)),
                Container(
                  width: Responsive.getWidth(context, 0.12),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.highlight],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.02)),
                if (_importMessage != null) _buildImportMessage(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                      : packs.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    itemCount: packs.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return _PackCard(
                        pack: packs[index],
                        onTap: () {
                          PackManager().selectPack(packs[index]);
                          _showGameStart(context, packs[index]);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.015)),
                Row(
                  children: [
                    Expanded(
                      child: _PackCreatorButton(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => const PackCreatorScreen(),
                            ),
                          )
                              .then((_) {
                            _loadPacks();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: Responsive.getWidth(context, 0.02)),
                    Expanded(
                      child: _ImportButton(onTap: _importPack),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.getHeight(context, 0.01)),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.muted, size: 18),
                  label: Text(
                    'НАЗАД',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: Responsive.getFontSize(context, 14),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.01)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.getHeight(context, 0.015)),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.04),
        vertical: Responsive.getHeight(context, 0.012),
      ),
      decoration: BoxDecoration(
        color: _importSuccess
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.highlight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _importSuccess
              ? AppColors.accent.withOpacity(0.4)
              : AppColors.highlight.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _importSuccess ? Icons.check_circle : Icons.error,
            color: _importSuccess ? AppColors.accent : AppColors.highlight,
            size: 20,
          ),
          SizedBox(width: Responsive.getWidth(context, 0.02)),
          Text(
            _importMessage!,
            style: TextStyle(
              color: _importSuccess ? AppColors.accent : AppColors.highlight,
              fontSize: Responsive.getFontSize(context, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: Responsive.getFontSize(context, 60),
            color: AppColors.muted.withOpacity(0.3),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.02)),
          Text(
            'Нет доступных паков',
            style: TextStyle(
              color: AppColors.muted.withOpacity(0.5),
              fontSize: Responsive.getFontSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showGameStart(BuildContext context, QuestionPack pack) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(timeSeconds: widget.timeSeconds),
      ),
    );
  }
}

class _PackCard extends StatefulWidget {
  final QuestionPack pack;
  final VoidCallback onTap;

  const _PackCard({
    required this.pack,
    required this.onTap,
  });

  @override
  State<_PackCard> createState() => _PackCardState();
}

class _PackCardState extends State<_PackCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.getHeight(context, 0.012)),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(Responsive.getWidth(context, 0.02)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)]
                    : AppColors.cardGradient,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.primary.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.getWidth(context, 0.07),
                  height: Responsive.getWidth(context, 0.07),
                  constraints: const BoxConstraints(minWidth: 45, maxWidth: 55),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: Responsive.getWidth(context, 0.02)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pack.name,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.004)),
                      Text(
                        widget.pack.description ?? 'Нет описания',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 12),
                          color: AppColors.muted.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.006)),
                      Row(
                        children: [
                          _difficultyBadge(widget.pack.easyQuestions.length, AppColors.accent),
                          SizedBox(width: Responsive.getWidth(context, 0.008)),
                          _difficultyBadge(widget.pack.mediumQuestions.length, AppColors.secondary),
                          SizedBox(width: Responsive.getWidth(context, 0.008)),
                          _difficultyBadge(widget.pack.hardQuestions.length, AppColors.highlight),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: Responsive.getFontSize(context, 16),
                  color: _isHovered ? AppColors.primary : AppColors.muted.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyBadge(int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.01),
        vertical: Responsive.getHeight(context, 0.003),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: Responsive.getFontSize(context, 11),
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _ImportButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ImportButton({required this.onTap});

  @override
  State<_ImportButton> createState() => _ImportButtonState();
}

class _ImportButtonState extends State<_ImportButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(context, 0.02),
            vertical: Responsive.getHeight(context, 0.012),
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.highlight.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? AppColors.highlight.withOpacity(0.6)
                  : AppColors.highlight.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'ЗАГРУЗИТЬ ПАК',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 13),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: _isHovered ? AppColors.highlight : AppColors.highlight.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PackCreatorButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PackCreatorButton({required this.onTap});

  @override
  State<_PackCreatorButton> createState() => _PackCreatorButtonState();
}

class _PackCreatorButtonState extends State<_PackCreatorButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(context, 0.02),
            vertical: Responsive.getHeight(context, 0.012),
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? AppColors.accent.withOpacity(0.6)
                  : AppColors.accent.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'СОЗДАТЬ ПАК',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 13),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: _isHovered ? AppColors.accent : AppColors.accent.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}