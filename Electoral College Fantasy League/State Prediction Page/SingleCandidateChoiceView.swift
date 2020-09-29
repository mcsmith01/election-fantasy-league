//
//  SingleCandidateChoiceView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/2/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct SingleCandidateChoiceView: View {
	@ObservedObject var model: StateChoiceModel
	
	var candidates: [String: String] {
		if model.showIncumbents {
			let party = model.race.incumbency?.keys.first ?? ""
			switch party {
			case "d": return ["d": "Democrat"]
			case "r": return ["r": "Republican"]
			case "i": return ["i": "Independent"]
			default: return ["t": "No Incumbent"]
			}
		} else {
			return model.race.candidates ?? [:]
		}
	}
	var partyList: [String] {
		var list = candidates.keys.sorted()
		if !model.showIncumbents {
			list.append("t")
		}
		return list
	}
	
	var body: some View {
		VStack {
			if model.called {
				SingleCandidateResultsView(race: model.race)
			} else {
				Picker(selection: $model.candidateID, label: EmptyView()) {
					ForEach(partyList, id: \.self) { party in
						Text(self.candidates[party] ?? "Too Close to Call")
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.disabled(model.isClosed)
				.padding(.top)
				Spacer()
			}
		}
	}
	
}

struct SingleCandidateResultsView: View {
	var race: Race
	var prediction: String {
		if let prediction = race.prediction, let candidateID = prediction.prediction.keys.first {
			return candidateID
		} else {
			return ""
		}
	}
	var winner: String {
		if let results = race.results, let candidateID = results.keys.first {
			return candidateID
		} else {
			return ""
		}
	}
	var score: Double {
		return race.prediction?.score ?? 0
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				VStack {
					Text("Prediction")
					Text("\(race.candidates?[prediction] ?? "None")")
						.padding()
						.foregroundColor(.white)
						.background(Color.blend([prediction: 1]))
						.modifier(RectangleBorder())
				}
				.padding(.trailing)
				VStack {
					Text("Winner")
					Text("\(race.candidates?[winner] ?? "No Results Yet")")
						.padding()
						.foregroundColor(.white)
						.background(Color.blend([winner: 1]))
						.modifier(RectangleBorder())
				}
				Spacer()
			}
			.padding(.bottom)
			HStack {
				Text("Score:")
					.padding(.trailing)
				Text(String(format: "%.2f", score))
			}
			.font(Font.title.bold())
			.padding()
			.background(
				Image("american_flag")
					.opacity(0.1)
			)
			.modifier(RectangleBorder())
			Spacer()
		}
	}
	
}
