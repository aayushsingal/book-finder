import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import 'book_card.dart';
import 'shimmer_book_card.dart';

class BookGridView extends StatefulWidget {
  final List<Book> books;
  final Function(Book) onBookTap;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const BookGridView({
    super.key,
    required this.books,
    required this.onBookTap,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  State<BookGridView> createState() => _BookGridViewState();
}

class _BookGridViewState extends State<BookGridView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger pagination near bottom
      if (widget.onLoadMore != null && 
          !widget.isLoadingMore && 
          !_isLoadingMore) {
        _isLoadingMore = true;
        widget.onLoadMore!();
        
        // Prevent rapid consecutive calls
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.books.length + (widget.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index < widget.books.length) {
            final book = widget.books[index];
            return BookCard(
              book: book,
              onTap: () => widget.onBookTap(book),
            );
          } else {
            // Loading placeholder
            return const ShimmerBookCard();
          }
        },
      ),
    );
  }
}