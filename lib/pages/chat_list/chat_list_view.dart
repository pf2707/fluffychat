import 'package:fluffychat/config/app_config.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/widgets/navigation_rail.dart';
import 'chat_list_body.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;

  const ChatListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !controller.isSearchMode && controller.activeSpaceId == null,
      onPopInvokedWithResult: (pop, _) {
        if (pop) return;
        if (controller.activeSpaceId != null) {
          controller.clearActiveSpace();
          return;
        }
        if (controller.isSearchMode) {
          controller.cancelSearch();
          return;
        }
      },
      child: Row(
        children: [
          if (FluffyThemes.isColumnMode(context) &&
              controller.widget.displayNavigationRail) ...[
            SpacesNavigationRail(
              activeSpaceId: controller.activeSpaceId,
              onGoToChats: controller.clearActiveSpace,
              onGoToSpaceId: controller.setActiveSpace,
            ),
            Container(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ],
          Expanded(
            child: GestureDetector(
              onTap: FocusManager.instance.primaryFocus?.unfocus,
              excludeFromSemantics: true,
              behavior: HitTestBehavior.translucent,
              child: Scaffold(
                body: ChatListViewBody(controller),
                floatingActionButton: !controller.isSearchMode &&
                        controller.activeSpaceId == null
                    ? TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      onPressed: () => context.go('/rooms/newprivatechat'),
                      child: Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.all(Radius.circular(30))
                        ),
                        child: Center(
                          child: SvgPicture.asset('assets/svg/ic_message_big.svg'),
                        ),
                      ),
                    )
                    // ? FloatingActionButton.extended(
                    //     backgroundColor: AppConfig.primaryColor,
                    //     onPressed: () => context.go('/rooms/newprivatechat'),
                    //     icon: SvgPicture.asset('assets/svg/ic_message.big.svg'), //const Icon(Icons.add_outlined),
                    //     label: Text(
                    //       L10n.of(context).chat,
                    //       overflow: TextOverflow.fade,
                    //     ),
                    //   )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
