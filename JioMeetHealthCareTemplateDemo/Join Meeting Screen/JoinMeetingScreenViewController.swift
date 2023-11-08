//
//  JoinMeetingScreenViewController.swift
//  JioMeetCoreUIDemo
//
//  Created by Rohit41.Kumar on 06/07/23.
//

import Foundation
import UIKit
import AVFoundation
import JioMeetHealthCareTemplate

class JoinMeetingScreenViewController: UIViewController {
	
	// MARK: - SubViews
	private var contentStackView = UIStackView()
	private var headerLabel = UILabel()
	private var meetingIdInputView = JoinInputDataView()
	private var meetingPinInputView = JoinInputDataView()
	private var userNameInputView = JoinInputDataView()
	private var joinButton = UIButton()
	
	// MARK: - UI Properties
	private var contentStackViewCenterYConstraints: NSLayoutConstraint!
	
	// MARK: - Properties
	private var isCameraAllowed = false
	private var isMicAllowed = false
	var meetingID = ""
	var meetingPIN = ""
	var hostToken = ""
	var userDisplayName = ""
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		self.view.backgroundColor = UIColor(hexString: "#141414")
		self.userDisplayName = UserDefaults.standard.value(forKey: "jm_saved_user_name") as? String ?? ""
		
		configureSubViews()
		arrangeAllSubViews()
		configureSubViewsLayouts()
		
		let keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
		self.view.addGestureRecognizer(keyboardDismissGesture)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didKeyBoardAppear(notification:)),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
	}
}

// MARK: - Selector Methods
extension JoinMeetingScreenViewController {
	@objc private func didPressCloseButton(sender: UIButton) {
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.popToRootViewController(animated: true)
	}
	
	@objc private func didTapView(gesture: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	@objc private func didKeyBoardAppear(notification: NSNotification) {
		if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
			let duration = animationDuration?.doubleValue ?? 0.33
			let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
			
			let contentStackViewHeight = contentStackView.frame.height
			let stackViewBottomPadding = (UIScreen.main.bounds.height - contentStackViewHeight) / 2
			
			let constantHeight = keyboardHeight - stackViewBottomPadding
			
			UIView.animate(withDuration: duration) {[weak self] in
				if keyboardHeight < 100 {
					// Keyboard is not visible
					self?.contentStackViewCenterYConstraints.constant = 0
				} else {
					// Keyboard is Visible
					self?.meetingIdInputView.removeError()
					self?.meetingPinInputView.removeError()
					self?.userNameInputView.removeError()
					self?.contentStackViewCenterYConstraints.constant = -(constantHeight + 10)//-stackViewBottomPadding/2
				}
				self?.view.layoutIfNeeded()
			}
		}
	}
	
	@objc private func didPressJoinButton(sender: UIButton) {
		view.endEditing(true)
		
		// Check Mic and Camera Permissions
		getAudioVideoAuthorization {[weak self] (isCameraAllowed, isMicAllowed, isFirstTime) in
			self?.isCameraAllowed = isCameraAllowed
			self?.isMicAllowed = isMicAllowed
			guard isCameraAllowed && isMicAllowed else {
				self?.showMicCameraErrorAlert()
				return
			}
			self?.joinMeeting()
		}
	}
	
	private func joinMeeting() {
		let meetingIDValidateResult = meetingIdInputView.validateData()
		let meetingPinValidateResult = meetingPinInputView.validateData()
		let userNameValidateResult = userNameInputView.validateData()
		
		guard meetingIDValidateResult, meetingPinValidateResult, userNameValidateResult else {
			if meetingIDValidateResult == false {
				meetingIdInputView.showErrorInValidation()
			}
			
			if meetingPinValidateResult == false {
				meetingPinInputView.showErrorInValidation()
			}
			
			if userNameValidateResult == false {
				userNameInputView.showErrorInValidation()
			}
			
			// Show Validation
			showDataValidationError()
			return
		}
		
		meetingIdInputView.removeError()
		meetingPinInputView.removeError()
		userNameInputView.removeError()
		
		UserDefaults.standard.set(userNameInputView.getTextFieldText(), forKey: "jm_saved_user_name")
		let meetingScreenController = MeetingScreenViewController()
		meetingScreenController.meetingID = meetingIdInputView.getTextFieldText()
		meetingScreenController.meetingPIN = meetingPinInputView.getTextFieldText()
		meetingScreenController.userDisplayName = userNameInputView.getTextFieldText()
		meetingScreenController.hostToken = hostToken
		navigationController?.pushViewController(meetingScreenController, animated: true)
	}
}

