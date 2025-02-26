import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/rby/rby.dart';
import 'package:shimmer/shimmer.dart';

/// Builds a network [Image] with a shimmer loading animation that fades into
/// the loaded image.
class HarpyImage extends StatelessWidget {
  const HarpyImage({
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      // empty on tap to prevent tap gestures on error widget
      onTap: () {},
      child: Container(
        color: theme.cardColor,
        width: width,
        height: height,
        child: FractionallySizedBox(
          widthFactor: .5,
          heightFactor: .5,
          child: FittedBox(
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;

    final theme = Theme.of(context);

    return HarpyAnimatedSwitcher(
      child: frame == null
          ? GestureDetector(
              // empty on tap to prevent tap gestures on loading shimmer
              onTap: () {},
              child: Shimmer(
                gradient: LinearGradient(
                  colors: [
                    theme.cardTheme.color!.withOpacity(.3),
                    theme.cardTheme.color!.withOpacity(.3),
                    theme.colorScheme.secondary,
                    theme.cardTheme.color!.withOpacity(.3),
                    theme.cardTheme.color!.withOpacity(.3),
                  ],
                ),
                child: ColoredBox(color: theme.cardTheme.color!),
              ),
            )
          : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      // fallback to NetworkImage in tests because we can't use mocked http
      // overrides for `NetworkImageWithRetry`
      image: (isTest ? NetworkImage(imageUrl) : NetworkImageWithRetry(imageUrl))
          as ImageProvider,
      errorBuilder: _errorBuilder,
      frameBuilder: _frameBuilder,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
