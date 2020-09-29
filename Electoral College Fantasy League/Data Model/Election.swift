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
			debugPrint("Updated \(race.state) \(race.type)")
			race.updateRace(withData: data)
		} else if let race = Race(id: id, data: data, election: self) {
			races.append(race)
			raceTypes.insert(race.type)
		} else {
			debugPrint("Could not create race \(id) with type \(data["type"] as? Int ?? -1)")
		}
	}
	
	func calledRaces() -> [Race] {
		return races.filter({ $0.results != nil }).sorted(by: {
			if $0.type != $1.type {
				return $0.type < $1.type
			} else {
				return $0 < $1
			}
		})
	}
	
	func setPredictionForRace(withID id: String, predictionID pid: String, data: [String: Any]) {
		if let race = races.first(where: { $0.id == id }) {
				race.prediction = Prediction(id: pid, data: data)
		}
	}
	
	func nextRace(after race: Race) -> Race {
		let races = racesOfType(race.type).sorted()
		let index = races.firstIndex(of: race)?.advanced(by: 1)
		if let index = index, index < races.count {
			return races[index]
		} else {
			return races.first!
		}
	}
	
	func nextRace(before race: Race) -> Race {
		let races = racesOfType(race.type).sorted()
		let index = races.firstIndex(of: race)?.advanced(by: -1)
		if let index = index, index >= 0 {
			return races[index]
		} else {
			return races.last!
		}
	}
	
}
