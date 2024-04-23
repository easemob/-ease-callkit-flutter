# Get Started with Agora Chat CallKit for Flutter

`em_chat_callkit` is a video and audio component library built on top of `im_flutter_sdk` and `agora_rtc_engine`. It provides logical modules for making and receiving calls, including one-to-one voice calls, one-to-one video calls, group audio calls, and group video calls. It uses `em_chat_callkit` to handle call invitations and negotiations. After negotiations are complete, the `ChatCallKitManager.setRTCTokenHandler` callback is triggered, and the Agora RTC token needs to be returned. The Agora RTC token must be provided by the developer.

## Understand the tech

For a call, the call invitation is implemented via Agora Chat, while the call is made through Agora RTC. As the accounts of Agora RTC and Agora Chat are not globally recognizable at present, the accounts need to be mapped via the `ChatCallKitManager.setUserMapperHandler` callback in `em_chat_callkit`. When a user joins the call, the Agora RTC user ID (UID) will be returned via the callback. After you get the corresponding Agora Chat user ID, you need to return it to `em_chat_callkit`. If there is no mapping between the two user IDs, the call will not proceed properly. See `ChatCallKitUserMapper`.

This section describes how to implement a one-to-one call or group call.

<div class="alert note">The `ChatCallKitManager.initRTC` method is called before a call is made or answered.</div>

The basic process for implementing a one-to-one audio or video call is as follows:

1. The caller calls the `ChatCallKitManager.startSingleCall` method to invite the callee to join the call.
2. The callee receives the call invitation through the `ChatCallKitObserver.onReceiveCall` callback and handles the call:
   - To answer the call, the callee calls the `ChatCallKitManager.answer` method. The other party receives the `ChatCallKitObserver.onUserJoined` event and the call starts.
   - To hang up the call, the callee calls the `ChatCallKitManager.releaseRTC` method. The other party receives the `ChatCallKitObserver.onCallEnd` event.

The basic process for implementing a group audio or video call is as follows:

1. The caller calls the `ChatCallKitManager.startInviteUsers` method to invite multiple users to join the call. 
2. The callee receives the call invitation through the `ChatCallKitObserver.onReceiveCall` event and handles the call:
  - To answer the call, the callee calls the `ChatCallKitManager.answer` method. The other parties receive the `ChatCallKitObserver.onUserJoined` event and the call starts.
  - To hang up the call, the callee calls the `ChatCallKitManager.releaseRTC` method. Group calls do not end automatically, and therefore the users need to call this method to hang up the call.

<div class="alert note">When users join or leave the call, the UI should be modified accordingly.</div>

## Prerequisites

In order to follow the procedure in this page, you must have the following:

