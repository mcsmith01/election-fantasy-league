//
//  ElectionMapView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/1/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct ElectionMapView: View {
	@EnvironmentObject var electionModel: ElectionModel
	
	var body: some View {
		ZStack {
			Image("map_background")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.colorMultiply(Color(.sRGB, white: 0.35, opacity: 1))
				.shadow(color: .gray, radius: 5)
			ForEach(electionModel.election.racesOfType(electionModel.raceType, activeOnly: false)) { race in
				MapPiece(race: race, showResults: self.electionModel.showResults)
			}
			Image("map_outline")
				.resizable()
				.aspectRatio(contentMode: .fit)
		}
	}
	
}

//struct ElectionMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElectionMapView()
//    }
//}

struct MapPiece: View {
	@ObservedObject var race: Race
	var showResults: Bool
	
	var body: some View {
		Image("\(race.state)_piece")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.colorMultiply(self.colorFor(race))
	}
	
	func colorFor(_ race: Race) -> Color {
		if !race.isActive {
			return .gray
		} else if showResults {
			if let results = race.results {
				return Color.blend(results)
			} else {
				return .white
			}
		} else {
			if let prediction = race.prediction {
				return Color.blend(prediction.prediction)
			} else {
				return .white
			}
		}
	}
}
