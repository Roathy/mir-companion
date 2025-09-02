// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_today_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentTodayModel _$StudentTodayModelFromJson(Map<String, dynamic> json) =>
    StudentTodayModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mircoins: json['mircoins'] as int?,
      level: json['level'] as String?,
      unit: json['unit'] as String?,
      activities: (json['activities'] as List<dynamic>?)
          ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: json['progress'] == null
          ? null
          : ProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentTodayModelToJson(StudentTodayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mircoins': instance.mircoins,
      'level': instance.level,
      'unit': instance.unit,
      'activities': instance.activities,
      'progress': instance.progress,
    };

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      points: json['points'] as int?,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'points': instance.points,
      'completion_percentage': instance.completionPercentage,
    };

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    ProgressModel(
      completedActivities: json['completed_activities'] as int?,
      totalActivities: json['total_activities'] as int?,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble(),
      currentStreak: json['current_streak'] as int?,
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'completed_activities': instance.completedActivities,
      'total_activities': instance.totalActivities,
      'completion_percentage': instance.completionPercentage,
      'current_streak': instance.currentStreak,
    };