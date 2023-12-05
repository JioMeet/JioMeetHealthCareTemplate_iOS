//
//  MeetingScreenViewController.swift
//  JioMeetCoreUIDemo
//
//  Created by Rohit41.Kumar on 06/07/23.
//

import Foundation
import UIKit
import JioMeetHealthCareTemplate
import JioMeetCoreSDK

class MeetingScreenViewController: UIViewController {
	
	// MARK: - SubViews
	private var meetingView = JMMeetingView()
	
	// MARK: - Properties
	public var meetingID = ""
	public var meetingPIN = ""
	public var userDisplayName = ""
	public var hostToken: String?
	private var identifier = UUID()
	
	// MARK: - Super Methods
	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		meetingView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(meetingView)
		
		NSLayoutConstraint.activate([
			meetingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			meetingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			meetingView.topAnchor.constraint(equalTo: view.topAnchor),
			meetingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
        
        
        let joinMeetingData = JMJoinMeetingData(
            meetingId: meetingID,
            meetingPin: meetingPIN,
            displayName: userDisplayName
        )
        
        let joinMeetingConfig = JMJoinMeetingConfig(
            userRole: .host(hostToken: hostToken ?? ""),
            isInitialAudioOn: false,
            isInitialVideoOn: false
        )
		meetingView.addMeetingEventsDelegate(delegate: self, identifier: identifier)
        meetingView.joinMeeting(meetingData: joinMeetingData, config: joinMeetingConfig, delegate: self)
	}
	
	private func showMeetingJoinError(message: String) {
		let errorAlertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default) {[weak self] _ in
			self?.navigationController?.popViewController(animated: true)
		}
		errorAlertController.addAction(okAction)
		present(errorAlertController, animated: true)
	}
	
	private func showMeetingShareView(meetingID: String, meetingPin: String) {
		let message = "Meeting Id: \(meetingID)" + "\n" + "Meeting PIN: \(meetingPin)"
		
		let shareItems = [message]
		let activityController = UIActivityViewController(activityItems: shareItems as [Any], applicationActivities: nil)
		activityController.excludedActivityTypes = [
			UIActivity.ActivityType.airDrop,
			UIActivity.ActivityType.print,
			UIActivity.ActivityType.assignToContact,
			UIActivity.ActivityType.saveToCameraRoll,
			UIActivity.ActivityType.postToFlickr,
			UIActivity.ActivityType.postToVimeo,
			UIActivity.ActivityType.addToReadingList]
		if let popoverPC = activityController.popoverPresentationController {
			popoverPC.sourceView = self.view
			popoverPC.sourceRect = CGRect(x: 0, y: self.view.bounds.maxY, width: 0, height: 0)
		}
		activityController.modalTransitionStyle = .coverVertical
		activityController.modalPresentationStyle = .fullScreen
		self.present(activityController, animated: true, completion: nil)
	}
}

extension MeetingScreenViewController: JMMeetingViewDelegate {
    func didPressParticipantListButton() {
        
    }
}

extension MeetingScreenViewController: JMClientDelegate {
	func jmClient(_ meeting: JMMeeting, didLocalUserJoinedMeeting user: JMMeetingUser) {
		print("LOGS ::: Main App ::: Local User Join Meeting")
	}
	
	func jmClient(_ meeting: JMMeeting, didLocalUserMicStatusUpdated isMuted: Bool) {
		print("LOGS ::: Main App ::: Local User Mic Muted ::: \(isMuted)")
	}
	
	func jmClient(_ meeting: JMMeeting, didLocalUserVideoStatusUpdated isMuted: Bool) {
		print("LOGS ::: Main App ::: Local User Video Muted ::: \(isMuted)")
	}
	
	func jmClient(_ meeting: JMMeeting, didRemoteUserJoinedMeeting user: JMMeetingUser) {
		print("LOGS ::: Main App ::: Remote User \(user.displayName) Join Meeting")
	}
	
	func jmClient(_ meeting: JMMeeting, didRemoteUserMicStatusUpdated user: JMMeetingUser, isMuted: Bool) {
		print("LOGS ::: Main App ::: Remote User \(user.displayName) Mic Muted ::: \(isMuted)")
	}
	
	func jmClient(_ meeting: JMMeeting, didRemoteUserVideoStatusUpdated user: JMMeetingUser, isMuted: Bool) {
		print("LOGS ::: Main App ::: Remote User \(user.displayName) Video Muted ::: \(isMuted)")
	}
	
	func jmClient(_ meeting: JMMeeting, didRemoteUserLeftMeeting user: JMMeetingUser, reason: JMUserLeftReason) {
		print("LOGS ::: Main App ::: Remote User \(user.displayName) Left Meeting")
	}
	
	func jmClient(_ meeting: JMMeeting, didLocalUserLeftMeeting reason: JMUserLeftReason) {
		print("LOGS ::: Main App ::: Local User Left Meeting")
		navigationController?.popViewController(animated: true)
	}
	
	func jmClient(didLocalUserFailedToJoinMeeting error: JMMeetingJoinError) {
		print("LOGS ::: Main App ::: Failed to Join Meeting")
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
}
