import 'dart:io';
import 'package:flutter/material.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late TransformationController _transformationController;
  
  double _dragDistance = 0.0;
  bool _isDragging = false;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    
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
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Listen to transformation changes to detect zoom level
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    setState(() {
      _isZoomed = scale > 1.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Only allow drag to dismiss when not zoomed
    if (!_isZoomed) {
      setState(() {
        _dragDistance += details.delta.dy;
        _isDragging = true;
      });

      // Calculate scale based on drag distance
      double scale = 1.0 - (_dragDistance.abs() / 500.0).clamp(0.0, 0.3);
      _scaleAnimation = Tween<double>(
        begin: scale,
        end: scale,
      ).animate(_scaleController);
      _scaleController.forward();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    // Only process drag end when not zoomed
    if (!_isZoomed) {
      if (_dragDistance.abs() > 150) {
        // Dismiss if dragged far enough
        _dismissImage();
      } else {
        // Spring back to original position
        setState(() {
          _dragDistance = 0.0;
          _isDragging = false;
        });
        _scaleAnimation = Tween<double>(
          begin: _scaleAnimation.value,
          end: 1.0,
        ).animate(_scaleController);
        _scaleController.reset();
        _scaleController.forward();
      }
    }
  }

  void _handleDoubleTap() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    Matrix4 newTransform;
    
    if (scale <= 1.0) {
      // Zoom in to 2x
      newTransform = Matrix4.identity()..scale(2.0);
    } else {
      // Reset to original size
      newTransform = Matrix4.identity();
    }
    
    _transformationController.value = newTransform;
  }

  void _dismissImage() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Widget _buildImage() {
    if (widget.imagePath == null) {
      return _buildDefaultImage();
    }

    if (widget.imagePath!.startsWith('assets/')) {
      return Image.asset(
        widget.imagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } else {
      return Image.file(
        File(widget.imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.pets,
        size: 80,
        color: Colors.orange.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withOpacity(0.9 * _animation.value),
            child: Stack(
              children: [
                // Dismiss on tap background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _dismissImage,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Image with zoom and drag gesture
                Center(
                  child: GestureDetector(
                    onPanUpdate: _handleDragUpdate,
                    onPanEnd: _handleDragEnd,
                    onDoubleTap: _handleDoubleTap,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _dragDistance),
                          child: Transform.scale(
                            scale: _scaleAnimation.value * _animation.value,
                            child: Hero(
                              tag: widget.heroTag,
                              child: InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.95,
                                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                                  ),
                                  child: _buildImage(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                
                // Drag indicator when dragging (only when not zoomed)
                if (_isDragging && _dragDistance.abs() > 50 && !_isZoomed)
                  Positioned(
                    bottom: 100,
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
                            _dragDistance.abs() > 150 
                                ? 'Suelta para cerrar' 
                                : 'Arrastra para cerrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Zoom instructions
                if (!_isDragging && !_isZoomed)
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
                            'Pellizca para zoom • Doble toque para acercar',
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
