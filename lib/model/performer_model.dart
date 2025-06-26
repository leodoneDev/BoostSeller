class PerformerModel {
  final int id;
  final int userId;
  final int assignedCount;
  final int acceptedCount;
  final int completedCount;
  final int closedCount;
  final double avgResponseTime;
  final double score;
  final bool? available;

  PerformerModel({
    required this.id,
    required this.userId,
    required this.assignedCount,
    required this.acceptedCount,
    required this.completedCount,
    required this.closedCount,
    required this.avgResponseTime,
    required this.score,
    required this.available,
  });

  factory PerformerModel.fromJson(Map<String, dynamic> json) {
    return PerformerModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      assignedCount: json['assignedCount'] ?? 0,
      acceptedCount: json['acceptedCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      closedCount: json['closedCount'] ?? 0,
      avgResponseTime: (json['avgResponseTime'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'assignedCount': assignedCount,
      'acceptedCount': acceptedCount,
      'completedCount': completedCount,
      'closedCount': closedCount,
      'avgResponseTime': avgResponseTime,
      'score': score,
      'available': available,
    };
  }

  PerformerModel copyWith({
    int? id,
    int? userId,
    int? assignedCount,
    int? acceptedCount,
    int? completedCount,
    int? closedCount,
    double? avgResponseTime,
    double? score,
    bool? available,
  }) {
    return PerformerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assignedCount: assignedCount ?? this.assignedCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      completedCount: completedCount ?? this.completedCount,
      closedCount: closedCount ?? this.closedCount,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      score: score ?? this.score,
      available: available ?? this.available,
    );
  }
}
