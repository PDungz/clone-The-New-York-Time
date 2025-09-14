import 'package:equatable/equatable.dart';

class NotificationCategory extends Equatable {
  final String? id;
  final String? name;
  final String? displayName;
  final String? description;
  final bool? isSystem;
  final bool? isActive;
  final String? createdAt;

  const NotificationCategory({
    this.id,
    this.name,
    this.displayName,
    this.description,
    this.isSystem,
    this.isActive,
    this.createdAt,
  });

  bool get isValid {
    return id?.isNotEmpty == true && name?.isNotEmpty == true && displayName?.isNotEmpty == true;
  }

  @override
  List<Object?> get props => [id, name, displayName, isSystem, isActive];
}
