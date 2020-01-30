//
//  LeagueInfoView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/26/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct LeagueInfoView: View {
	@EnvironmentObject var electionModel: ElectionModel
	var league: League
	@State var addMember: LeagueMember?
	@State var declineMember: LeagueMember?
	@State var removeMember: LeagueMember?
	
	var body: some View {
		List {
			Section(header: Text("Members")) {
				ForEach(league.activeMembers) { member in
					MemberRow(member: member, owner: self.league.owner)
				}
				.onDelete(perform: delete)
			}
			if league.owner == UserData.userID && league.pendingMembers.count > 0 {
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
								.padding(.trailing)
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
						.clipShape(rowShape)
						.overlay(
							rowShape
								.stroke(Color.primary, lineWidth: 3)
						)
					}
				}
			}
		}
		.alert(item: $removeMember) { (member) -> Alert in
			let primary = Alert.Button.default(Text("Remove")) {
				self.electionModel.removeFromLeague(league: self.league, player: member) { (error) in
					if let error = error {
						debugPrint("Error removing member from league\n\(error)")
					}
				}
			}
			return Alert(title: Text("Remove \(member.name) from \(league.name)?"), message: Text("This operation cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
		}
		.navigationBarItems(trailing: EditButton().disabled(league.owner != UserData.userID))
		.listStyle(GroupedListStyle())
		.navigationBarTitle(league.name)
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
	var member: LeagueMember
	var owner: String
	
	var body: some View {
		HStack {
			Text(member.id == UserData.userID ? "Me" : member.name)
				.underline(owner == member.id)
				.font(UserData.userID == member.id ? Font.body.bold() : Font.body)
			Spacer()
			Text(String(format: "%.2f", member.score))
		}
		.deleteDisabled(owner == member.id)
		.padding()
		.clipShape(rowShape)
		.overlay(
			rowShape
				.stroke(Color.primary, lineWidth: 3)
		)

	}
}
