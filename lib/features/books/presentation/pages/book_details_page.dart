import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/book.dart';
import '../bloc/book_details/book_details_bloc.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _startRotation() {
    if (!_isRotating) {
      setState(() {
        _isRotating = true;
      });
      _rotationController.forward().then((_) {
        _rotationController.reset();
        setState(() {
          _isRotating = false;
        });
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocProvider(
        create: (context) => sl<BookDetailsBloc>()
          ..add(GetBookDetailsEvent(
            workId: widget.book.workId,
            originalBook: widget.book,
          )),
        child: BlocConsumer<BookDetailsBloc, BookDetailsState>(
          listener: (context, state) {
            if (state is BookDetailsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          builder: (context, state) {
            Book currentBook = widget.book; // Default to original book

            if (state is BookDetailsLoaded) {
              currentBook = state.bookDetails;
            } else if (state is BookDetailsSaving) {
              currentBook = state.bookDetails;
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookDetailsBloc>().add(
                  GetBookDetailsEvent(
                    workId: widget.book.workId,
                    originalBook: widget.book,
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Book Cover and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Book Cover
                  GestureDetector(
                    onTap: _startRotation,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_rotationAnimation.value * 6.28),
                          child: Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: currentBook.coverUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: currentBook.coverUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[300],
                                            child: const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.book,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'No Cover',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.book,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'No Cover',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Book Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBook.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (currentBook.authorName.isNotEmpty)
                          Text(
                            'by ${currentBook.authorName.join(', ')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (currentBook.firstPublishYear != null)
                          Text(
                            'Published: ${currentBook.firstPublishYear}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Save/Unsave Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state is BookDetailsSaving
                                ? null
                                : () {
                                    if (currentBook.isSaved) {
                                      context.read<BookDetailsBloc>().add(
                                        UnsaveBookEvent(
                                          bookKey: currentBook.key,
                                        ),
                                      );
                                    } else {
                                      context.read<BookDetailsBloc>().add(
                                        SaveBookEvent(book: currentBook),
                                      );
                                    }
                                  },
                            icon: state is BookDetailsSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    currentBook.isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                            label: Text(
                              currentBook.isSaved ? 'Saved' : 'Save Book',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentBook.isSaved
                                  ? Colors.blue[100]
                                  : Colors.blue,
                              foregroundColor: currentBook.isSaved
                                  ? Colors.blue[700]
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

                    // Description Section
                    if (currentBook.description != null &&
                        currentBook.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              currentBook.description!,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),

                    // Additional Info Section
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (currentBook.isbn != null && currentBook.isbn!.isNotEmpty)
                      _buildInfoRow('ISBN', currentBook.isbn!.first),

                    _buildInfoRow('Work ID', currentBook.workId),

                    // Loading indicator for enhanced details
                    if (state is BookDetailsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Loading additional details...'),
                            ],
                          ),
                        ),
                      ),

                    // Add some extra spacing at the bottom
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
