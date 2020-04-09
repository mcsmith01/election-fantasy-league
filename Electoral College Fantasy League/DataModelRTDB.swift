//
//  DataModelFirestore.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/18/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import UIKit
import Firebase

struct UserData {
	
	static var data = UserData()
	
	subscript(field: Constants) -> Any? {
		get {
			return UserData.settings[field.rawValue]
		}
		set {
			UserData.settings[field.rawValue] = newValue
		}
	}
	
	private static var settings: [String: Any] = [String: Any]() {
		didSet {
			if userID != "" {
				UserDefaults.standard.set(settings, forKey: userID)
			}
		}
	}
	
	static var userID: String = "" {
		didSet {
			UserData.settings = UserDefaults.standard.object(forKey: userID) as? [String: Any] ?? [String: Any]()
		}
	}
}

extension Color {
	
	private static var dem: (r: Double, g: Double, b: Double) = (r: 35, g: 32, b: 102)
	private static var ind: (r: Double, g: Double, b: Double) = (r: 0, g: 190, b: 97)
	private static var rep: (r: Double, g: Double, b: Double) = (r: 233, g: 29, b: 14)
	private static var tcc: (r: Double, g: Double, b: Double) = (r: 102, g: 51, b: 153)

	static var democrat: Color {
		return Color(red: dem.r / 255.0, green: dem.g / 255.0, blue: dem.b / 255.0)
	}

	static var independent: Color {
		return Color(red: ind.r / 255.0, green: ind.g / 255.0, blue: ind.b / 255.0)
	}

	static var republican: Color {
		return Color(red: rep.r / 255.0, green: rep.g / 255.0, blue: rep.b / 255.0)
	}
	
	static var tooCloseToCall: Color {
		return Color(red: tcc.r / 255.0, green: tcc.g / 255.0, blue: tcc.b / 255.0)
	}

	private static func blend(dems: Double, inds: Double, reps: Double, tctc: Double) -> Color {
		let total = dems + inds + reps + tctc
		let red = (dem.r * dems + ind.r * inds + rep.r * reps + tcc.r * tctc) / total
		let green = (dem.g * dems + ind.g * inds + rep.g * reps + tcc.g * tctc) / total
		let blue = (dem.b * dems + ind.b * inds + rep.b * reps + tcc.b * tctc) / total
		return Color(red: red / 255, green: green / 255, blue: blue / 255)
	}
	
	static func blend(_ numbers: [String: Int]) -> Color {
		if numbers.count == 0 || (numbers.count == 1 && numbers.keys.first! == "") {
			return .gray
		}
		var dems = 0
		var inds = 0
		var reps = 0
		var tctc = 0
		for (key, count) in numbers {
			if key.starts(with: "d") {
				dems += count
			} else if key.starts(with: "i") {
				inds += count
			} else if key.starts(with: "r") {
				reps += count
			} else if key.starts(with: "t") {
				tctc += count
			}
		}
		return blend(dems: Double(dems), inds: Double(inds), reps: Double(reps), tctc: Double(tctc))
	}
	
}

extension Int {
	
	init(truncating num: Double) {
		self.init(truncating: NSNumber(floatLiteral: num))
	}
	
}

struct RectangleBorder: ViewModifier {
	var lineWidth: CGFloat = 3
	
	func body(content: Content) -> some View {
		content
			.clipShape(rowShape)
			.overlay(rowShape.stroke(Color.primary, lineWidth: lineWidth))
	}
	
}
