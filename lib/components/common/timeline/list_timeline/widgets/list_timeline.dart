import 'package:flutter/material.dart';
import 'package:harpy/components/common/timeline/list_timeline/bloc/list_timeline_bloc.dart';
import 'package:harpy/components/components.dart';
import 'package:provider/provider.dart';

class ListTimeline extends StatelessWidget {
  const ListTimeline({
    this.beginSlivers = const <Widget>[],
  });

  final List<Widget> beginSlivers;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final ListTimelineBloc bloc = context.watch<ListTimelineBloc>();
    final ListTimelineState state = bloc.state;

    return ScrollToStart(
      child: LoadMoreListener(
        listen: false, // todo
        onLoadMore: () async {
          // bloc.add(const RequestOlderLikesTimeline());
          // await bloc.requestOlderCompleter.future;
        },
        child: TweetList(
          state.timelineTweets,
          key: const PageStorageKey<String>('likes_timeline'),
          enableScroll: state.enableScroll,
          beginSlivers: beginSlivers,
          endSlivers: <Widget>[
            if (state.showLoading)
              const SliverFillLoadingIndicator()
            else if (state.showNoResult)
              SliverFillLoadingError(
                message: const Text('no liked tweets found'),
                onRetry: () => bloc.add(const RequestListTimeline()),
              )
            else if (state.showError)
              SliverFillLoadingError(
                message: const Text('error loading liked tweets'),
                onRetry: () => bloc.add(const RequestListTimeline()),
              ),
            // else if (state.showLoadingOlder)
            //     const SliverBoxLoadingIndicator()
            //   else if (state.showReachedEnd)
            //       const SliverBoxInfoMessage(
            //         secondaryMessage: Text('no more liked tweets available'),
            //       ),
            SliverToBoxAdapter(
              child: SizedBox(height: mediaQuery.padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}
