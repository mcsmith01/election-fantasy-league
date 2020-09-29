//
//  SettingsView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/9/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@State var logoutAlert = false

	var body: some View {
		VStack {
			HStack {
				Button("Dismiss") {
					self.presentationMode.wrappedValue.dismiss()
				}
				.foregroundColor(.white)
				.padding(.horizontal)
				.background(Color.republican)
				.clipShape(Capsule())
				Spacer()
			}
			.padding()
			HStack {
				VStack(alignment: .leading) {
					Text("Name: \(UserData.data[.name] as? String ?? "Unknown")")
						.font(.system(size: 25))
						.padding(.bottom)
					Text("Email: \(UserData.data[.email] as? String ?? "Unknown")")
				}
				.padding()
				Spacer()
			}
			Spacer()
			Button("Log Out") {
				self.logoutAlert = true
			}
			.foregroundColor(.white)
			.padding(.horizontal)
			.background(Color.republican)
			.clipShape(Capsule())
		}
		.alert(isPresented: $logoutAlert) { () -> Alert in
			let primary = Alert.Button.default(Text("Log Out")) {
				self.electionModel.logout()
				self.presentationMode.wrappedValue.dismiss()
			}
			return Alert(title: Text("Log Out?"), message: nil, primaryButton: primary, secondaryButton: .cancel())
		}
    }
	
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}

struct ScoringRulesView: View {
	
	var body: some View {
		VStack {
			Section(header: Text("Raw Score").bold(), footer: Text(" ")) {
				Text("• One point for each race")
				Text("• Partial points for House races based on accuracy")
			}
			Section(header: Text("Overall Score").bold()) {
				VStack {
					Text("• Raw score weighted according to accuracy of all players")
				}
			}
			Section(header: Text("League Score").bold()) {
				VStack {
					Text("• Raw score weighted according to accuracy of all players")
				}
			}
		}
	}
}

struct ScoringRulesView_Previews: PreviewProvider {
    static var previews: some View {
        ScoringRulesView()
    }
}
