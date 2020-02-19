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
	
	var body: some View {
			ZStack {
				VStack {
					Spacer()
					Image("outline 2016")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.padding()
						.shadow(color: .gray, radius: 5, x: 0, y: 0)
					Spacer()
					ZStack {
						VStack {
							Button("Create New Account") {
								withAnimation {
									self.electionModel.logInType = .create
								}
							}
							.foregroundColor(.white)
							.padding(.horizontal)
							.background(Color.democrat)
							.clipShape(Capsule())
							.padding()
							Button("Log In") {
								withAnimation {
									self.electionModel.logInType = .login
								}
							}
							.foregroundColor(.white)
							.padding(.horizontal)
							.background(Color.democrat)
							.clipShape(Capsule())
							.padding()
						}
						.opacity(self.electionModel.state == .logInFailure ? 1 : 0)
					}
					Spacer()
					SealsView()
					Spacer()
				}
				if electionModel.logInType != .none {
					LogInView()
						.transition(.scale)
				}
		}
		.onAppear {
			self.electionModel.logIn()
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
