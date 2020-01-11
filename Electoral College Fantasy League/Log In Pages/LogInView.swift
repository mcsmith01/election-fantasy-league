//
//  LogInView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/30/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct LogInView: View {
	@EnvironmentObject var electionModel: ElectionModel
	@State var type = LoginType.none {
		didSet {
			password = ""
			passwordVerify = ""
		}
	}
	@State var email = ""
	@State var password = ""
	@State var passwordVerify = ""
	@State var alertMessage: AlertMessage?
	
	var body: some View {
		VStack {
			Image("outline 2016")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding()
				.shadow(color: .gray, radius: 5, x: 0, y: 0)
			Text("Welcome to the\nElection Fantasy League")
				.font(.title)
				.multilineTextAlignment(.center)
			if type == .create {
				VStack {
					Text("Create Account")
					Group {
						TextField("Email", text: $email)
							.autocapitalization(.none)
						TextField("Password", text: $password)
							.autocapitalization(.none)
						TextField("Retype Password", text: $passwordVerify)
							.autocapitalization(.none)
					}
					HStack {
						Button("Submit") {
							self.electionModel.createAccount(email: self.email, password: self.password) { (errorMessage) in
								if let message = errorMessage {
									self.alertMessage = AlertMessage(text: message)
									self.password = ""
									self.passwordVerify = ""
								}
							}
						}
						.disabled(password == "" || email == "" || password != passwordVerify)
						Button("Cancel") {
							withAnimation {
								self.type = .none
							}
						}
						.foregroundColor(.red)
					}
				}
				.padding()
			} else if type == .login {
				VStack {
					Text("Log In")
					TextField("Username", text: $email)
						.autocapitalization(.none)
					TextField("Password", text: $password)
						.autocapitalization(.none)
					HStack {
						Button("Submit") {
							self.electionModel.logIn(email: self.email, password: self.password) { (errorMessage) in
								if let message = errorMessage {
									self.alertMessage = AlertMessage(text: message)
									self.password = ""
									self.passwordVerify = ""
								}
							}
						}
						.disabled(password == "" || email == "")
						Button("Cancel") {
							withAnimation {
								self.type = .none
							}
						}
						.foregroundColor(.red)
					}
				}
				.padding()
			} else {
				VStack {
					HStack {
						Button("Create Account") {
							withAnimation {
								self.type = .create
							}
						}
						.padding()
						Button("Log In") {
							withAnimation {
								self.type = .login
							}
						}
						.padding()
					}
					SealsView()
				}
			}
			Spacer()
		}
		.alert(item: $alertMessage) { (message) -> Alert in
			Alert(title: Text(message.text))
		}
	}
}

struct LogInView_Previews: PreviewProvider {
	static var previews: some View {
		LogInView()
	}
}

struct AlertMessage: Identifiable {
	let id = UUID()
	let text: String
}

enum LoginType {
	case none
	case create
	case login
}
