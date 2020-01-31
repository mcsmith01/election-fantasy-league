//
//  TabPageView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct TabPageView: View {
	@EnvironmentObject var electionModel: ElectionModel
	
    var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottomLeading) {
				TabView {
					MainPageView()
//					Text("Map")
						.tabItem {
							Image(systemName: "map")
							Text("Races")
						}
					AlertsView()
//					Text("Alerts")
						.tabItem {
							Image(systemName: "exclamationmark.bubble")
							Text("Alerts")
						}
					LeaguesView()
//					Text("League")
						.tabItem {
							Image(systemName: "person.3")
							Text("Leagues")
						}
				}
				Circle()
					.foregroundColor(.red)
					.frame(width: 10, height: 10)
					.offset(x: ((2 * 2 - 0.98) * (geometry.size.width / 6)) + 2, y: -33)
					.opacity(self.electionModel.election.unreadAlerts() ? 1 : 0)
				Circle()
					.foregroundColor(.red)
					.frame(width: 10, height: 10)
					.offset(x: ((2 * 3 - 0.9) * (geometry.size.width / 6)) + 2, y: -33)
					.opacity(self.electionModel.election.pendingLeagueRequests() ? 1 : 0)

			}
		}
    }
	
}

struct TabPageView_Previews: PreviewProvider {
    static var previews: some View {
        TabPageView()
    }
}
