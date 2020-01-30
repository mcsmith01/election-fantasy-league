//
//  League.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/25/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class League: NSObject, Identifiable, Comparable, ObservableObject {
	
	static func < (lhs: League, rhs: League) -> Bool {
		if lhs.name != rhs.name {
			return lhs.name < rhs.name
		} else {
			return lhs.id < rhs.id
		}
	}
	
	var id: String
	var name: String
	var isOpen: Bool
	var owner: String
	var raceTypes: Set<RaceType>
	var allMembers = Set<LeagueMember>()
	var activeMembers = [LeagueMember]()
	var pendingMembers = [LeagueMember]()
	@Published var refresh = false

	init?(id: String, data: [String: Any]) {
		guard let name = data["name"] as? String, let isOpen = data["isOpen"] as? Bool, let owner = data["owner"] as? String, let races = data["raceTypes"] as? [Int], let _ = data["members"] as? [String: [String: Any]] else { return nil }
		self.id = id
		self.name = name
		self.isOpen = isOpen
		self.owner = owner
		self.raceTypes = Set<RaceType>()
		for rawRace in races {
			if let race = RaceType(rawValue: rawRace) {
				self.raceTypes.insert(race)
			}
		}
		super.init()
		updateFrom(data)
	}

	func updateFrom(_ data: [String: Any]) {
		guard let members = data["members"] as? [String: [String: Any]] else { return }
		allMembers.removeAll()
		for (memberID, info) in members {
			if let member = LeagueMember(id: memberID, data: info) {
				allMembers.insert(member)
			}
		}
		activeMembers = self.allMembers.filter({ $0.member }).sorted(by: { $0.score != $1.score ? $0.score > $1.score : $0 < $1 })
		pendingMembers = self.allMembers.filter({ !$0.member }).sorted(by: { $0.score != $1.score ? $0.score > $1.score : $0 < $1 })
		refresh.toggle()
	}
	
	func containsMember(withID id: String) -> Bool {
		return allMembers.contains(where: {$0.id == id} )
	}
	
}
