import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String? imagePath;
  final String heroTag;

  const FullscreenImageViewer({
    Key? key,
    required this.imagePath,
    required this.heroTag,
  }) : super(key: key);

  @override
  _FullscreenImageViewerState createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PhotoViewController _photoViewController;
  
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Listen to scale changes to detect zoom level
    _photoViewController.outputStateStream.listen((state) {
      final scale = state.scale ?? 1.0;
      setState(() {
        _isZoomed = scale > 1.0;
      });
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _dismissImage() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  ImageProvider? _getImageProvider() {
    if (widget.imagePath == null) {
      return null;
    }

    if (widget.imagePath!.startsWith('assets/')) {
      return AssetImage(widget.imagePath!);
    } else {
      return FileImage(File(widget.imagePath!));
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.pets,
        size: 80,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.9 * _animation.value),
            child: Stack(
              children: [
                // PhotoView with fade animation
                Center(
                  child: FadeTransition(
                    opacity: _animation,
                    child: imageProvider != null
                        ? Hero(
                            tag: widget.heroTag,
                            child: PhotoView(
                              imageProvider: imageProvider,
                              controller: _photoViewController,
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 4.0,
                              initialScale: PhotoViewComputedScale.contained,
                              backgroundDecoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              enableRotation: false,
                              loadingBuilder: (context, event) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: event == null
                                        ? 0
                                        : event.cumulativeBytesLoaded /
                                            (event.expectedTotalBytes ?? 1),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultImage();
                              },
                              onTapUp: (context, details, controllerValue) {
                                // Only dismiss on tap if not zoomed
                                if (!_isZoomed) {
                                  _dismissImage();
                                }
                              },
                            ),
                          )
                        : Hero(
                            tag: widget.heroTag,
                            child: _buildDefaultImage(),
                          ),
                  ),
                ),
                
                // Close button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _animation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: _dismissImage,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Zoom instructions when not zoomed
                if (!_isZoomed)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Doble toque o pellizque para acercar • Toca fuera para cerrar',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Zoom indicator when zoomed
                if (_isZoomed)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Doble toque para alejar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
