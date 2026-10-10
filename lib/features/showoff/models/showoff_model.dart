import '../../auth/models/user_model.dart';

class ShowOffModel {
  final String id;
  final UserModel? user;
  final List<String> images;
  final DateTime? createdAt;
  final bool isChosen;
  final List<String> reportedBy;

  ShowOffModel({
    required this.id,
    this.user,
    required this.images,
    this.createdAt,
    this.isChosen = false,
    this.reportedBy = const [],
  });

  ShowOffModel copyWith({bool? isChosen, List<String>? reportedBy}) => ShowOffModel(
        id: id,
        user: user,
        images: images,
        createdAt: createdAt,
        isChosen: isChosen ?? this.isChosen,
        reportedBy: reportedBy ?? this.reportedBy,
      );

  factory ShowOffModel.fromJson(Map<String, dynamic> json) {
    return ShowOffModel(
      id: json['_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      isChosen: json['isChosen'] ?? false,
      reportedBy: json['reportedBy'] != null ? List<String>.from(json['reportedBy']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user?.toJson(),
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
      'reportedBy': reportedBy,
    };
  }
}
