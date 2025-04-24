import 'dart:typed_data';

import 'package:fluffychat/pages/chat/events/custom/matrix_client_extension.dart';
import 'package:fluffychat/pages/new_group/new_group_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart' as sdk;
import 'package:matrix/matrix.dart';

import 'package:fluffychat/utils/file_selector.dart';
import 'package:fluffychat/widgets/matrix.dart';

class NewGroup extends StatefulWidget {
  final CreateGroupType createGroupType;
  const NewGroup({
    this.createGroupType = CreateGroupType.group,
    super.key,
  });

  @override
  NewGroupController createState() => NewGroupController();
}

class NewGroupController extends State<NewGroup> {
  final nameEditController = TextEditingController();
  final descriptionEditController = TextEditingController();

  bool publicGroup = true;
  bool groupCanBeFound = true;

  Uint8List? avatar;

  Uri? avatarUrl;

  Object? error;

  bool loading = false;

  CreateGroupType get createGroupType =>
      _createGroupType ?? widget.createGroupType;

  CreateGroupType? _createGroupType;

  void setCreateGroupType(Set<CreateGroupType> b) =>
      setState(() => _createGroupType = b.single);

  void setPublicGroup(bool b) =>
      setState(() => publicGroup = groupCanBeFound = b);

  void setGroupCanBeFound(bool b) => setState(() => groupCanBeFound = b);

  var canGoNext = false;

  void selectPhoto() async {
    final photo = await selectFiles(
      context,
      type: FileSelectorType.images,
      allowMultiple: false,
    );
    final bytes = await photo.singleOrNull?.readAsBytes();

    setState(() {
      avatarUrl = null;
      avatar = bytes;
      checkCanContinue();
    });
  }

  Future<void> _createGroup() async {
    if (!mounted) return;
    // <thai.tran> here is custom method `createGroupChatWithDescription`
    final roomId = await Matrix.of(context).client.createGroupChatWithDescription(
      groupName: nameEditController.text,
      groupDescription: descriptionEditController.text,
      visibility:
          groupCanBeFound ? sdk.Visibility.public : sdk.Visibility.private,
      preset: publicGroup
          ? sdk.CreateRoomPreset.publicChat
          : sdk.CreateRoomPreset.privateChat,
      initialState: [
        if (avatar != null)
          sdk.StateEvent(
            type: sdk.EventTypes.RoomAvatar,
            content: {'url': avatarUrl.toString()},
          ),
      ],
    );
    if (!mounted) return;
    context.go('/rooms/$roomId/invite');
  }

  Future<void> _createSpace() async {
    if (!mounted) return;
    final spaceId = await Matrix.of(context).client.createRoom(
          preset: publicGroup
              ? sdk.CreateRoomPreset.publicChat
              : sdk.CreateRoomPreset.privateChat,
          creationContent: {'type': RoomCreationTypes.mSpace},
          visibility: publicGroup ? sdk.Visibility.public : null,
          roomAliasName: publicGroup
              ? nameEditController.text.trim().toLowerCase().replaceAll(' ', '_')
              : null,
          name: nameEditController.text.trim(),
          powerLevelContentOverride: {'events_default': 100},
          initialState: [
            if (avatar != null)
              sdk.StateEvent(
                type: sdk.EventTypes.RoomAvatar,
                content: {'url': avatarUrl.toString()},
              ),
          ],
        );
    if (!mounted) return;
    context.pop<String>(spaceId);
  }

  checkCanContinue() {
    setState(() {
      canGoNext = nameEditController.text.isNotEmpty
          && descriptionEditController.text.isNotEmpty
          && (avatar != null || avatarUrl != null);
    });
  }
  Future submitAction([_]) async {
    final client = Matrix.of(context).client;

    try {
      if (nameEditController.text.trim().isEmpty &&
          createGroupType == CreateGroupType.space) {
        setState(() => error = L10n.of(context).pleaseFillOut);
        return;
      }

      setState(() {
        loading = true;
        error = null;
      });

      final avatar = this.avatar;
      avatarUrl ??= avatar == null ? null : await client.uploadContent(avatar);

      if (!mounted) return;

      switch (createGroupType) {
        case CreateGroupType.group:
          await _createGroup();
        case CreateGroupType.space:
          await _createSpace();
      }
    } catch (e, s) {
      sdk.Logs().d('Unable to create group', e, s);
      setState(() {
        error = e;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => NewGroupScreen(this) /*NewGroupView(this)*/;
}

enum CreateGroupType { group, space }
