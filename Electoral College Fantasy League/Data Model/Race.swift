//
//  Race.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/11/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

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
	var incumbency: [String: Int]
	var splits: Bool
	var state: String
	var type: RaceType
	var candidates: [String: String]?
	var safety: [String: Int]?
	var results: [String: Int]?
	@Published var prediction: Prediction?
	var seats: Int {
		get {
			var count = 0
			for num in incumbency.values {
				count += num
			}
			return count
		}
	}

	init?(id: String, data: [String: Any], election: Election) {
		guard let rawType = data["type"] as? Int, let type = RaceType(rawValue: rawType), let state = data["state"] as? String, let incumbency = data["incumbency"] as? [String: Int] else { return nil }
		self.election = election
		self.id = id
		self.incumbency = incumbency
		self.state = state
		self.type = type
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
		if let splits = data["splits"] as? Bool {
			self.splits = splits
		} else {
			self.splits = false
		}
	}
	
	func updateRace(withData data: [String: Any]) {
		if let results = data["results"] as? [String: Int] {
			self.results = results
		}
	}
	
	func racesForState(activeOnly: Bool = false) -> [Race] {
		return election.racesForState(self.state, activeOnly: activeOnly)
	}
}
