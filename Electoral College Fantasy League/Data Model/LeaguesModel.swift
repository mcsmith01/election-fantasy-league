//
//  LeaguesModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/8/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class LeaguesModel: NSObject, ObservableObject {
	
	@Published var leagueRequests = 0

	var leagues = Set<League>()

	func updateOrCreateLeague(withID id: String, data: [String: Any]) {
		if let league = leagues.first(where: { $0.id == id }) {
			league.updateFrom(data)
			leagueRequests = leagues.filter({ $0.owner == UserData.userID && $0.pendingMembers.count > 0 }).count
		} else if let league = League(id: id, data: data) {
			leagues.insert(league)
		}
	}
	
	func removeLeague(withID id: String) {
		if let league = leagues.first(where: { $0.id == id }) {
			leagues.remove(league)
		}
	}

}
