import 'package:flutter/material.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';
import 'package:harpy/core/core.dart';

class TweetCardTranslation extends StatelessWidget {
  const TweetCardTranslation({
    required this.tweet,
    required this.outerPadding,
    required this.innerPadding,
    required this.requireBottomInnerPadding,
    required this.requireBottomOuterPadding,
    required this.style,
  });

  final TweetData tweet;
  final double outerPadding;
  final double innerPadding;
  final bool requireBottomInnerPadding;
  final bool requireBottomOuterPadding;
  final TweetCardElementStyle style;

  @override
  Widget build(BuildContext context) {
    final buildTranslation =
        tweet.translation != null && tweet.translation!.isTranslated;

    final bottomPadding = requireBottomInnerPadding
        ? innerPadding
        : requireBottomOuterPadding
            ? outerPadding
            : 0.0;

    return AnimatedSize(
      duration: kShortAnimationDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: buildTranslation ? 1 : 0,
        duration: kShortAnimationDuration,
        curve: Curves.easeOut,
        child: buildTranslation
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: outerPadding)
                    .copyWith(top: innerPadding)
                    .copyWith(bottom: bottomPadding),
                child: TranslatedText(
                  tweet.translation!.text,
                  language: tweet.translation!.language,
                  entities: tweet.entities,
                  urlToIgnore: tweet.quoteUrl,
                  fontSizeDelta: style.sizeDelta,
                ),
              )
            : SizedBox(
                width: double.infinity,
                height: bottomPadding,
              ),
      ),
    );
  }
}
