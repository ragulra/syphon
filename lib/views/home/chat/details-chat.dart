// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/views/home/chat/details-all-users.dart';
import 'package:syphon/views/widgets/containers/card-section.dart';
import 'package:syphon/views/widgets/lists/list-user-bubbles.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

// Project imports:
import 'package:syphon/global/colours.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/rooms/actions.dart';
import 'package:syphon/store/rooms/events/model.dart';
import 'package:syphon/store/rooms/events/selectors.dart';
import 'package:syphon/store/rooms/room/model.dart';
import 'package:syphon/store/rooms/selectors.dart' as roomSelectors;
import 'package:syphon/store/settings/chat-settings/actions.dart';
import 'package:syphon/store/settings/chat-settings/model.dart';
import 'package:syphon/store/user/model.dart';
import 'package:syphon/views/widgets/avatars/avatar-circle.dart';
import 'package:syphon/views/widgets/dialogs/dialog-color-picker.dart';

class ChatSettingsArguments {
  final String roomId;
  final String title;

  // Improve loading times
  ChatSettingsArguments({
    this.roomId,
    this.title,
  });
}

class ChatDetailsView extends StatefulWidget {
  const ChatDetailsView({Key key}) : super(key: key);

  @override
  ChatDetailsState createState() => ChatDetailsState();
}

