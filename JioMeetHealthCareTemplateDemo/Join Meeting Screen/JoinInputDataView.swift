//
//  JoinInputDataView.swift
//  JioMeetCoreUIDemo
//
//  Created by Rohit41.Kumar on 06/07/23.
//

import Foundation
import UIKit

class JoinInputDataView: UIView {
	// MARK: - SubViews
	private var contentStackView = UIStackView()
	private var label = UILabel()
	private var inputTextField = UITextField()
	private var textFieldBottomBorder = UIView()
	private var errorLabel = UILabel()
	
	// MARK: - Properties
	private var dataValidator = ""
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	private func commonInit() {
		configureSubViews()
		arrangeAllSubViews()
		configureSubViewsLayouts()
	}
}

// MARK: - Data Methods
extension JoinInputDataView {
	func setInputData(
		label: String,
		placeHolder: String,
		keyboardType: UIKeyboardType,
		keyboardTag: Int,
		textFieldDelegate: UITextFieldDelegate?,
		textFieldTargetAction: Selector
	) {
		self.label.text = label
		self.inputTextField.keyboardType = keyboardType
		self.inputTextField.tag = keyboardTag
		self.inputTextField.delegate = textFieldDelegate
		self.inputTextField.addTarget(textFieldDelegate, action: textFieldTargetAction, for: .editingChanged)
		self.inputTextField.attributedPlaceholder = NSAttributedString(
			string: placeHolder,
			attributes: [
				.foregroundColor: UIColor(hexString: "#A1A1A1"),
				.font: UIFont.systemFont(ofSize: 16, weight: .medium)
			]
		)
	}
	
	func setValidator(validator: String) {
		self.dataValidator = validator
	}
	
	func updateTextFieldText(_ text: String) {
		self.inputTextField.text = text
	}
	
	func getTextFieldText() -> String {
		return self.inputTextField.text ?? ""
	}
	
	func validateData() -> Bool {
		let predicate = NSPredicate(format: "SELF MATCHES %@", dataValidator)
		return predicate.evaluate(with: inputTextField.text ?? "")
	}
	
	func showErrorInValidation() {
		label.textColor = .systemRed
		inputTextField.textColor = .systemRed
		textFieldBottomBorder.backgroundColor = .systemRed
	}
	
	func removeError() {
		label.textColor = UIColor(hexString: "#CBCBCB")
		inputTextField.textColor = .white
		textFieldBottomBorder.backgroundColor = UIColor(hexString: "#A1A1A1")
	}
}

// MARK: - Configure SubViews
extension JoinInputDataView {
	private func configureSubViews() {
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.alignment = .fill
		contentStackView.backgroundColor = .clear
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .clear
		label.textAlignment = .left
		label.textColor = UIColor(hexString: "#CBCBCB")
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.numberOfLines = 1
		
		inputTextField.translatesAutoresizingMaskIntoConstraints = false
		inputTextField.backgroundColor = .clear
		inputTextField.borderStyle = .none
		inputTextField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		inputTextField.textColor = .white
		inputTextField.tintColor = .white
		inputTextField.autocorrectionType = .no
		inputTextField.autocapitalizationType = .none
		
		textFieldBottomBorder.translatesAutoresizingMaskIntoConstraints = false
		textFieldBottomBorder.backgroundColor = UIColor(hexString: "#A1A1A1")
	}
	
	private func arrangeAllSubViews() {
		addSubview(contentStackView)
		
		contentStackView.addArrangedSubview(label)
		contentStackView.addArrangedSubview(inputTextField)
		addVerticalSpacer(height: 5)
		contentStackView.addArrangedSubview(textFieldBottomBorder)
	}
	
	private func configureSubViewsLayouts() {
		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			label.heightAnchor.constraint(equalToConstant: 25),
			inputTextField.heightAnchor.constraint(equalToConstant: 25),
			textFieldBottomBorder.heightAnchor.constraint(equalToConstant: 0.75)
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
