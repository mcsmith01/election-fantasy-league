//
//  Prediction.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/11/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class Prediction {
	var id: String
	var prediction: [String: Int]
	var leagueScores: [String: Double]?
	var rawScore: Double?
	
	init?(id: String, data: [String: Any]) {
		guard let prediction = data["prediction"] as? [String: Int] else { return nil }
		self.id = id
		self.prediction = prediction
		if let score = data["rawScore"] as? Double {
			rawScore = score
		}
	}
	
	func updatePrediction(withData data: [String: Any]) {
		guard let prediction = data["prediction"] as? [String: Int] else { return }
		self.prediction = prediction
		if let score = data["rawScore"] as? Double {
			rawScore = score
		}
	}

}
