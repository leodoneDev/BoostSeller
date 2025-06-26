class LeadModel {
  final String id;
  String interestId;
  String stageId;
  final String name;
  final String interest;
  // final String idStr;
  final String phone;
  final String date;
  String status;
  final String registerId;
  bool isReturn;
  List<Map<String, dynamic>>? additionalInfo;

  LeadModel({
    required this.id,
    required this.interestId,
    required this.stageId,
    required this.name,
    required this.interest,
    // required this.idStr,
    required this.phone,
    required this.date,
    required this.status,
    required this.registerId,
    required this.isReturn,
    this.additionalInfo,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      interestId: json['interestId'] ?? '',
      stageId: json['stageId'] ?? '',
      name: json['name'] ?? '',
      interest: json['interest']?.toString() ?? '',
      // idStr: json['idStr']?.toString() ?? '',
      phone: json['phoneNumber'] ?? 'Not specified',
      date: json['createdAt'] ?? '',
      status: json['status'] ?? '',
      registerId: json['registerId']?.toString() ?? '',
      isReturn: json['isReturn'],
      additionalInfo:
          (json['additionalInfo'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interestId': interestId,
      'stageId': stageId,
      'name': name,
      'interest': interest,
      // 'idStr': idStr,
      'phoneNumber': phone,
      'createdAt': date,
      'status': status,
      'registerId': registerId,
      'isReturn': isReturn,
      'additionalInfo': additionalInfo,
    };
  }
}
