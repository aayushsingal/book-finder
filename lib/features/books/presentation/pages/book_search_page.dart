import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/constants.dart';
import '../../../../injection_container.dart';
import '../bloc/book_search/book_search_bloc.dart';
import '../widgets/book_grid_view.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_loading.dart';
import 'book_details_page.dart';
import 'saved_books_page.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Constants.appTitle,
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.favorite_border),
              iconSize: 26,
              color: Colors.black87,
              tooltip: Constants.favoritesTooltip,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedBooksPage(),
                  ),
                );
              },
            ),
          ),
        ],
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
                      } else {
                        // When search is cleared, load popular books
                        context.read<BookSearchBloc>().add(
                          const LoadPopularBooksEvent(),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: BlocConsumer<BookSearchBloc, BookSearchState>(
                    listener: (context, state) {
                      if (state is BookSearchError) {
                        // shows the corresponding error message to the user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${Constants.searchFailedPrefix}${state.errorMessage}',
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
                                if (_searchController.text.trim().isNotEmpty) {
                                  context.read<BookSearchBloc>().add(
                                    SearchBooksEvent(
                                      _searchController.text.trim(),
                                    ),
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
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<BookSearchBloc>().add(
                              const LoadPopularBooksEvent(),
                            );
                          },
                          child: const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 500,
                              child: EmptyStateWidget(
                                title: Constants.discoverBooksTitle,
                                subtitle: Constants.discoverBooksSubtitle,
                                icon: Icons.search,
                              ),
                            ),
                          ),
                        );
                      } else if (state is BookSearchLoading) {
                        return const ShimmerLoading();
                      } else if (state is BookSearchEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<BookSearchBloc>().add(
                              SearchBooksEvent(state.searchText),
                            );
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 500,
                              child: EmptyStateWidget(
                                title:
                                    'No books found for "${state.searchText}"',
                                subtitle: Constants.noSearchResultsSubtitle,
                                icon: Icons.book_outlined,
                              ),
                            ),
                          ),
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
                            onBookTap: (book) async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailsPage(book: book),
                                ),
                              );
                              // Refresh to update save states
                              if (context.mounted) {
                                final currentState = context
                                    .read<BookSearchBloc>()
                                    .state;
                                if (currentState is BookSearchLoaded &&
                                    currentState.searchText.isNotEmpty) {
                                  context.read<BookSearchBloc>().add(
                                    SearchBooksEvent(currentState.searchText),
                                  );
                                }
                              }
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
                        return RefreshIndicator(
                          onRefresh: () async {
                            if (_searchController.text.trim().isNotEmpty) {
                              context.read<BookSearchBloc>().add(
                                SearchBooksEvent(_searchController.text.trim()),
                              );
                            } else {
                              context.read<BookSearchBloc>().add(
                                const LoadPopularBooksEvent(),
                              );
                            }
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - 200,
                              child: CustomErrorWidget(
                                message: state.errorMessage,
                                onRetry:
                                    _searchController.text.trim().isNotEmpty
                                    ? () {
                                        context.read<BookSearchBloc>().add(
                                          SearchBooksEvent(
                                            _searchController.text.trim(),
                                          ),
                                        );
                                      }
                                    : () {
                                        context.read<BookSearchBloc>().add(
                                          const LoadPopularBooksEvent(),
                                        );
                                      },
                              ),
                            ),
                          ),
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
