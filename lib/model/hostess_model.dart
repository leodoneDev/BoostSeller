class HostessModel {
  final int id;
  final int userId;
  final int totalCount;
  final int acceptedCount;
  final int completedCount;

  HostessModel({
    required this.id,
    required this.userId,
    required this.totalCount,
    required this.acceptedCount,
    required this.completedCount,
  });

  factory HostessModel.fromJson(Map<String, dynamic> json) {
    return HostessModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      acceptedCount: json['acceptedCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalCount': totalCount,
      'acceptedCount': acceptedCount,
      'completedCount': completedCount,
    };
  }

  HostessModel copyWith({
    int? id,
    int? userId,
    int? totalCount,
    int? acceptedCount,
    int? completedCount,
  }) {
    return HostessModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalCount: totalCount ?? this.totalCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}
