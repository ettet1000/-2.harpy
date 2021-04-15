import 'package:dart_twitter_api/twitter_api.dart';
import 'package:harpy/api/api.dart';

class TwitterListData {
  TwitterListData.fromTwitterList(TwitterList list) {
    if (list == null) {
      return;
    }

    slug = list.slug;
    name = list.name;
    createdAt = list.createdAt;
    subscriberCount = list.subscriberCount;
    memberCount = list.memberCount;
    mode = list.mode;
    description = list.description;
    user = UserData.fromUser(list.user);
    following = list.following;
  }

  String slug;
  String name;
  DateTime createdAt;
  int subscriberCount;
  int memberCount;

  /// Can be 'private' or 'public'.
  String mode;

  String description;
  UserData user;
  bool following;

  /// Whether a description for this list exist.
  bool get hasDescription => description != null && description.isNotEmpty;

  /// Whether is is a private list.
  bool get isPrivate => mode == 'private';

  /// Whether this is a public list.
  bool get isPublic => mode == 'public';
}
