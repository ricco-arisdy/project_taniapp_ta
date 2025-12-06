import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class LaporanPdfService {
  /// Request storage permission (simplified)
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) doesn't need permission for Downloads via MediaStore
      return true; // Langsung return true karena targetSdk 34
    }
    return true;
  }

  /// Download PDF to Downloads folder
  static Future<String?> downloadPdf({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      // Request permission (akan langsung true di Android 13+)
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get Downloads directory
      Directory? directory;

      if (Platform.isAndroid) {
        // Android: Downloads folder
        directory = Directory('/storage/emulated/0/Download');

        // Fallback jika tidak bisa akses
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: Documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError('Platform not supported');
      }

      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save PDF
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Auto-rename jika file sudah ada
      if (await file.exists()) {
        final timestamp = DateFormat('HHmmss').format(DateTime.now());
        final newFileName = fileName.replaceFirst('.pdf', '_$timestamp.pdf');
        final newFilePath = '${directory.path}/$newFileName';

        await File(newFilePath).writeAsBytes(await pdf.save());
        return newFilePath;
      }

      await file.writeAsBytes(await pdf.save());
      return filePath;
    } catch (e) {
      print('❌ [PDF_SERVICE] Error downloading PDF: $e');
      rethrow;
    }
  }

  /// Generate PDF file name
  static String generateFileName({
    String? kebunName,
    DateTime? tanggalDari,
    DateTime? tanggalSampai,
  }) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    if (kebunName != null && kebunName.isNotEmpty) {
      final cleanName = kebunName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      return 'Laporan_${cleanName}_$timestamp.pdf';
    }

    return 'Laporan_Keseluruhan_$timestamp.pdf';
  }
}
