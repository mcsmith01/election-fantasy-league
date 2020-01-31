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

var rowShape: RoundedRectangle {
	return RoundedRectangle(cornerRadius: 20, style: .continuous)
}

enum Constants: String {
	case lastElectionUpdate
	case lastRaceUpdate
	case lastPredictionUpdate
	case lastLeagueUpdate
	case currentElection
	case setName
}

class ElectionModel: NSObject, ObservableObject, FUIAuthDelegate {
	var handle: AuthStateDidChangeListenerHandle!
	var raceHandle: DatabaseHandle?
	
	@Published var status: String?
	@Published var state = LoginState.logInBegan
	@Published var logInType = LoginType.none
	@Published var refresh = false
	@Published var raceType: RaceType = .house
	@Published var isSaving = false
	var name: String {
		return election.name
	}
	var elections = [Election]()
	var election: Election!
	var electionRef: DatabaseReference {
		return Database.database().reference().child("elections").child(election.id)
	}
	var playerRef: DatabaseReference {
		return Database.database().reference().child("players").child(UserData.userID)
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
				self.state = .logInSuccess
				self.status = "Logged in"
				self.loadData()
			} else {
				self.state = .logInFailure
				self.status = nil
			}
		}
	}
	
	func logIn(email: String, password: String, completion: @escaping (String?) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
			completion(error?.localizedDescription)
		}
	}
	
	func createAccount(email: String, password: String, displayName: String, completion: @escaping (Error?) -> Void) {
		Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
			if let error = error {
				completion(error)
			} else if let user = result?.user {
				Database.database().reference().child("players").child(user.uid).setValue(["name": displayName])
				completion(nil)
			} else {
				completion(nil)
			}
		}
	}
	
	func loadData() {
		status =  "Loading Election Data..."
		elections = [Election]()
		Database.database().reference().child("electionInfo").observeSingleEvent(of: .value) { (snapshot) in
			for snap in snapshot.children {
				if let child = snap as? DataSnapshot, let data = child.value as? [String: Any], let election = Election(id: child.key, data: data) {
					self.elections.append(election)
					if let id = UserData.data[Constants.currentElection] as? String, election.id == id {
						self.election = election
					}
				}
			}
			self.elections.sort()
			if self.election == nil {
				self.election = self.elections.first
				UserData.data[Constants.currentElection] = self.election.id
			}
			// TODO: Ask if want a change if most recent is not current
			self.loadElection(self.election)
		}
	}
	
	func loadElection(_ election: Election) {
		status = "Loading Race Data..."
		clearElectionData()
		self.election = election

		// Load Races
		electionRef.child("races").observeSingleEvent(of: .value) { (snapshot) in
			for snap in snapshot.children {
				if let child = snap as? DataSnapshot, let data = child.value as? [String: Any] {
					election.updateOrCreateRace(withID: child.key, data: data)
				}
			}
			
			// Load Leagues
			self.status = "Loading League Data.."
			self.electionRef.child("leagues").observeSingleEvent(of: .value) { (snapshot) in
				for snap in snapshot.children {
					if let child = snap as? DataSnapshot, let data = child.value as? [String: Any] {
						election.updateOrCreateLeague(withID: child.key, data: data)
					}
				}
				
				// Load Predictions
				self.status = "Loading User Data..."
				self.electionRef.child("predictions").queryOrdered(byChild: "owner")
					.queryEqual(toValue: UserData.userID).observeSingleEvent(of: .value) { (snapshot) in
						for snap in snapshot.children {
							if let child = snap as? DataSnapshot, let data = child.value as? [String: Any], let raceID = data["race"] as? String {
								election.setPredictionForRace(withID: raceID, predictionID: child.key, data: data)
							}
						}
						self.listenToElection(election)
						self.raceType = election.raceTypes.sorted().first!
						self.state = .logInComplete
						self.status = nil
				}
			}
			
		}
	}
	
	func listenToElection(_ election: Election) {
		let predictionQuery = electionRef.child("predictions")
			.queryOrdered(byChild: "owner").queryEqual(toValue: UserData.userID)
		electionRef.child("races").observe(.childChanged) { (snapshot) in
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateRace(withID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		predictionQuery.observe(.childAdded) { (snapshot) in
			if let data = snapshot.value as? [String: Any], let raceID = data["race"] as? String {
				election.setPredictionForRace(withID: raceID, predictionID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		predictionQuery.observe(.childChanged) { (snapshot) in
			if let data = snapshot.value as? [String: Any], let raceID = data["race"] as? String {
				election.setPredictionForRace(withID: raceID, predictionID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		electionRef.child("leagues").observe(.childAdded) { (snapshot) in
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateLeague(withID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		electionRef.child("leagues").observe(.childChanged) { (snapshot) in
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateLeague(withID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		playerRef.child("elections").child(election.id).child("alerts").observe(.childAdded) { (snapshot) in
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateAlert(withID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
		playerRef.child("elections").child(election.id).child("alerts").observe(.childChanged) { (snapshot) in
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateAlert(withID: snapshot.key, data: data)
				self.refresh.toggle()
			}
		}
	}
	
	func clearElectionData() {
		if election != nil {
			electionRef.child("races").removeAllObservers()
			electionRef.child("predictions").removeAllObservers()
		}
	}

	func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
		if let error = error {
			print("Error logging in\n\(error)")
			return
		}
		print("Logged in")
	}
	
	func savePrediction(_ numbers: [String: Int], forRace race: Race, completion: @escaping (Error?) -> Void) {
		let payload: [String: Any] = ["prediction": numbers, "election": election.id, "race": race.id]
		Functions.functions().httpsCallable("makePrediction").call(payload) {
			(_, error) in
			completion(error)
		}
	}
	
	func createLeague(name: String, isOpen: Bool, raceTypes: [Int], completion: @escaping (Error?) -> Void) {
		let payload: [String: Any] = ["name": name, "isOpen": isOpen, "races": raceTypes, "election": election.id]
		Functions.functions().httpsCallable("createLeague").call(payload) { (_, error) in
			completion(error)
		}
	}
	
	func joinLeague(_ league: League, completion: @escaping (Error?) -> Void) {
		status = league.isOpen ? "Joining \(league.name)" : "Applying to \(league.name)"
		let payload: [String: Any] = ["league": league.id, "election": election.id]
		Functions.functions().httpsCallable("joinLeague").call(payload) { (_, error) in
			self.status = nil
			completion(error)
		}
	}
	
	func processLeagueRequest(league: League, player: LeagueMember, accept: Bool, completion: @escaping (Error?) -> Void) {
		let payload: [String: Any] = ["league": league.id, "election": election.id, "player": player.id]
		if accept {
			status = "Accepting \(player.name) to \(league.name)"
			Functions.functions().httpsCallable("acceptToLeague").call(payload) { (_, error) in
				self.status = nil
				completion(error)
			}
		} else {
			status = "Rejecting \(player.name)'s appliction to \(league.name)"
			Functions.functions().httpsCallable("removeFromLeague").call(payload) { (_, error) in
				self.status = nil
				completion(error)
			}
		}
	}
	
	func removeFromLeague(league: League, player: LeagueMember, completion: @escaping (Error?) -> Void) {
		status = "Leaving \(league.name)"
		let payload: [String: Any] = ["league": league.id, "election": election.id, "player": player.id]
		Functions.functions().httpsCallable("removeFromLeague").call(payload) { (_, error) in
			self.status = nil
			completion(error)
		}
	}
	
	func markAlertsRead(_ read: Set<String>) {
		for alertID in read {
			playerRef.child("elections")
				.child(election.id).child("alerts").child(alertID).child("read").setValue(true)
		}
	}
	
	func getNumbers() -> (dems: Int, inds: Int, reps: Int, total: Int) {
//		debugPrint("Got Numbers")
		var dems = 0
		var inds = 0
		var reps = 0
		var total = 0
		for race in election.racesOfType(raceType) {
			if let prediction = race.prediction {
				for (party, count) in prediction.prediction {
					if party.starts(with: "d") {
						dems += count
					} else if party.starts(with: "i") {
						inds += count
					} else if party.starts(with: "r") {
						reps += count
					}
				}
			}
			for (_, count) in race.incumbency {
				total += count
			}
		}
		return (dems: dems, inds: inds, reps: reps, total: total)
	}

}
