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
	@State var mapOffset = CGSize.zero
	@State var showMap = true
	var numbers: (dems: Int, inds: Int, reps: Int, total: Int) {
		get {
			return electionModel.getNumbers()
		}
	}

	var body: some View {
		VStack {
			Picker(selection: $electionModel.raceType, label: EmptyView()) {
				ForEach(electionModel.election.raceTypes.sorted(), id: \.self) { raceType in
					Text(String(describing: raceType).capitalized)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.horizontal)
			ZStack(alignment: .bottom) {
				ZStack {
					ElectionMapView()
						.padding(.bottom)
						.opacity(showMap ? 1.0 : 0.0)
				}
				HStack {
					Spacer()
					NumberCell(text: "\(numbers.dems)", color: Colors.democrat)
					if numbers.inds > 0 {
						Spacer()
						NumberCell(text: "\(numbers.inds)", color: Colors.independent)
					}
					Spacer()
					NumberCell(text: "\(numbers.reps)", color: Colors.republican)
					Spacer()
				}
			}
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
			.sheet(item: $selectedRace) { (selected) in
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

struct NumberCell: View {
	var text: String
	var color: Color
	
	var body: some View {
		Text(text)
			.foregroundColor(.white)
			.padding(.horizontal)
			.background(color.opacity(0.65))
			.clipShape(Capsule())
			.overlay(Capsule().stroke(color, lineWidth: 2))
	}
	
	init(text: String, color: UIColor) {
		self.text = text
		self.color = Color(color)
	}
}
