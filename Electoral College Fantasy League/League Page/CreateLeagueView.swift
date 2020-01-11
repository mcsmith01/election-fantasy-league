//
//  CreateLeagueView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/6/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct CreateLeagueView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@State var name: String = ""
	@State var isOpen: Bool = false
	@State var races: String = "All"
	
	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section(header: Text("League Name")) {
						TextField("Name", text: $name)
					}
					Section() {
						Picker(selection: $races, label: Text("Scored Races")) {
							ForEach(["All", "President", "Senate", "House", "Governor", "President, Senate, House, Governor"]) { race in
								Text(race)
							}
						}
						MultiPickerLabel()
						Toggle(isOn: $isOpen) {
							Text("Open Membership")
						}
					}
				}
			}
			.navigationBarTitle("Create League", displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading:
				Button("Cancel") {
					self.presentationMode.wrappedValue.dismiss()
				}
				.foregroundColor(.red)
				, trailing:
				Button("Create") {
					self.presentationMode.wrappedValue.dismiss()
				}
			)
		}
	}
}


struct CreateLeagueView_Previews: PreviewProvider {
	static var previews: some View {
		CreateLeagueView()
	}
}

struct MultiPickerLabel: View {
	
	var body: some View {
		HStack {
			Text("Scored Races")
			Spacer()
			Text("President, Senate, House, Governor")
				.foregroundColor(.secondary)
			Image(systemName: "chevron.right")
				.brightness(1)
				.colorMultiply(.secondary)
		}
	}
}
