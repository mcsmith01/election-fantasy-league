//
//  LeagueInfoView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/26/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct LeagueInfoView: View {
	
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var electionModel: ElectionModel
	@ObservedObject var league: League
	@State var editMode: EditMode = .inactive
	@State var alert: IdentifiableAlert?
	var raceTypesString: String {
		let typesArray = league.raceTypes.sorted().map { (type) -> String in
			String(describing: type).capitalized
		}
		return typesArray.joined(separator: ", ")
	}
	
	var body: some View {
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Text("Commissioner:")
						.font(Font.body.bold())
						.padding(.horizontal)
					Text(league.ownerName)
						.padding(.horizontal)
					Text("Scored Races:")
						.font(Font.body.bold())
						.padding([.horizontal, .top])
					Text(raceTypesString)
						.padding(.horizontal)
					Text("Membership:")
						.font(Font.body.bold())
						.padding([.horizontal, .top])
					Text(league.isOpen ? "Open" : "Restricted")
						.padding(.horizontal)
				}
				Spacer()
			}
			.onAppear() {
				debugPrint(self.league.id)
			}
			.alert(item: $alert) { (alert) -> Alert in
				return alert.alert
			}
			if league.status == .member {
				List {
					Section(header: Text("Members")) {
						ForEach(league.activeMembers) { member in
							MemberRow(member: member, owner: self.league.ownerID, ranking: self.league.rankingFor(member))
						}
						.onDelete(perform: delete)
					}
					if league.ownerID == UserData.userID && league.pendingMembers.count > 0 {
						Section(header: Text("Pending")) {
							ForEach(league.pendingMembers) { member in
								HStack {
									Image(systemName: "plus.circle.fill")
										.foregroundColor(.green)
										.onTapGesture {
											let confirm = Alert.Button.default(Text("Confirm")) {
												self.electionModel.processLeagueRequest(league: self.league, player: member, accept: true) { (error) in
													if let error = error {
														debugPrint("Error accepting member\n\(error)")
													}
												}
											}
											let alert = Alert(title: Text("Add \(member.name) to \(self.league.name)?"), primaryButton: confirm, secondaryButton: .cancel())
											self.alert = IdentifiableAlert(alert: alert)
									}
									Text(member.name)
									Image(systemName: "minus.circle.fill")
										.foregroundColor(.red)
										.onTapGesture {
											let confirm = Alert.Button.default(Text("Confirm")) {
												self.electionModel.processLeagueRequest(league: self.league, player: member, accept: false) { (error) in
													if let error = error {
														debugPrint("Error declining member\n\(error)")
													}
												}
											}
											let alertText = Alert(title: Text("Decline \(member.name)'s application to \(self.league.name)?"), primaryButton: confirm, secondaryButton: .cancel())
											self.alert = IdentifiableAlert(alert: alertText)
									}
									Spacer()
								}
								.foregroundColor(.gray)
								.padding()
								.modifier(RectangleBorder())
							}
						}
					}
				}
			} else if league.status == .pending {
				Spacer()
				Button("Cancel Application") {
					let primary = Alert.Button.destructive(Text("Proceed")) {
						self.electionModel.removeFromLeague(league: self.league, playerID: UserData.userID) { (error) in
							if let error = error {
								debugPrint("Error withdrawing application from league\n\(error)")
							} else {
								self.presentationMode.wrappedValue.dismiss()
							}
						}
					}
					let alertText = Alert(title: Text("Withdraw application to \(self.league.name)?"), message: nil, primaryButton: primary, secondaryButton: .cancel())
					self.alert = IdentifiableAlert(alert: alertText)
				}
				.padding()
				.foregroundColor(.white)
				.background(Color.republican)
				.clipShape(Capsule())
			} else if league.status == .none {
				Spacer()
				Button("Join League") {
					let primary = Alert.Button.destructive(Text("Join")) {
						self.electionModel.joinLeague(self.league) { (error) in
							if let error = error {
								debugPrint("Error joining league\n\(error)")
							} else {
								self.presentationMode.wrappedValue.dismiss()
							}
						}
					}
					let alertText = Alert(title: Text("Join '\(self.league.name)'?"), message: self.league.isOpen
						? nil : Text("This is a closed league; the league commissioner must approve your request"), primaryButton: primary, secondaryButton: .cancel())
					self.alert = IdentifiableAlert(alert: alertText)
				}
				.padding()
				.foregroundColor(.white)
				.background(Color("democrat"))
				.clipShape(Capsule())
			}
			Spacer()
			if editMode == .active {
				if league.ownerID == UserData.userID {
					Button("Delete") {
						let primary = Alert.Button.destructive(Text("Delete League")) {
							self.electionModel.deleteLeague(self.league) { (error) in
								if let error = error {
									debugPrint("Error deleting league\n\(error)")
								} else {
									self.presentationMode.wrappedValue.dismiss()
								}
							}
						}
						let alert = Alert(title: Text("Delete '\(self.league.name)'?"), message: Text("This action cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
						self.alert = IdentifiableAlert(alert: alert)
					}
					.padding(.horizontal)
					.foregroundColor(.white)
					.background(Color.republican)
					.clipShape(Capsule())
					.padding(.bottom)
				} else if league.status == .member {
					Button("Leave") {
						let primary = Alert.Button.destructive(Text("Leave League")) {
							self.electionModel.status = "Leaving \(self.league.name)"
							self.electionModel.removeFromLeague(league: self.league, playerID: UserData.userID) { (error) in
								self.electionModel.status = nil
								if let error = error {
									debugPrint("Error leaving league\n\(error)")
								}
								self.presentationMode.wrappedValue.dismiss()
							}
						}
						let alert = Alert(title: Text("Leave \(self.league.name)?"), message: Text("This action cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
						self.alert = IdentifiableAlert(alert: alert)
					}
					.padding(.horizontal)
					.foregroundColor(.white)
					.background(Color.republican)
					.clipShape(Capsule())
					.padding(.bottom)
				}
			}
			
		}
		.navigationBarItems(trailing: EditButton())
		.listStyle(GroupedListStyle())
		.navigationBarTitle(league.name)
		.environment(\.editMode, $editMode)
		//		.navigationBarItems(trailing: league.status != .none ? EditButton() : EditButton().hidden())
	}
	
	func delete(at offset: IndexSet) {
		if let index = offset.first {
			let member = league.activeMembers[index]
			let primary = Alert.Button.default(Text("Remove")) {
				self.electionModel.removeFromLeague(league: self.league, playerID: member.id) { (error) in
					if let error = error {
						debugPrint("Error removing member from league\n\(error)")
					}
				}
			}
			let alert = Alert(title: Text("Remove \(member.name) from \(league.name)?"), message: Text("This operation cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
			self.alert = IdentifiableAlert(alert: alert)
		}
	}
	
}

//struct LeagueInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeagueInfoView()
//    }
//}

struct MemberRow: View {
	@ObservedObject var member: LeagueMember
	var owner: String
	var ranking: Double
	
	var body: some View {
		HStack {
			Text(member.id == UserData.userID ? "Me" : member.name)
				.underline(owner == member.id)
				.font(UserData.userID == member.id ? Font.body.bold() : Font.body)
			Spacer()
			Text(String(format: "%.2f", member.score))
		}
		.deleteDisabled(owner == member.id || owner != UserData.userID)
		.padding()
		.modifier(ScoreCell(score: ranking))
		.onAppear() {
			debugPrint("\(self.member.name) \(self.ranking)")
		}
	}
}
