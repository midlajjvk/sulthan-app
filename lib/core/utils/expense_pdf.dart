import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/expense_model.dart';
import 'formatters.dart';
import '../constants/app_constants.dart';

/// Builds and triggers the system share/save dialog for an expenses PDF.
Future<void> downloadExpensesPdf(List<ExpenseModel> expenses) async {
  // ── Load Unicode-capable fonts from Google Fonts ──────────────────────
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();

  final pdf = pw.Document();

  // ── Reusable styles (all use Noto Sans for full Unicode / ₹ support) ──
  final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
  final boldStyle = pw.TextStyle(font: bold, fontSize: 9);
  final headerStyle =
      pw.TextStyle(font: bold, fontSize: 20, color: PdfColors.red800);
  final subStyle =
      pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600);
  final tableHeaderStyle =
      pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.white);
  final sectionStyle =
      pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.grey800);

  // ── Group by category ─────────────────────────────────────────────────
  final Map<String, List<ExpenseModel>> byCategory = {};
  for (final e in expenses) {
    byCategory.putIfAbsent(e.category, () => []).add(e);
  }

  final total = expenses.fold(0.0, (s, e) => s + e.amount);
  final generatedOn = Fmt.date(DateTime.now());
  const currency = AppConstants.currency; // ₹

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      // ── Page header ─────────────────────────────────────────────────
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SULTHAN', style: headerStyle),
                  pw.Text('Community Treasury & Member Management',
                      style: subStyle),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('EXPENSE REPORT',
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 13,
                          color: PdfColors.grey800)),
                  pw.Text('Generated: $generatedOn', style: subStyle),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.red800, thickness: 1.5),
          pw.SizedBox(height: 8),
        ],
      ),
      // ── Page footer ──────────────────────────────────────────────────
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SULTHAN - Confidential',
              style: pw.TextStyle(
                  font: regular,
                  fontSize: 8,
                  color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(
                  font: regular,
                  fontSize: 8,
                  color: PdfColors.grey500)),
        ],
      ),
      build: (ctx) => [
        // ── Summary banner ─────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.red200),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Total Expenses',
                  '$currency${Fmt.moneyRaw(total)}', bold),
              _summaryItem('Records', '${expenses.length}', bold),
              _summaryItem('Categories', '${byCategory.length}', bold),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // ── Category breakdown ─────────────────────────────────────────
        pw.Text('Breakdown by Category', style: sectionStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.red800),
              children: [
                _hCell('Category', tableHeaderStyle),
                _hCell('Amount', tableHeaderStyle),
                _hCell('Count', tableHeaderStyle),
              ],
            ),
            ...byCategory.entries.map((entry) {
              final catTotal =
                  entry.value.fold(0.0, (s, e) => s + e.amount);
              return pw.TableRow(children: [
                _cell(entry.key, baseStyle),
                _cell('$currency${Fmt.moneyRaw(catTotal)}', boldStyle),
                _cell('${entry.value.length}', baseStyle),
              ]);
            }),
            // Total row
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColors.red100),
              children: [
                _cell('TOTAL', boldStyle),
                _cell('$currency${Fmt.moneyRaw(total)}', boldStyle),
                _cell('${expenses.length}', boldStyle),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // ── Full expense list ──────────────────────────────────────────
        pw.Text('All Expenses', style: sectionStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.5), // #
            1: const pw.FlexColumnWidth(3), // Purpose
            2: const pw.FlexColumnWidth(2), // Category
            3: const pw.FlexColumnWidth(1.5), // Date
            4: const pw.FlexColumnWidth(1.5), // Amount
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.red800),
              children: [
                _hCell('#', tableHeaderStyle),
                _hCell('Purpose', tableHeaderStyle),
                _hCell('Category', tableHeaderStyle),
                _hCell('Date', tableHeaderStyle),
                _hCell('Amount', tableHeaderStyle),
              ],
            ),
            // Data rows — alternate shading
            ...expenses.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final shade = i.isEven ? PdfColors.white : PdfColors.grey50;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: shade),
                children: [
                  _cell('${i + 1}', baseStyle),
                  _cell(e.purpose, baseStyle),
                  _cell(e.category, baseStyle),
                  _cell(Fmt.date(e.date), baseStyle),
                  _cell('$currency${Fmt.moneyRaw(e.amount)}', boldStyle),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename:
        'sulthan_expenses_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

pw.Widget _hCell(String text, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: style),
    );

pw.Widget _cell(String text, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: style),
    );

pw.Widget _summaryItem(String label, String value, pw.Font boldFont) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: boldFont, fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(
                font: boldFont, fontSize: 11, color: PdfColors.red800)),
      ],
    );
