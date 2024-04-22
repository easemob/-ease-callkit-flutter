import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:em_chat_callkit/chat_callkit.dart';
import 'package:em_chat_callkit/inherited/chat_callkit_manager_impl.dart';

class ChatCallKitManager {
  static ChatCallKitManagerImpl get _impl => ChatCallKitManagerImpl.instance;

  /// Initiate a 1v1 call.
  ///
  /// Param [userId] called user id.
  ///
  /// Param [type] call type, see [ChatCallKitCallType].
  ///
  /// Param [ext] additional information.
  ///
  static Future<String> startSingleCall(
    String userId, {
    String? inviteMessage,
    ChatCallKitCallType type = ChatCallKitCallType.audio_1v1,
    Map<String, String>? ext,
  }) {
    return _impl.startSingleCall(userId, type: type, ext: ext, inviteMessage: inviteMessage);
  }

  /// Initiate a multi-party call invitation.
  ///
  /// Param [userIds] Invited user.
  ///
  /// Param [ext] additional information.
  ///
  static Future<String> startInviteUsers(
    List<String> userIds, {
    String? inviteMessage,
    Map<String, String>? ext,
  }) {
    return _impl.startInviteUsers(userIds, inviteMessage, ext);
  }

  /// Initializes the rtc engine, which needs to be called before the call is established,
  /// and has a one-to-one correspondence with [releaseRTC].
  static Future<void> initRTC() {
    return _impl.initRTC();
  }

  /// release rtc engine. You are advised to call it after the call is over.
  /// The release relationship must be one-to-one with [initRTC].
  static Future<void> releaseRTC() {
    return _impl.releaseRTC();
  }

  /// Answer the call.
  ///
  /// Param [callId] the received call id.
  static Future<void> answer(String callId) {
    return _impl.answer(callId);
  }

  /// Hangup the call.
  ///
  /// Param [callId] the received call id.
  static Future<void> hangup(String callId) {
    return _impl.hangup(callId);
  }

  /// Turn on the camera, when you call it, the other party will receive
  /// a [ChatCallKitObserver.onUserMuteVideo] callback.
  static Future<void> cameraOn() async {
    await _impl.startPreview();
  }

  /// Turn off the camera, when you call it, the other party will receive
  /// a [ChatCallKitObserver.onUserMuteVideo] callback.
  static Future<void> cameraOff() async {
    await _impl.stopPreview();
  }

  /// Switch front and rear cameras.
  static Future<void> switchCamera() {
    return _impl.switchCamera();
  }

  /// Get the local capture screen widget.
  static AgoraVideoView? getLocalVideoView() {
    return _impl.getLocalVideoView();
  }

  /// Get the remote capture screen widget.
  ///
  /// Param [agoraUid] The agoraUid to be obtained. The user specifies which agoraUid the window to obtain belongs to.
  static AgoraVideoView? getRemoteVideoView(int agoraUid) {
    return _impl.getRemoteVideoView(agoraUid);
  }

  /// Mute, mute the other party can not hear you, when you mute,
  /// the other party will receive [ChatCallKitObserver.onUserMuteAudio] callback.
  static Future<void> mute() {
    return _impl.mute();
  }

  /// Unmute. When unmute, the other party can hear your voice. When you call unmute,
  /// the other party will receive a [ChatCallKitObserver.onUserMuteAudio] callback.
  static Future<void> unMute() {
    return _impl.unMute();
  }

  /// Turn on the speaker.
  static Future<void> speakerOn() {
    return _impl.speakerOn();
  }

  /// Turn off the speaker.
  static Future<void> speakerOff() {
    return _impl.speakerOff();
  }

  /// Set agoraToken handler to get agora tokens when agora_chat_callkit is needed.
  ///
  /// Param [handler] see [RtcTokenHandler].
  static void setRTCTokenHandler(RtcTokenHandler handler) {
    _impl.rtcTokenHandler = handler;
  }

  /// Set up the handler for the agoraUid and userId mapping to obtain the agora token when needed by agora_chat_callkit.
  ///
  /// Param [handler] see [UserMapperHandler].
  static void setUserMapperHandler(UserMapperHandler handler) {
    _impl.userMapperHandler = handler;
  }

  /// Add event listener
  ///
  /// Param [identifier] The custom handler identifier, is used to find the corresponding handler.
  ///
  /// Param [handler] The handle for callkit event. See [ChatCallKitObserver].
  static void addObserver(
    ChatCallKitObserver handler,
  ) {
    _impl.addEventListener(handler);
  }

  /// Remove the callkit event handler.
  ///
  /// Param [identifier] The custom handler identifier.
  static void removeObserver(ChatCallKitObserver handler) {
    _impl.removeEventListener(handler);
  }

  /// Remove all callkit event handler.
  ///
  static void clearAllEventListeners() {
    _impl.clearAllEventListeners();
  }
}
