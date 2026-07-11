import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../database/app_database.dart';
import 'formatters.dart';
import '../constants/app_constants.dart';

// ── Public entry point ────────────────────────────────────────────────────────

/// Downloads a PDF showing Paid / Partial / Pending members for a collection.
/// Pass [filterStatus] to export only one status, or null for all.
Future<void> downloadCollectionPaymentsPdf({
  required Collection collection,
  required List<Payment> payments,
  required Map<int, Member> memberMap,
  String? filterStatus, // null = all three groups
}) async {
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();

  final pdf = pw.Document();

  // ── Filter payments ────────────────────────────────────────────────────
  List<Payment> forStatus(String status) => payments
      .where((p) => p.status == status)
      .toList()
    ..sort((a, b) {
      final na = memberMap[a.memberId]?.name ?? '';
      final nb = memberMap[b.memberId]?.name ?? '';
      return na.compareTo(nb);
    });

  final paid = filterStatus == null || filterStatus == AppConstants.statusPaid
      ? forStatus(AppConstants.statusPaid)
      : <Payment>[];
  final partial =
      filterStatus == null || filterStatus == AppConstants.statusPartial
          ? forStatus(AppConstants.statusPartial)
          : <Payment>[];
  final pending =
      filterStatus == null || filterStatus == AppConstants.statusPending
          ? forStatus(AppConstants.statusPending)
          : <Payment>[];

  final totalCollected = [...paid, ...partial]
      .fold(0.0, (s, p) => s + p.paidAmount + (p.fineAmount ?? 0));
  final totalFinesCollected = [...paid, ...partial]
      .fold(0.0, (s, p) => s + (p.fineAmount ?? 0));
  
  // Calculate target based on what's actually in the filtered view
  final membersInView = paid.length + partial.length + pending.length;
  final target = collection.amountPerMember * membersInView;

  // ── Styles ─────────────────────────────────────────────────────────────
  final titleStyle =
      pw.TextStyle(font: bold, fontSize: 20, color: PdfColors.indigo800);
  final subStyle = pw.TextStyle(
      font: regular, fontSize: 10, color: PdfColors.grey600);
  final sectionStyle =
      pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.grey800);
  final tableHeaderStyle =
      pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white);
  final cell = pw.TextStyle(font: regular, fontSize: 9);
  final boldCell = pw.TextStyle(font: bold, fontSize: 9);
  final footerStyle = pw.TextStyle(
      font: regular, fontSize: 8, color: PdfColors.grey500);

  // Labels adapt to what's being shown
  final isOnlyPending = filterStatus == AppConstants.statusPending;
  final collectedLabel = isOnlyPending ? 'Outstanding' : 'Collected';
  final collectedValue = isOnlyPending
      ? '${AppConstants.currency}${Fmt.moneyRaw(target)} (${pending.length} members)'
      : totalFinesCollected > 0
          ? '${AppConstants.currency}${Fmt.moneyRaw(totalCollected)} / ${AppConstants.currency}${Fmt.moneyRaw(target)}\n(incl. ${AppConstants.currency}${Fmt.moneyRaw(totalFinesCollected)} fines)'
          : '${AppConstants.currency}${Fmt.moneyRaw(totalCollected)} / ${AppConstants.currency}${Fmt.moneyRaw(target)}';

  final collectionLabel = collection.type == AppConstants.typeMonthly &&
      collection.month != null
      ? Fmt.monthYearOf(collection.month!, collection.year!)
      : Fmt.date(collection.dateCreated);

  final title = filterStatus == null
      ? 'Payment Status Report'
      : '$filterStatus Members Report';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      // ── Page header ────────────────────────────────────────────────────
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SULTHAN', style: titleStyle),
                  pw.Text('Community Treasury & Member Management',
                      style: subStyle),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 12,
                          color: PdfColors.grey700)),
                  pw.Text(collectionLabel, style: subStyle),
                  pw.Text('Generated: ${Fmt.date(DateTime.now())}',
                      style: subStyle),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.indigo800, thickness: 1.5),
          pw.SizedBox(height: 6),
        ],
      ),
      // ── Page footer ────────────────────────────────────────────────────
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('${collection.title} - $collectionLabel',
              style: footerStyle),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: footerStyle),
        ],
      ),
      build: (ctx) => [
        // ── Summary banner ─────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.indigo50,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.indigo200),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _stat('Collection', collection.title, bold, regular,
                  maxWidth: 120),
              _stat('Period', collectionLabel, bold, regular),
              _stat('Per Member',
                  '${AppConstants.currency}${Fmt.moneyRaw(collection.amountPerMember)}',
                  bold, regular),
              _stat(collectedLabel, collectedValue, bold, regular),
            ],
          ),
        ),
        pw.SizedBox(height: 10),

        // ── Count chips row ────────────────────────────────────────────
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            if (filterStatus == null || filterStatus == AppConstants.statusPaid)
              _countChip('Paid', paid.length, PdfColors.green700,
                  PdfColors.green50, bold, regular),
            pw.SizedBox(width: 8),
            if (filterStatus == null ||
                filterStatus == AppConstants.statusPartial)
              _countChip('Partial', partial.length, PdfColors.orange700,
                  PdfColors.orange50, bold, regular),
            pw.SizedBox(width: 8),
            if (filterStatus == null ||
                filterStatus == AppConstants.statusPending)
              _countChip('Pending', pending.length, PdfColors.red700,
                  PdfColors.red50, bold, regular),
            if (totalFinesCollected > 0) ...[
              pw.SizedBox(width: 8),
              _fineChip(
                '${AppConstants.currency}${Fmt.moneyRaw(totalFinesCollected)} Fines',
                bold, regular,
              ),
            ],
          ],
        ),
        pw.SizedBox(height: 16),

        // ── Paid section ───────────────────────────────────────────────
        if (paid.isNotEmpty) ...[
          _sectionHeader('Paid Members (${paid.length})',
              PdfColors.green700, sectionStyle),
          pw.SizedBox(height: 6),
          _memberTable(paid, memberMap, tableHeaderStyle, cell, boldCell,
              PdfColors.green800, showAmount: true, showAdvance: true),
          pw.SizedBox(height: 16),
        ],

        // ── Partial section ────────────────────────────────────────────
        if (partial.isNotEmpty) ...[
          _sectionHeader('Partial Payments (${partial.length})',
              PdfColors.orange700, sectionStyle),
          pw.SizedBox(height: 6),
          _memberTable(partial, memberMap, tableHeaderStyle, cell, boldCell,
              PdfColors.orange800, showAmount: true, showAdvance: false),
          pw.SizedBox(height: 16),
        ],

        // ── Pending section ────────────────────────────────────────────
        if (pending.isNotEmpty) ...[
          _sectionHeader('Pending Members (${pending.length})',
              PdfColors.red700, sectionStyle),
          pw.SizedBox(height: 6),
          _memberTable(pending, memberMap, tableHeaderStyle, cell, boldCell,
              PdfColors.red800, showAmount: false, showAdvance: false),
        ],
      ],
    ),
  );

  // Build filename
  final statusPart = filterStatus?.toLowerCase() ?? 'all';
  final monthPart = collection.month != null
      ? '${collection.year}_${collection.month!.toString().padLeft(2, '0')}'
      : Fmt.date(collection.dateCreated).replaceAll(' ', '_');

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename:
        'sulthan_${statusPart}_payments_${monthPart}_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
}

