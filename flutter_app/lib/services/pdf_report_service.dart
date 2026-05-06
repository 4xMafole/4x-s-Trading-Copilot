import 'dart:io';
import 'dart:math' as math;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../data/models.dart';

/// Sprint 5.4 — PDF Tear Sheet Export.
///
/// Pure-Dart report generation: filters trades by date range, computes
/// institutional metrics (equity curve, max drawdown, Sharpe-style ratio,
/// profit factor, win rate), draws a sparkline of the equity curve, and
/// hands the file to the OS share sheet.
class PdfReportService {
  const PdfReportService();

  /// Builds a tear sheet covering [start]..[end] inclusive (yyyy-MM-dd
  /// strings). Returns the file path written to the temp directory.
  Future<String> exportTearSheet({
    required AppState state,
    required String startDate,
    required String endDate,
  }) async {
    final filtered =
        state.allTrades.where((t) {
          return t.date.compareTo(startDate) >= 0 &&
              t.date.compareTo(endDate) <= 0;
        }).toList()..sort((a, b) {
          final c = a.date.compareTo(b.date);
          if (c != 0) return c;
          return a.time.compareTo(b.time);
        });

    final stats = _TearStats.compute(filtered, state.balance);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _header(startDate, endDate),
          pw.SizedBox(height: 16),
          _kpiGrid(stats),
          pw.SizedBox(height: 18),
          _equityChart(stats),
          pw.SizedBox(height: 18),
          _tradeTable(filtered),
          pw.SizedBox(height: 14),
          _footer(),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final path = '${dir.path}/4xtrades-tearsheet-$ts.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save(), flush: true);

    await Share.shareXFiles(
      [XFile(path)],
      subject: '4x Trades performance tear sheet',
      text: 'Performance summary $startDate → $endDate',
    );
    return path;
  }

  pw.Widget _header(String start, String end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '4x Trades — Performance Tear Sheet',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '$start  →  $end',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _kpiGrid(_TearStats s) {
    pw.Widget cell(String label, String value, {PdfColor? color}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color ?? PdfColors.black,
              ),
            ),
          ],
        ),
      );
    }

    final pnlColor = s.totalPnl >= 0 ? PdfColors.green800 : PdfColors.red800;
    final ddColor = s.maxDrawdown <= 0 ? PdfColors.red800 : PdfColors.black;
    return pw.GridView(
      crossAxisCount: 3,
      childAspectRatio: 2.4,
      children: [
        cell('Trades', s.totalCount.toString()),
        cell('Win rate', '${(s.winRate * 100).toStringAsFixed(1)}%'),
        cell('Net P/L', '\$${s.totalPnl.toStringAsFixed(2)}', color: pnlColor),
        cell(
          'Profit factor',
          s.profitFactor.isFinite ? s.profitFactor.toStringAsFixed(2) : '∞',
        ),
        cell(
          'Max drawdown',
          '\$${s.maxDrawdown.toStringAsFixed(2)}',
          color: ddColor,
        ),
        cell('Sharpe (per-trade)', s.sharpe.toStringAsFixed(2)),
        cell('Avg win', '\$${s.avgWin.toStringAsFixed(2)}'),
        cell('Avg loss', '\$${s.avgLoss.toStringAsFixed(2)}'),
        cell('Expectancy', '\$${s.expectancy.toStringAsFixed(2)}'),
      ],
    );
  }

  pw.Widget _equityChart(_TearStats s) {
    if (s.equity.length < 2) {
      return pw.Container(
        height: 120,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'Not enough data for equity curve.',
          style: const pw.TextStyle(color: PdfColors.grey600),
        ),
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Equity Curve',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.CustomPaint(
            size: const PdfPoint(double.infinity, 150),
            painter: (canvas, size) =>
                _paintEquity(canvas, size, s.equity, s.totalPnl >= 0),
          ),
        ),
      ],
    );
  }

  void _paintEquity(
    PdfGraphics canvas,
    PdfPoint size,
    List<double> equity,
    bool positive,
  ) {
    if (equity.length < 2) return;
    final w = size.x;
    final h = size.y;
    const pad = 8.0;
    final minV = equity.reduce(math.min);
    final maxV = equity.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);

    double xFor(int i) => pad + (w - 2 * pad) * (i / (equity.length - 1));
    double yFor(double v) => pad + (h - 2 * pad) * (1 - (v - minV) / range);

    // Zero line if the curve crosses zero.
    if (minV < 0 && maxV > 0) {
      final yz = yFor(0);
      canvas
        ..setStrokeColor(PdfColors.grey400)
        ..setLineWidth(0.4)
        ..drawLine(pad, yz, w - pad, yz)
        ..strokePath();
    }

    // Curve.
    canvas
      ..setStrokeColor(positive ? PdfColors.green700 : PdfColors.red700)
      ..setLineWidth(1.1);
    canvas.moveTo(xFor(0), yFor(equity[0]));
    for (var i = 1; i < equity.length; i++) {
      canvas.lineTo(xFor(i), yFor(equity[i]));
    }
    canvas.strokePath();
  }

  pw.Widget _tradeTable(List<Trade> trades) {
    if (trades.isEmpty) {
      return pw.Text(
        'No trades in selected range.',
        style: const pw.TextStyle(color: PdfColors.grey600),
      );
    }
    final rows = <List<String>>[
      ['Date', 'Time', 'Sym', 'Dir', 'Lots', 'P/L', 'Flags'],
      ...trades
          .take(80)
          .map(
            (t) => [
              t.date,
              t.time,
              t.sym,
              t.dir,
              t.lots.toStringAsFixed(2),
              '\$${t.pnl.toStringAsFixed(2)}',
              [
                if (t.violations.isNotEmpty) 'V:${t.violations.length}',
                if (t.isHypothetical) 'paper',
              ].join(' '),
            ],
          ),
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          trades.length > 80
              ? 'Trade Log (first 80 of ${trades.length})'
              : 'Trade Log (${trades.length})',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          data: rows,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
        ),
      ],
    );
  }

  pw.Widget _footer() {
    final ts = DateTime.now().toIso8601String().split('.').first;
    return pw.Text(
      'Generated $ts by 4x Trades. Numbers reflect logged trades only.',
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
    );
  }
}