class ChatDetailsState extends State<ChatDetailsView> {
  ChatDetailsState({Key key}) : super();

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
  );

  double headerOpacity = 1;
  double headerSize = 54;
  List<User> usersList;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      final height = MediaQuery.of(context).size.height;
      final minOffset = 0;
      final maxOffset = height * 0.2;
      final offsetRatio = scrollController.offset / maxOffset;

      final isOpaque = scrollController.offset <= minOffset;
      final isTransparent = scrollController.offset > maxOffset;
      final isFading = !isOpaque && !isTransparent;

      if (isFading) {
        return this.setState(() {
          headerOpacity = 1 - offsetRatio;
        });
      }

      if (isTransparent) {
        return this.setState(() {
          headerOpacity = 0;
        });
      }

      return this.setState(() {
        headerOpacity = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @protected
  onShowColorPicker({
    context,
    int originalColor,
    Function onSelectColor,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => DialogColorPicker(
        title: 'Select Chat Color',
        currentColor: originalColor,
        onSelectColor: onSelectColor,
      ),
    );
  }

  @protected
  onLeaveChat(_Props props) async {
    props.onLeaveChat();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // Confirm this is needed in chat details
    final titlePadding = Dimensions.listTitlePaddingDynamic(width: width);
    final contentPadding = Dimensions.listPaddingDynamic(width: width);

    final ChatSettingsArguments arguments =
        ModalRoute.of(context).settings.arguments;

    final scaffordBackgroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : Theme.of(context).scaffoldBackgroundColor;

    return StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) => _Props.mapStateToProps(
        store,
        arguments.roomId,
      ),
      builder: (context, props) => Scaffold(
        backgroundColor: scaffordBackgroundColor,
        body: CustomScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: height * 0.3,
              brightness: Theme.of(context).appBarTheme.brightness,
              automaticallyImplyLeading: false,
              titleSpacing: 0.0,
              title: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      arguments.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              flexibleSpace: Hero(
                tag: "ChatAvatar",
                child: Container(
                  padding: EdgeInsets.only(top: height * 0.075),
                  color: props.roomPrimaryColor,
                  width: width,
                  child: OverflowBox(
                    minHeight: 64,
                    maxHeight: height * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: headerOpacity,
                          child: AvatarCircle(
                            size: height * 0.15,
                            uri: props.room.avatarUri,
                            alt: props.room.name,
                            background: Colours.hashedColor(props.room.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  children: <Widget>[
                    CardSection(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      margin: EdgeInsets.only(bottom: 4),
                      child: Column(
                        children: [
                          Container(
                            width: width,
                            padding: titlePadding,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        Strings.labelUsersSection,
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ],
                                  ),
                                ),
                                TouchableOpacity(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/home/chat/users',
                                      arguments: ChatUsersDetailArguments(
                                        roomId: props.room.id,
                                      ),
                                    );
                                  },
                                  activeOpacity: 0.4,
                                  child: Row(
                                    children: [
                                      Text(
                                        Strings.buttonTextSeeAllUsers,
                                        textAlign: TextAlign.start,
                                      ),
                                      Container(
                                        child: Text(
                                          ' (${props.room.users.length})',
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: width,
                              maxHeight: Dimensions.avatarSizeLarge,
                            ),
                            child: ListUserBubbles(
                              users: props.userList,
                              roomId: props.room.id,
                            ),
                          )
                        ],
                      ),
                    ),
                    CardSection(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width,
                            padding: titlePadding,
                            child: Text(
                              'About',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          Container(
                            padding: contentPadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  props.room.name,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(
                                  props.room.id,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Text(
                                  props.room.type,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Visibility(
                                  visible: props.room.topic != null &&
                                      props.room.topic.length > 0,
                                  maintainSize: false,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      props.room.topic,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    CardSection(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              padding: contentPadding,
                              child: Text(
                                'Chat Settings',
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            ListTile(
                              contentPadding: contentPadding,
                              title: Text(
                                'Color',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              trailing: Container(
                                padding: EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: props.roomPrimaryColor,
                                ),
                              ),
                              onTap: () => onShowColorPicker(
                                context: context,
                                onSelectColor: props.onSelectPrimaryColor,
                                originalColor: props.roomPrimaryColor.value,
                              ),
                            ),
                            ListTile(
                              enabled: !props.loading,
                              contentPadding: contentPadding,
                              title: Text(
                                'Toggle Direct Room',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              trailing: Container(
                                child: Switch(
                                  value: props.room.direct,
                                  onChanged: (value) {
                                    props.onToggleDirectRoom();
                                  },
                                ),
                              ),
                              onTap: () {
                                props.onToggleDirectRoom();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    CardSection(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Container(
                            width: width,
                            padding: contentPadding,
                            child: Text(
                              'Notifications Settings',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          ListTile(
                            enabled: false,
                            contentPadding: contentPadding,
                            title: Text(
                              'Mute Notifications',
                            ),
                            trailing: Container(
                              child: Switch(
                                value: false,
                                onChanged: null,
                              ),
                            ),
                          ),
                          ListTile(
                            enabled: false,
                            contentPadding: contentPadding,
                            title: Text(
                              'Vibrate',
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Default',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                          ),
                          ListTile(
                            enabled: false,
                            contentPadding: contentPadding,
                            title: Text(
                              'Notification Sound',
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Default (Argon)',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CardSection(
                      child: Column(
                        children: [
                          Container(
                            width: width,
                            padding: contentPadding,
                            child: Text(
                              'Privacy and Status',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                          ListTile(
                            enabled: false,
                            contentPadding: contentPadding,
                            title: Text(
                              'View Encryption Key',
                            ),
                          ),
                        ],
                      ),
                    ),
                    CardSection(
                      child: Container(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () => this.onLeaveChat(props),
                              contentPadding: contentPadding,
                              title: Text(
                                'Leave Chat',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      color: Colors.redAccent,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ])),
          ],
        ),
      ),
    );
  }
}

class _Props extends Equatable {
  final Room room;
  final bool loading;
  final Color roomPrimaryColor;
  final List<Message> messages;
  final List<User> userList;

  final Function onLeaveChat;
  final Function onSelectPrimaryColor;
  final Function onToggleDirectRoom;
  final Function onViewEncryptionKeys;

  _Props({
    @required this.room,
    @required this.userList,
    @required this.loading,
    @required this.messages,
    @required this.onLeaveChat,
    @required this.roomPrimaryColor,
    @required this.onSelectPrimaryColor,
    @required this.onToggleDirectRoom,
    @required this.onViewEncryptionKeys,
  });

  @override
  List<Object> get props => [
        room,
        messages,
        roomPrimaryColor,
        loading,
      ];

  static _Props mapStateToProps(Store<AppState> store, String roomId) => _Props(
      room: roomSelectors.room(id: roomId, state: store.state),
      loading: store.state.roomStore.loading,
      userList: List.from(
        roomSelectors.room(id: roomId, state: store.state).users.values,
      ),
      messages: latestMessages(
        roomSelectors.room(id: roomId, state: store.state).messages,
      ),
      onLeaveChat: () async {
        await store.dispatch(removeRoom(room: Room(id: roomId)));
      },
      roomPrimaryColor: () {
        final customChatSettings =
            store.state.settingsStore.customChatSettings ??
                Map<String, ChatSetting>();

        if (customChatSettings[roomId] != null) {
          return customChatSettings[roomId].primaryColor != null
              ? Color(customChatSettings[roomId].primaryColor)
              : Colors.grey;
        }

        return Colours.hashedColor(roomId);
      }(),
      onSelectPrimaryColor: (color) {
        store.dispatch(
          updateRoomPrimaryColor(roomId: roomId, color: color),
        );
      },
      onToggleDirectRoom: () {
        final room = roomSelectors.room(id: roomId, state: store.state);
        store.dispatch(toggleDirectRoom(room: room, enabled: !room.direct));
      });
}
