import 'package:boostseller/model/hostess_model.dart';
import 'package:boostseller/model/performer_model.dart';

class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String role;
  final bool isVerified;
  final bool isApproved;
  final String avatarPath;
  final String adminId;
  HostessModel? hostess;
  PerformerModel? performer;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isApproved,
    required this.avatarPath,
    required this.adminId,
    this.hostess,
    this.performer,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isApproved: json['is_approved'] ?? false,
      avatarPath: json['avatar_path'] ?? '',
      adminId: json['adminId'].toString(),
      hostess:
          json['hostess'] != null
              ? HostessModel.fromJson(json['hostess'])
              : null,
      performer:
          json['performer'] != null
              ? PerformerModel.fromJson(json['performer'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'is_approved': isApproved,
      'avatar_path': avatarPath,
      'adminId': adminId,
      'hostess': hostess?.toJson(),
      'performer': performer?.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    bool? isVerified,
    bool? isApproved,
    String? avatarPath,
    String? adminId,
    HostessModel? hostess,
    PerformerModel? performer,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      avatarPath: avatarPath ?? this.avatarPath,
      adminId: adminId ?? this.adminId,
      hostess: hostess ?? this.hostess,
      performer: performer ?? this.performer,
    );
  }
}
