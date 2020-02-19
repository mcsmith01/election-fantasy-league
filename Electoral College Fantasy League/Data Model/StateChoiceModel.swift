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
			if let prediction = race.prediction?.prediction {
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
					if updated {
						showWarning = true
					} else {
						updateRace()
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
	var numbers: [String: Int] {
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
	@Published var saving: Bool = false
	@Published var showWarning: Bool = false
	var called: Bool {
		return race.results != nil
	}
	
	init(race: Race, isClosed: Bool) {
		self.race = race
		self.raceID = race.id
		self.isClosed = isClosed
	}
	
	func updateRace() {
		self.race = self.allRaces.first(where: { $0.id == self.raceID })!
	}

	func colorForPrediction() -> Color {
		return Color.blend(numbers)
	}
	
	func colorForResults() -> Color {
		return Color.blend(race.results ?? [:])
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
		Functions.functions().httpsCallable("makePrediction").call(payload) {
			(_, error) in
			self.saving = false
			completion(error)
		}
	}
	
//	func colorForResults() -> Color {
//		if let 
//	}
	
}
