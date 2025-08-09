// lib/services/image_cache_service.dart
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  // Cache to store preloaded images
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, bool> _loadingStatus = {};
  bool _isInitialized = false;

  // Reward image paths
  static const List<String> rewardImagePaths = [
    'assets/images/5.png',
    'assets/images/10.png',
    'assets/images/15.png',
    'assets/images/25.png',
    'assets/images/50.png',
    'assets/images/100.png',
    'assets/images/jackpot.png',
  ];

  /// Preload all reward images at app startup
  Future<void> preloadRewardImages() async {
    if (_isInitialized) return;

    // Load all images in parallel for faster startup
    final loadingFutures = rewardImagePaths.map(
      (path) => _loadAndCacheImage(path),
    );

    try {
      await Future.wait(loadingFutures);
      _isInitialized = true;
    } catch (e) {
      // Continue anyway - we'll handle missing images gracefully
      _isInitialized = true;
    }
  }

  /// Load and cache a single image
  Future<void> _loadAndCacheImage(String path) async {
    if (_imageCache.containsKey(path) || _loadingStatus[path] == true) {
      return; // Already cached or currently loading
    }

    _loadingStatus[path] = true;

    try {
      final image = await _loadImageFromAsset(path);
      _imageCache[path] = image;
    } catch (e) {
      // Don't throw - continue with other images
    } finally {
      _loadingStatus[path] = false;
    }
  }

  /// Optimized image loading with target size
  Future<ui.Image> _loadImageFromAsset(String path) async {
    final byteData = await rootBundle.load(path);

    // Decode with optimal target size for wheel display
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: 140, // 2x the display size for crisp rendering
      targetHeight: 140,
    );

    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Get cached image or return null if not available
  ui.Image? getCachedImage(String path) {
    return _imageCache[path];
  }

  /// Check if an image is cached
  bool isImageCached(String path) {
    return _imageCache.containsKey(path);
  }

  /// Get all cached images for the wheel
  Map<String, ui.Image> get cachedRewardImages {
    final rewardImages = <String, ui.Image>{};
    for (final path in rewardImagePaths) {
      if (_imageCache.containsKey(path)) {
        rewardImages[path] = _imageCache[path]!;
      }
    }
    return rewardImages;
  }

  /// Check if all reward images are loaded
  bool get areAllRewardImagesLoaded {
    return rewardImagePaths.every((path) => _imageCache.containsKey(path));
  }

  /// Get loading progress (0.0 to 1.0)
  double get loadingProgress {
    if (rewardImagePaths.isEmpty) return 1.0;
    final loadedCount =
        rewardImagePaths.where((path) => _imageCache.containsKey(path)).length;
    return loadedCount / rewardImagePaths.length;
  }

  /// Force reload a specific image (useful for error recovery)
  Future<void> reloadImage(String path) async {
    _imageCache.remove(path);
    _loadingStatus.remove(path);
    await _loadAndCacheImage(path);
  }

  /// Clear all cached images (useful for memory management)
  void clearCache() {
    _imageCache.clear();
    _loadingStatus.clear();
    _isInitialized = false;
  }

  /// Get cache status for debugging
  Map<String, dynamic> get cacheStatus {
    return {
      'initialized': _isInitialized,
      'cached_count': _imageCache.length,
      'total_reward_images': rewardImagePaths.length,
      'loading_progress': loadingProgress,
      'cached_paths': _imageCache.keys.toList(),
    };
  }
}
