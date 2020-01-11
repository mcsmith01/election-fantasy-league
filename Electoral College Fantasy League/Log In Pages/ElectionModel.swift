//
//  ElectionModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/4/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseUI

class ElectionModel: NSObject, ObservableObject, FUIAuthDelegate {
	var handle: AuthStateDidChangeListenerHandle!
	@Published var status = "Logging in..."
	@Published var state = LoginState.logInBegan
	@Published var refresh = false
	@Published var raceType: RaceType = .house
	var name: String {
		return election.name!
	}
	var elections: [Election]!
	var election: Election!
	var races: [Race]!
	var allRaceTypes: [RaceType] {
		return election.raceTypes.sorted()
	}

	func logIn() {
//		try! Auth.auth().signOut()
		let authUI = FUIAuth.defaultAuthUI()
		authUI?.delegate = self
		authUI?.providers = [FUIEmailAuth()]
		handle = Auth.auth().addStateDidChangeListener() {
			(auth, user) in
			if let user = user {
				UserData.userID = user.uid
				Player.fetchOrCreate(user: user, completion: { (player) in
					self.state = .logInSuccess
					self.status = "Logged in"
					self.loadData()
				})
			} else {
				self.state = .logInFailure
			}
		}
	}
	
	func logIn(email: String, password: String, completion: @escaping (String?) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
			completion(error?.localizedDescription)
		}
	}
	
	func createAccount(email: String, password: String, completion: @escaping (String?) -> Void) {
		Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
			completion(error?.localizedDescription)
		}
	}
	
	func loadData() {
		status =  "Loading Election Data..."
		Election.fetchAndCreateOrUpdateAll { (current) in
			self.election = current
			self.status = "Loading Race Data..."
			Race.fetchAndCreateOrUpdateAll(forElection: self.election, completion: {
				self.races = self.election.races?.allObjects as? [Race] ?? []
				self.status = "Loading User Data..."
				Prediction.fetchAndCreateOrUpdateAll(forElection: self.election, forPlayer: UserData.userID, completion: {
					self.status = "Loading League Data..."
					League.fetchAndCreateOrUpdateAll(forElection: self.election, completion: {
						self.raceType = self.election.raceTypes.sorted().first!
						self.state = .logInComplete
					})
				})
			})
		}
	}
	
	func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
		if let error = error {
			print("Error logging in\n\(error)")
			return
		}
		print("Logged in")
	}
	
	
}
