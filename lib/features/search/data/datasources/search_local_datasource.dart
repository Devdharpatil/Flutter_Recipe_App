import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class SearchLocalDataSource {
  /// Gets the list of recent searches from local storage
  Future<List<String>> getRecentSearches();
  
  /// Saves a search query to recent searches
  Future<bool> saveRecentSearch(String query);
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  // Maximum number of recent searches to store
  static const int _maxRecentSearches = 10;
  static const String _recentSearchesKey = 'RECENT_SEARCHES';

  SearchLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final jsonString = sharedPreferences.getString(_recentSearchesKey);
      if (jsonString == null) return [];
      
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList.map((e) => e.toString()).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get recent searches: $e');
    }
  }

  @override
  Future<bool> saveRecentSearch(String query) async {
    try {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty) return false;
      
      // Get existing searches
      List<String> searches = await getRecentSearches();
      
      // Remove if it already exists (to move it to the top)
      searches.removeWhere((element) => element.toLowerCase() == normalizedQuery.toLowerCase());
      
      // Add to the beginning of the list
      searches.insert(0, normalizedQuery);
      
      // Limit the list to max size
      if (searches.length > _maxRecentSearches) {
        searches = searches.sublist(0, _maxRecentSearches);
      }
      
      // Save to shared preferences
      return await sharedPreferences.setString(
        _recentSearchesKey,
        json.encode(searches),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save recent search: $e');
    }
  }
} 