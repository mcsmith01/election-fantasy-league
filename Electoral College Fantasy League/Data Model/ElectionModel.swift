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

var rowShape: RoundedRectangle {
	return RoundedRectangle(cornerRadius: 20, style: .continuous)
}

enum Constants: String {
	case currentElection
	case seenTutorial
	case email
	case name
}

class ElectionModel: NSObject, ObservableObject {
	var handle: AuthStateDidChangeListenerHandle!
	
	@Published var status: String?
	@Published var state = LoginState.logInBegan
	@Published var logInType = LoginType.none
	@Published var raceType: RaceType = .house {
		didSet {
			numbersModel.races = election.racesOfType(raceType, activeOnly: false)
		}
	}

	var name: String {
		return election.name
	}
	var elections = [Election]()
	var election: Election!
	var leaguesModel = LeaguesModel()
	var alertsModel = AlertsModel()
	var numbersModel = NumbersModel()
	@Published var listIndex = 0 {
		didSet {
			numbersModel.results = showResults
		}
	}
	var showResults: Bool {
		return listIndex == 1
	}
	var lists = ["Predictions", "Results"]
	var predictionsLocked: Bool {
		return election.date <= Date()
	}

	var electionRef: DatabaseReference {
		return Database.database().reference().child("elections").child(election.id)
	}
	var racesRef: DatabaseReference {
		return electionRef.child("races")
	}
	var leagueInfoRef: DatabaseReference {
		return electionRef.child("leagueInfo")
	}
	var leagueDataRef: DatabaseReference {
		return electionRef.child("leagueData")
	}
	var predictionsQuery: DatabaseQuery {
		return electionRef.child("predictions").queryOrdered(byChild: "owner").queryEqual(toValue: UserData.userID)
	}
	var playerRef: DatabaseReference {
		return Database.database().reference().child("players").child(UserData.userID)
	}
	var alertsRef: DatabaseReference {
		return playerRef.child("elections").child(election.id).child("alerts")
	}
	var leaguesRef: DatabaseReference {
		return playerRef.child("elections").child(election.id).child("leagues")
	}
	var observedLeagues = Set<String>()

	func logIn() {
		handle = Auth.auth().addStateDidChangeListener() {
			(auth, user) in
			if let user = user {
				UserData.userID = user.uid
				UserData.data[.email] = user.email
				self.playerRef.child("name").observeSingleEvent(of: .value) { (snapshot) in
					if let name = snapshot.value as? String {
						UserData.data[.name] = name
					}
				}
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
				let changeRequest = user.createProfileChangeRequest()
				changeRequest.displayName = displayName
				changeRequest.commitChanges(completion: nil)
				//TODO: Make this so it's not done directly.
				Database.database().reference().child("players").child(user.uid).child("name").setValue(displayName)
				completion(nil)
			} else {
				completion(nil)
			}
		}
	}
	
