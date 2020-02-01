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
				ForEach(electionModel.election.leagues.filter({ !$0.containsMember(withID: UserData.userID) && $0.searchFilter(searchText) }).sorted()) { league in
					LeagueRow(league: league)
						.padding(.trailing)
						.modifier(RectangleBorder())
						.onTapGesture {
							self.joinLeague = league
					}
				}
			}
		}
		.alert(item: $joinLeague) { (league) -> Alert in
			let confirm = Alert.Button.default(Text("Join")) {
				self.electionModel.joinLeague(league) { (error) in
					if let error = error {
						debugPrint("Error creating league\n\(error)")
					}
				}
			}
			return Alert(title: Text("Join \(league.name)?"), message: !league.isOpen ? Text("This is a closed league and will require the owner to approve your membership") : nil, primaryButton: confirm, secondaryButton: .cancel())
		}
		.navigationBarTitle("All Leagues")
    }
}

struct FindLeagueView_Previews: PreviewProvider {
    static var previews: some View {
        FindLeagueView()
    }
}
