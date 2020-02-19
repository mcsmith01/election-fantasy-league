//
//  MasterView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct MasterView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@State var loggedIn = false

	var body: some View {
		ZStack {
			if loggedIn {
				TabPageView()
					.transition(.opacity)
			} else {
				SplashPageView()
					.transition(.opacity)
			}
			if electionModel.status != nil {
				BusyInfoView(text: electionModel.status!)
			}
		}
		.onReceive(self.electionModel.$state) { (newState) in
			withAnimation {
				self.loggedIn = newState == .logInComplete
			}
		}
	}
}

struct MasterView_Previews: PreviewProvider {
	static var previews: some View {
		MasterView()
    }
}
