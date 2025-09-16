import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/constants.dart';
import '../../../../injection_container.dart';
import '../bloc/saved_books/saved_books_bloc.dart';
import '../widgets/book_grid_view.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/shimmer_loading.dart';
import 'book_details_page.dart';

class SavedBooksPage extends StatefulWidget {
  const SavedBooksPage({super.key});

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
  late SavedBooksBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<SavedBooksBloc>();
    // Load saved books when the page first loads
    _bloc.add(const LoadSavedBooksEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Constants.favoritesTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87, size: 24),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              iconSize: 26,
              color: Colors.black87,
              tooltip: Constants.refreshTooltip,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _bloc.add(const RefreshSavedBooksEvent());
              },
            ),
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocConsumer<SavedBooksBloc, SavedBooksState>(
          listener: (context, state) {
            if (state is SavedBooksError) {
              // Debug logging for developers
              debugPrint('SavedBooksError: ${state.errorMessage}');
              
              // User-friendly error display
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load favorites: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  action: SnackBarAction(
                    label: Constants.retryButtonText,
                    textColor: Colors.white,
                    onPressed: () {
                      _bloc.add(const LoadSavedBooksEvent());
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SavedBooksInitial || state is SavedBooksLoading) {
              return const ShimmerLoading();
            } else if (state is SavedBooksEmpty) {
              return const EmptyStateWidget(
                title: Constants.noFavoritesTitle,
                subtitle: Constants.noFavoritesSubtitle,
                icon: Icons.favorite_border,
              );
            } else if (state is SavedBooksLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(const RefreshSavedBooksEvent());
                },
                child: BookGridView(
                  books: state.savedBooks,
                  onBookTap: (book) async {
                    // Navigate to book details and refresh when returning
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsPage(book: book),
                      ),
                    );
                    
                    // Refresh the saved books list when returning from details
                    // in case the save status changed
                    if (result == null) {
                      _bloc.add(const RefreshSavedBooksEvent());
                    }
                  },
                  isLoadingMore: false, // No pagination needed for saved books
                ),
              );
            } else if (state is SavedBooksError) {
              return CustomErrorWidget(
                message: state.errorMessage,
                onRetry: () {
                  _bloc.add(const LoadSavedBooksEvent());
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}