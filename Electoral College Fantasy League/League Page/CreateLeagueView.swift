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
	@EnvironmentObject var electionModel: ElectionModel
	@State var name: String = ""
	@State var desc: String = ""
	@State var isOpen: Bool = true
	var pickerOptions: [String]  = {
		return ["President", "Senate",  "House", "Governor"]
	}()
	@State var selectedOptions = Set<Int>(0..<4)
	@State var navigationTag: Int?
	@State var isSaving = false
	
	var body: some View {
		ZStack {
			NavigationView {
				VStack {
					Form {
						Section(header: Text("League Name")) {
							TextField("Name", text: $name)
								.autocapitalization(.words)
						}
//						Section(header: Text("Description")) {
//							TextField("Description (Optional)", text: $desc)
//						}
						Section() {
							MultiPickerRow(options: pickerOptions, selectedOptions: $selectedOptions)
								.onTapGesture {
									self.navigationTag = 1
							}
							Toggle(isOn: $isOpen) {
								Text("Open Membership")
							}
						}
					}
					.blur(radius: self.isSaving ? 3 : 0)
					.disabled(self.isSaving)
					NavigationLink(destination: MultiPickerView(options: pickerOptions, selected: $selectedOptions), tag: 1, selection: $navigationTag) {
						EmptyView()
					}
				}
				.navigationBarTitle("Create League", displayMode: .inline)
				.navigationBarBackButtonHidden(true)
				.navigationBarItems(leading:
					Button("Cancel") {
						self.presentationMode.wrappedValue.dismiss()
					}
					.foregroundColor(.white)
					.padding(.horizontal)
					.background(Color.republican)
					.clipShape(Capsule())
					, trailing:
					Button("Create") {
						self.isSaving = true
						self.electionModel.createLeague(name: self.name, isOpen: self.isOpen, raceTypes: self.selectedOptions.sorted()) { (error) in
							self.isSaving = false
							if let error = error {
								debugPrint("Error creating league\n\(error)")
							} else {
								self.presentationMode.wrappedValue.dismiss()
							}
						}
					}
					.foregroundColor(.white)
					.padding(.horizontal)
					.background(name == "" ? Color.gray : Color.democrat)
					.clipShape(Capsule())
					.disabled(name == "")
				)
			}
			if self.isSaving {
				BusyInfoView(text: "Creating \(name)...")
					.transition(.scale)
			}
		}
	}
}


struct CreateLeagueView_Previews: PreviewProvider {
	static var previews: some View {
		CreateLeagueView()
	}
}

struct MultiPickerRow: View {
	var options: [String]
	@Binding var selectedOptions: Set<Int>
	
	var body: some View {
		HStack {
			Text("Scored Races")
			Spacer()
			Text(selectedString)
				.foregroundColor(.secondary)
			Image(systemName: "chevron.right")
				.brightness(1)
				.colorMultiply(.secondary)
		}
	}
	
	var selectedString: String {
		if selectedOptions.count == options.count {
			return "All"
		} else {
			var result = ""
			for index in selectedOptions.sorted() {
				if result == "" {
					result = options[index]
				} else {
					result += ", \(options[index])"
				}
			}
			return result
		}
	}
}
