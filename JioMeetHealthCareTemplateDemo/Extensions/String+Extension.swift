//
//  String+Extension.swift
//  JioMeetCoreUIDemo
//
//  Created by Rohit41.Kumar on 06/07/23.
//

import Foundation

extension String {
	var isNumeric: Bool {
		return CharacterSet.decimalDigits.isSuperset(
			of: CharacterSet(
				charactersIn: self
			)
		)
	}
}
