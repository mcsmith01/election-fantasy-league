//
//  LeaguesModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/8/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class LeaguesModel: NSObject, ObservableObject {
	
	var allLeagues = Set<League>()
	var memberLeagues: [League] {
		return allLeagues.filter({ $0.status == .member }).sorted()
	}
	var pendingLeagues: [League] {
		return allLeagues.filter({ $0.status == .pending }).sorted()
	}
	@Published var leagueRequests = 0

	func updateOrCreateLeague(withID id: String, data: [String: Any]) {
		// TODO: Perform filter on update?
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.updateInfoFrom(data)
			leagueRequests = allLeagues.filter({ $0.ownerID == UserData.userID && $0.pendingMembers.count > 0 }).count
		} else if let league = League(id: id, data: data) {
			allLeagues.insert(league)
			// TODO: Could a league be added that has an existing pending request?
		}
	}
	
	func updateActiveMembersForLeague(withID id: String, data: [String: [String: Any]]) {
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.updateActiveMembers(fromData: data)
			objectWillChange.send()
		}
	}
	
	func addPendingMemberToLeague(withID id: String, playerID: String, data: [String: Any]) {
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.addPendingMember(withID: playerID, fromData: data)
			objectWillChange.send()
		}
	}
	
	func removePendingMemberFromLeague(withID id: String, playerID: String) {
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.removePendingMember(withID: playerID)
			objectWillChange.send()
		}
	}
	
	@discardableResult func updateMemberStatusForLeague(withID id: String, data: [String: Any]) -> League? {
		if let league = allLeagues.first(where: { $0.id == id }), let member = data["member"] as? Bool {
			league.status = member ? .member : .pending
			objectWillChange.send()
			return league
		} else {
			return nil
		}
	}
	
	func removeMembershipFromLeague(withID id: String) -> League? {
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.status = .none
			objectWillChange.send()
			return league
		} else {
			return nil
		}
	}
	
	func updateScores(forLeagueWithID id: String, withData data: [String: Double], forRaceWithID raceID: String) {
		if let league = allLeagues.first(where: { $0.id == id }) {
			league.updateScores(fromData: data, forRaceWithID: raceID)
		}
	}
	
	func removeLeague(withID id: String) {
		if let league = allLeagues.first(where: { $0.id == id }) {
			allLeagues.remove(league)
			leagueRequests = allLeagues.filter({ $0.ownerID == UserData.userID && $0.pendingMembers.count > 0 }).count
		}
	}
	
	func clearAll() {
		allLeagues.removeAll()
		leagueRequests = 0
	}
	
}
