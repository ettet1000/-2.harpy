import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';

class TweetCardMedia extends ConsumerWidget {
  const TweetCardMedia({
    required this.provider,
    required this.delegates,
  });

  final StateNotifierProvider<TweetNotifier, TweetData> provider;
  final TweetDelegates delegates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final harpyTheme = ref.watch(harpyThemeProvider);
    final tweet = ref.watch(provider);

    Widget child;

    void onMediaLongPress(MediaData media) => showMediaActionsBottomSheet(
          context,
          read: ref.read,
          tweet: tweet,
          media: media,
        );

    switch (tweet.mediaType) {
      case MediaType.image:
        child = TweetImages(
          provider: provider,
          delegates: delegates,
          onImageLongPress: (index) => onMediaLongPress(tweet.media[index]),
        );
        break;
      case MediaType.gif:
        child = TweetGif(
          tweet: tweet,
          heroTag: 'tweet${mediaHeroTag(context, tweet.media.single)}',
          onGifTap: () => Navigator.of(context).push<void>(
            HeroDialogRoute(
              builder: (_) => MediaGalleryOverlay(
                provider: provider,
                media: tweet.media.single,
                delegates: delegates,
                child: TweetGalleryGif(
                  tweet: tweet,
                  heroTag: 'tweet${mediaHeroTag(context, tweet.media.single)}',
                ),
              ),
            ),
          ),
          onGifLongPress: () => onMediaLongPress(tweet.media.single),
        );
        break;
      case MediaType.video:
        child = TweetVideo(
          tweet: tweet,
          heroTag: 'tweet${mediaHeroTag(context, tweet.media.single)}',
          onVideoLongPress: () => onMediaLongPress(tweet.media.single),
          overlayBuilder: (data, notifier, child) => StaticVideoPlayerOverlay(
            data: data,
            notifier: notifier,
            onVideoTap: () => Navigator.of(context).push<void>(
              HeroDialogRoute(
                builder: (_) => MediaGalleryOverlay(
                  provider: provider,
                  media: tweet.media.single,
                  delegates: delegates,
                  child: TweetGalleryVideo(
                    tweet: tweet,
                    heroTag: 'tweet'
                        '${mediaHeroTag(context, tweet.media.single)}',
                  ),
                ),
              ),
            ),
            onVideoLongPress: () => onMediaLongPress(tweet.media.single),
            child: child,
          ),
        );
        break;
      case null:
        assert(false);
        return const SizedBox();
    }

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: harpyTheme.borderRadius,
      child: _MediaConstrainedHeight(
        tweet: tweet,
        child: child,
      ),
    );
  }
}

class _MediaConstrainedHeight extends ConsumerWidget {
  const _MediaConstrainedHeight({
    required this.tweet,
    required this.child,
  });

  final TweetData tweet;
  final Widget child;

  Widget _constrainedAspectRatio(double aspectRatio) {
    return LayoutBuilder(
      builder: (_, constraints) => aspectRatio > constraints.biggest.aspectRatio
          // child does not take up the constrained height
          ? AspectRatio(
              aspectRatio: aspectRatio,
              child: child,
            )
          // child takes up all of the constrained height and overflows.
          // the width of the child gets reduced to match a 16:9 aspect
          // ratio
          : AspectRatio(
              aspectRatio: min(constraints.biggest.aspectRatio, 16 / 9),
              child: child,
            ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final mediaPreferences = ref.watch(mediaPreferencesProvider);

    Widget child;

    switch (tweet.mediaType) {
      case MediaType.image:
        child = tweet.hasSingleImage
            ? _constrainedAspectRatio(
                mediaPreferences.cropImage
                    ? min(tweet.media.single.aspectRatioDouble, 16 / 9)
                    : tweet.media.single.aspectRatioDouble,
              )
            : _constrainedAspectRatio(16 / 9);

        break;
      case MediaType.gif:
      case MediaType.video:
        child = _constrainedAspectRatio(tweet.media.single.aspectRatioDouble);
        break;
      case null:
        return const SizedBox();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * .8),
      child: child,
    );
  }
}

/// Creates a hero tag for the media which is unique for each [HarpyPage].
String mediaHeroTag(BuildContext context, MediaData media) {
  final routeSettings = ModalRoute.of(context)?.settings;

  if (routeSettings is HarpyPage && routeSettings.key is ValueKey) {
    final key = routeSettings.key as ValueKey;
    // key = current route path
    return '${media.hashCode}$key';
  } else {
    return '${media.hashCode}';
  }
}
