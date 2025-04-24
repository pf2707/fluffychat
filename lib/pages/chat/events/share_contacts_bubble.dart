
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/events/custom/share_contacts_impl.dart';
import 'package:fluffychat/pages/invitation_selection/contacts_preview_screen.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ShareContactsBubble extends StatelessWidget {
  final Event event;
  final bool tapToView;
  final Color? backgroundColor;
  final Color? textColor;
  final bool animated;
  final BorderRadius? borderRadius;
  final Timeline? timeline;

  const ShareContactsBubble(
    this.event, {
    this.tapToView = true,
    this.animated = false,
    this.borderRadius,
    this.timeline,
    this.textColor,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(AppConfig.borderRadius);

    final contacts = ShareContactsImpl.getListOfSharedContacts(event);

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
      ),
      child: InkWell(
        onTap: () => _onTap(context, contacts),
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _avatars(contacts),
                const SizedBox(width: 8,),
                Expanded(
                  child: _content(context, contacts),
                ),
              ],
            ),
            const SizedBox(height: 5,),
            Divider(color: theme.primaryColorLight, thickness: 1,),
            Center(
              child: Text(
                L10n.of(context).viewAll,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor ?? Colors.white,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatars(List<Profile> contacts) {
    final shownAvatars = contacts.take(3).toList();
    final reversedList = shownAvatars.reversed.toList();
    const avatarWidth = 30.0;
    final totalWidth = avatarWidth + (reversedList.length - 1) * avatarWidth / 2;
    var leftOffset = totalWidth - avatarWidth / 2;
    return SizedBox(
      height: avatarWidth, width: totalWidth,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          for (int i = 0; i < reversedList.length; i++)
            Positioned(
              left: leftOffset -= (avatarWidth / 2), top: 0,
              child: Avatar(mxContent: reversedList[i].avatarUrl, size: avatarWidth, name: reversedList[i].displayName,),
            ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, List<Profile> contacts) {
    final firstUserName = contacts.first.displayName ?? "";
    final content = contacts.length > 2 ?
    "$firstUserName ${L10n.of(context).andOtherNContact(contacts.length - 1)}" :
    "$firstUserName ${L10n.of(context).andOtherOneContact}";
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: textColor ?? Colors.white),
    );
  }

  void _onTap(BuildContext context, List<Profile> contacts) async {
    if (!tapToView) return;
    await showAdaptiveDialog(
    context: context,
    builder: (c) => SizedBox(
      width: double.infinity, height: double.infinity,
      child: ContactsPreviewScreen(contacts: contacts),),
    );
  }
}
