# JioMeet Health Care Template  Quickstart

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
pod 'JioMeetHealthCareTemplate_iOS', '1.0.0-alpha.1'
```

Also please add this lines in your pod file if you're facing any issues.

```swift
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
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

| Property Name | Type  | Description  |
| ------- | --- | --- |
| meetingId | String | Meeting ID of the meeting user is going to join. |
| meetingPin | String | Meeting PIN of the meeting user is going to join. |
| displayName | String | Display Name with which user is going to join the meeting. |

```swift
let joinMeetingData = JMJoinMeetingData(
    meetingId: "9680763133",
    meetingPin: "1tKzt",
    displayName: "John Appleased"
)
```

### Create Meeting Configuration

Create a `JMJoinMeetingConfig` type object. Following are the properties of this object.

| Property Name | Type  | Description  |
| ------- | --- | --- |
| userRole | JMUserRole | Role of the user in the meeting. Possible values are `.host`, `.speaker`, `.audience`. If you are assigning `.host` value, please pass the token in its argument. |
| isInitialAudioOn | Bool | Initial Audio State of the user when user joins the meeting. If meeting is hard muted by a host, initial audio state will be muted and this setting will not take place. |
| isInitialVideoOn | Bool | Initial Video State of the user when user joins the meeting. |

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

| Argument Name | Type  | Description  |
| ------- | --- | --- |
| meetingData | JMJoinMeetingData | Meeting Data which include meeting id, pin and user display name. |
| config | JMJoinMeetingConfig | Meeting Configuration which include user role, mic and camera initial states. |
| delegate | JMClientDelegate? | A class conforming to `JMClientDelegate` protocol.  |


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

// Local User has left the meeting
func didLocalParticipantLeaveMeeting() {
    navigationController?.popViewController(animated: true)
}

// Local User failed to joined the meeting. Please use errorMessage to show any error.
func didLocalUserFailedToJoinMeeting(errorMessage: String) {
    showMeetingJoinError(message: errorMessage)
}


// When user clicks on partipants icon this delegate will trigger
func didPressParticipantListButton() {
    
}

```

## Run Project

Run `pod install --repo-update` command. Open JioMeetCoreUIDemo.xcworkspace file.


## Reference Classes

Please check `MeetingScreenViewController` class for integration reference.

## Troubleshooting

Facing any issues while integrating or installing the JioMeet Template UI Kit please connect with us via real time support present in jiomeet.support@jio.com or https://jiomeetpro.jio.com/contact-us
