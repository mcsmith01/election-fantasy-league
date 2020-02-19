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
	@State var addMember: LeagueMember?
	@State var declineMember: LeagueMember?
	@State var removeMember: LeagueMember?
	@State var deleteLeague = false
	@State var leaveLeague = false
	var raceTypesString: String {
		let typesArray = league.raceTypes.sorted().map { (type) -> String in
			String(describing: type).capitalized
		}
		return typesArray.joined(separator: ", ")
	}
	
	var body: some View {
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
			if league.status == .member {
				List {
					Section(header: Text("Members")) {
						ForEach(league.activeMembers) { member in
							MemberRow(member: member, owner: self.league.ownerID)
						}
						.onDelete(perform: delete)
					}
					.alert(item: $removeMember) { (member) -> Alert in
						let primary = Alert.Button.default(Text("Remove")) {
							self.electionModel.removeFromLeague(league: self.league, playerID: member.id) { (error) in
								if let error = error {
									debugPrint("Error removing member from league\n\(error)")
								}
							}
						}
						return Alert(title: Text("Remove \(member.name) from \(league.name)?"), message: Text("This operation cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
					}
					if league.ownerID == UserData.userID && league.pendingMembers.count > 0 {
						Section(header: Text("Pending")) {
							ForEach(league.pendingMembers) { member in
								HStack {
									Image(systemName: "plus.circle.fill")
										.foregroundColor(.green)
										.alert(item: self.$addMember) { (member) -> Alert in
											let confirm = Alert.Button.default(Text("Confirm")) {
												self.electionModel.processLeagueRequest(league: self.league, player: member, accept: true) { (error) in
													if let error = error {
														debugPrint("Error accepting member\n\(error)")
													}
												}
											}
											return Alert(title: Text("Add \(member.name) to \(self.league.name)?"), primaryButton: confirm, secondaryButton: .cancel())
									}
									.onTapGesture {
										self.addMember = member
									}
									Text(member.name)
									Image(systemName: "minus.circle.fill")
										.foregroundColor(.red)
										.alert(item: self.$declineMember) { (member) -> Alert in
											let confirm = Alert.Button.default(Text("Confirm")) {
												self.electionModel.processLeagueRequest(league: self.league, player: member, accept: false) { (error) in
													if let error = error {
														debugPrint("Error accepting member\n\(error)")
													}
												}
											}
											return Alert(title: Text("Decline \(member.name)'s application to \(self.league.name)?"), primaryButton: confirm, secondaryButton: .cancel())
									}
									.onTapGesture {
										self.declineMember = member
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
				Button("Cancel Applicatioon") {
					debugPrint("Cancel Application")
				}
				.padding(.horizontal)
				.foregroundColor(.white)
				.background(Color.republican)
				.clipShape(Capsule())
				.padding()
			} else if league.status == .none {
				Button("Join League") {
					debugPrint("Cancel Application")
				}
				.padding(.horizontal)
				.foregroundColor(.white)
				.background(Color.democrat)
				.clipShape(Capsule())
				.padding()
			}
			Spacer()
			if editMode == .active {
				if league.ownerID == UserData.userID {
					Button("Delete") {
						self.deleteLeague = true
					}
					.padding(.horizontal)
					.foregroundColor(.white)
					.background(Color.republican)
					.clipShape(Capsule())
					.padding(.bottom)
					.alert(isPresented: $deleteLeague) { () -> Alert in
						let primary = Alert.Button.destructive(Text("Delete League")) {
							self.electionModel.deleteLeague(league: self.league) { (error) in
								if let error = error {
									debugPrint("Error deleting league\n\(error)")
								} else {
									self.presentationMode.wrappedValue.dismiss()
								}
							}
						}
						return Alert(title: Text("Delete \(self.league.name)?"), message: Text("This action cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
					}
				} else {
					Button("Leave") {
						self.leaveLeague = true
					}
					.padding(.horizontal)
					.foregroundColor(.white)
					.background(Color.republican)
					.clipShape(Capsule())
					.padding(.bottom)
					.alert(isPresented: $leaveLeague) { () -> Alert in
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
						return Alert(title: Text("Leave \(self.league.name)?"), message: Text("This action cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
					}
				}
			}
		}
		.navigationBarItems(trailing: EditButton())
		.listStyle(GroupedListStyle())
		.navigationBarTitle(league.name)
		.environment(\.editMode, $editMode)
	}
	
	func delete(at offset: IndexSet) {
		if let index = offset.first {
			removeMember = league.activeMembers[index]
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
		.modifier(RectangleBorder())
	}
}
