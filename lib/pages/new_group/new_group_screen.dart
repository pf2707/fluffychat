import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:fluffychat/widgets/layouts/primary_button.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluffychat/pages/new_group/new_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewGroupScreen extends StatefulWidget {
  final NewGroupController controller;

  const NewGroupScreen(this.controller, {super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Center(
            child: BackButton(
              onPressed: widget.controller.loading ? null : Navigator.of(context).pop,
            ),
          ),
          title: Text(L10n.of(context).createGroup,),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => widget.controller.selectPhoto(),
                        child: SizedBox(
                          width: 100, height: 100,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  width: double.infinity, height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5FF),
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(color: const Color(0xFFEAEAEA))
                                  ),
                                  child: widget.controller.avatar != null ?
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    child: Image.memory(widget.controller.avatar!, fit: BoxFit.cover,),
                                  ) :
                                  Center(
                                    child: SvgPicture.asset('assets/svg/avatar_group_default.svg'),
                                  ),
                                )
                              ),
                              Positioned(
                                right: 11, bottom: 0, width: 24, height: 24,
                                child: SvgPicture.asset('assets/svg/ic_change_avatar.svg'),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      //Group name
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              L10n.of(context).groupName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 48, width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                controller: widget.controller.nameEditController,
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: L10n.of(context).hintInputGroupName,
                                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) => widget.controller.checkCanContinue(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      //Group description
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              L10n.of(context).description,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 60, width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                controller: widget.controller.descriptionEditController,
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: L10n.of(context).hintInputGroupDescription,
                                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                textAlignVertical: TextAlignVertical.top,
                                maxLines: 10,
                                keyboardType: TextInputType.multiline,
                                onChanged: (text) => widget.controller.checkCanContinue(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10n.of(context).groupType,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),

                            //Public
                            _radioForGroupType(context, true),
                            const SizedBox(height: 12,),
                            _radioForGroupType(context, false),
                          ],
                        ),
                      ),

                      //Group members
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: Column(
                      //     children: [
                      //       SingleChildScrollView(
                      //         child: Row(
                      //           children: [
                      //             Text(
                      //               L10n.of(context).groupType,
                      //               style: const TextStyle(fontWeight: FontWeight.w600),
                      //             ),
                      //             const SizedBox(height: 12),
                      //             SizedBox(
                      //               width: double.infinity, height: 66,
                      //               child: SingleChildScrollView(
                      //                 child: Row(
                      //                   mainAxisAlignment: MainAxisAlignment.start,
                      //                   children: [
                      //
                      //                   ],
                      //                 ),
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       )
                      //     ],
                      //   )
                      // ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15,),

              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: PrimaryButton(
                    title: L10n.of(context).create,
                    enableStatus: widget.controller.canGoNext,
                    action: () => _submit(context),
                  ),
                ),
              ),

              const SizedBox(height: 5,),
            ],
          ),
        ),
      ),
    );
  }

  _radioForGroupType(BuildContext context, bool isPublic) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (isPublic) {
          if (!widget.controller.publicGroup) {
            setState(() {
              widget.controller.setPublicGroup(true);
            });
          }
        } else {
          if (widget.controller.publicGroup) {
            setState(() {
              widget.controller.setPublicGroup(false);
            });
          }
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((isPublic && widget.controller.publicGroup) || (!isPublic && !widget.controller.publicGroup))
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.onPrimaryContainer, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),

            const SizedBox(width: 12,),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPublic ? L10n.of(context).groupTypePublic : L10n.of(context).groupTypePrivate,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isPublic ? L10n.of(context).groupTypePublicCaption : L10n.of(context).groupTypePrivateCaption,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _submit(BuildContext context) async {
    await showFutureLoadingDialog(context: context, future: () => widget.controller.submitAction());
  }
  // _memberItem() {
  //   return SizedBox(
  //     width: 60, height: double.infinity,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //
  //       ],
  //     ),
  //   );
  // }
}
