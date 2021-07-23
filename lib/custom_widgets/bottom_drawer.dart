import 'package:cyclopath/draggable/delivering_sheet.dart';
import 'package:cyclopath/draggable/offline_sheet.dart';
import 'package:cyclopath/draggable/returning_sheet.dart';
import 'package:cyclopath/draggable/waiting_sheet.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BottomDrawerDestinations extends StatelessWidget {
  const BottomDrawerDestinations({
    required this.panelController,
    required this.fabHeight,
    required this.scrollController,
    required this.getCurrentLocation(),
    required this.setCameraToRoute(),
  });

  final PanelController panelController;
  final double fabHeight;
  final ScrollController scrollController;
  final VoidCallback getCurrentLocation;
  final VoidCallback setCameraToRoute;

  Widget _showBottomSheet({
    required PanelController panelController,
    required UserSessionType selectedUserSessionType,
    required VoidCallback getCurrentLocation,
  }) {
    switch (selectedUserSessionType) {
      case UserSessionType.offline:
        return OfflineSheet(
          panelController: panelController,
        );
      case UserSessionType.delivering:
        return DeliveringSheet(
          panelController: panelController,
          setCameraToRoute: setCameraToRoute,
        );
      case UserSessionType.returning:
        return ReturningSheet(
          panelController: panelController,
          setCameraToRoute: setCameraToRoute,
        );

      default:
        return WaitingSheet(
          panelController: panelController,
          setCameraToRoute: setCameraToRoute,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserSessionType = context
        .select((UserSession session) => session.selectedUserSessionType);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        // physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        children: <Widget>[
          const SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),

          //GestureDetector seems to only work with ListView
          GestureDetector(
            onTap: () => panelController.panelPosition >= 0.1
                ? panelController.close()
                : panelController.open(),
            child: _showBottomSheet(
              selectedUserSessionType: selectedUserSessionType,
              panelController: panelController,
              getCurrentLocation: getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}
