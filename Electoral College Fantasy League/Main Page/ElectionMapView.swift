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
			Image("outline 2016")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.brightness(1)
				.shadow(color: .gray, radius: 5)
			ForEach(electionModel.election.racesOfType(electionModel.raceType, activeOnly: false), id: \.id) { race in
				Image("\(race.state!)_piece")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.colorMultiply(self.colorFor(race))
			}
			Image("map_outline")
				.resizable()
				.aspectRatio(contentMode: .fit)
		}
	}
	
	func colorFor(_ race: Race) -> Color {
		if !race.isActive {
			return Color.gray
		} else if let prediction = race.prediction {
			return Color(prediction.getColor())
		} else {
			return .white
		}
	}
	
}

//struct ElectionMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElectionMapView()
//    }
//}
