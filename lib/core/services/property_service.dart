import 'package:firebase_database/firebase_database.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';

class PropertyService {
  static final DatabaseReference _propertiesRef = FirebaseDatabase.instance.ref('properties');

  static Future<bool> addProperty(Property property) async {
    try {
      await _propertiesRef.child(property.id).set(property.toMap());
      return true;
    } catch (e) {
      print('Error adding property: $e');
      return false;
    }
  }

  static Future<bool> updateProperty(Property property) async {
    try {
      await _propertiesRef.child(property.id).update(property.toMap());
      return true;
    } catch (e) {
      print('Error updating property: $e');
      return false;
    }
  }

  static Future<bool> deleteProperty(String id) async {
    try {
      await _propertiesRef.child(id).remove();
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }

  static Stream<DatabaseEvent> getPropertiesStream() {
    return _propertiesRef.onValue;
  }
}