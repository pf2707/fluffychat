import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/client_chooser_button.dart';
import 'package:fluffychat/utils/sync_status_localization.dart';
import '../../widgets/matrix.dart';

class ChatListHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatListController controller;
  final bool globalSearch;

  const ChatListHeader({
    super.key,
    required this.controller,
    this.globalSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = Matrix.of(context).client;

    return SliverAppBar(
      floating: true,
      toolbarHeight: 72,
      pinned: FluffyThemes.isColumnMode(context),
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          SvgPicture.asset('assets/svg/logo.svg'),
          const SizedBox(width: 10),
          Expanded(
            child: StreamBuilder(
              stream: client.onSyncStatus.stream,
              builder: (context, snapshot) {
                final status = client.onSyncStatus.value ??
                    const SyncStatusUpdate(SyncStatus.waitingForResponse);
                final hide = client.onSync.value != null &&
                    status.status != SyncStatus.error &&
                    client.prevBatch != null;
                return SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.searchController,
                    focusNode: controller.searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (text) => controller.onSearchEnter(
                      text,
                      globalSearch: globalSearch,
                    ),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.secondaryContainer,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        contentPadding: EdgeInsets.zero,
                        hintText: hide
                            ? L10n.of(context).searchChatsRooms
                            : status.calcLocalizedString(context),
                        hintStyle: TextStyle(
                          color: status.error != null
                              ? theme.colorScheme.error
                              : theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: hide
                            ? controller.isSearchMode
                            ? IconButton(
                          tooltip: L10n.of(context).cancel,
                          icon: const Icon(Icons.close_outlined),
                          onPressed: controller.cancelSearch,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                            : IconButton(
                          onPressed: controller.startSearch,
                          icon: Icon(
                            Icons.search_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                            : Container(
                          margin: const EdgeInsets.all(12),
                          width: 8,
                          height: 8,
                          child: Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              value: status.progress,
                              valueColor: status.error != null
                                  ? AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.error,
                              )
                                  : null,
                            ),
                          ),
                        ),
                        suffixIcon: controller.isSearchMode && globalSearch
                            ? controller.isSearching
                            ? const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12,
                          ),
                          child: SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                            : TextButton.icon(
                          onPressed: controller.setServer,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(
                            controller.searchServer ??
                                Matrix.of(context).client.homeserver!.host,
                            maxLines: 2,
                          ),
                        )
                            : const SizedBox()
                      /// <thai tran> Hide - Figma doesn't have it
                      // : SizedBox(
                      //   width: 0,
                      //   child: ClientChooserButton(controller),
                      // ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.sizeOf(context).width, 1),
        child: const Divider(height: 1, color: Color(0xFFE6E6E6)),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
          onPressed: () {},
          child: SizedBox(
            height: 40,
            child: SvgPicture.asset('assets/svg/ic_phone.svg'),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
          onPressed: () {},
          child: SizedBox(
            width: 24, height: 40,
            child: Center(
              child: SvgPicture.asset('assets/svg/ic_three_dots.svg'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
