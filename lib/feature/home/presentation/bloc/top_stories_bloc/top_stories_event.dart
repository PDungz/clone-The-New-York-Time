part of 'top_stories_bloc.dart';

abstract class TopStoriesEvent extends Equatable {
  const TopStoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopStoriesEvent extends TopStoriesEvent {
  final String section;

  const LoadTopStoriesEvent({required this.section});

  @override
  List<Object?> get props => [section];
}

class RefreshTopStoriesEvent extends TopStoriesEvent {
  final String section;

  const RefreshTopStoriesEvent({required this.section});

  @override
  List<Object?> get props => [section];
}
