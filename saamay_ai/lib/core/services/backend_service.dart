import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BackendService {
  // Use the modal.run backend URL
  static const String baseUrl = "https://alihassanshahid00--saamay-backend-fastapi-app.modal.run";

  static bool _isWarmedUp = false;

  /// Pre-warm the Modal serverless container so the first transcription is fast.
  /// Call this early (e.g. at app startup or when navigating to a recording screen).
  static Future<void> warmup() async {
    if (_isWarmedUp) return; // Only warm up once per session
    try {
      // A lightweight GET to wake up the container — we don't care about the response
      await http.get(Uri.parse('$baseUrl/health')).timeout(
        const Duration(seconds: 15),
        onTimeout: () => http.Response('timeout', 408),
      );
      _isWarmedUp = true;
    } catch (_) {
      // Swallow errors silently — warmup is best-effort
    }
  }

  /// Send an audio file to backend for transcription and analysis
  static Future<Map<String, dynamic>> transcribeAudio(File file, int surahNumber, int ayahNumber) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/transcribe'));
      
      request.fields['surah_number'] = surahNumber.toString();
      request.fields['ayah_number'] = ayahNumber.toString();
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return json.decode(responseData.body);
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during transcription: $e');
    }
  }

  /// Get EveryAyah correction audio URL
  static String getAyahAudioUrl(int surahNumber, int ayahNumber) {
    // Both parts must be 3 digits
    String surah = surahNumber.toString().padLeft(3, '0');
    String ayah = ayahNumber.toString().padLeft(3, '0');
    
    // Defaulting to AbdulSamad as requested
    return 'https://everyayah.com/data/AbdulSamad_64kbps_QuranExplorer.Com/$surah$ayah.mp3';
  }
}
