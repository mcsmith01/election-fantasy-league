//
//  NumbersModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/9/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class NumbersModel: NSObject, ObservableObject {
	
	@Published var demText = ""
	@Published var indText = ""
	@Published var repText = ""

	var dems: Int = 0
	var inds: Int = 0
	var reps: Int = 0
	var safeDems: Int = 0
	var safeInds: Int = 0
	var safeReps: Int = 0
	
	var results = false {
		didSet {
			updateNumbers()
		}
	}
	var races = [Race]() {
		didSet {
			updateNumbers()
		}
	}
	
	func updateNumbers() {
		dems = 0
		inds = 0
		reps = 0
		safeDems = 0
		safeReps = 0
		safeInds = 0
		
		for race in races {
			if !results {
				if let prediction = race.prediction {
					for (party, count) in prediction.prediction {
						if party.starts(with: "d") {
							dems += count
						} else if party.starts(with: "i") {
							inds += count
						} else if party.starts(with: "r") {
							reps += count
						}
					}
				}
			} else {
				if let results = race.results {
					for (party, count) in results {
						if party.starts(with: "d") {
							dems += count
						} else if party.starts(with: "i") {
							inds += count
						} else if party.starts(with: "r") {
							reps += count
						}
					}
				}
			}
			if let safety = race.safety {
				for (party, count) in safety {
					if party.starts(with: "d") {
						safeDems += count
					} else if party.starts(with: "i") {
						safeInds += count
					} else if party.starts(with: "r") {
						safeReps += count
					}
				}
			}
		}
		demText = "\(dems)\(safeDems > 0 ? " (\(dems + safeDems))" : "")"
		indText = "\(inds)\(safeInds > 0 ? " (\(inds + safeInds))" : "")"
		repText = "\(reps)\(safeReps > 0 ? " (\(reps + safeReps))" : "")"
	}
	
}
