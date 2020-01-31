//
//  LeaguesView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/5/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct LeaguesView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@State var navigationTag: Int?
	@State var joinLeague: League?
	
	var body: some View {
		NavigationView {
			VStack {
				List {
					ForEach(electionModel.election.leagues.filter({ $0.activeMembers.contains(where: { $0.id == UserData.userID }) }).sorted()) { league in
						NavigationLink(destination: LeagueInfoView(league: league)) {
							LeagueRow(league: league)
						}
						.padding(.trailing)
						.modifier(RectangleBorder())
					}
					if electionModel.election.leagues.filter({ $0.pendingMembers.contains(where: { $0.id == UserData.userID }) }).count > 0 {
						Section(header: Text("Pending Leagues")) {
							ForEach(electionModel.election.leagues.filter({ $0.pendingMembers.contains(where: { $0.id == UserData.userID }) }).sorted()) { league in
								LeagueRow(league: league)
									.foregroundColor(.gray)
									.modifier(RectangleBorder())
							}
							.onDelete(perform: removeAppliction)
						}
					}
				}
				NavigationLink(destination: FindLeagueView()) {
					Text("Find a League")
						.foregroundColor(.primary)
						.padding()
						.modifier(RectangleBorder())
						.padding(.bottom)
				}
			}
			.navigationBarTitle("My Leagues")
			.navigationBarItems(trailing: Button("Create") { self.navigationTag = 1 })
			.sheet(item: $navigationTag) { (tag) in
				if tag == 1 {
					CreateLeagueView()
						.environmentObject(self.electionModel)
				}
			}
		}
	}
	
	func removeAppliction(at offset: IndexSet) {
		debugPrint("Remove League Appliction")
	}
	
}

struct LeaguesView_Previews: PreviewProvider {
	static var previews: some View {
		LeaguesView()
	}
}

struct LeagueRow: View {
	@ObservedObject var league: League
	
	var body: some View {
		ZStack {
			Color.primary.colorInvert()
			VStack(alignment: .leading) {
				HStack {
					Text(league.name)
						.underline(league.owner == UserData.userID)
						.font(league.owner == UserData.userID ? Font.body.bold() : nil)
					if league.owner == UserData.userID && league.pendingMembers.count > 0 {
						Image(systemName: "exclamationmark.circle.fill")
							.foregroundColor(.orange)
						
					}
					Spacer()
				}
				Text("\t\(league.activeMembers.count) member\(league.activeMembers.count != 1 ? "s" : "")")
					.font(.subheadline)
			}
			.padding()
			.background(
				Image("flag")
					.opacity(0.1)
			)
		}
	}
}
