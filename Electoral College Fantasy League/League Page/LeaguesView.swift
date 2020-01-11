//
//  LeaguesView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/5/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct LeaguesView: View {
	@State var navigationTag: Int?
	
    var body: some View {
		GeometryReader { geometry in
			VStack {
				Image("governor")
				.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(height: geometry.size.height / 3)
				Spacer()
			}
		}
		.navigationBarTitle("Leagues")
		.navigationBarItems(trailing:
			Button("Create") { self.navigationTag = 1 }
		)
			.sheet(item: $navigationTag) { (tag) in
				if tag == 1 {
					CreateLeagueView()
				}
		}
	}
}

struct LeaguesView_Previews: PreviewProvider {
    static var previews: some View {
        LeaguesView()
    }
}
