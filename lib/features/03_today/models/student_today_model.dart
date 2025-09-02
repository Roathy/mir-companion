import 'package:json_annotation/json_annotation.dart';

part 'student_today_model.g.dart';

@JsonSerializable()
class StudentTodayModel {
  final String? id;
  final String? name;
  final String? email;
  final int? mircoins;
  final String? level;
  final String? unit;
  final List<ActivityModel>? activities;
  final ProgressModel? progress;

  const StudentTodayModel({
    this.id,
    this.name,
    this.email,
    this.mircoins,
    this.level,
    this.unit,
    this.activities,
    this.progress,
  });

  factory StudentTodayModel.fromJson(Map<String, dynamic> json) =>
      _$StudentTodayModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentTodayModelToJson(this);
}

@JsonSerializable()
class ActivityModel {
  final String? id;
  final String? title;
  final String? description;
  final String? type;
  final String? status;
  final int? points;
  @JsonKey(name: 'completion_percentage')
  final double? completionPercentage;

  const ActivityModel({
    this.id,
    this.title,
    this.description,
    this.type,
    this.status,
    this.points,
    this.completionPercentage,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);
}

@JsonSerializable()
class ProgressModel {
  @JsonKey(name: 'completed_activities')
  final int? completedActivities;
  @JsonKey(name: 'total_activities')
  final int? totalActivities;
  @JsonKey(name: 'completion_percentage')
  final double? completionPercentage;
  @JsonKey(name: 'current_streak')
  final int? currentStreak;

  const ProgressModel({
    this.completedActivities,
    this.totalActivities,
    this.completionPercentage,
    this.currentStreak,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);
}