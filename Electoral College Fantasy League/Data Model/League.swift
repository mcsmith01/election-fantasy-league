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
	
	enum MemberStatus {
		case member
		case pending
		case none
	}
	
	var id: String
	var name: String
	var isOpen: Bool
	var ownerID: String
	var ownerName: String
	var desc: String?
	@Published var memberCount: Int
	@Published var status: MemberStatus = .none
	var raceTypes: Set<RaceType>
	var allMembers = Set<LeagueMember>()
	var activeMembers = [LeagueMember]()
	var pendingMembers = [LeagueMember]()

	init?(id: String, data: [String: Any]) {
		guard let name = data["name"] as? String, let isOpen = data["isOpen"] as? Bool, let owner = data["owner"] as? [String: String], let ownerName = owner["name"], let ownerID = owner["id"], let races = data["raceTypes"] as? [Int], let memberCount = data["members"] as? Int else { return nil }
		self.id = id
		self.name = name
		self.isOpen = isOpen
		self.ownerID = ownerID
		self.ownerName = ownerName
		self.memberCount = memberCount
		self.raceTypes = Set<RaceType>()
		for rawRace in races {
			if let race = RaceType(rawValue: rawRace) {
				self.raceTypes.insert(race)
			}
		}
		super.init()
	}

	func updateInfoFrom(_ data: [String: Any]) {
		guard let name = data["name"] as? String, let memberCount = data["members"] as? Int else { return }
		self.name = name
		self.memberCount = memberCount
	}
	
	func updateActiveMembers(fromData data: [String: [String: Any]]) {
		activeMembers.removeAll()
		for (memberID, info) in data {
			if let member = allMembers.first(where: { $0.id == memberID }) {
				member.updateFrom(info, member: true)
				activeMembers.append(member)
			} else if let name = info["name"] as? String {
				let member = LeagueMember(id: memberID, name: name, member: true)
				activeMembers.append(member)
			}
		}
		allMembers.removeAll()
		allMembers.formUnion(activeMembers)
		allMembers.formUnion(pendingMembers)
		activeMembers.sort()
		objectWillChange.send()
	}
	
	func addPendingMember(withID playerID: String, fromData data: [String: Any]) {
		if let name = data["name"] as? String {
			let member = LeagueMember(id: playerID, name: name, member: false)
			pendingMembers.append(member)
			allMembers.insert(member)
			pendingMembers.sort()
			objectWillChange.send()
		}
	}
	
	func removePendingMember(withID playerID: String) {
		if let index = pendingMembers.firstIndex(where: { $0.id == playerID }) {
			let member = pendingMembers.remove(at: index)
			allMembers.remove(member)
			objectWillChange.send()
		}
	}
	
	func updateScores(fromData data: [String: Double], forRaceWithID raceID: String) {
		for (player, score) in data {
			if let member = allMembers.first(where: { $0.id == player }) {
				member.updateScore(score, forRaceWithID: raceID)
			} else {
				let member = LeagueMember(id: player, name: nil, member: true)
				member.updateScore(score, forRaceWithID: raceID)
				activeMembers.append(member)
			}
		}
		activeMembers.sort()
		objectWillChange.send()
	}
	
	func containsMember(withID id: String) -> Bool {
		return allMembers.contains(where: {$0.id == id} )
	}
	
	func searchFilter(_ text: String) -> Bool {
		return text == "" || name.contains(text)
	}
	
	func rankingFor(_ member: LeagueMember) -> Double {
		let fewer = activeMembers.filter({ $0.score < member.score}).count
		let greater = activeMembers.filter({ $0.score > member.score}).count
		return Double(fewer + 1) / Double(greater + 1)
	}
	
}
