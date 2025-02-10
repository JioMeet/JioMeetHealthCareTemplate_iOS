//
//  SampleHandler.swift
//  ScreenShareExtension
//
//  Created by Mani Baratam on 10/02/25.
//


import ReplayKit
import JioMeetScreenShareSDK

class SampleHandler: JMScreenShareHandler {
    override func getAppGroupsIdentifier() -> String {
        return "group.com.jio.jiomeet.nativesdk"
    }
}
