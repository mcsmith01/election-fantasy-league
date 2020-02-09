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
	@ObservedObject var model: StateChoiceModel
	@State var alertMessage: AlertMessage?

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				VStack {
					HStack {
						Button("Cancel") {
							self.presentationMode.wrappedValue.dismiss()
						}
						.foregroundColor(.white)
						.padding(.horizontal)
						.background(Color.republican)
						.clipShape(Capsule())
						Spacer()
						Button("Save") {
							self.model.savePrediction() { (error) in
								if let error = error {
									self.alertMessage = AlertMessage(text: error.localizedDescription)
								} else {
									self.presentationMode.wrappedValue.dismiss()
								}
							}
						}
						.foregroundColor(.white)
						.padding(.horizontal)
						.background(!self.model.updated ? Color.gray : Color.democrat)
						.clipShape(Capsule())
						.disabled(!self.model.updated)
					}
					.padding()
					Text("\(self.model.race.state)\(self.model.race.type == .president ? " (\(self.model.race.seats))" : "")")
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
							.padding(.horizontal)
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
				}
				.blur(radius: self.model.saving ? 3 : 0)
				.disabled(self.model.saving)
				.alert(isPresented: self.$model.showWarning) { () -> Alert in
					let saveButton = Alert.Button.default(Text("Save")) {
						self.model.savePrediction { (error) in
							if let error = error {
								self.alertMessage = AlertMessage(text: error.localizedDescription)
							}
							self.model.updateRace()
						}
					}
					let cancelButton = Alert.Button.cancel(Text("Discard")) {
						self.model.updateRace()
					}
					return Alert(title: Text("Save changes made to \(self.model.race.state) \(String(describing: self.model.race.type).capitalized) race?"), primaryButton: saveButton, secondaryButton: cancelButton)
				}
				.onAppear {
					self.model.updateRace()
				}
				if self.model.saving {
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
