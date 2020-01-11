//
//  SplashPageView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/30/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct SplashPageView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@State var requireLogin = false
	@State var loggedIn = false
	var rotation: Double = 0
	
	var body: some View {
		NavigationView {
			VStack {
				Image("outline 2016")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding()
					.shadow(color: .gray, radius: 5, x: 0, y: 0)
				Spacer()
				Text("\(self.electionModel.status)")
					.font(.subheadline)
				ActivityView(isAnimating: .constant(true), style: .large)
				Spacer()
				SealsView()
				NavigationLink(destination: MainPageView(), isActive: $loggedIn) {
					EmptyView()
				}
			}
			.navigationBarTitle("Election Fantasy League")
		}
		.onAppear {
			self.electionModel.logIn()
		}
		.sheet(isPresented: $requireLogin, onDismiss: nil) {
			//TODO: onDismiss need to log in again?
			LogInView()
		}
		.onReceive(self.electionModel.$state) { (newState) in
			if newState == .logInFailure {
				self.requireLogin = true
			} else if newState == .logInSuccess {
				self.requireLogin = false
			} else if newState == .logInComplete {
				self.loggedIn = true
			}
		}
	}
	
}

struct SplashPage_Previews: PreviewProvider {
	static var previews: some View {
		SplashPageView()
	}
}

enum LoginState: Int, Identifiable {
	var id: Int {
		return rawValue
	}
	
	case logInBegan
	case logInSuccess
	case logInFailure
	case logInComplete
}
