//
//  StateChoiceView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/1/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct StateChoiceView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var electionModel: ElectionModel
	@ObservedObject var model: StateChoiceModel
	@State var isSaving = false
	@State var alertMessage: AlertMessage?

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				VStack {
					HStack {
						Button(self.model.updated ? "Cancel" : "Dismiss") {
							self.presentationMode.wrappedValue.dismiss()
						}
						.foregroundColor(.red)
						Spacer()
						Button("Save") {
							withAnimation {
								self.isSaving = true
							}
							self.electionModel.savePrediction(self.model.numbers, forRace: self.model.race) { (error) in
								withAnimation {
									self.isSaving = false
								}
								if let error = error {
									self.alertMessage = AlertMessage(text: error.localizedDescription)
								} else {
									self.presentationMode.wrappedValue.dismiss()
								}
							}
						}
						.disabled(!self.model.updated)
					}
					.padding()
					Text(self.model.race.state)
						.font(.title)
					Image(self.model.race.state)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: geometry.size.height / 2)
						.colorMultiply(self.model.colorForPrediction())
						.shadow(color: .gray, radius: 5)
						.animation(.easeInOut)
					if self.model.race.type == .house || self.model.race.splits {
						MultipleCandidateChoiceView(model: self.model)
							.padding(.horizontal)
							.animation(.easeInOut)
					} else {
						SingleCandidateChoiceView(model: self.model)
							.padding()
							.animation(.easeInOut)
					}
					Spacer()
					Picker(selection: self.$model.raceID, label: EmptyView()) {
						ForEach(self.model.allRaces) { race in
							Text(String(describing: race.type).capitalized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding(.horizontal)
					.frame(alignment: .bottom)
				}
				.alert(isPresented: self.$model.showWarning) { () -> Alert in
					let saveButton = Alert.Button.default(Text("Save")) {
						withAnimation {
							self.isSaving = true
						}
						self.electionModel.savePrediction(self.model.numbers, forRace: self.model.race) { (error) in
							withAnimation {
								self.isSaving = false
							}
							if let error = error {
								self.alertMessage = AlertMessage(text: error.localizedDescription)
							}
							debugPrint("Updating Model")
							self.model.updateRace()
							debugPrint(self.model.race.type)
						}
					}
					let cancelButton = Alert.Button.cancel(Text("Discard")) {
						self.model.updateRace()
					}
					return Alert(title: Text("Save changes made to \(self.model.race.state) \(String(describing: self.model.race.type).capitalized) race?"), primaryButton: saveButton, secondaryButton: cancelButton)
				}
				.blur(radius: self.isSaving ? 3 : 0)
				.disabled(self.isSaving)
				.onAppear {
					self.model.updateRace()
				}
				if self.isSaving {
					BusyInfoView(text: "Saving...")
						.transition(.scale)
				}
			}
		}
	}
	
	init(race: Race) {
		self.model = StateChoiceModel(race: race)
	}
	
}

//struct StateChoiceView_Previews: PreviewProvider {
//	static var previews: some View {
//
//	}
//}

struct ImageTestView: View {
	var state = "Alabama"
	
	var body: some View {
		Image(self.state)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.contrast(0)
			.brightness(1)
			.colorMultiply(Color(Colors.getColor(for: nil)))
			.shadow(color: .gray, radius: 5)
	}
}

struct ImageTestView_Previews: PreviewProvider {
	static var previews: some View {
		ImageTestView()
	}
}
