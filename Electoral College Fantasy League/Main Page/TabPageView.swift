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
	@State var selectedTab = 0
	
    var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottomLeading) {
				TabView(selection: self.$selectedTab) {
					MainPageView()
//					Text("Map")
						.tabItem {
							if self.selectedTab == 0 {
								Image(systemName: "flag.fill")
							} else {
								Image(systemName: "flag")
							}
							Text("Races")
						}
					.tag(0)
					AlertsView()
//					Text("Alerts")
						.tabItem {
							if self.selectedTab == 1 {
								Image(systemName: "exclamationmark.bubble.fill")
							} else {
								Image(systemName: "exclamationmark.bubble")
							}
							Text("Alerts")
						}
					.tag(1)
					LeaguesView()
//					Text("League")
						.tabItem {
							if self.selectedTab == 2 {
								Image(systemName: "person.3.fill")
							} else {
								Image(systemName: "person.3")
							}
							Text("Leagues")
						}
					.tag(2)
				}
				.accentColor(.democrat)
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
