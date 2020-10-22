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
	@State var collapsed = Set<RaceType>()
	
    var body: some View {
		NavigationView {
			List {
				ForEach(electionModel.election.raceTypes.sorted()) { type in
					Section(header: HStack {
						Text("\(String(describing: type).capitalized) - \(String(format: "%.2f", self.scoreForType(type)))")
						Image(systemName: collapsed.contains(type) ? "chevron.right" : "chevron.down")
					}
					.onTapGesture {
//						withAnimation {
						// TODO: Animate without cells overlapping title
						if collapsed.contains(type) {
							collapsed.remove(type)
						} else {
							collapsed.insert(type)
						}
//						}
					}) {
						if !collapsed.contains(type) {
							ForEach(self.racesForType(type)) { race in
								NavigationLink(destination: StateChoiceView(race: race, isClosed: true, canChange: false)) {
									HStack {
										Text(race.state)
										Spacer()
										Text("\(String(format: "%.2f", race.prediction?.score ?? 0.0))")
									}
									.padding()
									.background(Color.forScore(race.prediction?.score ?? 0.0))
									.modifier(RectangleBorder())
								}
							}
						}
						
					}
				}
			}
			.navigationBarTitle(Text("Score: \(String(format: "%.2f", totalScore()))"))
		}
	}
	
	func totalScore() -> Double {
		return electionModel.election.calledRaces().reduce(0.0) { (total, race) in
			if let score = race.prediction?.score {
				return total + score
			} else {
				return total
			}
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
