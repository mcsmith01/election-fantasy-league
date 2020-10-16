//
//  Race.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/11/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation
import UserNotifications

class Race: NSObject, Identifiable, Comparable, ObservableObject {
	
	static func < (lhs: Race, rhs: Race) -> Bool {
		if lhs.state != rhs.state {
			return lhs.state < rhs.state
		} else if lhs.type != rhs.type {
			return lhs.type < rhs.type
		} else {
			return lhs.id < rhs.id
		}
	}
	
	var election: Election
	var id: String
	var isActive: Bool
	var incumbency: [String: Int]?
	var splits: Bool
	var state: String
	var abbreviation: String
	var type: RaceType
	var candidates: [String: String]?
	var safety: [String: Int]?
	var results: [String: Int]?
	@Published var prediction: Prediction?
	var seats: Int {
		get {
			var count = 0
			if let incumbency = incumbency {
				for num in incumbency.values {
					count += num
				}
			}
			return count
		}
	}

	init?(id: String, data: [String: Any], election: Election) {
		guard let rawType = data["type"] as? Int, let type = RaceType(rawValue: rawType), let state = data["state"] as? String, let abbreviation = data["abbreviation"] as? String else { debugPrint("Bad state \n\(data)"); return nil }
		self.election = election
		self.id = id
		self.state = state
		self.type = type
		self.abbreviation = abbreviation
		if let incumbency = data["incumbency"] as? [String: Int] {
			self.incumbency = incumbency
		}
		if let candidates = data["candidates"] as? [String: String] {
			self.candidates = candidates
			isActive = true
		} else if type == .house {
			isActive = true
		} else {
			isActive = false
		}
		if let safety = data["safety"] as? [String: Int] {
			self.safety = safety
		}
		self.splits = data["splits"] as? Bool ?? false
		if let results = data["results"] as? [String: Int] {
			self.results = results
		}
	}
	
	func updateRace(withData data: [String: Any]) {
		if let results = data["results"] as? [String: Int] {
			self.results = results
			presentResultsNotification(fromResults: results)
		} else {
			self.results = nil
		}
	}
	
	func racesForState(activeOnly: Bool = false) -> [Race] {
		return election.racesForState(self.state, activeOnly: activeOnly)
	}
	
	func presentResultsNotification(fromResults results: [String: Int]) {
		let center = UNUserNotificationCenter.current()
		let raceActions = "Race Called Actions"
		let content = UNMutableNotificationContent()
		content.title = "Results are in for the \(state) \(type.adjective) race!"
		if type == .house {
			let d = results["d"] ?? 0
			let i = results["i"] ?? 0
			let r = results["r"] ?? 0
			let t = results["t"] ?? 0
			var resultStrings = [String]()
			if d > 0 {
				resultStrings.append("\(d) Democrat\(d > 1 ? "s":"")")
			}
			if i > 0 {
				resultStrings.append("\(i) Democrat\(i > 1 ? "s":"")")
			}
			if r > 0 {
				resultStrings.append("\(r) Democrat\(r > 1 ? "s":"")")
			}
			var body = "The congressional delegation will be "
			switch resultStrings.count {
			case 1: body += "\(resultStrings[0])."
			case 2: body += "\(resultStrings[0]) and \(resultStrings[1])."
			case 3: body += "\(resultStrings[0]), \(resultStrings[1]), and \(resultStrings[2])."
			default: body += "unknown."
			}
			if t > 0 {
				body += " \(t) \(t > 1 ? "of the races were" : "race was") too close to call."
			}
			content.body = body
		} else if splits {
			// Nebraska or Maine Presidential 
			let d = results["d"] ?? 0
			let i = results["i"] ?? 0
			let r = results["r"] ?? 0
			let t = results["t"] ?? 0
			var resultStrings = [String]()
			if d > 0 {
				if i == 0 && r == 0 && t == 0 {
					resultStrings.append("\(candidates!["d"]!) won all \(d) electors")
				} else {
					resultStrings.append("\(candidates!["d"]!) won \(d) electors")
				}
			}
			if i > 0 {
				if d == 0 && r == 0 && t == 0 {
					resultStrings.append("\(candidates!["i"]!) won all \(i) electors")
				} else {
					resultStrings.append("\(candidates!["i"]!) won \(i) electors")
				}
			}
			if r > 0 {
				if d == 0 && i == 0 && t == 0 {
					resultStrings.append("\(candidates!["r"]!) won all \(r) electors")
				} else {
					resultStrings.append("\(candidates!["r"]!) won \(r) electors")
				}
			}
			var body = ""
			switch resultStrings.count {
			case 1: body += "\(resultStrings[0])."
			case 2: body += "\(resultStrings[0]) and \(resultStrings[1])."
			case 3: body += "\(resultStrings[0]), \(resultStrings[1]), and \(resultStrings[2])."
			default: body += "unknown."
			}
			if t > 0 {
				body += " \(t) \(t > 1 ? "of the electors were" : "elector was") too close to call."
			}
			content.body = body
		} else {
			// Senate, gubernatorial, or standard Presidential
			if let winner = results.keys.first, let winnerName = candidates?[winner] {
				content.body = "We called the race for \(winnerName)!"
			} else {
				content.body = "At the end of the night, the results are too close to call!"
			}
		}
		content.categoryIdentifier = raceActions
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let identifier = self.id
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		center.add(request) { (error) in
			if let error = error {
				debugPrint("Error scheduling settings notification\n\(error)")
			}
		}
		let moreInfoAction = UNNotificationAction(identifier: "More Info", title: "More Info", options: [])
		let category = UNNotificationCategory(identifier: raceActions, actions: [moreInfoAction], intentIdentifiers: [], options: [])
		center.setNotificationCategories([category])
	}
}
