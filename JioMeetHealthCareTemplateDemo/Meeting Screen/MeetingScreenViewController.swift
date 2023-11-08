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
    func didLocalParticipantLeaveMeeting() {
        navigationController?.popViewController(animated: true)
    }
    
    func didPressParticipantListButton() {
        
    }
    
	func didLocalUserFailedToJoinMeeting(errorMessage: String) {
		showMeetingJoinError(message: errorMessage)
	}
	
}
