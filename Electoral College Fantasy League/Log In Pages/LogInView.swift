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
	@State var displayName = ""
	@State var email = ""
	@State var password = ""
	@State var passwordVerify = ""
	@State var alertMessage: AlertMessage?
	
	var body: some View {
		VStack {
			if self.electionModel.logInType == .create {
				Text("Create Account")
				Group {
					TextField("Display Name", text: $displayName)
						.autocapitalization(.words)
						.textFieldStyle(RoundedBorderTextFieldStyle())
					TextField("Email", text: $email)
						.keyboardType(.emailAddress)
						.autocapitalization(.none)
						.textFieldStyle(RoundedBorderTextFieldStyle())
					SecureField("Password", text: $password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
					SecureField("Retype Password", text: $passwordVerify)
						.textFieldStyle(RoundedBorderTextFieldStyle())
				}
				HStack {
					Spacer()
					Button("Submit") {
						let pass = self.password
						self.password = ""
						self.passwordVerify = ""
						self.electionModel.createAccount(email: self.email, password: pass, displayName: self.displayName) { (error) in
							if let error = error {
								self.alertMessage = AlertMessage(text: error.localizedDescription)
							} else {
								self.electionModel.logInType = .none
							}
						}
					}
					.disabled(password == "" || email == "" || displayName == "" || password != passwordVerify)
					Spacer()
					Button("Cancel") {
						withAnimation {
							self.electionModel.logInType = .none
						}
					}
					.foregroundColor(.red)
					Spacer()
				}
			} else if self.electionModel.logInType == .login {
				Text("Log In")
				TextField("Username", text: $email)
					.keyboardType(.emailAddress)
					.autocapitalization(.none)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				SecureField("Password", text: $password)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				HStack {
					Spacer()
					Button("Submit") {
						let pass = self.password
						self.password = ""
						self.passwordVerify = ""
						self.electionModel.logIn(email: self.email, password: pass) { (errorMessage) in
							if let message = errorMessage {
								self.alertMessage = AlertMessage(text: message)
							} else {
								self.electionModel.logInType = .none
							}
						}
					}
					.disabled(password == "" || email == "")
					Spacer()
					Button("Cancel") {
						withAnimation {
							self.electionModel.logInType = .none
						}
					}
					.foregroundColor(.red)
					Spacer()
				}
			}
		}
		.padding()
		.background(Color.primary.colorInvert())
		.cornerRadius(25)
		.padding()
		.shadow(color: .gray, radius: 5)
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

struct IdentifiableAlert: Identifiable {
	let id = UUID()
	let alert: Alert
}

enum LoginType {
	case none
	case create
	case login
}