// ── PDF helper widgets ────────────────────────────────────────────────────────

pw.Widget _sectionHeader(
        String text, PdfColor color, pw.TextStyle base) =>
    pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius:
            const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: base.font,
              fontSize: 10,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _memberTable(
  List<Payment> list,
  Map<int, Member> memberMap,
  pw.TextStyle headerStyle,
  pw.TextStyle cell,
  pw.TextStyle boldCell,
  PdfColor accentColor, {
  required bool showAmount,
  required bool showAdvance,
}) {
  // Check if any in this list has a fine
  final hasFines = showAmount && list.any((p) => (p.fineAmount ?? 0) > 0);

  // Build column widths dynamically
  final Map<int, pw.TableColumnWidth> colWidths = showAmount
      ? {
          0: const pw.FlexColumnWidth(0.4),   // #
          1: const pw.FlexColumnWidth(2.2),   // Name
          2: const pw.FlexColumnWidth(1.6),   // Mobile
          3: const pw.FlexColumnWidth(1.3),   // Paid
          if (hasFines) 4: const pw.FlexColumnWidth(1.0),  // Fine
          if (hasFines) 5: const pw.FlexColumnWidth(1.3),  // Total
          if (!hasFines) 4: const pw.FlexColumnWidth(1.4), // Date
          if (showAdvance && hasFines) 6: const pw.FlexColumnWidth(1.8),
          if (showAdvance && !hasFines) 5: const pw.FlexColumnWidth(1.8),
        }
      : {
          0: const pw.FlexColumnWidth(0.4),
          1: const pw.FlexColumnWidth(3),
          2: const pw.FlexColumnWidth(2),
        };

  final headers = showAmount
      ? [
          '#', 'Name', 'Mobile', 'Paid',
          if (hasFines) 'Fine',
          if (hasFines) 'Total',
          if (!hasFines) 'Date',
          if (showAdvance) 'Advance Until',
        ]
      : ['#', 'Name', 'Mobile'];

  final paidTotal = list.fold(0.0, (s, p) => s + p.paidAmount);
  final fineTotal = list.fold(0.0, (s, p) => s + (p.fineAmount ?? 0));
  final grandTotal = paidTotal + fineTotal;

  final fineStyle = pw.TextStyle(
      font: boldCell.font, fontSize: 9, color: PdfColors.orange800);
  final totalStyle = pw.TextStyle(
      font: boldCell.font, fontSize: 9, color: PdfColors.indigo800);

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    columnWidths: colWidths,
    children: [
      // ── Header row ──────────────────────────────────────────────────
      pw.TableRow(
        decoration: pw.BoxDecoration(color: accentColor),
        children: headers.map((h) => _tc(h, headerStyle)).toList(),
      ),
      // ── Data rows ───────────────────────────────────────────────────
      ...list.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final member = memberMap[p.memberId];
        final shade = i.isEven ? PdfColors.white : PdfColors.grey50;
        final fine = p.fineAmount ?? 0;
        final rowTotal = p.paidAmount + fine;
        final advanceLabel = p.advanceEndMonth != null
            ? '${AppDatabase.monthName(p.advanceEndMonth!)} ${p.advanceEndYear}'
            : '-';

        if (!showAmount) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: shade),
            children: [
              _tc('${i + 1}', cell),
              _tc(member?.name ?? '-', boldCell),
              _tc(member?.mobile ?? '-', cell),
            ],
          );
        }

        return pw.TableRow(
          decoration: pw.BoxDecoration(color: shade),
          children: [
            _tc('${i + 1}', cell),
            _tc(member?.name ?? '-', boldCell),
            _tc(member?.mobile ?? '-', cell),
            _tc('${AppConstants.currency}${Fmt.moneyRaw(p.paidAmount)}',
                boldCell),
            if (hasFines)
              _tc(fine > 0
                  ? '${AppConstants.currency}${Fmt.moneyRaw(fine)}'
                  : '-', fineStyle),
            if (hasFines)
              _tc('${AppConstants.currency}${Fmt.moneyRaw(rowTotal)}',
                  totalStyle),
            if (!hasFines)
              _tc(p.paymentDate != null ? Fmt.date(p.paymentDate!) : '-',
                  cell),
            if (showAdvance) _tc(advanceLabel, cell),
          ],
        );
      }),
      // ── Totals row ───────────────────────────────────────────────────
      if (showAmount)
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _tc('', cell),
            _tc('TOTAL', boldCell),
            _tc('${list.length} members', cell),
            _tc('${AppConstants.currency}${Fmt.moneyRaw(paidTotal)}',
                boldCell),
            if (hasFines)
              _tc(fineTotal > 0
                  ? '${AppConstants.currency}${Fmt.moneyRaw(fineTotal)}'
                  : '-', fineStyle),
            if (hasFines)
              _tc('${AppConstants.currency}${Fmt.moneyRaw(grandTotal)}',
                  totalStyle),
            if (!hasFines) _tc('', cell),
            if (showAdvance) _tc('', cell),
          ],
        ),
    ],
  );
}

