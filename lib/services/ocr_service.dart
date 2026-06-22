import 'package:file_selector/file_selector.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'file_import_service.dart';

/// Extracts text from images using on-device OCR (Phase 14B gallery, 14C camera).
///
/// Uses Google ML Kit Latin text recognition. Inference runs locally — the
/// image is never uploaded. Returns the same [ImportedFile] shape as the TXT
/// and PDF importers so the rest of the flow (preview → create) is identical.
class OcrService {
  const OcrService();

  /// Opens the gallery picker for an image and extracts its text on-device.
  ///
  /// Returns `null` if the user cancels. Throws a [FileImportException] with a
  /// friendly message if the image can't be read or has no recognizable text.
  Future<ImportedFile?> pickImageAndExtract() async {
    const typeGroup = XTypeGroup(
      label: 'Images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp', 'bmp'],
      mimeTypes: <String>['image/*'],
      uniformTypeIdentifiers: <String>['public.image'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file == null) return null; // cancelled

    final text = await extractTextFromImage(file.path);
    return ImportedFile(text: text, fileName: file.name);
  }

  /// Opens the device camera to take a photo and extracts its text on-device
  /// (Phase 14C). The system camera app handles capture and Retake/Use.
  ///
  /// Returns `null` if the user backs out without taking a photo.
  Future<ImportedFile?> captureImageAndExtract() async {
    final XFile? photo;
    try {
      photo = await ImagePicker().pickImage(source: ImageSource.camera);
    } catch (_) {
      throw const FileImportException(
        "Couldn't open the camera. Please try again.",
      );
    }
    if (photo == null) return null; // cancelled

    final text = await extractTextFromImage(photo.path);
    return ImportedFile(text: text, fileName: photo.name);
  }

  /// Runs on-device ML Kit Latin OCR on the image at [imagePath]. Shared by the
  /// gallery and camera flows. Returns the recognized text, or throws a
  /// [FileImportException] when there is no readable text or recognition fails.
  Future<String> extractTextFromImage(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result =
          await recognizer.processImage(InputImage.fromFilePath(imagePath));
      final text = result.text.trim();
      if (text.isEmpty) {
        throw const FileImportException(
          "Couldn't find readable text. Works best with clear printed English "
          'text (Sinhala and Tamil are not supported yet).',
        );
      }
      return text;
    } on FileImportException {
      rethrow;
    } catch (_) {
      throw const FileImportException(
        'Text recognition failed. Please try another image.',
      );
    } finally {
      await recognizer.close();
    }
  }
}
