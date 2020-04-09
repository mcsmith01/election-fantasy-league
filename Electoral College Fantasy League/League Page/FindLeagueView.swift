//
//  FindLeagueView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct FindLeagueView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@ObservedObject var leaguesModel: LeaguesModel
	@State var joinLeague: League?
	@State var searchText: String = ""
	
	var body: some View {
		List {
			Section(header: Text("Search")) {
				HStack {
					Image(systemName: "magnifyingglass")
						.foregroundColor(.gray)
					TextField("Search", text: $searchText)
				}
				.padding()
				.modifier(RectangleBorder(lineWidth: 1))
			}
			Section(header: Text("Leagues")) {
				ForEach(electionModel.leaguesModel.allLeagues.filter({ $0.status == .none && $0.searchFilter(searchText) }).sorted()) { league in
					NavigationLink(destination: LeagueInfoView(league: league)) {
						LeagueRow(league: league)
					}
					.padding(.trailing)
					.modifier(RectangleBorder())
				}
			}
		}
		.navigationBarTitle("All Leagues")
    }
}

//struct FindLeagueView_Previews: PreviewProvider {
//    static var previews: some View {
//        FindLeagueView()
//    }
//}
