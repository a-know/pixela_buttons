import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/pixela_client.dart';
import '../../core/models/card_config.dart';
import '../../core/storage/card_storage.dart';
import '../../core/theme/app_theme.dart';
import '../main_shell.dart';
import 'record_dialog.dart';

class CardWidget extends StatefulWidget {
  final CardConfig card;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardWidget({
    super.key,
    required this.card,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  CardConfig get card => widget.card;

  String? _todayValue;
  String? _svgData;

  @override
  void initState() {
    super.initState();
    _fetchTodayValue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    _fetchSvg(isDark);
  }

  Future<void> _fetchTodayValue() async {
    try {
      final username = await CardStorage.getUsername() ?? '';
      final value = await pixelaClient.getTodayValue(username, card.graphId);
      if (mounted) setState(() => _todayValue = _formatValue(value ?? 0));
    } catch (_) {
      if (mounted) setState(() => _todayValue = '--');
    }
  }

  Future<void> _fetchSvg(bool isDark) async {
    try {
      final username = await CardStorage.getUsername() ?? '';
      final svg = await pixelaClient.getGraphSvg(username, card.graphId, darkMode: isDark);
      if (mounted) setState(() => _svgData = svg);
    } catch (_) {}
  }

  String _formatValue(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  Color get _addColor {
    try {
      return Color(int.parse(card.color.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.teal;
    }
  }

  Future<void> _record(BuildContext context, double value, {DateTime? date}) async {
    final username = await CardStorage.getUsername() ?? '';
    try {
      final recordedAt = date ?? DateTime.now();
      if (date != null) {
        final yyyyMMdd = DateFormat('yyyyMMdd').format(date);
        if (value >= 0) {
          await pixelaClient.addPixelOnDate(username, card.graphId, yyyyMMdd, value);
        } else {
          await pixelaClient.subtractPixelOnDate(username, card.graphId, yyyyMMdd, value.abs());
        }
      } else {
        if (value >= 0) {
          await pixelaClient.addPixel(username, card.graphId, value);
        } else {
          await pixelaClient.subtractPixel(username, card.graphId, value.abs());
        }
      }
      HapticFeedback.mediumImpact();
      if (context.mounted) await RecordDialog.show(context, card, value, recordedAt, card.timezone, specificDate: date);
      _fetchTodayValue();
      if (context.mounted) {
        final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        _fetchSvg(isDark);
      }
    } catch (e) {
      if (!context.mounted) return;
      if (e is DioException && e.response?.statusCode == 404) {
        await _handleGraphNotFound(context);
      } else {
        final l10n = AppLocalizations.of(context)!;
        final msg = (e is DioException && e.response?.statusCode != null)
            ? l10n.errorGeneric(e.response!.statusCode.toString())
            : l10n.errorUnknown(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Future<void> _handleGraphNotFound(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.errorGraphNotFoundTitle),
        content: Text(l10n.errorGraphNotFoundMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
    if (delete == true) {
      final cards = await CardStorage.loadCards();
      await CardStorage.saveCards(cards.where((c) => c.id != card.id).toList());
      homeTabNotifier.value++;
    }
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var selectedDate = DateTime.now();

    final result = await showDialog<({double value, DateTime date})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.customDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  DateFormat.yMMMd(Localizations.localeOf(ctx).languageCode)
                      .format(selectedDate),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: card.unit,
                  border: const OutlineInputBorder(),
                  helperText: l10n.customDialogHelper,
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text);
                if (v != null) Navigator.of(ctx).pop((value: v, date: selectedDate));
              },
              child: Text(l10n.buttonRecord),
            ),
          ],
        ),
      ),
    );
    if (result != null && context.mounted) {
      await _record(context, result.value, date: result.date);
    }
  }

  Widget _typeBadge(BuildContext context, String type) {
    final (bg, fg) = switch (type) {
      'int'   => (Colors.blue.withAlpha(40), Colors.blue),
      'float' => (Colors.orange.withAlpha(40), Colors.orange.shade800),
      _       => (Colors.grey.withAlpha(40), Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }

  void _openGraph(String username) {
    final url = ApiEndpoints.graphHtml(username, card.graphId);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Size? _parseSvgSize(String svg) {
    final w = RegExp(r'width="([\d.]+)"').firstMatch(svg)?.group(1);
    final h = RegExp(r'height="([\d.]+)"').firstMatch(svg)?.group(1);
    if (w == null || h == null) return null;
    return Size(double.parse(w), double.parse(h));
  }

  Future<void> _showRetinaPreview(BuildContext context) async {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final username = await CardStorage.getUsername() ?? '';
    DateTime now;
    try {
      now = card.timezone != null
          ? tz.TZDateTime.now(tz.getLocation(card.timezone!))
          : DateTime.now();
    } catch (_) {
      now = DateTime.now();
    }
    final yyyyMMdd = DateFormat('yyyyMMdd').format(now);

    Size? svgSize;
    try {
      final svg = await pixelaClient.getGraphSvgRetina(username, card.graphId, yyyyMMdd);
      svgSize = _parseSvgSize(svg);
    } catch (_) {}

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => _RetinaWebViewDialog(
        username: username,
        graphId: card.graphId,
        displayName: card.displayName,
        yyyyMMdd: yyyyMMdd,
        svgSize: svgSize,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addColor = _addColor;
    final subtractColor = AppTheme.darkenColor(addColor);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                if (card.emoji.isNotEmpty)
                  Text(card.emoji,
                      style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FutureBuilder<String?>(
                  future: CardStorage.getUsername(),
                  builder: (ctx, snap) => IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    onPressed: () => _openGraph(snap.data ?? ''),
                    tooltip: AppLocalizations.of(context)!.tooltipOpenGraph,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (v) {
                    if (v == 'edit') widget.onEdit();
                    if (v == 'delete') widget.onDelete();
                  },
                  itemBuilder: (ctx) {
                    final l10n = AppLocalizations.of(ctx)!;
                    return [
                      PopupMenuItem(value: 'edit', child: Text(l10n.menuEdit)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.menuDelete)),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<String?>(
              future: CardStorage.getUsername(),
              builder: (ctx, snap) => GestureDetector(
                onTap: () => _openGraph(snap.data ?? ''),
                onLongPress: () => _showRetinaPreview(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 80,
                    child: _svgData != null
                    ? SvgPicture.string(
                        _svgData!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        placeholderBuilder: (_) => const SizedBox.shrink(),
                      )
                    : const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  if (card.graphType != null) _typeBadge(context, card.graphType!),
                  Text(
                    _todayValue != null
                        ? AppLocalizations.of(context)!.labelUnitToday(card.unit, _todayValue!)
                        : AppLocalizations.of(context)!.labelUnit(card.unit),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...card.buttons.map((btn) {
                    final isAdd = btn.value >= 0;
                    final color = isAdd ? addColor : subtractColor;
                    final numLabel =
                        '${isAdd ? "+" : ""}${btn.value == btn.value.truncateToDouble() ? btn.value.toInt() : btn.value}';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: color.withAlpha(150),
                          side: BorderSide(
                            color: Colors.white.withAlpha(80),
                            width: 1,
                          ),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onPressed: () => _record(context, btn.value),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(numLabel),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, size: 14),
                          ],
                        ),
                      ),
                    );
                  }),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => _showCustomDialog(context),
                    icon: const Icon(Icons.edit, size: 14),
                    label: Text(AppLocalizations.of(context)!.buttonCustom),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetinaWebViewDialog extends StatefulWidget {
  final String username;
  final String graphId;
  final String displayName;
  final String yyyyMMdd;
  final Size? svgSize;
  final bool isDark;

  const _RetinaWebViewDialog({
    required this.username,
    required this.graphId,
    required this.displayName,
    required this.yyyyMMdd,
    this.svgSize,
    this.isDark = false,
  });

  @override
  State<_RetinaWebViewDialog> createState() => _RetinaWebViewDialogState();
}

class _RetinaWebViewDialogState extends State<_RetinaWebViewDialog> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final base = '${ApiEndpoints.baseUrl}/v1/users/${widget.username}/graphs/${widget.graphId}/${widget.yyyyMMdd}/retina';
    final url = widget.isDark ? '$base?appearance=dark' : base;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final maxW = screen.width - 48;
    final maxH = screen.height * 0.7;
    double dialogW = maxW;
    double dialogH = maxH;
    if (widget.svgSize != null) {
      final aspect = widget.svgSize!.width / widget.svgSize!.height;
      dialogH = (dialogW / aspect).clamp(0.0, maxH);
      if (dialogH == maxH) dialogW = (maxH * aspect).clamp(0.0, maxW);
    }

    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.retinaDialogTitle(widget.displayName),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          SizedBox(
            width: dialogW,
            height: dialogH,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
