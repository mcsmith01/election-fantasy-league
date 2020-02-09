//
//  Prediction.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/11/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation
import SwiftUI

class Prediction {
	var id: String
	var raceID: String
	var prediction: [String: Int]
	var leagueScores: [String: Double]?
	var rawScore: Double?
	var weightedScore: Double?
	
	init?(id: String, data: [String: Any]) {
		guard let prediction = data["prediction"] as? [String: Int], let race = data["race"] as? String else { return nil }
		self.id = id
		self.raceID = race
		self.prediction = prediction
//		updatePrediction(withData: data)
		if let score = data["rawScore"] as? Double {
			rawScore = score
		}
		if let score = data["weightedScore"] as? Double {
			weightedScore = score
		}
	}
	
//	func updatePrediction(withData data: [String: Any]) {
//		guard let prediction = data["prediction"] as? [String: Int] else { return }
//		self.prediction = prediction
//		if let score = data["rawScore"] as? Double {
//			rawScore = score
//		}
//		if let score = data["weightedScore"] as? Double {
//			weightedScore = score
//		}
//	}

}
