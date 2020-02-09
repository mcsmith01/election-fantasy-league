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
				MapPiece(race: race)
//				Image("\(race.state)_piece")
//					.resizable()
//					.aspectRatio(contentMode: .fit)
//					.colorMultiply(self.colorFor(race))
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
	
	var body: some View {
		Image("\(race.state)_piece")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.colorMultiply(self.colorFor(race))
	}
	
	func colorFor(_ race: Race) -> Color {
		if let prediction = race.prediction {
			return Color(Colors.getColor(for: prediction.prediction))
		} else {
			return .white
		}
	}
}
