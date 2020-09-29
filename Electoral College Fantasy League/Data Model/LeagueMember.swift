//
//  LeagueMember.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/25/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class LeagueMember: NSObject, Identifiable, Comparable, ObservableObject {

	static func < (lhs: LeagueMember, rhs: LeagueMember) -> Bool {
		if lhs.score != rhs.score {
			return lhs.score > rhs.score
		} else if lhs.name != rhs.name {
			return lhs.name < rhs.name
		} else {
			return lhs.id < rhs.id
		}
	}
	
	var id: String
	var name: String
	var member: Bool
	var scores = [String: Double]()
	
	var score: Double {
		get {
			//TODO: Make reduce
			var total: Double = 0
			for score in scores.values {
				total += score
			}
			return total
		}
	}
	
	init(id: String, name: String?, member: Bool) {
		self.id = id
		self.name  = name ?? "Unknown"
		self.member = member
	}
	
	func updateFrom(_ data: [String: Any], member: Bool) {
		guard let name = data["name"] as? String else { return }
		self.name = name
		self.member = member
	}
	
	func updateScore(_ score: Double, forRaceWithID raceID: String) {
		scores[raceID] = score
		objectWillChange.send()
	}
	
}