	func loadData() {
		status =  "Loading Election Data..."
		elections = [Election]()
		Database.database().reference().child("electionInfo").keepSynced(true)
		// TODO: Is there enough time to ensure changes are synced before observing?
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

		// Subscribe to election messages
		Messaging.messaging().subscribe(toTopic: election.id)
		
		// Load Races
		racesRef.observeSingleEvent(of: .value) { (snapshot) in
			for snap in snapshot.children {
				if let child = snap as? DataSnapshot, let data = child.value as? [String: Any] {
					election.updateOrCreateRace(withID: child.key, data: data)
				}
			}
			
			// Load Leagues
			self.status = "Loading Leagues.."
			self.leagueInfoRef.observeSingleEvent(of: .value) { (snapshot) in
				for snap in snapshot.children {
					if let child = snap as? DataSnapshot, let data = child.value as? [String: Any] {
						self.leaguesModel.updateOrCreateLeague(withID: child.key, data: data)
					}
				}
				// Load Predictions
				self.status = "Loading User Data..."
				self.predictionsQuery.observeSingleEvent(of: .value) { (snapshot) in
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
		racesRef.observe(.childChanged) { (snapshot) in
			// Race called
			if let data = snapshot.value as? [String: Any] {
				election.updateOrCreateRace(withID: snapshot.key, data: data)
				self.numbersModel.updateNumbers()
				self.objectWillChange.send()
			}
		}
		predictionsQuery.observe(.childAdded) { (snapshot) in
			// Made new prediction
			if let data = snapshot.value as? [String: Any], let raceID = data["race"] as? String {
				election.setPredictionForRace(withID: raceID, predictionID: snapshot.key, data: data)
				self.numbersModel.updateNumbers()
			}
		}
		predictionsQuery.observe(.childChanged) { (snapshot) in
			// Prediction changed or scored
			if let data = snapshot.value as? [String: Any], let raceID = data["race"] as? String {
				election.setPredictionForRace(withID: raceID, predictionID: snapshot.key, data: data)
				self.numbersModel.updateNumbers()
			}
		}
		leagueInfoRef.observe(.childAdded) { (snapshot) in
			// League created
			if let data = snapshot.value as? [String: Any] {
				self.leaguesModel.updateOrCreateLeague(withID: snapshot.key, data: data)
			}
		}
		leagueInfoRef.observe(.childChanged) { (snapshot) in
			// League membership changed
			if let data = snapshot.value as? [String: Any] {
				self.leaguesModel.updateOrCreateLeague(withID: snapshot.key, data: data)
			}
		}
		leagueInfoRef.observe(.childRemoved) { (snapshot) in
			// League deleted
			self.leaguesModel.removeLeague(withID: snapshot.key)
		}
		alertsRef.observe(.childAdded) { (snapshot) in
			// Alert sent
			if let data = snapshot.value as? [String: Any] {
				self.alertsModel.updateOrCreateAlert(withID: snapshot.key, data: data)
			}
		}
		alertsRef.observe(.childChanged) { (snapshot) in
			// Alert marked as read
			if let data = snapshot.value as? [String: Any] {
				self.alertsModel.updateOrCreateAlert(withID: snapshot.key, data: data)
			}
		}
		leaguesRef.observe(.childAdded) { (snapshot) in
			// Joined or applied to league
			if let data = snapshot.value as? [String: Any], let league = self.leaguesModel.updateMemberStatusForLeague(withID: snapshot.key, data: data) {
				self.listenToLeague(league)
			} else {
				debugPrint("Error listening to league")
			}
		}
		leaguesRef.observe(.childChanged) { (snapshot) in
			// Accepted to league
			if let data = snapshot.value as? [String: Any], let league = self.leaguesModel.updateMemberStatusForLeague(withID: snapshot.key, data: data) {
				self.listenToLeague(league)
			}
		}
		leaguesRef.observe(.childRemoved) { (snapshot) in
			// Left league / withdrew application
			if let league = self.leaguesModel.removeMembershipFromLeague(withID: snapshot.key) {
				// Removes all league listeners
				self.listenToLeague(league)
			}
		}
	}
	
	// TODO: Rename, because will stop listening if removed (intentionally)
	func listenToLeague(_ league: League) {
		if !observedLeagues.contains(league.id) && league.status == .member {
			// I am a mmeber but not observing the league
			// Subscribe to messags for this league
			Messaging.messaging().subscribe(toTopic: league.id)
			if league.ownerID == UserData.userID {
				// TODO: Just send messages to owner instead of subscribing?w3
				Messaging.messaging().subscribe(toTopic: "\(league.id)-owner")
			}
			leagueDataRef.child(league.id).child("members").observe(.value) { (snapshot) in
				// Members added or removed
				if let data = snapshot.value as? [String: [String: Any]] {
					self.leaguesModel.updateActiveMembersForLeague(withID: league.id, data: data)
				}
			}
			leagueDataRef.child(league.id).child("scores").observe(.childAdded) { (snapshot) in
				// Scores updated
				if let data = snapshot.value as? [String: Double] {
					self.leaguesModel.updateScores(forLeagueWithID: league.id, withData: data, forRaceWithID: snapshot.key)
				}
			}
			if league.ownerID == UserData.userID {
				leagueDataRef.child(league.id).child("pending").observe(.childAdded) { (snapshot) in
					// Member request added
					if let data = snapshot.value as? [String: Any] {
						self.leaguesModel.addPendingMemberToLeague(withID: league.id, playerID: snapshot.key, data: data)
					}
				}
				leagueDataRef.child(league.id).child("pending").observe(.childRemoved) { (snapshot) in
					// member request removed (accepted, denied, or withdrawn)
					self.leaguesModel.removePendingMemberFromLeague(withID: league.id, playerID: snapshot.key)
				}
			}
			observedLeagues.insert(league.id)
		} else if observedLeagues.contains(league.id) && league.status != .member {
			Messaging.messaging().unsubscribe(fromTopic: league.id)
			Messaging.messaging().unsubscribe(fromTopic: "\(league.id)-owner")
			// I am not a member but am observing the league
			leagueDataRef.child(league.id).child("scores").child(league.id).removeAllObservers()
			leagueDataRef.child(league.id).child("active").removeAllObservers()
			leagueDataRef.child(league.id).child("pending").removeAllObservers()
			observedLeagues.remove(league.id)
		}
	}
	
	func clearElectionData() {
		if election != nil {
			racesRef.removeAllObservers()
			predictionsQuery.removeAllObservers()
			leagueInfoRef.removeAllObservers()
			alertsRef.removeAllObservers()
			for league in observedLeagues {
				leagueDataRef.child(league.id).child("scores").removeAllObservers()
				leagueDataRef.child(league.id).child("active").removeAllObservers()
				leagueDataRef.child(league.id).child("pending").removeAllObservers()
			}
			leaguesModel.clearAll()
			alertsModel.clearAll()
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
			status = "Accepting \(player.name) to '\(league.name)'"
			Functions.functions().httpsCallable("acceptToLeague").call(payload) { (_, error) in
				self.status = nil
				completion(error)
			}
		} else {
			status = "Rejecting \(player.name)'s appliction to '\(league.name)'"
			Functions.functions().httpsCallable("removeFromLeague").call(payload) { (_, error) in
				self.status = nil
				completion(error)
			}
		}
	}
	
	func removeFromLeague(league: League, playerID: String, completion: @escaping (Error?) -> Void) {
		if playerID == UserData.userID {
			status = "Leaving '\(league.name)'"
		} else {
			// TODO: Take in LeagueMember
			status = "Removing player from '\(league.name)'"
		}
		let payload: [String: Any] = ["league": league.id, "election": election.id, "player": playerID]
		Functions.functions().httpsCallable("removeFromLeague").call(payload) { (_, error) in
			self.status = nil
			completion(error)
		}
	}
	
	func deleteLeague(_ league: League, completion: @escaping (Error?) -> Void) {
		status = "Deleting \(league.name)..."
		let payload: [String: Any] = ["league": league.id, "election": election.id]
		Functions.functions().httpsCallable("deleteLeague").call(payload) { (_, error) in
			self.status = nil
			completion(error)
		}
	}
	
	func markAlertsRead(_ read: Set<String>) {
		for alertID in read {
			alertsRef.child(alertID).child("read").setValue(true)
		}
	}

	func logout() {
		clearElectionData()
		try! Auth.auth().signOut()
	}
	
}
