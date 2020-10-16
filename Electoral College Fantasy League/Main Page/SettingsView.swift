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
	@State var showRules = false

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
			Text("EFL Scoring Guidelines")
				.font(.title)
				.padding()
			ScrollView {
				VStack {
					Spacer()
					Section(header: Text("General Scoring"), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("Due to COVID-19 and the increase in mail-in and absentee balloting this year, the game will oficially end at 11:59 PM on Friday, November 6th. If you believe that a race will be officially called in a sstate, pick the candidate you feel will be victorious. If you believe that a state's election will still be undecided by that time, choose \"Too Close to Call.\"")
							BulletedText("While you can join as many leagues as you would like, you can only make one prediction per race and this prediction is used in all of your leagues.")
						}
					}
					Section(header: Text("Presidential, Senatorial, and Gubernatorial Races").multilineTextAlignment(.center), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("Your score is based on the total nnumber of correct predictions. You raw score will be determined against all other players, with points earned being in the range of 0 - total number of players. Equal points will be awarded to all players who predicted correctly.")
							BulletedText("For example, if there are 1000 players and 50 correctly predicted the winner, each of those players will earn 20 points.")
						}
					}
					Section(header: Text("House Races"), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("For each state, use the sliding bar to predict the outcome of the Houe delegation for that state. If you feel that any of the House races will be undecided by the end of the game, leave those seats unallocated as \"Too Close to Call\". Points are awarded proportional to how many seats you correctly predicted relative to all players.")
							BulletedText("For example, if you correctly predicted 5 out of 7 seats in a particular race and the average of all of the players was 4 correect seats, you would earn 5/4, or 1.25, points.")
						}
					}
					Section(header: Text("League Scoring"), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("Your score in a particular league is generated in the same mannner as your overall score, except points are distributed according to how other players in your league did.")
							BulletedText("Your score in each league can vary significantly due to this, particularly if the other members are significantly more or less accurate than the average of all players.")
							BulletedText("When you create a league, you can choose to score races of any or all types.")
						}
					}
					Section(header: Text("Presidential Race Errata"), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("Maine and Nebraska split their electors; the scoring for the Presidential race in those states is calculated the same as for House races.")
						}
					}
					Section(header: Text("Senatorial Race Errata"), footer: Text(" ")) {
						VStack(alignment: .leading) {
							BulletedText("Georgia has two elections, one standard Senate race and one Special Election primary for the other seat. Each race will be scored independently.")
							BulletedText("Louisina has a jungle primary; the candidate with the most votes, even if that candidate does not earn 50% of the vote.")
						}
					}
				}
			}
			.padding(.horizontal)
		}
	}
}

struct ScoringRulesView_Previews: PreviewProvider {
	static var previews: some View {
		ScoringRulesView()
	}
}

struct BulletedText: View {
	var text: String
	var body: some View {
		HStack(alignment: .top) {
			Text("•")
			Text(text).font(.subheadline)
		}
	}
	
	init(_ text: String) {
		self.text = text
	}
}
