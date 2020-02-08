//
//  Election.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/11/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class Election: NSObject, Comparable {
	
	static func < (lhs: Election, rhs: Election) -> Bool {
		if lhs.date != rhs.date {
			return lhs.date > rhs.date
		} else {
			return lhs.id < rhs.id
		}
	}
	
	let id: String
	let name: String
	let date: Date
	var raceTypes = Set<RaceType>()
	var races = [Race]()
	var leagues = Set<League>()
	var alerts = [ElectionAlert]()
	
	init?(id: String, data: [String: Any]) {
		guard let name = data["name"] as? String, let dateString = data["date"] as? String, let date = Objects.dateFormatter.date(from: dateString) else {
			return nil
		}
		self.id = id
		self.name = name
		self.date = date
	}
	
	func racesOfType(_ type: RaceType, activeOnly: Bool = true) -> [Race] {
		return races.filter({ $0.type == type && ($0.isActive || !activeOnly) })
	}

	func racesForState(_ state: String, activeOnly: Bool = false) -> [Race] {
		return races.filter({ $0.state == state && ($0.isActive || !activeOnly) })
	}
	
	func updateOrCreateRace(withID id: String, data: [String: Any]) {
		if let race = races.first(where: {$0.id == id}) {
			race.updateRace(withData: data)
		} else if let race = Race(id: id, data: data, election: self) {
			races.append(race)
			raceTypes.insert(race.type)
		}
	}
	
	func updateOrCreateAlert(withID id: String, data: [String: Any]) {
		if let alert = alerts.first(where: {$0.id == id}) {
			alert.updateFrom(data)
		} else if let alert = ElectionAlert(id: id, data: data) {
			alerts.append(alert)
			alerts.sort()
		}
	}
	
	func setPredictionForRace(withID id: String, predictionID pid: String, data: [String: Any]) {
		if let race = races.first(where: { $0.id == id }) {
			if let prediction = race.prediction {
				prediction.updatePrediction(withData: data)
			} else {
				race.prediction = Prediction(id: pid, data: data)
			}
		}
	}
	
	func updateOrCreateLeague(withID id: String, data: [String: Any]) {
		if let league = leagues.first(where: { $0.id == id }) {
			league.updateFrom(data)
		} else if let league = League(id: id, data: data) {
			leagues.insert(league)
		}
	}
	
	func removeLeague(withID id: String) {
		if let league = leagues.first(where: { $0.id == id }) {
			leagues.remove(league)
		}
	}
	
	func unreadAlerts() -> Bool {
		return alerts.contains(where: { !$0.read })
	}
	
	func pendingLeagueRequests() -> Bool {
		return leagues.contains(where: { $0.owner == UserData.userID && $0.pendingMembers.count > 0 })
	}

}
