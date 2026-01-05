// lib/services/content_service.dart
import '../models/content_model.dart';

class ContentService {
  // Simulasi database menggunakan List
  final List<ContentModel> _contents = [];

  void addContent(ContentModel content) {
    content = ContentModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: content.name,
      category: content.category,
      price: content.price,
      about: content.about,
    );
    _contents.add(content);
  }

  // Read: Mendapatkan semua konten
  List<ContentModel> getAllContents() {
    return _contents;
  }

  // Read: Mendapatkan konten berdasarkan ID
  ContentModel? getContentById(int id) {
    try {
      return _contents.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update: Memperbarui konten
  void updateContent(ContentModel updatedContent) {
    final index =
        _contents.indexWhere((content) => content.id == updatedContent.id);
    if (index != -1) {
      _contents[index] = updatedContent;
    }
  }

  // Delete: Menghapus konten
  void deleteContent(int id) {
    _contents.removeWhere((content) => content.id == id);
  }
}