// MARK: - UITextField Delegate Methods
extension JoinMeetingScreenViewController: UITextFieldDelegate {
	@objc private func textFieldTextDidChange(textField: UITextField) {
		// Check if textField is Meeting ID Input view else return
		guard textField.tag == 1000 else { return }
		guard let meetinIdInputText = textField.text else { return }
		guard meetinIdInputText.count > 0 else { return }
		guard meetinIdInputText.isNumeric == false else {
			meetingIdInputView.updateTextFieldText(meetinIdInputText)
			return
		}
		
		guard let urlComponents = URLComponents(string: meetinIdInputText) else { return }
		guard let queryItems = urlComponents.queryItems, queryItems.count >= 2 else { return }
		guard let meetingID = queryItems.first(where: { $0.name == "meetingId" })?.value else { return }
		guard let meetingPIN = queryItems.first(where: { $0.name == "pwd" })?.value else { return }
		
		meetingIdInputView.updateTextFieldText(meetingID)
		meetingPinInputView.updateTextFieldText(meetingPIN)
	}
}

// MARK: - UI Helper Methods
extension JoinMeetingScreenViewController {
	private func showDataValidationError() {
		let errorAlert = UIAlertController(title: "Error", message: "Please check input data", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default)
		errorAlert.addAction(okAction)
		present(errorAlert, animated: true)
	}
	
	private func showMicCameraErrorAlert() {
		let errorAlert = UIAlertController(
			title: "Camera Mic Permission Error",
			message: "You have not granted Mic and Camera Permission. Please provide.",
			preferredStyle: .alert
		)
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
			guard let appSettingURL = URL(string: UIApplication.openSettingsURLString) else { return }
			guard UIApplication.shared.canOpenURL(appSettingURL) else { return }
			UIApplication.shared.open(appSettingURL)
		}
		errorAlert.addAction(cancelAction)
		errorAlert.addAction(settingsAction)
		present(errorAlert, animated: true)
	}
	
	private func getAudioVideoAuthorization(completion: @escaping ((_ isCameraAllowed: Bool, _ isMicAllowed: Bool, _ isFirstTime: Bool) -> Void)) {
		getVideoAuthorization(completion: {(isSuccess, isFirstTime) in
			let cameraAccess = isSuccess
			self.getAudioAuthorization(completion: {(isSuccess) in
				let micAccess = isSuccess
				completion(cameraAccess, micAccess, isFirstTime)
			})
		})
	}
	
	private func getVideoAuthorization(completion: @escaping (_ isAuthorized: Bool, _ isFirstTime: Bool) -> Void) {
		AVCaptureDevice.authorizeVideo(completion: {(status) in
			switch status {
			case .justAuthorized:
				completion(true, true)
			case .alreadyAuthorized:
				completion(true, false)
			case .justDenied:
				completion(false, true)
			case .alreadyDenied, .restricted:
				completion(false, false)
			default:
				completion(false, false)
			}
		})
	}
	
	private func getAudioAuthorization(completion: @escaping (_ isAuthorized: Bool) -> Void) {
		AVCaptureDevice.authorizeAudio(completion: {(status) in
			switch status {
			case .justAuthorized, .alreadyAuthorized:
				completion(true)
			default:
				completion(false)
			}
		})
	}
}

