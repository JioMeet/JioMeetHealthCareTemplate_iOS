# JioMeet Health Care Template Quickstart

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Setup](#setup)
   - [Register on JioMeet Platform](#register-on-jiomeet-platform)
   - [Get Your Application Keys](#get-your-application-keys)
   - [Get Your JioMeet Meeting ID and PIN](#get-your-jiomeet-meeting-id-and-pin)
4. [Project Settings](#project-settings)
   - [Info.plist Changes](#infoplist-changes)
   - [Enable Background Mode](#enable-background-mode)
   - [Enable Audio Video Permissons](#enable-audio-video-permissons)
   - [Orientation](#orientation)
5. [Integration Steps](#integration-steps)
   - [Add SDK](#add-sdk)
   - [Import SDK](#import-sdk)
   - [Integrate Meeting View](#integrate-meeting-view)
6. [Join Meeting](#join-meeting)
   - [Create Meeting Data](#create-meeting-data)
   - [Create Meeting Configuration](#create-meeting-configuration)
   - [Join Meeting with data and config](#join-meeting-with-data-and-config)
   - [Implement JMMeetingViewDelegate methods](#implement-jmmeetingviewdelegate-methods)
   - [Implement JMClientDelegate Methods](#implement-jmclientdelegate-methods)
7. [Run Project](#run-project)
8. [Reference Classes](#reference-classes)
9. [Troubleshooting](#troubleshooting)

## Introduction

In this documentation, we'll guide you through the process of installation, enabling you to enhance your iOS app with Jiomeet's real-time communication capabilities swiftly and efficiently. Let's get started on your journey to creating seamless communication experiences with Jiomeet Template UI!

---

## Prerequisites

Before getting started with this example app, please ensure you have the following software installed on your machine:

- Xcode 14.2 or later.
- Swift 5.0 or later.
- An iOS device or emulator running iOS 13.0 or later.

## Setup

#### Register on JioMeet Platform:

You need to first register on Jiomeet platform. [Click here to sign up](https://platform.jiomeet.com/login/signUp)

#### Get your application keys:

Create a new app. Please follow the steps provided in the [Documentation guide](https://dev.jiomeet.com/docs/quick-start/introduction) to create apps before you proceed.

#### Get your Jiomeet meeting id and pin

Use the [create meeting api](https://dev.jiomeet.com/docs/JioMeet%20Platform%20Server%20APIs/create-a-dynamic-meeting) to get your room id and password

## Project Settings

### Info.plist Changes

Please add below permissions keys to your `Info.plist` file with proper description.

```swift
<key>NSCameraUsageDescription</key>
<string>Allow access to camera for meetings</string>
<key>NSMicrophoneUsageDescription</key>
<string>Allow access to mic for meetings</string>
```

### Enable Background Mode

Please enable `Background Modes` in your project `Signing & Capibilities` tab. After enabling please check box with option `Audio, Airplay, and Pictures in Pictures`. If you don't enables this setting, your mic will be muted when your app goes to background.

### Enable Audio Video Permissons

Before joining the meeting please check audio video permissons are enabled or not. If not please throw an error to enable both audio and video permissons

### Orientation

Currently SDK support portarait orientation for the iPhone and landscape for the iPad. If your app supports multiple orientation, please lock down orientation when you show the SDK View.

## Integration Steps

### Add SDK

Please add below pod to your Podfile and run command `pod install --repo-update --verbose`.

```ruby
pod 'JioMeetHealthCareTemplate_iOS', '1.0.0-alpha.2'
```

Also please add this lines in your pod file if you're facing any issues.

```swift
post_install do |installer|
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
      # For xcode 15+ only
      if config.base_configuration_reference && Integer(xcode_base_version) >= 15
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
```

### Import SDK

Please use below import statements

```swift
import JioMeetHealthCareTemplate
import JioMeetCoreSDK
```

### Integrate Meeting View

Create instance of `JMMeetingView`.

```swift
private var meetingView = JMMeetingView()
```

Add it to your viewController view.

```swift
meetingView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(meetingView)

NSLayoutConstraint.activate([
    meetingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    meetingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    meetingView.topAnchor.constraint(equalTo: view.topAnchor),
    meetingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
])
```

## Join Meeting

### Create Meeting Data

First create `JMJoinMeetingData` type object. Following are the properties of this object.

| Property Name | Type   | Description                                                |
| ------------- | ------ | ---------------------------------------------------------- |
| meetingId     | String | Meeting ID of the meeting user is going to join.           |
| meetingPin    | String | Meeting PIN of the meeting user is going to join.          |
| displayName   | String | Display Name with which user is going to join the meeting. |

```swift
let joinMeetingData = JMJoinMeetingData(
    meetingId: "9680763133",
    meetingPin: "1tKzt",
    displayName: "John Appleased"
)
```

### Create Meeting Configuration

Create a `JMJoinMeetingConfig` type object. Following are the properties of this object.

| Property Name    | Type       | Description                                                                                                                                                              |
| ---------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| userRole         | JMUserRole | Role of the user in the meeting. Possible values are `.host`, `.speaker`, `.audience`. If you are assigning `.host` value, please pass the token in its argument.        |
| isInitialAudioOn | Bool       | Initial Audio State of the user when user joins the meeting. If meeting is hard muted by a host, initial audio state will be muted and this setting will not take place. |
| isInitialVideoOn | Bool       | Initial Video State of the user when user joins the meeting.                                                                                                             |

```swift
let joinMeetingConfig = JMJoinMeetingConfig(
    userRole: .host(hostToken: "MD5hQxGAwjW2"),
    isInitialAudioOn: false,
    isInitialVideoOn: false
)
```

### Join Meeting with data and config

After creating `JMJoinMeetingData` and `JMJoinMeetingConfig` objects, call `joinMeeting` method of `JMClient` instance.

Following are the arguments of `joinMeeting` method.

| Argument Name | Type                | Description                                                                   |
| ------------- | ------------------- | ----------------------------------------------------------------------------- |
| meetingData   | JMJoinMeetingData   | Meeting Data which include meeting id, pin and user display name.             |
| config        | JMJoinMeetingConfig | Meeting Configuration which include user role, mic and camera initial states. |
| delegate      | JMClientDelegate?   | A class conforming to `JMClientDelegate` protocol.                            |

```swift
meetingView.joinMeeting(
    meetingData: joinMeetingData,
    config: joinMeetingConfig,
    delegate: self
)
```

**Note: Host Token can be nil.**

### Implement JMMeetingViewDelegate methods

Confirm your class with `JMMeetingViewDelegate` protocol and implement its methods

```swift
// When user clicks on partipants icon this delegate will trigger
func didPressParticipantListButton() {

}

```

### Implement JMClientDelegate Methods

You can observer all events happening in the meeting related to all users. To observer these events, first confirm your class with `JMClientDelegate` protocol and implement its methods. Also call `addMeetingEventsDelegate` method of your meeting view and pass an `UUID` type identifier.

```swift
let identifier = UUID()
```

```swift
meetingView.addMeetingEventsDelegate(delegate: self, identifier: identifier)
```

```swift
func jmClient(_ meeting: JMMeeting, didLocalUserJoinedMeeting user: JMMeetingUser) {
		// Local User has Joined Meeting
}

func jmClient(_ meeting: JMMeeting, didLocalUserMicStatusUpdated isMuted: Bool) {
  // Local User Mic status Updated
}

func jmClient(_ meeting: JMMeeting, didLocalUserVideoStatusUpdated isMuted: Bool) {
  // Local User Video status Updated
}

func jmClient(_ meeting: JMMeeting, didRemoteUserJoinedMeeting user: JMMeetingUser) {
  // Remote User has Joined Meeting
}

func jmClient(_ meeting: JMMeeting, didRemoteUserMicStatusUpdated user: JMMeetingUser, isMuted: Bool) {
  // Remote User Mic status Updated
}

func jmClient(_ meeting: JMMeeting, didRemoteUserVideoStatusUpdated user: JMMeetingUser, isMuted: Bool) {
  // Remote User Video status Updated
}

func jmClient(_ meeting: JMMeeting, didRemoteUserLeftMeeting user: JMMeetingUser, reason: JMUserLeftReason) {
  // Remote User Left Meeting
}

func jmClient(_ meeting: JMMeeting, didLocalUserLeftMeeting reason: JMUserLeftReason) {
  // Local User Left Meeting
  navigationController?.popViewController(animated: true)
}

func jmClient(didLocalUserFailedToJoinMeeting error: JMMeetingJoinError) {
  
  // Local User failed to join Meeting
  var errorMessageString = ""
  switch error {
  case .invalidConfiguration:
    errorMessageString = "Failed to Get Configurations"
  case .invalidMeetingDetails:
    errorMessageString = "Invalid Meeting ID or PIN, Please check again."
  case .meetingExpired:
    errorMessageString = "This meeting has been expired."
  case .meetingLocked:
    errorMessageString = "Sorry, you cannot join this meeting because room is locked."
  case .failedToRegisterUser:
    errorMessageString = "Failed to Register User for Meeting."
  case .maxParticipantsLimit:
    errorMessageString = "Maximum Participant Limit has been reached for this meeting."
  case .failedToJoinCall(let errorMessage):
    errorMessageString = errorMessage
  case .other(let errorMessage):
    errorMessageString = errorMessage
  default:
    errorMessageString = "Unknown Error Occurred."
  }

  showMeetingJoinError(message: errorMessageString)
}

func jmClient(didErrorOccured error: JMMeetingError) {
  // Some error Occurred in Meeting. This will not end your meeting.

  var errorMessage = ""
  switch error {
  case .cannotChangeMicStateInAudienceMode:
    errorMessage = "You are in Audience Mode. Cannot update Mic status"
  case .cannotChangeCameraStateinAudienceMode:
    errorMessage = "You are in Audience Mode. Cannot update Camera status"
  case .audioPermissionNotGranted:
    errorMessage = "Mic permission is not granted. Please allow Mic permission in app setting."
  case .videoPermissionNotGranted:
    errorMessage = "Camera permission is not granted. Please allow Camera permission in app setting."
  default:
    errorMessage = "Some other error Occurred"
  }

  let errorAlertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
  let okAction = UIAlertAction(title: "Ok", style: .default)
  errorAlertController.addAction(okAction)
  present(errorAlertController, animated: true)

}
```

## Run Project

Run `pod install --repo-update` command. Open JioMeetHealthCareTemplateDemo.xcworkspace file.

## Reference Classes

Please check `MeetingScreenViewController` class for integration reference.

## Troubleshooting

Facing any issues while integrating or installing the JioMeet Template UI Kit please connect with us via real time support present in jiomeet.support@jio.com or https://jiomeetpro.jio.com/contact-us
