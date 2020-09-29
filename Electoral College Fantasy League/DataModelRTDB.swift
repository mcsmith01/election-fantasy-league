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
		return blend(["d": 1])
	}

	static var independent: Color {
		return blend(["i": 1])
	}

	static var republican: Color {
		return blend(["r": 1])
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
	
	static func gradient(_ numbers: [String: Int]) -> Gradient {
		if numbers.count == 0 || (numbers.count == 1 && numbers.keys.first! == "") {
			return Gradient(colors: [Color.gray])
		}

		var dems: CGFloat = 0
		var inds: CGFloat = 0
		var reps: CGFloat = 0
		var tctc: CGFloat = 0
		var total: CGFloat = 0
		for (key, count) in numbers {
			total += CGFloat(count)
			if key.starts(with: "d") {
				dems += CGFloat(count)
			} else if key.starts(with: "i") {
				inds += CGFloat(count)
			} else if key.starts(with: "r") {
				reps += CGFloat(count)
			} else if key.starts(with: "t") {
				tctc += CGFloat(count)
			}
		}
		var stops = [Gradient.Stop]()
		if dems > 0 {
			stops.append(Gradient.Stop(color: Color("democrat"), location: (dems * 0.5) / total))
		}
		if inds > 0 {
			stops.append(Gradient.Stop(color: Color("independent"), location: (dems + inds * 0.5) / total))
		}
		if reps > 0 {
			stops.append(Gradient.Stop(color: Color("republican"), location: (dems + inds + reps * 0.5) / total))
		}
		if tctc > 0 {
			stops.append(Gradient.Stop(color: Color("too_close"), location: (dems + inds + reps + tctc * 0.5) / total))
		}
		debugPrint(stops)
		return Gradient(stops: stops)
	}
	

	static func forScore(_ score: Double) -> Color {
		var color: Color
		let opacity = max(2.0, abs(score - 1.0))
		if score >= 1.0 {
			color = Color.green.opacity(opacity)
		} else {
			color = Color.red.opacity(opacity)
		}
		return color
	}
	
}

extension Int {
	
	init(truncating num: Double) {
		self.init(truncating: NSNumber(floatLiteral: num))
	}
	
}

struct RectangleBorder: ViewModifier {
	
	var color: Color = .primary
	var lineWidth: CGFloat = 3
	
	func body(content: Content) -> some View {
		content
			.clipShape(rowShape)
			.overlay(rowShape.stroke(color, lineWidth: lineWidth))
	}
	
}

struct CellBackground: ViewModifier {
	
	func body(content: Content) -> some View {
		content
			.background(
				Image("american_flag")
					.opacity(0.1)
		)
	}
	
}

struct StandardCell: ViewModifier {
	
	func body(content: Content) -> some View {
		content
			.background(Image("american_flag").opacity(0.1))
			.modifier(RectangleBorder())
	}
}

struct ColoredCell: ViewModifier {
	
	var color: Color = .primary
	
	func body(content: Content) -> some View {
		content
			.background(color.opacity(0.2))
			.modifier(RectangleBorder())
	}
}

struct ScoreCell: ViewModifier {
	
	var score: Double
	
	func body(content: Content) -> some View {
		content
			.background(Color.forScore(score))
			.modifier(RectangleBorder())
	}
}

struct Cells_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			Text("Standard Cell")
				.padding()
				.modifier(StandardCell())
				.padding()
			
			Text("Green Cell")
				.padding()
				.modifier(ColoredCell(color: .green))
				.padding()

			Text("Orange Cell")
				.padding()
				.modifier(ColoredCell(color: .orange))
				.padding()

			Text("Red Cell")
				.padding()
				.modifier(ColoredCell(color: .red))
				.padding()
		}
	}

}
