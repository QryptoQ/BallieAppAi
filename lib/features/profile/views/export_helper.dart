
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<void> exportStatsToPdf({
  required String name,
  required int mvp,
  required int presence,
  required int total,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Spelerstatistieken', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Naam: \$name'),
          pw.Text('MVP-stemmen ontvangen: \$mvp'),
          pw.Text('Aanwezig geweest: \$presence keer'),
          pw.Text('Totaal aantal events: \$total'),
        ],
      ),
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File('\${dir.path}/statistieken_\${name.replaceAll(' ', '_')}.pdf');
  await file.writeAsBytes(await pdf.save());

  await Share.shareXFiles([XFile(file.path)], text: 'Statistieken voor \$name');
}
