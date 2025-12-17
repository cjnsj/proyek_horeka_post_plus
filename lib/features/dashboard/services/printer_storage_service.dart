import 'package:horeka_post_plus/features/dashboard/data/saved_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PrinterStorageService {
  static const String _keyPrinters = 'saved_printers';
  static const String _keySelectedPrinter = 'selected_printer_id';

  // Save printers to SharedPreferences
  Future<bool> savePrinters(List<SavedPrinter> printers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = SavedPrinter.encodeList(printers);
      return await prefs.setString(_keyPrinters, jsonString);
    } catch (e) {
      print('Error saving printers: $e');
      return false;
    }
  }

  // Load printers from SharedPreferences
  Future<List<SavedPrinter>> loadPrinters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyPrinters);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      return SavedPrinter.decodeList(jsonString);
    } catch (e) {
      print('Error loading printers: $e');
      return [];
    }
  }

  // Save selected printer ID
  Future<bool> saveSelectedPrinter(String printerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keySelectedPrinter, printerId);
    } catch (e) {
      print('Error saving selected printer: $e');
      return false;
    }
  }

  // Load selected printer ID
  Future<String?> loadSelectedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySelectedPrinter);
    } catch (e) {
      print('Error loading selected printer: $e');
      return null;
    }
  }

  // Clear all printer data
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPrinters);
      await prefs.remove(_keySelectedPrinter);
      return true;
    } catch (e) {
      print('Error clearing printer data: $e');
      return false;
    }
  }
}