class _TearStats {
  _TearStats({
    required this.totalCount,
    required this.winRate,
    required this.totalPnl,
    required this.profitFactor,
    required this.maxDrawdown,
    required this.sharpe,
    required this.avgWin,
    required this.avgLoss,
    required this.expectancy,
    required this.equity,
  });

  final int totalCount;
  final double winRate;
  final double totalPnl;
  final double profitFactor;
  final double maxDrawdown;
  final double sharpe;
  final double avgWin;
  final double avgLoss;
  final double expectancy;
  final List<double> equity;

  static _TearStats compute(List<Trade> trades, double startBalance) {
    if (trades.isEmpty) {
      return _TearStats(
        totalCount: 0,
        winRate: 0,
        totalPnl: 0,
        profitFactor: 0,
        maxDrawdown: 0,
        sharpe: 0,
        avgWin: 0,
        avgLoss: 0,
        expectancy: 0,
        equity: [startBalance],
      );
    }
    final wins = trades.where((t) => t.pnl > 0).toList();
    final losses = trades.where((t) => t.pnl < 0).toList();
    final grossWin = wins.fold<double>(0, (s, t) => s + t.pnl);
    final grossLoss = losses.fold<double>(0, (s, t) => s + t.pnl).abs();
    final totalPnl = grossWin - grossLoss;
    final pf = grossLoss == 0
        ? (grossWin > 0 ? double.infinity : 0)
        : grossWin / grossLoss;

    final equity = <double>[startBalance];
    for (final t in trades) {
      equity.add(equity.last + t.pnl);
    }
    var peak = equity.first;
    var maxDd = 0.0;
    for (final v in equity) {
      if (v > peak) peak = v;
      final dd = v - peak;
      if (dd < maxDd) maxDd = dd;
    }

    final returns = trades.map((t) => t.pnl).toList();
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance =
        returns.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) /
        returns.length;
    final std = math.sqrt(variance);
    final sharpe = std == 0 ? 0.0 : mean / std;

    final avgWin = wins.isEmpty ? 0.0 : grossWin / wins.length;
    final avgLoss = losses.isEmpty ? 0.0 : grossLoss / losses.length;
    final winRate = wins.length / trades.length;
    final expectancy = winRate * avgWin - (1 - winRate) * avgLoss;

    return _TearStats(
      totalCount: trades.length,
      winRate: winRate,
      totalPnl: totalPnl,
      profitFactor: pf is double ? pf : pf.toDouble(),
      maxDrawdown: maxDd,
      sharpe: sharpe,
      avgWin: avgWin,
      avgLoss: avgLoss,
      expectancy: expectancy,
      equity: equity,
    );
  }
}
