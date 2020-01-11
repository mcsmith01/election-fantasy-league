//
//  MainPageView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/1/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct MainPageView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@State var whichList = "Predictions"
	@State var selectedRace: Race?
	@State var navigationTag: Int?
	
	var body: some View {
		VStack {
			Picker(selection: $electionModel.raceType, label: EmptyView()) {
				ForEach(electionModel.allRaceTypes, id: \.self) { raceType in
					Text(String(describing: raceType).capitalized)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.horizontal)
			ElectionMapView()
				.animation(.easeInOut)
			Section(header:
				Picker(selection: $whichList, label: EmptyView()) {
					ForEach(["Predictions", "Results"]) { choice in
						Text(choice)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding(.horizontal)) {
					StateChoiceListView(selectedRace: $selectedRace)
			}
			NavigationLink(destination: LeaguesView(), tag: 1, selection: $navigationTag) {
				EmptyView()
			}
		}
		.navigationBarTitle(electionModel.name)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(trailing: Button(
			action: { self.navigationTag = 1 },
			label: {
				HStack {
					Text("Leagues")
					Image(systemName: "chevron.right")
				}
		})
		)
			.sheet(item: $selectedRace, onDismiss: { self.electionModel.refresh.toggle() }) { (selected) in
			StateChoiceView(race: selected).environmentObject(self.electionModel)
		}
	}
	
	init() {
		UITableView.appearance().separatorColor = .clear
	}
	
}

//struct MainPageView_Previews: PreviewProvider {
//    static var previews: some View {
//		MainPageView(election: Election.fetchCurrent())
//    }
//}
