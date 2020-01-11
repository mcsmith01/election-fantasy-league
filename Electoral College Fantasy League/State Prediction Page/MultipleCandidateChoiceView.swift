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
	var democratsLabel: String {
		if let candidates = model.race.candidates, let name = candidates["d"] {
			return name
		} else {
			return "Democrats"
		}
	}
	
	var body: some View {
		VStack {
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
