
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatFunctionPicker extends StatelessWidget {
  final ChatController controller;
  const ChatFunctionPicker(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      height: controller.showFunctionToolPicker
          ? 262
          : 0,
      child: controller.showFunctionToolPicker
          ? Container(
            width: double.infinity, height: 262,
            padding: const EdgeInsets.only(left: 60, right: 60, top: 30),
            child: StaggeredGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 30,
              children: [
                for (final tool in controller.functionTools)
                  StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => controller.onAddPopupMenuButtonSelected(tool),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 75,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: tool.backgroundColor(),
                                  borderRadius: const BorderRadius.all(Radius.circular(25))
                                ),
                                child: Center(
                                  child: SvgPicture.asset('assets/svg/${tool.icon()}'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tool.title(),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF262626)),
                              )
                            ],
                          )
                        ),
                      )
                  ),
              ],
            ),
          )
          : null,
    );
  }
}