- A valid Agora [account](https://docs.agora.io/en/video-calling/reference/manage-agora-account/#create-an-agora-account)
- An Agora [project](https://docs.agora.io/en/video-calling/reference/manage-agora-account/#create-an-agora-project) with an [App Key](https://doc.easemob.com/product/enable_and_configure_IM.html).

If your target platform is iOS, your development environment must meet the following requirements:
- Flutter 3.3.0 or later
- Dart >=3.0.0 <4.0.0
- macOS
- Xcode 12.4 or later with Xcode Command Line Tools
- CocoaPods
- An iOS simulator or a real iOS device running iOS 10.0 or later

If your target platform is Android, your development environment must meet the following requirements:
- Flutter 3.3.0 or later
- Dart >=3.0.0 <4.0.0
- macOS or Windows
- Android Studio 4.0 or later with JDK 1.8 or later
- An Android simulator or a real Android device running Android SDK API level 21 or later

<div class="alert note">You can run <code>flutter doctor</code> to see if there are any platform dependencies you need to complete the setup.</div>

## Project setup

### Add the dependencies

Add the following dependencies in `pubspec.yaml`:

```sh
  im_flutter_sdk: ^4.2.0
  agora_rtc_engine: ^6.3.0
```

### Add project permissions

#### Android

```
<manifest>
...
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<!-- The Agora SDK requires Bluetooth permissions in case users are using Bluetooth devices.-->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WAKE_LOCK"/>
...
</manifest>
```

#### iOS

Add the following lines to **info.plist**:


|Key|Type|Value|
---|---|---
`Privacy - Microphone Usage Description` | String | For microphone access
`Privacy - Camera Usage Description` | String | For camera access


### Prevent code obfuscation

In the example/android/app/proguard-rules.pro file, add the following lines to prevent code obfuscation: </application>

```
-keep class com.hyphenate.** {*;}
-dontwarn  com.hyphenate.**
```


## Implement audio and video calling

You need to make sure that the Agora Chat SDK is initialized before calling ChatCallKit and ChatCallKit widget at the top of your widget tree. You can add it in the `MaterialApp` builder.

```
import 'package:em_chat_callkit/chat_callkit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child){
         return ChatCallKit(
            agoraAppId: <--Add Your Agora App Id Here-->,
            child: child!,
          );
      },
      home: const MyHomePage(title: 'Flutter Demo'),
    );
  }
}
```

### Add the Agora token callback

Agora RTC needs a token and a channel ID to join a channel. Therefore, the two parameters are required when `em_chat_callkit` is used. `em_chat_callkit` gets the two parameters from the `ChatCallKitManager.setRTCTokenHandler` callback.

```
// channel: The channel to join.
// agoraAppId: The Agora app ID.
// agoraUid: The user ID (UID) of Agora RTC.
ChatCallKitManager.setRTCTokenHandler((channel, agoraAppId, agoraUid) {
  // agoraToken: The token of the Agora RTC user.
  // agoraUid: The user ID of Agora RTC.
  return Future(() => {agoraToken, agoraUid});
});
```

### Add the user mapping callback

Set the callback of the mapping between the Agora RTC user ID and Agora Chat user ID.

```
// channel: The channel to which the Agora RTC user ID belongs.
// agoraUid: The Agora RTC user ID that corresponds to the Agora Chat user ID.
ChatCallKitManager.setUserMapperHandler((channel, agoraUid) {
  // channel: The channel to which the Agora RTC user ID belongs.
  // agoraUid: The Agora RTC user ID that corresponds to the Agora Chat user ID.
  // userId: The Agora Chat user ID that corresponds to the Agora RTC user ID.
  return Future(() => ChatCallKitUserMapper(channel, {agoraUid, userId}));
});
```

### Listen for callback events

Add a `ChatCallKitObserver` observer by using the `ChatCallKitManager.addObserver(this)` method. Call `ChatCallKitManager.removeObserver(this);` to remove the observer when not in use.

```dart
class _MyHomePageState extends State<MyHomePage> with ChatCallKitObserver {
  @override
  void initState() {
    super.initState();
    ChatCallKitManager.addObserver(this);
  }

  @override
  void dispose() {
    ChatCallKitManager.removeObserver(this);
    super.dispose();
  }
}
```

`ChatCallKitObserver` is described as follows:

```
abstract mixin class ChatCallKitObserver {
  /// Callback when the call fails, See [ChatCallKitError].

  void onError(ChatCallKitError error) {}

  /// Callback when the call ends, See [ChatCallKitCallEndReason].

  void onCallEnd(String? callId, ChatCallKitCallEndReason reason) {}

  /// Callback when you receive a call invitation.

  void onReceiveCall(
    String userId,
    String callId,
    ChatCallKitCallType callType,
    Map<String, String>? ext,
  ) {}

  /// Callback when the current user joins the call.

  void onJoinedChannel(String channel) {}

  /// Callback when an active user leaves.

  void onUserLeaved(int agoraUid, String? userId) {}

  /// Callback when a user joins a call.

  void onUserJoined(int agoraUid, String? userId) {}

  /// Callback when the peer's mute status changes.

  void onUserMuteAudio(int agoraUid, bool muted) {}

  /// Callback when the peer's camera status changes.

  void onUserMuteVideo(int agoraUid, bool muted) {}

  /// Callback when the user rejects the call or the call times out.

  void onUserRemoved(
      String callId, String userId, ChatCallKitCallEndReason reason) {}

  /// Callback when the call is answered.

  void onAnswer(String callId) {}
}

```

| Event             | Description                    |
| :---------------- | :----------------------- |
| final void Function(ChatCallKitError error)? onError       | Occurs when the call fails. For example, the callee fails to join the channel or the call invitation fails to be sent. The operator receives the event. This event is applicable to one-to-one calls and group calls. See `ChatCallKitError`.  |
| final void Function(String? callId, ChatCallKitCallEndReason reason)? onCallEnd | Occurs when the call ends. This event is applicable only to one-to-one calls. Both the caller and callee receive this event. See `ChatCallKitCallEndReason`.  |
| final void Function(int agoraUid, String? userId)? onUserLeaved | Occurs when an active user leaves. This event is applicable only to group calls. All other users in the call receive this event. In this event, `agoraUid` indicates the Agora RTC user ID and `userId` indicates the Agora Chat user ID. |
| final void Function(int agoraUid, String? userId)? onUserJoined | Occurs when a user joins a call. The user that joins the call receives this event. This event is applicable only to group calls. In this event, `agoraUid` indicates the Agora RTC user ID and `userId` indicates the Agora Chat user ID. |
| final void Function(String channel)? onJoinedChannel         | Occurs when the current user joins the call. This event is applicable only to group calls. All other users in the call receive this event. In this event, `channel` indicates the channel ID. |
| final void Function(String callId)? onAnswer                 | Occurs when the call is answered. This event is applicable only to one-to-one calls. Both the caller and callee receive this event. |
| final void Function(String userId, String callId, ChatCallKitCallType callType, Map<String, String>? ext)? onReceiveCall | Occurs when a call invitation is received. This event is applicable to both one-to-one calls and groups calls. The callee receives this event. In this event, `userId` indicates the Agora Chat user ID of the caller, `callId` indicates the ID of the current call, and `callType` indicates the current call type. See `ChatCallKitCallType`. |
| final void Function(int agoraUid, bool muted)? onUserMuteAudio | Occurs when the microphone status of the peer user changes. This event is applicable to both one-to-one calls and groups calls. The peer user in one-to-one calls or other users in group calls receive this event. In this event, `agoraUid` indicates the Agora RTC user ID of the peer user and `muted` indicates whether the peer microphone is muted or not. |
| final void Function(int agoraUid, bool muted)? onUserMuteVideo | Occurs when the camera status of the peer user changes. This event is applicable to both one-to-one calls and groups calls. The peer user in one-to-one calls or other users in group calls receive this event. In this event, `agoraUid` indicates the Agora RTC user ID of the peer user and `muted` indicates whether the peer camera is disabled or not. |
| final void Function(String callId, String userId, ChatCallKitCallEndReason reason)? onUserRemoved | Occurs when the callee rejects the call or the call times out. This event is applicable only to groups calls. The caller receives this event. In this event, `callId` indicates the current call ID, `userId` indicates the Agora Chat user ID of the callee, and `reason` indicates the hangup reason. See `ChatCallKitCallEndReason`. |

### Start a call

Before making or answering a call, you need to first call the `ChatCallKitManager.initRTC` method to initialize Agora RTC. 

#### Start a one-to-one call

Call the `ChatCallKitManager.startSingleCall` method to make a one-to-one call. This method returns the `callId` parameter which can be used by the caller to hang up the call. The callee receives the `onReceiveCall` event.

```dart
await ChatCallKitManager.initRTC();
try {
  // userId: The Agora Chat user ID of the callee.
  // type: The call type, which can be `ChatCallKitCallType.audio_1v1` or `ChatCallKitCallType.video_1v1`. 
  String callId = await ChatCallKitManager.startSingleCall(
    userId,
    type: ChatCallKitCallType.audio_1v1,
  );
} on ChatCallKitError catch (e) {
  ...
}
```

#### Start a group call

To make a group call, you can call the `await ChatCallKitManager.startInviteUsers` method to invite users to join
 the call. This method returns the `callId` parameter which can be used by the caller to hang up the call. The callees receive the `onReceiveCall` event.

```
await ChatCallKitManager.initRTC();
try {
  // userList: The Agora Chat user IDs of the callees.
  String callId = await ChatCallKitManager.startInviteUsers(userList);
} on ChatCallKitError catch (e) {
  ...
}
```

### Receive a call

To listen for the received call invitation, the users need to first add a `ChatCallKitObserver` observer by using the `ChatCallKitManager.addObserver(this);` method. Call `ChatCallKitManager.removeObserver(this);` to remove the observer when not in use.

In either a one-to-one call or group call, once a call invitation is sent, the callee receives the invitation in the `onReceiveCall` callback. The audio or video page can be displayed, depending on the call type.

```dart
class _MyHomePageState extends State<MyHomePage> with ChatCallKitObserver {
  @override
  void initState() {
    super.initState();
    ChatCallKitManager.addObserver(this);
  }

  @override
  void onReceiveCall(
    String userId,
    String callId,
    ChatCallKitCallType callType,
    Map<String, String>? ext,
  ) async {
    // show receive call page.
  }

  @override
  void dispose() {
    ChatCallKitManager.removeObserver(this);
    super.dispose();
  }
}
```

The callee needs to choose whether to answer or reject the call:

- To answer a call, call the `ChatCallKitManager.initRTC` method first and then the `answer` method.

In a one-to-one call, both the caller and callee receive the `onAnswer` event. In a group call, the new user that joins the call receives the `onUserJoined` event and other users in the call receive the `onJoinedChannel` event.

```
await ChatCallKitManager.initRTC();
try {
  // callId: The call ID which can be obtained from the onReceiveCall callback.
  await ChatCallKitManager.answer(callId);
} on ChatCallKitError catch (e) {
  ...
}
```

- To reject the call, call the `ChatCallKitManager.releaseRTC` method:

For a one-to-one call, the caller receives the `onError` event. For a group call, other users than the callee receive the `onUserRemoved` event.

```
try {
  // callId: The call ID which can be obtained via the `onReceiveCall` callback.
  await ChatCallKitManager.hangup(callId);
} on ChatCallKitError catch (e) {
  ...
}
await ChatCallKitManager.releaseRTC();
```

### End the call

A one-to-one call ends as soon as one of the two users hangs up, while a group call ends only after the local user hangs up.

For a one-to-one call, either the caller or callee can call the `ChatCallKitManager.releaseRTC` method to end the call. When one party ends the call, the other party receives the `onCallEnd` event.

For a group call, when a user calls the `ChatCallKitManager.releaseRTC` method to leave a call, other users in the call receive the `onUserLeaved` event.

## Next steps

### Turn on or off the speaker

You can call the `ChatCallKitManager.speakerOn` or `ChatCallKitManager.speakerOff` method to turn on or turn off the speaker during a call. 

```
await ChatCallKitManager.speakerOn();
await ChatCallKitManager.speakerOff();
```

### Mute or unmute the microphone

You can call the `ChatCallKitManager.mute` or `ChatCallKitManager.unMute` method to mute or unmute the microphone during a call. When the microphone status changes, the peer user in the one-to-one call or other users in the group call receive the `ChatCallKitObserver.onUserMuteAudio` event.

```
await ChatCallKitManager.mute();
await ChatCallKitManager.unMute();
```

### Turn on or off the camera

You can call the `ChatCallKitManager.cameraOn` or `ChatCallKitManager.cameraOff` method to turn on or turn off the camera. The peer user in the one-to-one call or other users in the group call receive the `ChatCallKitObserver.onUserMuteVideo` event.

```
await ChatCallKitManager.cameraOn();
await ChatCallKitManager.cameraOff();
```

### Switch the camera

You can call the `ChatCallKitManager.switchCamera` method to switch the front and rear cameras.

```
await ChatCallKitManager.switchCamera();
```

### Get the local preview view  

When making a one-to-one video call or group call, you can call the `ChatCallKitManager.getLocalVideoView` method to obtain the local camera preview widget.

```
Widget? localPreviewWidget = ChatCallKitManager.getLocalVideoView();
```

### Get the remote video view

During a one-to-one video call or group call, if a user joins the call, you can call the `ChatCallKitManager.getRemoteVideoView` method to obtain the video widget of this user.

```
// agoraUid: The Agora RTF user ID of a user in the call.
Widget? remoteVideoWidget = ChatCallKitManager.getRemoteVideoView(agoraUid);
```

### Delete the listener handler

You can call the `ChatCallKitManager.removeObserver(this);` method to remove callbacks when the callkit is no longer needed.

```dart
ChatCallKitManager.removeObserver(this);
```

## Push notifications

In scenarios where the app runs on the background or goes offline, use push notifications to ensure that the callee receives the call invitation. To enable push notifications, see [Set up push notifications](https://docs.agora.io/en/agora-chat/develop/offline-push?platform=flutter).

Once push notifications are enabled, when a call invitation arrives, a notification message pops out on the notification panel. Users can click the message to view the call invitation.

## Reference

### API list

This section provides other reference information that you can refer to when implementing real-time audio and video communications functionalities.

In `agora_chat_callkit`, `ChatCallKitManager` provides the following APIs:

|  Method          | Description              |
| :-------------------------- | :------------------ |
| addEventListener          | Adds an event listener.   |
| removeEventListener       | Removes an event listener.   |
| initRTC             | Initializes the Agora RTC.         |
| startSingleCall           | Makes a one-to-one call.    |
| startInviteUsers       | Invites users to join a group call.      |
| answer          | Answers a call.        |
| releaseRTC       | Rejects a call or hangs up a call.      |
| speakerOn           | Turns on the speaker.            |
| speakerOff       | Turns off the speaker.          |
| mute          | Mutes the microphone.            |
| unMute        | Unmutes the microphone.          |
| cameraOn           | Turns on the camera.           |
| cameraOff     | Turns off the camera.        |
| switchCamera   | Switches the front and rear cameras.           |
| getLocalVideoView  | Gets the local video view.            |
| getRemoteVideoView    | Gets the remote video view.          |

`ChatCallKitObserver` contains call-related events. For details, see [Listen for callback events](#Listen for callback events).

### Sample project

If demo is required, configure the following information in the `example/lib/config.dart` file:

```
class Config {
  static String agoraAppId = "";
  static String appkey = "";

  static String appServerDomain = "";

  static String appServerRegister = '';
  static String appServerGetAgoraToken = '';

  static String appServerTokenURL = "";
  static String appServerUserMapperURL = "";
}
```

To obtain the Agora RTC token, you need to set up an [App Server](./authentication#Deploy an app server to generate tokens) and provide a mapping service for the agora user ID and the Agora Chat user ID.
