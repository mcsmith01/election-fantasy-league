//
//  ScoresView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/15/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct ScoresView: View {
	@EnvironmentObject var electionModel: ElectionModel
	var totalScore: Double {
		return electionModel.election.calledRaces().reduce(0.0) { (total, race) in
			if let score = race.prediction?.score {
				return total + score
			} else {
				return total
			}
		}
	}
	
    var body: some View {
		NavigationView {
		List {
			Text("Total: \(String(format: "%.2f", totalScore))")
			ForEach(electionModel.election.raceTypes.sorted()) { type in
				Section(header: Text("\(String(describing: type).capitalized) - \(String(format: "%.2f", self.scoreForType(type)))")) {
					ForEach(self.racesForType(type)) { race in
						HStack {
							Text(race.state)
							Spacer()
							Text("\(String(format: "%.2f", race.prediction?.score ?? 0.0))")
						}
						.padding()
						.modifier(RectangleBorder())
					}
				}
			}
		}
		.navigationBarTitle("Scores")
		}
	}
	
	func racesForType(_ type: RaceType) -> [Race] {
		return electionModel.election.calledRaces().filter({ $0.type == type }).sorted()
	}
	
	func scoreForType(_ type: RaceType) -> Double {
		return racesForType(type).reduce(0.0) { (total, race) in
			if let score = race.prediction?.score {
				return total + score
			} else {
				return total
			}
		}

	}
}

struct ScoresView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresView()
    }
}
