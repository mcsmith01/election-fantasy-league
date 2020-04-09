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
	@ObservedObject var leaguesModel: LeaguesModel
	@State var navigationTag: Int?
	@State var findLeague = false
	@State var joinLeague: League?
	@State var withdrawApplication: League?
	
	var body: some View {
		NavigationView {
			List {
				ForEach(electionModel.leaguesModel.memberLeagues) { league in
					NavigationLink(destination: LeagueInfoView(league: league)) {
						LeagueRow(league: league)
					}
					.padding(.trailing)
					.modifier(RectangleBorder())
				}
				.alert(item: $withdrawApplication) { (league) -> Alert in
					let primary = Alert.Button.destructive(Text("Withdraw")) {
						self.electionModel.status = "Withdrawing application to \(league.name)"
						self.electionModel.removeFromLeague(league: league, playerID: UserData.userID) { (error) in
							self.electionModel.status = nil
							if let error = error {
								debugPrint("Error withdrawing application to league\n\(error)")
							}
						}
					}
					return Alert(title: Text("Withdraw application to \(league.name)?"), message: Text("This action cannot be undone"), primaryButton: primary, secondaryButton: .cancel())
				}
				if electionModel.leaguesModel.pendingLeagues.count > 0 {
					Section(header: Text("Pending Leagues")) {
						ForEach(electionModel.leaguesModel.pendingLeagues) { league in
							NavigationLink(destination: LeagueInfoView(league: league)) {
								LeagueRow(league: league)
							}
							.foregroundColor(.gray)
							.padding(.trailing)
							.modifier(RectangleBorder())
						}
					}
				}
			}
			.sheet(item: $navigationTag) { (tag) in
				if tag == 1 {
					CreateLeagueView()
						.environmentObject(self.electionModel)
				}
			}
			.navigationBarTitle("My Leagues")
			.navigationBarItems(trailing:
				HStack {
					NavigationLink(destination: FindLeagueView(leaguesModel: leaguesModel
					), label: { Image(systemName: "magnifyingglass.circle.fill") })
					Button(action: { self.navigationTag = 1 }, label: { Image(systemName: "plus.circle.fill") })
				}
				.imageScale(Image.Scale.large)
			)
//				.navigationBarTitle("")
//				.navigationBarItems(
//					leading: Text("My Leagues").font(.largeTitle).bold(),
//					trailing:
//					HStack {
//						Button(action: { self.findLeague = true }, label: { Image(systemName: "magnifyingglass.circle.fill") })
//						Button(action: { self.navigationTag = 1 }, label: { Image(systemName: "plus.circle.fill") })
//						NavigationLink(destination: FindLeagueView(), isActive: $findLeague, label: { EmptyView() })
//					}
//					.imageScale(Image.Scale.large)
//			)
		}
	}
	
	func removeAppliction(at offset: IndexSet) {
		debugPrint("Remove League Appliction")
	}
	
}

//struct LeaguesView_Previews: PreviewProvider {
//	static var previews: some View {
//		LeaguesView()
//	}
//}

struct LeagueRow: View {
	@ObservedObject var league: League
	
	var body: some View {
		ZStack {
			Color.primary.colorInvert()
			VStack(alignment: .leading) {
				HStack {
					Text(league.name)
						.underline(league.ownerID == UserData.userID)
						.font(league.ownerID == UserData.userID ? Font.body.bold() : nil)
					if league.ownerID == UserData.userID && league.pendingMembers.count > 0 {
						Image(systemName: "exclamationmark.circle.fill")
							.foregroundColor(.orange)
						
					}
					Spacer()
				}
				Text("\t\(league.memberCount) member\(league.memberCount != 1 ? "s" : "")")
					.font(.subheadline)
			}
			.padding()
			.background(
				Image("american_flag")
					.opacity(0.1)
			)
		}
	}
}
