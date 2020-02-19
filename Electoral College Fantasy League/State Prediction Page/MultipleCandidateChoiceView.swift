//
//  MultipleCandidateChoiceView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/2/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct MultipleCandidateChoiceView: View {
	@ObservedObject var model: StateChoiceModel
	var labels: (dems: String, inds: String, reps: String) {
		if let candidates = model.race.candidates {
			let dem = candidates["d"] ?? "Democrat"
			let ind = candidates["i"] ?? ""
			let rep = candidates["r"] ?? "Republican"
			return (dem, ind, rep)
		} else {
			return ("Democrats", "Independents", "Republicans")
		}
	}
	
	var body: some View {
		VStack {
			if model.called {
				Spacer()
				MultipleCandidateResultsView(race: model.race)
			} else {
				GeometryReader { geometry in
					HStack {
						Spacer()
						VerticalSliderView(num: self.$model.demNum, model: self.model, title: self.labels.dems, color: Color(Colors.democrat), height: geometry.size.height, width: geometry.size.width / 5)
						if self.labels.inds != "" {
							Spacer()
							VerticalSliderView(num: self.$model.indNum, model: self.model, title: self.labels.inds, color: Color(Colors.independent), height: geometry.size.height, width: geometry.size.width / 5)
						}
						Spacer()
						VerticalSliderView(num: self.$model.repNum, model: self.model, title: self.labels.reps, color: Color(Colors.republican), height: geometry.size.height, width: geometry.size.width / 5)
						Spacer()
					}
					.disabled(self.model.isClosed)
				}
				HStack {
					Text("Too Close to Call:")
					Text("\(self.model.tccNum >= 0 ? self.model.tccNum : 0)")
					Spacer()
				}
				.padding(.horizontal)
			}
		}
	}
}

//struct MultipleCandidateChoiceView_Previews: PreviewProvider {
//	static var previews: some View {
//		MultipleCandidateChoiceView(total: 10)
//	}
//}

struct VerticalSliderView: View {
	@Binding var num: Double
	@ObservedObject var model: StateChoiceModel
	var title: String
	var color: Color
	var height: CGFloat
	var width: CGFloat
	
	var body: some View {
		VStack {
			HStack {
				Text(Int(truncating: num).description)
					.rotationEffect(.degrees(90))
				Slider(value: $num, in: 0...Double(model.totalSeats), step: 1.0, onEditingChanged: {
					(change) in
					if self.model.tccNum < 0 {
						self.num += Double(self.model.tccNum)
					}
				})
					.accentColor(color)
			}
			.padding(.leading)
			.frame(width: height)
			Text(title)
		}
		.rotationEffect(.degrees(-90))
		.frame(maxWidth: width, maxHeight: height)
	}
}

//struct VerticalSliderView_Previews: PreviewProvider {
//	@State static var count: Double = 3
//	static var total = 10
//	static var remaining: Int {
//		return total - Int(truncating: count)
//	}
//
//	static var previews: some View {
//		VerticalSliderView(num: $count, remainingNum: remaining, totalNum: total, title: "Democrats", color: Color(Colors.democrat), height: 200, width: 75)
//			.border(Color.green)
//	}
//}

struct MultipleCandidateResultsView: View {
	var race: Race
	var prediction: [String: Int] {
		return race.prediction?.prediction ?? [:]
	}
	var results: [String: Int] {
		return race.results ?? [:]
	}
	var accuracy: Double {
		return (race.prediction?.accuracy ?? 0) * 100
	}
	var score: Double {
		return race.prediction?.score ?? 0
	}
	var predictionString: String {
		if let prediction = race.prediction?.prediction {
//			return "D: \(prediction["d"] ?? 0) / I: \(prediction["i"] ?? 0) / R: \(prediction["r"] ?? 0)"
			return "\(prediction["d"] ?? 0) / \(prediction["i"] ?? 0) / \(prediction["r"] ?? 0)"
		} else {
			return "None"
		}
	}
	var resultsString: String {
		if let results = race.results {
//			return "D: \(results["d"] ?? 0) / I: \(results["i"] ?? 0) / R: \(results["r"] ?? 0)"
			return "\(results["d"] ?? 0) / \(results["i"] ?? 0) / \(results["r"] ?? 0)"
		} else {
			return "None"
		}
	}
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				VStack {
					Text("Prediction")
					Text(predictionString)
						.padding()
						.foregroundColor(.white)
						.background(Color.blend(prediction))
						.modifier(RectangleBorder())
				}
				.padding(.trailing)
				VStack {
					Text("Winner")
					Text(resultsString)
						.padding()
						.foregroundColor(.white)
						.background(Color.blend(results))
						.modifier(RectangleBorder())
				}
				Spacer()
			}
			.padding(.bottom)			
			HStack {
				VStack(alignment: .trailing) {
					Text("Accuracy:")
					Text("Score:")
				}
				.padding(.trailing)
				VStack(alignment: .leading) {
					Text(String(format: "%.2f%@", accuracy, "%"))
					Text(String(format: "%.2f", score))
				}
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
