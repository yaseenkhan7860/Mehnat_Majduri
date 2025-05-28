import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AstroApiService {
  // Base URL for your self-hosted API
  // Change this to your actual server address
  final String baseUrl;
  
  // API endpoints
  static const String _kundaliEndpoint = '/api/kundali';
  static const String _dailyHoroscopeEndpoint = '/api/horoscope/daily';
  static const String _compatibilityEndpoint = '/api/compatibility';
  
  AstroApiService({this.baseUrl = 'http://localhost:3000'});
  
  // Method to generate Kundali chart
  Future<Map<String, dynamic>> generateKundali({
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required String stateOrCountry,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Format data for the API request
      final Map<String, dynamic> requestData = {
        'date_of_birth': dateOfBirth.toIso8601String(),
        'time_of_birth': timeOfBirth,
        'place_of_birth': placeOfBirth,
        'state_or_country': stateOrCountry,
        'latitude': latitude,
        'longitude': longitude,
      };
      
      // Make the API call
      final response = await http.post(
        Uri.parse('$baseUrl$_kundaliEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      // Check if the request was successful
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate Kundali: ${response.body}');
      }
    } catch (e) {
      // Log the error
      if (kDebugMode) {
        print('Error generating Kundali: $e');
      }
      
      // Return error information
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }
  
  // Method to get daily horoscope
  Future<Map<String, dynamic>> getDailyHoroscope(String zodiacSign) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_dailyHoroscopeEndpoint/$zodiacSign'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get horoscope: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting horoscope: $e');
      }
      
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }
  
  // Method to calculate compatibility between two charts
  Future<Map<String, dynamic>> calculateCompatibility({
    required Map<String, dynamic> firstPersonData,
    required Map<String, dynamic> secondPersonData,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'first_person': firstPersonData,
        'second_person': secondPersonData,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl$_compatibilityEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate compatibility: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating compatibility: $e');
      }
      
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }
  
  // Method to check if the API is reachable
  Future<bool> isApiAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getKundaliDetails({
    required int day,
    required int month,
    required int year,
    required int hour,
    required int minute,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    try {
      // This is a placeholder implementation
      // In a real app, you would make an actual API call to an astrology service
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, return mock data
      return {
        'ascendant': 'Taurus',
        'moon_sign': 'Gemini',
        'sun_sign': 'Cancer',
        'birth_date': '$day/$month/$year',
        'birth_time': '$hour:$minute',
        'coordinates': 'Lat: $latitude, Long: $longitude',
        'timezone': 'GMT+$timezone',
        'planets': {
          'sun': 'Cancer',
          'moon': 'Gemini',
          'mercury': 'Leo',
          'venus': 'Virgo',
          'mars': 'Libra',
          'jupiter': 'Scorpio',
          'saturn': 'Sagittarius',
        },
        'houses': {
          'house1': 'Taurus',
          'house2': 'Gemini',
          'house3': 'Cancer',
          'house4': 'Leo',
          'house5': 'Virgo',
          'house6': 'Libra',
          'house7': 'Scorpio',
          'house8': 'Sagittarius',
          'house9': 'Capricorn',
          'house10': 'Aquarius',
          'house11': 'Pisces',
          'house12': 'Aries',
        },
      };
      
      // Actual API implementation would look something like this:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/kundali'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'day': day,
          'month': month,
          'year': year,
          'hour': hour,
          'minute': minute,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate kundali: ${response.statusCode}');
      }
      */
    } catch (e) {
      throw Exception('Failed to generate kundali: $e');
    }
  }
} 