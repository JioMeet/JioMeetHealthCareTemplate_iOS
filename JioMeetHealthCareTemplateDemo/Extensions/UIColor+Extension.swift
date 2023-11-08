//
//  UIColor+Extension.swift
//  JioMeetCoreUIDemo
//
//  Created by Rohit41.Kumar on 06/07/23.
//

import Foundation
import UIKit

extension UIColor {
	
	convenience init(hexString: String, alpha: CGFloat = 1.0) {
		if hexString.hasPrefix("#") {
			let start = hexString.index(hexString.startIndex, offsetBy: 1)
			let hexColor = String(hexString[start...])
			
			let scanner = Scanner(string: hexColor)
			var hexNumber: UInt64 = 0
			
			if scanner.scanHexInt64(&hexNumber) {
				let mask = 0x000000FF
				let r = Int(hexNumber >> 16) & mask
				let g = Int(hexNumber >> 8) & mask
				let b = Int(hexNumber) & mask
				let red   = CGFloat(r) / 255.0
				let green = CGFloat(g) / 255.0
				let blue  = CGFloat(b) / 255.0
				
				self.init(red: red, green: green, blue: blue, alpha: alpha)
				return
			}
		}
		self.init(white: 1, alpha: 1)
	}
}
