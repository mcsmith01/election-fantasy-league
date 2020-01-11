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
			StateRow(race: race)
				.onTapGesture {
					self.selectedRace = race
			}
		}
	}
	
}

//struct StateChoiceListView_Previews: PreviewProvider {
//    static var previews: some View {
//        StateChoiceListview()
//    }
//}

struct StateRow: View {
	@EnvironmentObject var electionModel: ElectionModel
	var race: Race
	var color: Color {
		if let prediction = race.prediction {
			return Color(prediction.getColor())
		} else {
			return Color.primary
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
				Text(race.state!)
					.foregroundColor(color == .primary ? Color.primary : .white)
				Spacer()
				Image(systemName: "chevron.right")
			}
			.padding()
		}
		.clipShape(Capsule())
		.overlay(
			Capsule()
				.stroke(Color.primary, lineWidth: 3)
		)
	}
}
