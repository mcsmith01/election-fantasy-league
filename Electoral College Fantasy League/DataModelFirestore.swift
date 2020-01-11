////
////  DataModelFirestore.swift
////  Electoral College Fantasy League
////
////  Created by Chase Smith on 2/18/18.
////  Copyright © 2018 ls -applications. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//import Firebase
//
//@objc protocol Listener {
//	
//	@objc optional func electionUpdated(_: Election)
//	@objc optional func leagueUpdated(_: League)
//	
//}
//
//struct Colors {
//	private static let dem: (red: Float, green: Float, blue: Float) = (35, 32, 102)
//	private static let rep: (red: Float, green: Float, blue: Float) = (233, 29, 14)
//	private static let ind: (red: Float, green: Float, blue: Float) = (0, 190, 97)
//	static let democrat = UIColor(red: 35 / 255.0, green: 32 / 255.0, blue: 102 / 255.0, alpha: 1.0)
//	static let republican = UIColor(red: 233 / 255.0, green: 29 / 255.0, blue: 14 / 255.0, alpha: 1.0)
//	static let independent = UIColor(red: 0 / 255.0, green: 190 / 255.0, blue: 97 / 255.0, alpha: 1.0)
//	
//	static func getColor(for prediction: [String: Int]?, winner: String? = nil, type: RaceType?) -> UIColor {
//		if let prediction = prediction, let type = type {
//			if type == .house {
//				let demNumber = prediction["d"] ?? 0
//				let indNumber = prediction["i"] ?? 0
//				let repNumber = prediction["r"] ?? 0
//				return Colors.blend(dems: demNumber, inds: indNumber, reps: repNumber)
//			} else if let winner = winner, let percent = prediction[winner] {
//				return getColor(winner: winner, percent: percent)
//			} else {
//				return .lightGray
//			}
//		} else {
//			return .lightGray
//		}
//	}
//	
//	private static func getColor(winner: String, percent: Int) -> UIColor {
//		if winner.starts(with: "d") {
//			return Colors.democrat.withAlphaComponent(CGFloat(percent + 50) / 150.0)
//		} else if winner.starts(with: "r") {
//			return Colors.republican.withAlphaComponent(CGFloat(percent + 50) / 150.0)
//		} else {
//			return Colors.independent.withAlphaComponent(CGFloat(percent + 50) / 150.0)
//		}
//	}
//	
//	private static func blend(dems: Int, inds: Int, reps: Int) -> UIColor {
//		let total = Float(dems + inds + reps)
//		let demPercent = Float(dems) / total
//		let repPercent = Float(reps) / total
//		let indPercent = Float(inds) / total
//		let red = CGFloat(demPercent * dem.red + repPercent * rep.red + indPercent * ind.red)
//		let green = CGFloat(demPercent * dem.green + repPercent * rep.green + indPercent * ind.green)
//		let blue = CGFloat(demPercent * dem.blue + repPercent * rep.blue + indPercent * ind.blue)
//		return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
//	}
//	
//	static func gradient(dems: Int, inds: Int, reps: Int, vertical: Bool = false) -> CAGradientLayer {
//		let total = CGFloat(dems + inds + reps)
//		let demPer = CGFloat(dems) / total
//		let repPer = CGFloat(reps) / total
//		let indPer = CGFloat(inds) / total
//		let gradient = CAGradientLayer()
//		gradient.locations = [0.0]
//		gradient.colors = []
//		if dems != 0 {
//			gradient.locations?.append(contentsOf: [demPer, demPer] as [NSNumber])
//			gradient.colors?.append(contentsOf: [Colors.democrat.cgColor, Colors.democrat.cgColor])
//		}
//		if inds != 0 {
//			gradient.locations?.append(contentsOf: [demPer + indPer, demPer + indPer] as [NSNumber])
//			gradient.colors?.append(contentsOf: [Colors.independent.cgColor, Colors.independent.cgColor])
//		}
//		if reps != 0 {
//			gradient.locations?.append(contentsOf: [1 - repPer, 1 - repPer] as [NSNumber])
//			gradient.colors?.append(contentsOf: [Colors.republican.cgColor, Colors.republican.cgColor])
//		}
//		gradient.locations?.append(1.0)
//		
//		if vertical {
//			if dems > reps {
//				gradient.startPoint = CGPoint(x: 0.5, y: 0)
//				gradient.endPoint = CGPoint(x: 0.5, y: 1)
//			} else {
//				gradient.startPoint = CGPoint(x: 0.5, y: 1)
//				gradient.endPoint = CGPoint(x: 0.5, y: 0)
//			}
//		} else {
//			gradient.startPoint = CGPoint(x: 0, y: 0.5)
//			gradient.endPoint = CGPoint(x: 1, y: 0.5)
//		}
//		return gradient
//	}
//	
//}
//
//extension User {
//	
//	var ref: DocumentReference {
//		return Firestore.firestore().collection("Users").document(uid)
//	}
//}
//
//extension Election {
//	
//	class func fetchCurrent(moc: NSManagedObjectContext) -> Election? {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		if let id = UserDefaults.standard.string(forKey: Constants.currentElection) {
//			request.predicate = NSPredicate(format: "id = %@", id)
//		}
//		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//		do {
//			let result = try moc.fetch(request).first!
//			UserDefaults.standard.set(result.id!, forKey: Constants.currentElection)
//			return result
//		} catch {
//			print("Error fetching elections\n\(error)")
//			return nil
//		}
//	}
//
//	class func fetchAll(moc: NSManagedObjectContext) -> [Election] {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching elections\n\(error)")
//			return [Election]()
//		}
//	}
//	
//	class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> Election? {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching election with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func createOrUpdate(snapshot: DocumentSnapshot) -> Election {
//		defer {
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving new prediction\n\(error)")
//			}
//		}
//		if let election = fetchWithID(snapshot.documentID, moc: moc) {
//			election.updateFrom(snapshot: snapshot, moc: moc)
//			return election
//		} else {
//			let election = Election(moc: moc, snapshot: snapshot)
//			return election
//		}
//	}
//	
//	var reference: DatabaseReference {
//		return Firestore.firestore().collection("Elections").document(id!)
//	}
//	
//	var raceTypes: [RaceType] {
//		get {
//			var types = [RaceType]()
//			for type in RaceType.allCases {
//				if (races?.allObjects as? [Race])?.filter({ $0.type == Int32(type.rawValue) }).count != 0 {
//					types.append(type)
//				}
//			}
//			return types
//		}
//	}
//	
//	private convenience init(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) {
//		self.init(context: moc)
//		id = snapshot.documentID
//		updateFrom(snapshot: snapshot, moc: moc)
//	}
//	
//	func updateFrom(snapshot: DocumentSnapshot, moc: NSManagedObjectContext) {
//		name = snapshot.get("name") as? String
//		date = (snapshot.get("date") as? Timestamp)?.dateValue()
//		if let scores = snapshot.get("scores") as? [String: [String: Double]] {
//			debugPrint("There were new scores")
//			for (id, races) in scores {
//				let member = Member.createOrFetch(moc: moc, id: id)
//				member.updateScore(races)
//			}
//		} else {
//			debugPrint("There were no scores...")
//			debugPrint(snapshot.get("scores")!)
//		}
//		modified = (snapshot.get("modified") as? Timestamp)?.dateValue()
//	}
//	
//	func racesForState(_ state: State) -> [Int: Race] {
//		var foundRaces = [Int: Race]()
//		for race in races!.allObjects as! [Race] {
//			if race.state! == state {
//				foundRaces[Int(race.type)] = race
//			}
//		}
//		return foundRaces
//	}
//	
//}
//
//extension State {
//	
//	class func fetchAll(moc: NSManagedObjectContext) -> [State] {
//		let request: NSFetchRequest<State> = fetchRequest()
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching states\n\(error)")
//			return [State]()
//		}
//	}
//	
//	class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> State? {
//		let request: NSFetchRequest<State> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching state with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func createOrUpdate(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) -> State {
//		defer {
//			do {
//				try moc.save()
//			} catch {
//				print("Error saving new prediction\n\(error)")
//			}
//		}
//		if let state = fetchWithID(snapshot.documentID, moc: moc) {
//			state.updateFrom(snapshot: snapshot)
//			return state
//		} else {
//			let state = State(moc: moc, snapshot: snapshot)
//			return state
//		}
//	}
//	
//	private convenience init(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) {
//		self.init(context: moc)
//		id = snapshot.documentID
//		updateFrom(snapshot: snapshot)
//	}
//	
//	func updateFrom(snapshot: DocumentSnapshot) {
//		name = snapshot.get("name") as? String
//		representatives = snapshot.get("representatives") as! Int32
//		splitsElectors = snapshot.get("splitsElectoral") as? Bool ?? false
//		modified = (snapshot.get("modified") as? Timestamp)?.dateValue()
//	}
//	
//	func racesForType(_ type: RaceType, for election: Election) -> [Race] {
//		var foundRaces = [Race]()
//		if let races = races?.allObjects as? [Race] {
//			for race in races {
//				if race.type == type.rawValue && race.election! == election {
//					foundRaces.append(race)
//				}
//			}
//		}
//		return foundRaces
//	}
//	
//}
//
//extension Race {
//	
//	class func fetchAll(moc: NSManagedObjectContext, forElection election: Election) -> [Race] {
//		let request: NSFetchRequest<Race> = fetchRequest()
//		request.predicate = NSPredicate(format: "election = %@", election)
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching races\n\(error)")
//			return [Race]()
//		}
//	}
//	
//	class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> Race? {
//		let request: NSFetchRequest<Race> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching race with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func createOrUpdate(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) -> Race {
//		defer {
//			do {
//				try moc.save()
//			} catch {
//				print("Error saving new prediction\n\(error)")
//			}
//		}
//		if let race = fetchWithID(snapshot.documentID, moc: moc) {
//			race.updateFrom(snapshot: snapshot)
//			return race
//		} else {
//			let race = Race(moc: moc, snapshot: snapshot)
//			return race
//		}
//	}
//	
//	var reference: DocumentReference {
//		return Firestore.firestore().collection("Elections").document(election!.id!).collection("Races").document(id!)
//	}
//	
//	var name: String {
//		return state!.name!
//	}
//	
//	var isActive: Bool {
//		return incumbents == nil || incumbents!.count != 2
//	}
//	
//	var raceType: RaceType {
//		return RaceType(rawValue: Int(type))!
//	}
//	
//	private convenience init(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) {
//		self.init(context: moc)
//		id = snapshot.documentID
//		let stateID = snapshot.get("state") as! String
//		state = State.fetchWithID(stateID, moc: moc)
//		state?.addToRaces(self)
//		updateFrom(snapshot: snapshot)
//		let electionID = snapshot.reference.parent.parent!.documentID
//		election = Election.fetchWithID(electionID, moc: moc)
//		election?.addToRaces(self)
//	}
//	
//	func updateFrom(snapshot: DocumentSnapshot) {
//		type = snapshot.get("type") as! Int32
//		candidates = snapshot.get("candidates") as? [String: String]
//		incumbents = snapshot.get("incumbents") as? [String]
//		results = snapshot.get("results") as? [String: Int]
//		complete = snapshot.get("complete") as? Bool ?? false
//		modified = (snapshot.get("modified") as? Timestamp)?.dateValue()
//	}
//}
//
//extension Prediction {
//	
//	class func fetchAll(moc: NSManagedObjectContext, forUser user: User, forElection election: Election) -> [Prediction] {
//		let request: NSFetchRequest<Prediction> = fetchRequest()
//		request.predicate = NSPredicate(format: "user = %@ AND race.election = %@", user.uid, election)
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching predictions\n\(error)")
//			return [Prediction]()
//		}
//	}
//	
//	class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> Prediction? {
//		let request: NSFetchRequest<Prediction> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching prediction with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func fetchAll(moc: NSManagedObjectContext, forElection election: Election) -> [Prediction] {
//		let request: NSFetchRequest<Prediction> = fetchRequest()
//		request.predicate = NSPredicate(format: "race.election = %@", election)
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching predictions\n\(error)")
//			return [Prediction]()
//		}
//	}
//	
//	@discardableResult class func createOrUpdate(moc: NSManagedObjectContext, user: User, for race: Race, dictionary: [String: Any]) -> Prediction {
//		defer {
//			do {
//				try moc.save()
//			} catch {
//				print("Error saving new prediction\n\(error)")
//			}
//		}
//		if let prediction = fetchWithID(race.id!, moc: moc) {
//			prediction.updateFrom(dictionary: dictionary)
//			return prediction
//		} else {
//			let prediction = Prediction(moc: moc, user: user, for: race, dictionary: dictionary)
//			return prediction
//		}
//	}
//	
//	var demNumber: Int {
//		var number = 0
//		if let prediction = prediction {
//			for (key, value) in prediction {
//				if key.starts(with: "d") {
//					number += value
//				}
//			}
//		}
//		return number
//	}
//	
//	var repNumber: Int {
//		var number = 0
//		if let prediction = prediction {
//			for (key, value) in prediction {
//				if key.starts(with: "r") {
//					number += value
//				}
//			}
//		}
//		return number
//	}
//	
//	var indNumber: Int {
//		var number = 0
//		if let prediction = prediction {
//			for (key, value) in prediction {
//				if key.starts(with: "i") {
//					number += value
//				}
//			}
//		}
//		return number
//	}
//	
//	private convenience init(moc: NSManagedObjectContext, user: User, for race: Race, dictionary: [String: Any]) {
//		self.init(context: moc)
//		self.id = race.id
//		self.user = user.uid
//		self.race = race
//		self.race?.prediction = self
//		updateFrom(dictionary: dictionary)
//	}
//	
//	private func updateFrom(dictionary: [String: Any]) {
//		if let predDict = dictionary["prediction"] as? [String: Any] {
//			prediction = [String: Int]()
//			for (party, value) in predDict {
//				if let valInt = value as? Int {
//					prediction![party] = valInt
//				}
//			}
//		}
//		modified = (dictionary["modified"] as? Timestamp)?.dateValue()
//		if let score = dictionary["score"] as? Double {
//			self.score = score
//		}
//	}
//	
//	func getColor() -> UIColor {
//		return Colors.getColor(for: prediction, winner: getWinner()?.0, type: RaceType(rawValue: Int(race!.type)))
//	}
//	
//	func getWinner() -> (String, Int)? {
//		// TODO: There is something screwy with this
//		if let prediction = prediction, prediction.count == 1, let winner = prediction.keys.first, let number = prediction[winner] {
//			return (winner, number)
//		} else {
//			return nil
//		}
//	}
//	
//}
//
//extension League {
//	
//	class func fetchAll(moc: NSManagedObjectContext, forElection election: Election) -> [League] {
//		let request: NSFetchRequest<League> = fetchRequest()
//		request.predicate = NSPredicate(format: "election = %@", election)
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching races\n\(error)")
//			return [League]()
//		}
//	}
//	
//	private class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> League? {
//		let request: NSFetchRequest<League> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching prediction with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func createOrUpdate(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) -> League {
//		defer {
//			do {
//				try moc.save()
//			} catch {
//				print("Error saving new league\n\(error)")
//			}
//		}
//		if snapshot.metadata.isFromCache {
//			debugPrint("Cached data for League")
//		}
//		if let league = League.fetchWithID(snapshot.documentID, moc: moc) {
//			league.updateFrom(moc: moc, snapshot: snapshot)
//			return league
//		} else {
//			let league = League(moc: moc, snapshot: snapshot)
//			return league
//		}
//	}
//	
//	var ref: DocumentReference {
//		return election!.reference.collection("Leagues").document(id!)
//	}
//	
//	private convenience init(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) {
//		self.init(context: moc)
//		id = snapshot.documentID
//		owner = snapshot.get("owner") as? String
//		name = snapshot.get("name") as? String
//		election = Election.fetchWithID(snapshot.reference.parent.parent!.documentID, moc: moc)
//		updateFrom(moc: moc, snapshot: snapshot)
//	}
//	
//	private func updateFrom(moc: NSManagedObjectContext, snapshot: DocumentSnapshot) {
//		isOpen = snapshot.get("open") as? Bool ?? false
//		races = snapshot.get("scores") as? [Int]
//		debugPrint(races)
//		modified = (snapshot.get("modified") as? Timestamp)?.dateValue()
//		if let memberList = snapshot.get("members") as? [String: Bool] {
//			for (memberID, _) in memberList {
//				let member = Member.createOrFetch(moc: moc, id: memberID)
//				addToMembers(member)
//				member.addToLeagues(self)
//			}
//		}
//	}
//
//	func hasMemberWith(id: String) -> Bool {
//		if let members = members?.allObjects as? [Member] {
//			for member in members {
//				if member.id! == id {
//					return true
//				}
//			}
//		}
//		return false
//	}
//	
//}
//
//extension Member {
//	
//	class func fetchAll(moc: NSManagedObjectContext) -> [Member] {
//		let request: NSFetchRequest<Member> = fetchRequest()
//		do {
//			let results = try moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching elections\n\(error)")
//			return [Member]()
//		}
//	}
//
//	private class func fetchWithID(_ id: String, moc: NSManagedObjectContext) -> Member? {
//		let request: NSFetchRequest<Member> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try moc.fetch(request).first
//		} catch {
//			print("Error fetching member with id \(id)\n\(error)")
//			return nil
//		}
//	}
//	
//	class func createOrFetch(moc: NSManagedObjectContext, id: String) -> Member {
//		if let member = Member.fetchWithID(id, moc: moc) {
//			return member
//		} else {
//			let member = Member(context: moc)
//			member.id = id
//			return member
//		}
//	}
//	
//	func getDisplayString(completion: ((String) -> Void)?) -> String {
//		if let name = name {
//			return name
//		} else {
//			fetchName(completion: completion)
//			return "New Member"
//		}
//	}
//	
//	private func fetchName(completion: ((String) -> Void)?) {
//		Firestore.firestore().collection("Users").document(id!).getDocument { (snapshot, error) in
//			guard let snapshot = snapshot else {
//				if let error = error {
//					print("Error fetching info for user \(self.id!)\n\(error)")
//				}
//				print("No snapshot for user \(self.id!)")
//				return
//			}
//			self.name = snapshot.get("name") as? String
//			completion?(self.name ?? "New Member")
//		}
//	}
//	
//	func updateScore(_ dictionary: [String: Double]) {
//		scores = [Int: Double]()
//		for (race, score) in dictionary {
//			scores![Int(race)!] = score
//		}
//	}
//	
//}
