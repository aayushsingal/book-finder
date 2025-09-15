part of 'book_details_bloc.dart';

abstract class BookDetailsState extends Equatable {
  const BookDetailsState();

  @override
  List<Object> get props => [];
}

class BookDetailsInitial extends BookDetailsState {}

class BookDetailsLoading extends BookDetailsState {}

class BookDetailsLoaded extends BookDetailsState {
  final Book bookDetails;

  const BookDetailsLoaded({required this.bookDetails});

  @override
  List<Object> get props => [bookDetails];
}

class BookDetailsSaving extends BookDetailsState {
  final Book bookDetails;

  const BookDetailsSaving({required this.bookDetails});

  @override
  List<Object> get props => [bookDetails];
}

class BookDetailsError extends BookDetailsState {
  final String errorMessage;

  const BookDetailsError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}