pw.Widget _tc(String text, pw.TextStyle style) => pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: style),
    );

pw.Widget _stat(
  String label,
  String value,
  pw.Font boldFont,
  pw.Font regularFont, {
  double? maxWidth,
}) =>
    pw.SizedBox(
      width: maxWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 8,
                  color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(value,
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 10,
                  color: PdfColors.indigo800),
              textAlign: pw.TextAlign.center),
        ],
      ),
    );

pw.Widget _countChip(
  String label,
  int count,
  PdfColor textColor,
  PdfColor bgColor,
  pw.Font boldFont,
  pw.Font regularFont,
) =>
    pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius:
            const pw.BorderRadius.all(pw.Radius.circular(20)),
        border: pw.Border.all(color: textColor),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text('$count',
              style: pw.TextStyle(
                  font: boldFont, fontSize: 13, color: textColor)),
          pw.SizedBox(width: 4),
          pw.Text(label,
              style: pw.TextStyle(
                  font: regularFont, fontSize: 9, color: textColor)),
        ],
      ),
    );

pw.Widget _fineChip(String label, pw.Font boldFont, pw.Font regularFont) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
        border: pw.Border.all(color: PdfColors.orange700),
      ),
      child: pw.Text(label,
          style: pw.TextStyle(
              font: boldFont, fontSize: 10, color: PdfColors.orange900)),
    );
