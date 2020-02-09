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
		NavigationView{
			VStack {
				Picker(selection: $electionModel.raceType, label: EmptyView()) {
					ForEach(electionModel.election.raceTypes.sorted(), id: \.self) { raceType in
						Text(String(describing: raceType).capitalized)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding(.horizontal)
				ZStack(alignment: .bottom) {
					if showMap {
						ElectionMapView()
							.padding(.bottom)
							.transition(.scale(scale: 0.0, anchor: .top))
					}
					HStack {
						Spacer()
						NumberCell(text: "\(numbers.dems)", color: Colors.democrat, oversized: !showMap)
						if numbers.inds > 0 {
							Spacer()
							NumberCell(text: "\(numbers.inds)", color: Colors.independent, oversized: !showMap)
						}
						Spacer()
						NumberCell(text: "\(numbers.reps)", color: Colors.republican, oversized: !showMap)
						Spacer()
					}
				}
				.animation(.easeInOut)
				.gesture(
					DragGesture()
						.onEnded { (value) in
							if value.translation.height < -50 {
								withAnimation {
									self.showMap = false
								}
							} else if value.translation.height > 25 {
								withAnimation {
									self.showMap = true
								}
							}
					}
				)
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
			}
			.navigationBarTitle(electionModel.name)
			.sheet(item: $selectedRace) { (selected) in
				StateChoiceView(race: selected)
			}
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
	var oversized: Bool
	
	var body: some View {
		Text(text)
			.font(oversized ? Font.largeTitle : Font.body)
			.foregroundColor(.white)
			.padding(.horizontal)
			.background(color.opacity(0.65))
			.clipShape(Capsule())
			.overlay(Capsule().stroke(color, lineWidth: 2))
	}
	
	init(text: String, color: UIColor, oversized: Bool) {
		self.text = text
		self.color = Color(color)
		self.oversized = oversized
	}
	
}
