class KundaliChart {
  final String userId;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String stateOrCountry;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> chartData;
  final DateTime createdAt;
  
  KundaliChart({
    required this.userId,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.stateOrCountry,
    this.latitude,
    this.longitude,
    required this.chartData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Convert from JSON
  factory KundaliChart.fromJson(Map<String, dynamic> json) {
    return KundaliChart(
      userId: json['user_id'] ?? '',
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      timeOfBirth: json['time_of_birth'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? '',
      stateOrCountry: json['state_or_country'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      chartData: json['chart_data'] ?? {},
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'time_of_birth': timeOfBirth,
      'place_of_birth': placeOfBirth,
      'state_or_country': stateOrCountry,
      'latitude': latitude,
      'longitude': longitude,
      'chart_data': chartData,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Get zodiac sign based on date of birth
  String get zodiacSign {
    final day = dateOfBirth.day;
    final month = dateOfBirth.month;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'Aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'Taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'Gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'Cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'Leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'Virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'Libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'Scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'Sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'Capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'Aquarius';
    } else {
      return 'Pisces';
    }
  }
  
  // Get ascendant (Lagna) from chart data
  String? get ascendant {
    return chartData['ascendant'] as String?;
  }
  
  // Get planetary positions
  Map<String, dynamic>? get planetaryPositions {
    return chartData['planetary_positions'] as Map<String, dynamic>?;
  }
  
  // Get houses information
  Map<String, dynamic>? get houses {
    return chartData['houses'] as Map<String, dynamic>?;
  }
  
  // Get dasha periods
  Map<String, dynamic>? get dashaPeriods {
    return chartData['dasha_periods'] as Map<String, dynamic>?;
  }
} 