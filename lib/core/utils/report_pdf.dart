import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/reports/presentation/reports_screen.dart'
    show ReportData;
import 'formatters.dart';
import '../constants/app_constants.dart';

Future<void> downloadReportPdf(ReportData d) async {
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();
  final italic = await PdfGoogleFonts.notoSansItalic();

  final pdf = pw.Document();
  final generatedOn = Fmt.date(DateTime.now());
  const currency = AppConstants.currency;

  // ── Styles ──────────────────────────────────────────────────────────────
  pw.TextStyle s(
          {double size = 10,
          pw.Font? font,
          PdfColor color = PdfColors.grey900}) =>
      pw.TextStyle(font: font ?? regular, fontSize: size, color: color);

  final headerStyle = s(font: bold, size: 20, color: PdfColors.indigo800);
  final subStyle = s(size: 10, color: PdfColors.grey600);
  final sectionStyle = s(font: bold, size: 12, color: PdfColors.grey800);
  final tableHeader =
      s(font: bold, size: 9, color: PdfColors.white);
  final cell = s(size: 9);
  final boldCell = s(font: bold, size: 9);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
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
                  pw.Text(
                      'Community Treasury & Member Management',
                      style: subStyle),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('FINANCIAL REPORT',
                      style: s(font: bold, size: 13, color: PdfColors.grey700)),
                  pw.Text('Generated: $generatedOn', style: subStyle),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.indigo800, thickness: 1.5),
          pw.SizedBox(height: 8),
        ],
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SULTHAN - Financial Report',
              style: s(size: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: s(size: 8, color: PdfColors.grey500)),
        ],
      ),
      build: (ctx) => [
        // ── Net balance banner ─────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [PdfColors.indigo700, PdfColors.indigo400],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _bannerStat('Net Balance',
                  '$currency${Fmt.moneyRaw(d.balance)}', bold,
                  valueColor: d.balance >= 0
                      ? PdfColors.green200
                      : PdfColors.red200),
              _vDivider(),
              _bannerStat('Total Income',
                  '$currency${Fmt.moneyRaw(d.totalIncome)}', bold),
              _vDivider(),
              _bannerStat('Total Expenses',
                  '$currency${Fmt.moneyRaw(d.totalExpenses)}', bold),
            ],
          ),
        ),
        pw.SizedBox(height: 18),

        // ── Collections ────────────────────────────────────────────────
        pw.Text('Collections', style: sectionStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            _tableHeaderRow(
                ['Category', 'Amount'], tableHeader),
            _dataRow(
                ['Monthly Collections',
                  '$currency${Fmt.moneyRaw(d.monthlyTotal)}'],
                cell, boldCell, 0),
            _dataRow(
                ['Event Collections',
                  '$currency${Fmt.moneyRaw(d.eventTotal)}'],
                cell, boldCell, 1),
            _dataRow(
                ['Total Collections', '${d.totalCollections}'],
                cell, boldCell, 2),
          ],
        ),
        pw.SizedBox(height: 16),

        // ── Payment status ─────────────────────────────────────────────
        pw.Text('Payment Status', style: sectionStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            _tableHeaderRow(['Status', 'Count'], tableHeader),
            _dataRowColored('Paid', '${d.paidPayments}',
                cell, bold, PdfColors.green700, 0),
            _dataRowColored('Partial', '${d.partialPayments}',
                cell, bold, PdfColors.orange700, 1),
            _dataRowColored('Pending', '${d.pendingPayments}',
                cell, bold, PdfColors.red700, 2),
          ],
        ),
        pw.SizedBox(height: 16),

        // ── Members ────────────────────────────────────────────────────
        pw.Text('Members', style: sectionStyle),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            _tableHeaderRow(['Metric', 'Value'], tableHeader),
            _dataRow(
                ['Total Members', '${d.memberCount}'],
                cell, boldCell, 0),
            _dataRowColored(
                'Pending Monthly Dues', '${d.pendingCount}',
                cell, bold, PdfColors.red700, 1),
          ],
        ),
        pw.SizedBox(height: 16),

        // ── Expense by category ────────────────────────────────────────
        if (d.expenseByCategory.isNotEmpty) ...[
          pw.Text('Expenses by Category', style: sectionStyle),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.4),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              _tableHeaderRow(
                  ['#', 'Category', 'Amount', '% of Total'],
                  tableHeader),
              ..._sortedCategories(d).asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final pct = d.totalExpenses > 0
                    ? (e.value / d.totalExpenses * 100)
                        .toStringAsFixed(1)
                    : '0.0';
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: i.isEven
                          ? PdfColors.white
                          : PdfColors.grey50),
                  children: [
                    _tc('${i + 1}', cell),
                    _tc(e.key, cell),
                    _tc('$currency${Fmt.moneyRaw(e.value)}',
                        boldCell),
                    _tc('$pct%', cell),
                  ],
                );
              }),
              // Total row
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.red50),
                children: [
                  _tc('', cell),
                  _tc('TOTAL',
                      s(font: bold, size: 9, color: PdfColors.grey900)),
                  _tc(
                      '$currency${Fmt.moneyRaw(d.totalExpenses)}',
                      s(
                          font: bold,
                          size: 9,
                          color: PdfColors.red800)),
                  _tc('100%', cell),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Category bar chart (visual proportion bars)
          pw.Text('Category Breakdown (Visual)',
              style: s(font: italic, size: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          ..._sortedCategories(d).map((e) {
            final pct = d.totalExpenses > 0
                ? e.value / d.totalExpenses
                : 0.0;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(e.key, style: cell),
                      pw.Text(
                          '$currency${Fmt.moneyRaw(e.value)}  (${(pct * 100).toStringAsFixed(1)}%)',
                          style: boldCell),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    height: 8,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4)),
                    ),
                    child: pw.Row(children: [
                      pw.Container(
                        height: 8,
                        width: (pct * 500).clamp(0.0, 500.0),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red600,
                          borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4)),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename:
        'sulthan_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

List<MapEntry<String, double>> _sortedCategories(ReportData d) =>
    d.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

pw.Widget _tc(String text, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: style),
    );

pw.TableRow _tableHeaderRow(List<String> labels, pw.TextStyle style) =>
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.indigo800),
      children: labels.map((l) => _tc(l, style)).toList(),
    );

pw.TableRow _dataRow(List<String> cells, pw.TextStyle base,
        pw.TextStyle valueBold, int index) =>
    pw.TableRow(
      decoration: pw.BoxDecoration(
          color: index.isEven ? PdfColors.white : PdfColors.grey50),
      children: [
        _tc(cells[0], base),
        _tc(cells[1], valueBold),
      ],
    );

pw.TableRow _dataRowColored(String label, String value,
        pw.TextStyle base, pw.Font boldFont, PdfColor valueColor, int index) =>
    pw.TableRow(
      decoration: pw.BoxDecoration(
          color: index.isEven ? PdfColors.white : PdfColors.grey50),
      children: [
        _tc(label, base),
        _tc(value,
            pw.TextStyle(
                font: boldFont, fontSize: 9, color: valueColor)),
      ],
    );

pw.Widget _bannerStat(String label, String value, pw.Font boldFont,
    {PdfColor valueColor = PdfColors.white}) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: boldFont,
                fontSize: 8,
                color: PdfColors.grey200)),
        pw.SizedBox(height: 3),
        pw.Text(value,
            style: pw.TextStyle(
                font: boldFont, fontSize: 13, color: valueColor)),
      ],
    );

pw.Widget _vDivider() => pw.Container(
      width: 1,
      height: 36,
      color: PdfColors.grey300,
    );
