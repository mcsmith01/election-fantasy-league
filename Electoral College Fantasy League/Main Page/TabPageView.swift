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
						.tabItem {
							Image(systemName: "flag\(self.selectedTab == 0 ? ".fill" : "")")
							Text("Races")
						}
					.tag(0)
					AlertsView(alertsModel: self.electionModel.alertsModel)
						.tabItem {
							Image(systemName: "exclamationmark.bubble\(self.selectedTab == 1 ? ".fill" : "")")
							Text("Alerts")
						}
					.tag(1)
					LeaguesView(leaguesModel: self.electionModel.leaguesModel)
						.tabItem {
							Image(systemName: "person.3\(self.selectedTab == 2 ? ".fill" : "")")
							Text("Leagues")
						}
					.tag(2)
					ScoresView()
						.tabItem {
							Image(systemName: "1.circle\(self.selectedTab == 3 ? ".fill" : "")")
							Text("Scores")
						}
					.tag(3)
				}
				.accentColor(Color("democrat"))
				TabCirclesImageView(size: geometry.size, leaguesModel: self.electionModel.leaguesModel, alertsModel: self.electionModel.alertsModel)
			}
		}
    }
	
}

struct TabPageView_Previews: PreviewProvider {
    static var previews: some View {
        TabPageView()
    }
}

struct TabCirclesImageView: View {
	var size: CGSize
	@ObservedObject var leaguesModel: LeaguesModel
	@ObservedObject var alertsModel: AlertsModel

	var body: some View {
			ZStack {
				Circle()
					.foregroundColor(.red)
					.frame(width: 10, height: 10)
					.offset(x: ((2 * 2 - 0.98) * (size.width / 8)) + 2, y: -33)
					.opacity(self.alertsModel.unreadAlerts > 0 ? 1 : 0)
				Circle()
					.foregroundColor(.red)
					.frame(width: 10, height: 10)
					.offset(x: ((2 * 3 - 0.9) * (size.width / 8)) + 2, y: -33)
					.opacity(self.leaguesModel.leagueRequests > 0 ? 1 : 0)
			}
	}
	
}
