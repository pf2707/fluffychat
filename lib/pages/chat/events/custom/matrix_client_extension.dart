
import 'package:matrix/matrix.dart';

extension MatrixClientExtension on Client {

  /// An upgraded of method to create a new group chat which has a description. By default it is a private
  /// chat. The encryption is enabled if this client supports encryption and
  /// the preset is not a public chat.
  Future<String> createGroupChatWithDescription({
    required String groupName,
    required String groupDescription,
    bool? enableEncryption,
    List<String>? invite,
    CreateRoomPreset preset = CreateRoomPreset.privateChat,
    List<StateEvent>? initialState,
    Visibility? visibility,
    HistoryVisibility? historyVisibility,
    bool waitForSync = true,
    bool groupCall = false,
    bool federated = true,
    Map<String, dynamic>? powerLevelContentOverride,
  }) async {
    enableEncryption ??=
        encryptionEnabled && preset != CreateRoomPreset.publicChat;
    if (enableEncryption) {
      initialState ??= [];
      if (!initialState.any((s) => s.type == EventTypes.Encryption)) {
        initialState.add(
          StateEvent(
            content: {
              'algorithm': Client.supportedGroupEncryptionAlgorithms.first,
            },
            type: EventTypes.Encryption,
          ),
        );
      }
    }
    if (historyVisibility != null) {
      initialState ??= [];
      if (!initialState.any((s) => s.type == EventTypes.HistoryVisibility)) {
        initialState.add(
          StateEvent(
            content: {
              'history_visibility': historyVisibility.text,
            },
            type: EventTypes.HistoryVisibility,
          ),
        );
      }
    }
    if (groupCall) {
      powerLevelContentOverride ??= {};
      powerLevelContentOverride['events'] ??= {};
      powerLevelContentOverride['events'][EventTypes.GroupCallMember] ??=
          powerLevelContentOverride['events_default'] ?? 0;
    }

    final roomId = await createRoom(
      creationContent: federated ? null : {'m.federate': false},
      invite: invite,
      preset: preset,
      name: groupName,
      initialState: initialState,
      visibility: visibility,
      topic: groupDescription,
      powerLevelContentOverride: powerLevelContentOverride,
    );

    if (waitForSync) {
      if (getRoomById(roomId) == null) {
        // Wait for room actually appears in sync
        await waitForRoomInSync(roomId, join: true);
      }
    }
    return roomId;
  }
}