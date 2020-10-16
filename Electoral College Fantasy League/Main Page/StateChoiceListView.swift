//
//  StateChoiceListView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/1/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct StateChoiceListView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@Binding var selectedRace: Race?
	
	var body: some View {
		List(electionModel.election.racesOfType(electionModel.raceType).sorted(), id: \.id) { race in
			StateRow(race: race, showResults: self.electionModel.showResults)
				.onTapGesture {
					self.selectedRace = race
			}
				.listRowBackground(Color.blue)
		}
		.listRowBackground(Color.blue)
	}
	
}

//struct StateChoiceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        StateChoiceListview()
//    }
//}

struct StateRow: View {
	@ObservedObject var race: Race
	var showResults: Bool
	
	var color: Color {
		if showResults {
			if let results = race.results {
				return Color.blend(results)
			} else {
				return Color.primary
			}
		} else {
			if let prediction = race.prediction {
				return Color.blend(prediction.prediction)
			} else {
				return Color.primary
			}
		}
	}
	
	var gradient: Gradient {
		if showResults {
			if let results = race.results {
				return Color.gradient(results)
			} else {
				return Gradient(colors: [Color.primary])
			}
		} else {
			if let prediction = race.prediction {
				return Color.gradient(prediction.prediction)
			} else {
				return Gradient(colors: [Color.primary])
			}
		}
	}

	var body: some View {
		ZStack {
			if color == .primary {
				color.colorInvert()
			} else {
				color
			}
			HStack {
				Text("\(race.state)\(race.type == .president || race.type == .house ? " (\(race.seats))" : "")")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.foregroundColor(color == .primary ? Color.primary : .white)
			.padding()
		}
		.modifier(RectangleBorder())
	}
	
}
