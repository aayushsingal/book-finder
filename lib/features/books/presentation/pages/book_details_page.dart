import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/constants.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Constants.bookDetailsTitle,
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
            // Show loading screen during initial load
            if (state is BookDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

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
                                  width: 130,
                                  height: 190,
                            decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                        color: Colors.grey.withValues(
                                          alpha: 0.2,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
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
                                                        Constants.noCoverText,
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
                                                  Constants.noCoverText,
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (currentBook.authorName.isNotEmpty)
                          Text(
                                  '${Constants.authorPrefix}${currentBook.authorName.join(', ')}',
                            style: TextStyle(
                              fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                    height: 1.3,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (currentBook.firstPublishYear != null)
                          Text(
                                  '${Constants.publishedLabel}${currentBook.firstPublishYear}',
                            style: TextStyle(
                              fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                    height: 1.3,
                            ),
                          ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save/Unsave Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: currentBook.isSaved
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(16),
                        color: currentBook.isSaved
                            ? Colors.red[50]
                            : Colors.grey[50],
                        child: InkWell(
                          onTap: state is BookDetailsSaving
                              ? null
                              : () {
                                  if (currentBook.isSaved) {
                                    context.read<BookDetailsBloc>().add(
                                      UnsaveBookEvent(bookKey: currentBook.key),
                                    );
                                  } else {
                                    context.read<BookDetailsBloc>().add(
                                      SaveBookEvent(book: currentBook),
                                    );
                                  }
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: currentBook.isSaved
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state is BookDetailsSaving)
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: currentBook.isSaved
                                          ? Colors.red[600]
                                          : Colors.grey[600],
                                    ),
                                  )
                                else
                                  Icon(
                                    currentBook.isSaved
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 22,
                                    color: currentBook.isSaved
                                        ? Colors.red[600]
                                        : Colors.grey[600],
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  currentBook.isSaved
                                      ? Constants.savedButtonText
                                      : Constants.saveButtonText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: currentBook.isSaved
                                        ? Colors.red[700]
                                        : Colors.grey[700],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

                    // Description Section
                    if (currentBook.description != null &&
                        currentBook.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Constants.descriptionLabel,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              currentBook.description!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Additional Info Section
                    const SizedBox(height: 32),
                    const Text(
                      Constants.additionalInfoLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (currentBook.isbn != null && currentBook.isbn!.isNotEmpty)
                      _buildInfoRow(
                        Constants.isbnLabel,
                        currentBook.isbn!.first,
                      ),

                    _buildInfoRow(Constants.workIdLabel, currentBook.workId),

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
