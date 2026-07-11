import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../database/app_database.dart';
import 'formatters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry points
// ─────────────────────────────────────────────────────────────────────────────

/// Download a single member's profile as PDF.
Future<void> downloadSingleMemberPdf(Member m) async {
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();

  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pageHeader(regular, bold),
          pw.SizedBox(height: 20),
          // ── Member card ───────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Avatar + name row
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Circle avatar placeholder
                    pw.Container(
                      width: 56,
                      height: 56,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.indigo100,
                        shape: pw.BoxShape.circle,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        m.name[0].toUpperCase(),
                        style: pw.TextStyle(
                            font: bold,
                            fontSize: 24,
                            color: PdfColors.indigo800),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(m.name,
                              style: pw.TextStyle(
                                  font: bold,
                                  fontSize: 18,
                                  color: PdfColors.grey900)),
                          pw.SizedBox(height: 4),
                          _statusBadge(m.status, bold),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.grey200),
                pw.SizedBox(height: 12),
                // Detail rows
                _detailGrid(m, regular, bold),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Generated on ${Fmt.date(DateTime.now())}',
            style: pw.TextStyle(
                font: regular, fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'member_${m.name.replaceAll(' ', '_')}.pdf',
  );
}

/// Download all members as a table PDF.
Future<void> downloadAllMembersPdf(List<Member> members) async {
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();

  final pdf = pw.Document();

  final tableHeaderStyle =
      pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white);
  final cellStyle = pw.TextStyle(font: regular, fontSize: 8);
  final boldCell = pw.TextStyle(font: bold, fontSize: 8);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pageHeader(regular, bold),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.indigo800, thickness: 1.5),
          pw.SizedBox(height: 6),
        ],
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SULTHAN - Members Directory',
              style: pw.TextStyle(
                  font: regular, fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(
                  font: regular, fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
      build: (ctx) => [
        // ── Summary banner ─────────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.indigo50,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.indigo200),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Total Members', '${members.length}', bold),
              _summaryItem(
                  'Active',
                  '${members.where((m) => m.status == 'Active').length}',
                  bold),
              _summaryItem(
                  'Inactive',
                  '${members.where((m) => m.status == 'Inactive').length}',
                  bold),
              _summaryItem(
                  'Generated', Fmt.date(DateTime.now()), bold),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // ── Members table ──────────────────────────────────────────────
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.4),  // #
            1: const pw.FlexColumnWidth(2.2),  // Name
            2: const pw.FlexColumnWidth(1.6),  // Mobile
            3: const pw.FlexColumnWidth(2.0),  // Email
            4: const pw.FlexColumnWidth(0.8),  // Blood
            5: const pw.FlexColumnWidth(1.2),  // DOB
            6: const pw.FlexColumnWidth(2.2),  // Address
            7: const pw.FlexColumnWidth(0.8),  // Status
          },
          children: [
            // Header
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColors.indigo800),
              children: [
                _hCell('#', tableHeaderStyle),
                _hCell('Name', tableHeaderStyle),
                _hCell('Mobile', tableHeaderStyle),
                _hCell('Email', tableHeaderStyle),
                _hCell('Blood', tableHeaderStyle),
                _hCell('DOB', tableHeaderStyle),
                _hCell('Address', tableHeaderStyle),
                _hCell('Status', tableHeaderStyle),
              ],
            ),
            // Data rows
            ...members.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              final shade =
                  i.isEven ? PdfColors.white : PdfColors.grey50;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: shade),
                children: [
                  _cell('${i + 1}', cellStyle),
                  _cell(m.name, boldCell),
                  _cell(m.mobile, cellStyle),
                  _cell(m.email ?? '-', cellStyle),
                  _cell(m.bloodGroup ?? '-', cellStyle),
                  _cell(m.dateOfBirth != null
                      ? Fmt.date(m.dateOfBirth!)
                      : '-', cellStyle),
                  _cell(m.address ?? '-', cellStyle),
                  _cell(m.status,
                      m.status == 'Active'
                          ? pw.TextStyle(
                              font: bold,
                              fontSize: 8,
                              color: PdfColors.green700)
                          : pw.TextStyle(
                              font: regular,
                              fontSize: 8,
                              color: PdfColors.grey600)),
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
        'sulthan_members_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

pw.Widget _pageHeader(pw.Font regular, pw.Font bold) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SULTHAN',
                style: pw.TextStyle(
                    font: bold,
                    fontSize: 20,
                    color: PdfColors.indigo800)),
            pw.Text('Community Treasury & Member Management',
                style: pw.TextStyle(
                    font: regular,
                    fontSize: 10,
                    color: PdfColors.grey600)),
          ],
        ),
        pw.Text('MEMBERS DIRECTORY',
            style: pw.TextStyle(
                font: bold, fontSize: 12, color: PdfColors.grey700)),
      ],
    );

/// Two-column detail grid for single member view.
pw.Widget _detailGrid(Member m, pw.Font regular, pw.Font bold) {
  final items = <_DetailItem>[
    _DetailItem('Mobile', m.mobile),
    _DetailItem('Email', m.email ?? '-'),
    _DetailItem('Date of Birth',
        m.dateOfBirth != null
            ? '${Fmt.date(m.dateOfBirth!)}  (Age ${Fmt.age(m.dateOfBirth!)})'
            : '-'),
    _DetailItem('Blood Group', m.bloodGroup ?? '-'),
    _DetailItem('Address', m.address ?? '-'),
    if (m.additionalInfo != null)
      _DetailItem('Additional Info', m.additionalInfo!),
    _DetailItem('Member Since', Fmt.date(m.createdAt)),
  ];

  return pw.Column(
    children: items.map((item) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(item.label,
                  style: pw.TextStyle(
                      font: bold,
                      fontSize: 10,
                      color: PdfColors.grey700)),
            ),
            pw.Text(':  ',
                style: pw.TextStyle(
                    font: regular, fontSize: 10, color: PdfColors.grey600)),
            pw.Expanded(
              child: pw.Text(item.value,
                  style: pw.TextStyle(
                      font: regular,
                      fontSize: 10,
                      color: PdfColors.grey900)),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

pw.Widget _statusBadge(String status, pw.Font bold) {
  final isActive = status == 'Active';
  return pw.Container(
    padding:
        const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: isActive ? PdfColors.green50 : PdfColors.grey200,
      borderRadius:
          const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(
          color: isActive ? PdfColors.green300 : PdfColors.grey400),
    ),
    child: pw.Text(
      status,
      style: pw.TextStyle(
          font: bold,
          fontSize: 9,
          color: isActive ? PdfColors.green800 : PdfColors.grey700),
    ),
  );
}

pw.Widget _summaryItem(String label, String value, pw.Font bold) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: bold, fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(
                font: bold, fontSize: 11, color: PdfColors.indigo800)),
      ],
    );

pw.Widget _hCell(String text, pw.TextStyle style) => pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Text(text, style: style),
    );

pw.Widget _cell(String text, pw.TextStyle style) => pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(text, style: style),
    );

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}
