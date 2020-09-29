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
	@State var showVisual = true
	@State var showMap = true
	@State var showSettings = false
	@State var viewIndex = 0
	var viewArray: [AnyView] {
		return [AnyView(ElectionMapView().padding(.bottom)), AnyView(ElectionGraphView(model: electionModel.numbersModel).padding())]
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
					if showVisual {
						PagedView(index: $viewIndex, showView: $showVisual, pages: viewArray)
//							.transition(.move(edge: .top))
							.transition(.scale(scale: 0.0, anchor: .top))
					}
					NumbersView(model: electionModel.numbersModel, smallSize: $showVisual)
				}
				.animation(.easeInOut)
				.gesture(
					DragGesture()
						.onEnded { (value) in
							if value.translation.height < -50 {
								withAnimation {
									self.showVisual = false
								}
							} else if value.translation.height > 25 {
								withAnimation {
									self.showVisual = true
								}
							} else if abs(value.translation.width) > 50 {
								withAnimation(Animation.spring()) {
									self.showMap.toggle()
								}
							}
					}
				)
				Section(header:
					Picker(selection: $electionModel.listIndex, label: EmptyView()) {
						ForEach(0..<electionModel.lists.count) { index in
							Text(self.electionModel.lists[index])
						}
					}
//					.disabled(!electionModel.predictionsLocked)
					.pickerStyle(SegmentedPickerStyle())
					.padding(.horizontal)) {
						StateChoiceListView(selectedRace: $selectedRace)
				}
			}
			.sheet(item: $selectedRace) { (selected) in
				StateChoiceView(race: selected, isClosed: self.electionModel.predictionsLocked)
			}
			.navigationBarTitle(electionModel.name)
			.navigationBarItems(trailing:
				HStack {
					Button(
						action: { self.showSettings = true },
						label: {
							Image(systemName: "gear")
					})
						.sheet(isPresented: $showSettings) {
							SettingsView().environmentObject(self.electionModel)
					}
				}
				.imageScale(Image.Scale.large)
			)
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

struct NumbersView: View {
	@ObservedObject var model: NumbersModel
	@Binding var smallSize: Bool
	
	var body: some View {
		HStack {
			Spacer()
			NumberCell(text: model.demText, color: Color("democrat"), oversized: !smallSize)
			if model.indText != "0" {
				Spacer()
				NumberCell(text: model.indText, color: .independent, oversized: !smallSize)
			}
			Spacer()
			NumberCell(text: model.repText, color: .republican, oversized: !smallSize)
			Spacer()
		}
	}
}

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
	
}
