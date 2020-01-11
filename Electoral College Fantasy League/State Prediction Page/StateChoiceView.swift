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
							self.model.savePrediction() {
								self.presentationMode.wrappedValue.dismiss()
							}
						}
						.disabled(!self.model.updated)
					}
					.padding()
					Text(self.model.race.state!)
						.font(.title)
					Image(self.model.race.state!)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: geometry.size.height / 2)
						.colorMultiply(self.model.colorForPrediction())
						.shadow(color: .gray, radius: 5)
						.animation(.easeInOut)
					if self.model.race.raceType == .house || self.model.race.splits {
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
						ForEach(self.model.allRaces, id: \.id!) { race in
							Text(String(describing: race.raceType).capitalized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding(.horizontal)
					.frame(alignment: .bottom)
				}
				.alert(isPresented: self.$model.showWarning) { () -> Alert in
					let saveButton = Alert.Button.default(Text("Save")) {
						self.model.savePrediction() {
							self.model.updateRace()
						}
					}
					let cancelButton = Alert.Button.cancel(Text("Discard")) {
						self.model.updateRace()
					}
					return Alert(title: Text("Save changes made to \(self.model.race.state!) \(String(describing: self.model.race.raceType).capitalized) race?"), primaryButton: saveButton, secondaryButton: cancelButton)
				}
				.blur(radius: self.model.isSaving ? 3 : 0)
				.disabled(self.model.isSaving)
				.onAppear {
					self.model.updateRace()
				}
				if self.model.isSaving {
					Color.primary.colorInvert()
						.frame(width: geometry.size.width / 2, height: geometry.size.width / 2)
						.cornerRadius(25)
						.shadow(color: .gray, radius: 5)
					VStack {
						Spacer()
						ActivityView(isAnimating: .constant(true), style: .large)
							.background(Color.primary.colorInvert())
							.foregroundColor(.primary)
						Text("Saving...")
						Spacer()
					}
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
//		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
