import 'dart:async';

import 'package:fluffychat/config/routes.dart';
import 'package:fluffychat/pages/chat/events/custom/share_contacts_impl.dart';
import 'package:fluffychat/pages/invitation_selection/invitation_selection_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/pages/invitation_selection/invitation_selection_view.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../utils/localized_exception_extension.dart';

enum InvitationMode {
  joinGroup,
  shareContact,
}

class InvitationSelection extends StatefulWidget {
  final String roomId;
  final InvitationMode mode;
  const InvitationSelection({
    super.key,
    required this.roomId,
    this.mode = InvitationMode.joinGroup,
  });

  @override
  InvitationSelectionController createState() =>
      InvitationSelectionController();
}

class InvitationSelectionController extends State<InvitationSelection> {
  TextEditingController controller = TextEditingController();
  late String currentSearchTerm;
  bool loading = false;
  List<Profile> foundProfiles = [];
  Timer? coolDown;

  final selectedUsers = <String, Profile>{};

  updateUserSelection(Profile user) {
    setState(() {
      if (selectedUsers[user.userId] != null) {
        selectedUsers.remove(user.userId);
      } else {
        selectedUsers[user.userId] = user;
      }
    });
  }

  String? get roomId => widget.roomId;
  Future<List<User>> getContacts(BuildContext context) async {
    final client = Matrix.of(context).client;
    final room = client.getRoomById(roomId!)!;

    final participants = (room.summary.mJoinedMemberCount ?? 0) > 100
        ? room.getParticipants()
        : await room.requestParticipants();
    participants.removeWhere(
      (u) => ![Membership.join, Membership.invite].contains(u.membership),
    );
    final contacts = client.rooms
        .where((r) => r.isDirectChat)
        .map((r) => r.unsafeGetUserFromMemoryOrFallback(r.directChatMatrixID!))
        .toList();
    contacts.sort(
      (a, b) => a.calcDisplayname().toLowerCase().compareTo(
            b.calcDisplayname().toLowerCase(),
          ),
    );
    return contacts;
  }

  void inviteAction(BuildContext context, String id, String displayname) async {
    final room = Matrix.of(context).client.getRoomById(roomId!)!;

    final success = await showFutureLoadingDialog(
      context: context,
      future: () => room.invite(id),
    );
    if (success.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context).contactHasBeenInvitedToTheGroup),
        ),
      );
    }
  }

  _inviteMultipleUsersAction(BuildContext context) async {
    if (selectedUsers.isEmpty) {
      return;
    }
    final room = Matrix.of(context).client.getRoomById(roomId!)!;

    showFutureLoadingDialog(
      context: context,
      future: () async {
        Future.forEach(selectedUsers.values, (user) {
          room.invite(user.userId);
        });
      },
    );
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context).contactHasBeenInvitedToTheGroup),
      ),
    );
  }

  _sendShareContactsMessage(List<Profile> contacts) async {
    if (selectedUsers.isEmpty) {
      return;
    }
    final room = Matrix.of(context).client.getRoomById(roomId!)!;

    await showFutureLoadingDialog(
      context: context,
      future: () => ShareContactsImpl.sendMessage(context, room, contacts),
    );
    context.pop();
  }

  nextAction(BuildContext context) {
    if (widget.mode == InvitationMode.shareContact) {
      _sendShareContactsMessage(selectedUsers.values.toList());
    } else {
      _inviteMultipleUsersAction(context);
    }
  }

  void searchUserWithCoolDown(String text) async {
    coolDown?.cancel();
    coolDown = Timer(
      const Duration(milliseconds: 500),
      () => searchUser(context, text),
    );
  }

  void searchUser(BuildContext context, String text) async {
    coolDown?.cancel();
    if (text.isEmpty) {
      setState(() => foundProfiles = []);
    }
    currentSearchTerm = text;
    if (currentSearchTerm.isEmpty) return;
    if (loading) return;
    setState(() => loading = true);
    final matrix = Matrix.of(context);
    SearchUserDirectoryResponse response;
    try {
      response = await matrix.client.searchUserDirectory(text, limit: 10);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((e).toLocalizedString(context))),
      );
      return;
    } finally {
      setState(() => loading = false);
    }
    setState(() {
      foundProfiles = List<Profile>.from(response.results);
      if (text.isValidMatrixId &&
          foundProfiles.indexWhere((profile) => text == profile.userId) == -1) {
        setState(
          () => foundProfiles = [
            Profile.fromJson({'user_id': text}),
          ],
        );
      }
    });
  }

  @override
  // Widget build(BuildContext context) => InvitationSelectionView(this);
  Widget build(BuildContext context) => InvitationSelectionScreen(this);
}
