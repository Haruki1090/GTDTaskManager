// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
          TaskStatus.inbox,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      project: json['project'] as String?,
      context: json['context'] as String?,
      userId: json['userId'] as String?,
      taskColor: (json['taskColor'] as num?)?.toInt() ?? 0xFF337EA9,
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'project': instance.project,
      'context': instance.context,
      'userId': instance.userId,
      'taskColor': instance.taskColor,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.inbox: 'inbox',
  TaskStatus.nextAction: 'nextAction',
  TaskStatus.waiting: 'waiting',
  TaskStatus.completed: 'completed',
  TaskStatus.someday: 'someday',
};
