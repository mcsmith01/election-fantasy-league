//
//  StateChoiceModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/4/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
		
class StateChoiceModel: ObservableObject {

	@Published var race: Race {
		didSet {
			updateNumbers()
			raceID = race.id
			updated = false
		}
	}
	var allRaces: [Race] {
		get {
			return race.racesForState(activeOnly: true).sorted()
		}
	}
	var raceID: String {
		didSet {
			if raceID != race.id {
				nextRace = self.allRaces.first(where: { $0.id == self.raceID })!
			}
		}
	}
	private var nextRace: Race {
		didSet {
			if updated {
				showWarning = true
			} else {
				withAnimation {
					updateRace()
				}
			}
		}
	}
	@Published var candidateID: String = "" { didSet { updated = true } }
	@Published var demNum: Double = 0  { didSet { updated = true } }
	@Published var repNum: Double = 0  { didSet { updated = true } }
	@Published var indNum: Double = 0  { didSet { updated = true } }
	var tccNum: Int {
		return totalSeats - Int(truncating: demNum + repNum + indNum)
	}
	var totalSeats: Int {
		return race.seats
	}
	var isClosed: Bool
	var updated = false
	private var numbers: [String: Int] {
		get {
			let numbers: [String: Int]
			if race.type == .house || race.splits {
				numbers = ["d": Int(truncating: demNum), "i": Int(truncating: indNum), "r": Int(truncating: repNum), "t": tccNum]
			} else {
				numbers = [candidateID: totalSeats]
			}
			return numbers
		}
	}
	private var savedNumbers: [String: Int]?
	@Published var saving: Bool = false
	@Published var showWarning: Bool = false
	var called: Bool {
		return race.results != nil
	}
	@Published var showIncumbents = false {
		didSet {
			if showIncumbents {
				savedNumbers = numbers
			}
			updateNumbers()
		}
	}
	
	init(race: Race, isClosed: Bool) {
		self.race = race
		self.nextRace = race
		self.raceID = race.id
		self.isClosed = isClosed
	}
	
	func updateRace() {
		race = nextRace
	}

	func colorForPrediction() -> Color {
		return Color.blend(numbers)
	}
	
	func colorForResults() -> Color {
		return Color.blend(race.results ?? [:])
	}
	
	func colorForIncumbency() -> Color {
		return Color.blend(race.incumbency ?? [:])
	}
	
	func backgroundForState() -> LinearGradient {
		if called {
			let predictionColor = Color.blend(race.prediction?.prediction ?? [:])
			let resultsColor = Color.blend(race.results ?? [:])
			return LinearGradient(gradient: Gradient(colors: [predictionColor, resultsColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
		} else {
			let color = Color.blend(numbers)
			return LinearGradient(gradient: Gradient(colors: [color, color]), startPoint: .topLeading, endPoint: .bottomTrailing)
		}

	}
	
	func savePrediction(completion: @escaping (Error?) -> Void) {
		saving = true
		let payload: [String: Any] = ["prediction": numbers, "election": race.election.id, "race": race.id]
		debugPrint(payload)
		Functions.functions().httpsCallable("makePrediction").call(payload) {
			(_, error) in
			self.saving = false
			completion(error)
		}
	}
	
	func changeRaceTo(_ newRace: Race) {
		nextRace = newRace
	}

	func updateNumbers() {
		let updateSave = updated
		if showIncumbents {
			if race.type == .house || race.splits {
				demNum = Double(race.incumbency?["d"] ?? 0)
				indNum = Double(race.incumbency?["i"] ?? 0)
				repNum = Double(race.incumbency?["r"] ?? 0)
			} else {
				candidateID = race.incumbency!.keys.first!
			}
		} else if let savedNumbers = savedNumbers {
			if race.type == .house || race.splits {
				demNum = Double(savedNumbers["d"] ?? 0)
				indNum = Double(savedNumbers["i"] ?? 0)
				repNum = Double(savedNumbers["r"] ?? 0)
			} else {
				candidateID = savedNumbers.keys.first!
			}
			self.savedNumbers = nil
		} else if let prediction = race.prediction?.prediction {
			if race.type == .house || race.splits {
				demNum = Double(prediction["d"] ?? 0)
				indNum = Double(prediction["i"] ?? 0)
				repNum = Double(prediction["r"] ?? 0)
			} else {
				candidateID = prediction.keys.first!
			}
		} else {
			if race.type == .house || race.splits {
				demNum = 0
				indNum = 0
				repNum = 0
			} else {
				candidateID = ""
			}
		}
		updated = updateSave
	}
	
	func getNextRace() -> Race {
		return race.election.nextRace(after: race)
	}
	
	func getPrevRace() -> Race {
		return race.election.nextRace(before: race)
	}
	
}
