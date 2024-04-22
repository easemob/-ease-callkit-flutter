import 'package:em_chat_callkit/chat_callkit_define.dart';

import 'chat_callkit_call.dart';
import 'tools/chat_callkit_tools.dart';

class ChatCallKitCallModel {
  ChatCallKitCall? curCall;
  String curDevId;

  String? agoraRTCToken;
  bool hasJoined;
  int? agoraUid;
  ChatCallKitStateChange? stateChanged;
  ChatCallKitCallState _state;
  Map<String, ChatCallKitCall> recvCalls;

  ChatCallKitCallModel({
    this.curCall,
    Map<String, ChatCallKitCall>? recvCalls,
    this.agoraRTCToken,
    ChatCallKitCallState state = ChatCallKitCallState.idle,
    this.hasJoined = false,
    this.agoraUid,
    String? curDevId,
    this.stateChanged,
  })  : curDevId = curDevId ?? ChatCallKitTools.randomStr,
        _state = state,
        recvCalls = recvCalls ?? {};

  set state(ChatCallKitCallState state) {
    if (_state == state) return;
    stateChanged?.call(state, _state);
    _state = state;
  }

  ChatCallKitCallState get state => _state;
}
