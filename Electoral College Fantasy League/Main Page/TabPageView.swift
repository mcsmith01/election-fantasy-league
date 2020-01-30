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
		TabView {
			MainPageView()
				.tabItem {
					Image(systemName: "map")
					Text("Races")
				}
			Text("Alerts")
				.tabItem {
					Image(systemName: "exclamationmark.triangle")
					Text("Alerts")
				}
			LeaguesView()
				.tabItem {
					Image(systemName: "person.3")
					Text("Leagues")
				}
		}
		.navigationBarBackButtonHidden(true)
    }
}

struct TabPageView_Previews: PreviewProvider {
    static var previews: some View {
        TabPageView()
    }
}
