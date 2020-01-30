//
//  LeagueMember.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/25/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class LeagueMember: NSObject, Identifiable, Comparable {

	static func < (lhs: LeagueMember, rhs: LeagueMember) -> Bool {
		if lhs.score != rhs.score {
			return lhs.score < rhs.score
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
			var total: Double = 0
			for score in scores.values {
				total += score
			}
			return total
		}
	}
	
	init?(id: String, data: [String: Any]) {
		guard let name = data["name"] as? String, let member = data["member"] as? Bool else { return nil }
		self.id = id
		self.name  = name
		self.member = member
	}
	
	func updateFrom(_ data: [String: Any]) {
		guard let member = data["member"] as? Bool else { return }
		self.member = member
	}
	
	func updateScores(data: [String: Double]) {
		for (race, score) in data {
			scores[race] = score
		}
	}
	
}