// MARK: - Configure SubViews
extension JoinMeetingScreenViewController {
	private func configureSubViews() {
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.alignment = .center
		contentStackView.backgroundColor = .clear
		
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		headerLabel.textColor = .white
		headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
		headerLabel.textAlignment = .center
		headerLabel.numberOfLines = 2
		headerLabel.text = ["You're about to join", "a meeting"].joined(separator: "\n")
		
		meetingIdInputView.translatesAutoresizingMaskIntoConstraints = false
		meetingIdInputView.backgroundColor = .clear
		meetingIdInputView.setInputData(
			label: "Meeting ID or link",
			placeHolder: "Enter meeting id or link",
			keyboardType: .numberPad,
			keyboardTag: 1000,
			textFieldDelegate: self,
			textFieldTargetAction: #selector(textFieldTextDidChange(textField:))
		)
		meetingIdInputView.setValidator(validator: "^\\d{10}$")
		meetingIdInputView.updateTextFieldText(meetingID)
		
		meetingPinInputView.translatesAutoresizingMaskIntoConstraints = false
		meetingPinInputView.backgroundColor = .clear
		meetingPinInputView.setInputData(
			label: "Password",
			placeHolder: "Enter password",
			keyboardType: .namePhonePad,
			keyboardTag: 2000,
			textFieldDelegate: self,
			textFieldTargetAction: #selector(textFieldTextDidChange(textField:))
		)
		meetingPinInputView.setValidator(validator: "^\\w{5}$")
		meetingPinInputView.updateTextFieldText(meetingPIN)
		
		userNameInputView.translatesAutoresizingMaskIntoConstraints = false
		userNameInputView.backgroundColor = .clear
		userNameInputView.setInputData(
			label: "Name",
			placeHolder: "Enter name",
			keyboardType: .namePhonePad,
			keyboardTag: 3000,
			textFieldDelegate: self,
			textFieldTargetAction: #selector(textFieldTextDidChange(textField:))
		)
		userNameInputView.setValidator(validator: "^[a-zA-Z0-9 ]{2,45}")
		userNameInputView.updateTextFieldText(userDisplayName)
		
		joinButton.translatesAutoresizingMaskIntoConstraints = false
		joinButton.backgroundColor = UIColor(hexString: "#2143DB")
		joinButton.setTitle("Join", for: .normal)
		joinButton.setTitleColor(.white, for: .normal)
		joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		joinButton.layer.masksToBounds = true
		joinButton.layer.cornerRadius = 25
		joinButton.addTarget(self, action: #selector(didPressJoinButton(sender:)), for: .touchUpInside)
		
	}
	
	private func arrangeAllSubViews() {
		view.addSubview(contentStackView)
		
		contentStackView.addArrangedSubview(headerLabel)
		addVerticalSpacer(height: 40)
		contentStackView.addArrangedSubview(meetingIdInputView)
		addVerticalSpacer(height: 25)
		contentStackView.addArrangedSubview(meetingPinInputView)
		addVerticalSpacer(height: 25)
		contentStackView.addArrangedSubview(userNameInputView)
		addVerticalSpacer(height: 40)
		contentStackView.addArrangedSubview(joinButton)
	}
	
	private func configureSubViewsLayouts() {
		contentStackViewCenterYConstraints = contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
		
		NSLayoutConstraint.activate([
			contentStackViewCenterYConstraints,
			contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
			
			meetingIdInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			meetingPinInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			userNameInputView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			
			joinButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1, constant: -50),
			joinButton.heightAnchor.constraint(equalToConstant: 50),
		])
	}
	
	private func addVerticalSpacer(height: CGFloat) {
		let spacerView = UIView()
		spacerView.translatesAutoresizingMaskIntoConstraints = false
		spacerView.backgroundColor = .clear
		spacerView.heightAnchor.constraint(equalToConstant: height).isActive = true
		contentStackView.addArrangedSubview(spacerView)
	}
}
