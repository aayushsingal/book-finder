import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/book_search/book_search_bloc.dart';
import '../widgets/book_grid_view.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';
import 'book_details_page.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late BookSearchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<BookSearchBloc>();
    // Load popular books when the page first loads
    _bloc.add(const LoadPopularBooksEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Finder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: BlocBuilder<BookSearchBloc, BookSearchState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onSearch: (query) {
                      if (query.trim().isNotEmpty) {
                        context.read<BookSearchBloc>().add(
                          SearchBooksEvent(query),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: BlocConsumer<BookSearchBloc, BookSearchState>(
                    listener: (context, state) {
                      if (state is BookSearchError) {
                        // Debug logging for developers
                        debugPrint('BookSearchError: ${state.errorMessage}');
                        
                        // User-friendly error display
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Search failed: ${state.errorMessage}',
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
                              label: 'RETRY',
                              textColor: Colors.white,
                              onPressed: () {
                                if (_searchController.text.trim().isNotEmpty) {
                                  context.read<BookSearchBloc>().add(
                                    SearchBooksEvent(_searchController.text.trim()),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is BookSearchInitial) {
                        return const EmptyStateWidget(
                          title: 'Discover Amazing Books',
                          subtitle:
                              'Search for your favorite books by title or author\n\nTry searching for "Harry Potter" or "Lord of the Rings"',
                          icon: Icons.search,
                        );
                      } else if (state is BookSearchLoading) {
                        return const ShimmerLoading();
                      } else if (state is BookSearchEmpty) {
                        return EmptyStateWidget(
                          title: 'No books found for "${state.searchText}"',
                          subtitle:
                              'Try searching with different keywords or check your spelling',
                          icon: Icons.book_outlined,
                          onAction: () {
                            _searchController.clear();
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          actionText: 'Try Again',
                        );
                      } else if (state is BookSearchLoaded ||
                          state is BookSearchLoadingMore) {
                        final books = state is BookSearchLoaded
                            ? state.bookList
                            : (state as BookSearchLoadingMore).bookList;

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<BookSearchBloc>().add(
                              const RefreshBooksEvent(),
                            );
                          },
                          child: BookGridView(
                            books: books,
                            onBookTap: (book) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailsPage(book: book),
                                ),
                              );
                            },
                            isLoadingMore: state is BookSearchLoadingMore,
                            onLoadMore: () {
                              context.read<BookSearchBloc>().add(
                                const LoadMoreBooksEvent(),
                              );
                            },
                          ),
                        );
                      } else if (state is BookSearchError) {
                        return CustomErrorWidget(
                          message: state.errorMessage,
                          onRetry: _searchController.text.trim().isNotEmpty
                              ? () {
                                  context.read<BookSearchBloc>().add(
                                    SearchBooksEvent(
                                      _searchController.text.trim(),
                                    ),
                                  );
                                }
                              : null,
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
