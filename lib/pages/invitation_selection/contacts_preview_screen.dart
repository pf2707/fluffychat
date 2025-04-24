
import 'package:fluffychat/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ContactsPreviewScreen extends StatelessWidget {

  final List<Profile> contacts;
  const ContactsPreviewScreen({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: BackButton()),
        titleSpacing: 0,
        title: Text(L10n.of(context).contacts),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int i) =>
          _InviteContactListTile(
            profile: contacts[i],
            onTap: (contact) => showAdaptiveBottomSheet(
              context: context,
              builder: (c) => UserBottomSheet(
                profile: contact,
                outerContext: context,
              ),
            ),
          ),
      ),
    );
  }
}

class _InviteContactListTile extends StatelessWidget {
  final Profile profile;
  final void Function(Profile) onTap;

  const _InviteContactListTile({
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    return ListTile(
      leading: Avatar(
        mxContent: profile.avatarUrl,
        name: profile.displayName,
        presenceUserId: profile.userId,
        size: 44,
      ),
      title: Text(
        profile.displayName ?? profile.userId.localpart ?? l10n.user,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        profile.userId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.colorScheme.secondary,
        ),
      ),
      onTap: () => onTap(profile),
    );
  }
}
