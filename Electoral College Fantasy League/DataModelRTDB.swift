//
//  DataModelFirestore.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/18/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import UIKit
import Firebase

//@objc protocol Listener {
//
//	@objc optional func electionUpdated(_: Election)
//	@objc optional func leagueUpdated(_: League)
//}

struct UserData {
	
	static var data = UserData()
	
	subscript(field: Constants) -> Any? {
		get {
			return UserData.settings[field.rawValue]
		}
		set {
			UserData.settings[field.rawValue] = newValue
		}
	}
	
	private static var settings: [String: Any] = [String: Any]() {
		didSet {
			if userID != "" {
				UserDefaults.standard.set(settings, forKey: userID)
			}
		}
	}
	
	static var userID: String = "" {
		didSet {
			UserData.settings = UserDefaults.standard.object(forKey: userID) as? [String: Any] ?? [String: Any]()
		}
	}
}

//extension Objects {
//
//	static let moc = {
//		return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//	}()
//
//}

struct Colors {
	private static let dem: (red: Float, green: Float, blue: Float) = (35, 32, 102)
	private static let rep: (red: Float, green: Float, blue: Float) = (233, 29, 14)
	private static let ind: (red: Float, green: Float, blue: Float) = (0, 190, 97)
	private static let tcc: (red: Float, green: Float, blue: Float) = (102, 51, 153)
	static let democrat = blend(dems: 1, inds: 0, reps: 0, tctc: 0)
	static let republican = blend(dems: 0, inds: 0, reps: 1, tctc: 0)
	static let independent = blend(dems: 0, inds: 1, reps: 0, tctc: 0)
	static let tooClose = blend(dems: 0, inds: 0, reps: 0, tctc: 1)
	
//	static func getColor(for prediction: [String: Int]?) -> UIColor {
//		if let prediction = prediction {
//			var demNumber = 0
//			var indNumber = 0
//			var repNumber = 0
//			var tccNumber = 0
//			for (party, num) in prediction {
//				if party.starts(with: "d") {
//					demNumber += num
//				} else if party.starts(with: "r") {
//					repNumber += num
//				} else if party.starts(with: "i") {
//					indNumber += num
//				} else if party.starts(with: "t") {
//					tccNumber += num
//				}
//			}
//			return Colors.blend(dems: demNumber, inds: indNumber, reps: repNumber, tctc: tccNumber)
//		} else {
//			return .darkGray
//		}
//	}
	
	private static func blend(dems: Int, inds: Int, reps: Int, tctc: Int) -> UIColor {
		let total = Float(dems + inds + reps + tctc)
		let demPercent = Float(dems) / total
		let repPercent = Float(reps) / total
		let indPercent = Float(inds) / total
		let tccPercent = Float(tctc) / total

		let red = CGFloat(demPercent * dem.red + repPercent * rep.red + indPercent * ind.red + tccPercent * tcc.red)
		let green = CGFloat(demPercent * dem.green + repPercent * rep.green + indPercent * ind.green + tccPercent * tcc.green)
		let blue = CGFloat(demPercent * dem.blue + repPercent * rep.blue + indPercent * ind.blue + tccPercent * tcc.blue)
		return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
	}
	
	static func gradient(dems: Int, inds: Int, reps: Int, tctc: Int, vertical: Bool = false) -> CAGradientLayer {
		let total = CGFloat(dems + inds + reps + tctc)
		let demPer = CGFloat(dems) / total
		let indPer = CGFloat(inds) / total
		let repPer = CGFloat(reps) / total
		let tccPer = CGFloat(tctc) / total
		let gradient = CAGradientLayer()
		gradient.locations = [0.0]
		gradient.colors = []
		if dems != 0 {
			gradient.locations?.append(contentsOf: [demPer, demPer] as [NSNumber])
			gradient.colors?.append(contentsOf: [Colors.democrat.cgColor, Colors.democrat.cgColor])
		}
		if inds != 0 {
			gradient.locations?.append(contentsOf: [demPer + indPer, demPer + indPer] as [NSNumber])
			gradient.colors?.append(contentsOf: [Colors.independent.cgColor, Colors.independent.cgColor])
		}
		if reps != 0 {
			gradient.locations?.append(contentsOf: [demPer + indPer + repPer, demPer + indPer + repPer] as [NSNumber])
			gradient.colors?.append(contentsOf: [Colors.republican.cgColor, Colors.republican.cgColor])
		}
		if tctc != 0 {
			gradient.locations?.append(contentsOf: [1 - tccPer, 1 - tccPer] as [NSNumber])
			gradient.colors?.append(contentsOf: [Colors.tooClose.cgColor, Colors.tooClose.cgColor])
		}

		gradient.locations?.append(1.0)
		
		if vertical {
			if dems > reps {
				gradient.startPoint = CGPoint(x: 0.5, y: 0)
				gradient.endPoint = CGPoint(x: 0.5, y: 1)
			} else {
				gradient.startPoint = CGPoint(x: 0.5, y: 1)
				gradient.endPoint = CGPoint(x: 0.5, y: 0)
			}
		} else {
			gradient.startPoint = CGPoint(x: 0, y: 0.5)
			gradient.endPoint = CGPoint(x: 1, y: 0.5)
		}
		return gradient
	}
	
}

extension Color {
	
	private static var dem: (r: Double, g: Double, b: Double) = (r: 35, g: 32, b: 102)
	private static var ind: (r: Double, g: Double, b: Double) = (r: 0, g: 190, b: 97)
	private static var rep: (r: Double, g: Double, b: Double) = (r: 233, g: 29, b: 14)
	private static var tcc: (r: Double, g: Double, b: Double) = (r: 102, g: 51, b: 153)

	static var democrat: Color {
		return Color(red: dem.r / 255.0, green: dem.g / 255.0, blue: dem.b / 255.0)
	}

	static var independent: Color {
		return Color(red: ind.r / 255.0, green: ind.g / 255.0, blue: ind.b / 255.0)
	}

	static var republican: Color {
		return Color(red: rep.r / 255.0, green: rep.g / 255.0, blue: rep.b / 255.0)
	}
	
	static var tooCloseToCall: Color {
		return Color(red: tcc.r / 255.0, green: tcc.g / 255.0, blue: tcc.b / 255.0)
	}

	private static func blend(dems: Double, inds: Double, reps: Double, tctc: Double) -> Color {
		let total = dems + inds + reps + tctc
		let red = (dem.r * dems + ind.r * inds + rep.r * reps + tcc.r * tctc) / total
		let green = (dem.g * dems + ind.g * inds + rep.g * reps + tcc.g * tctc) / total
		let blue = (dem.b * dems + ind.b * inds + rep.b * reps + tcc.b * tctc) / total
		return Color(red: red / 255, green: green / 255, blue: blue / 255)
	}
	
	static func blend(_ numbers: [String: Int]) -> Color {
		if numbers.count == 0 || (numbers.count == 1 && numbers.keys.first! == "") {
			return .gray
		}
		var dems = 0
		var inds = 0
		var reps = 0
		var tctc = 0
		for (key, count) in numbers {
			if key.starts(with: "d") {
				dems += count
			} else if key.starts(with: "i") {
				inds += count
			} else if key.starts(with: "r") {
				reps += count
			} else if key.starts(with: "t") {
				tctc += count
			}
		}
		return blend(dems: Double(dems), inds: Double(inds), reps: Double(reps), tctc: Double(tctc))
	}
	
}

extension Int {
	
	init(truncating num: Double) {
		self.init(truncating: NSNumber(floatLiteral: num))
	}
	
}

struct RectangleBorder: ViewModifier {
	var lineWidth: CGFloat = 3
	
	func body(content: Content) -> some View {
		content
			.clipShape(rowShape)
			.overlay(rowShape.stroke(Color.primary, lineWidth: lineWidth))
	}
	
}

//extension Player {
//
//	var ref: DatabaseReference {
//		return Database.database().reference().child("players").child(id!)
//	}
//
//	class func fetchWithID(_ id: String) -> Player? {
//		let request: NSFetchRequest<Player> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching election with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	class func fetchOrCreate(user: User, completion: @escaping (Player?) -> Void) {
//		if let player = Player.fetchWithID(user.uid) {
//			completion(player)
//		} else {
//			Database.database().reference().child("players").child(user.uid).observeSingleEvent(of: .value) { (snapshot) in
//				if !snapshot.exists() {
//					Database.database().reference().child("players").child(user.uid).setValue(["email": user.email]) { (error, _) in
//						if error != nil {
//							completion(nil)
//						} else {
//							let player = Player(user: user)
//							do {
//								try Objects.moc.save()
//							} catch {
//								print("Error saving player\n\(error)")
//							}
//							completion(player)
//						}
//					}
//				} else {
//					let player = Player(snapshot: snapshot)
//					do {
//						try Objects.moc.save()
//					} catch {
//						print("Error saving player\n\(error)")
//					}
//					completion(player)
//				}
//			}
//		}
//	}
//
//	private convenience init(user: User) {
//		self.init(context: Objects.moc)
//		email = user.email
//		id = user.uid
//		name = user.displayName
//	}
//
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		if let dict = snapshot.value as? [String: String] {
//			for (key, value) in dict {
//				setValue(value, forKey: key)
//			}
//		}
//	}
//
//	func updateData(name: String, email: String) {
//		ref.updateChildValues(["name": name, "email": email])
//	}
//
//}
//
//extension Election {
//
//	class func fetchCurrent() -> Election {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		if let id = UserData.data[.currentElection] as? String {
//			request.predicate = NSPredicate(format: "id = %@", id)
//		}
//		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//		do {
//			let elections = try Objects.moc.fetch(request)
//			var result = elections.first
//			for election in elections {
//				if let date = election.date, date.timeIntervalSinceNow > 0 {
//					result = election
//				}
//			}
//			if let id = result?.id {
//				UserData.data[.currentElection] = id
//			}
//			return result!
//		} catch {
//			print("Error fetching elections\n\(error)")
//			return Election(context: Objects.moc)
//		}
//	}
//
//	class func fetchAll() -> [Election] {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//		do {
//			let results = try Objects.moc.fetch(request)
//			return results
//		} catch {
//			print("Error fetching elections\n\(error)")
//			return [Election]()
//		}
//	}
//
//	class func fetchWithID(_ id: String) -> Election? {
//		let request: NSFetchRequest<Election> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching election with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	class func createNew(named name: String, date: Date, completion: @escaping (Election) -> Void) {
//		let payload = ["name": name, "date": Objects.dateFormatter.string(from: date), "modified": Objects.dateFormatter.string(from: Date())]
//		Database.database().reference().child("electionInfo").childByAutoId().setValue(payload) {
//			(error, reference) in
//			if let error = error {
//				print("Error creating new election\n\(error)")
//				return
//			}
//			reference.observeSingleEvent(of: .value, with: { (snapshot) in
//				let election = Election.createOrUpdate(snapshot: snapshot)
//				completion(election)
//			})
//		}
//	}
//
//	class func fetchAndCreateOrUpdateAll(completion: @escaping (Election) -> Void) {
//		let since = UserData.data[.lastElectionUpdate] as? String ?? Objects.dateFormatter.string(from: Date.distantPast)
//		Database.database().reference().child("electionInfo")
//			.queryOrdered(byChild: "modified").queryStarting(atValue: since).observeSingleEvent(of: .value) { (snaps) in
//				var last = since
//				for child in snaps.children {
//					if let snap = child as? DataSnapshot {
//						createOrUpdate(snapshot: snap)
//						if let mod = snap.childSnapshot(forPath: "modified").value as? String, Objects.dateFormatter.date(from: mod) != nil {
//							last = mod
//						}
//					}
//				}
//				let date = Objects.dateFormatter.date(from: last)!.addingTimeInterval(0.001)
//				UserData.data[.lastElectionUpdate] = Objects.dateFormatter.string(from: date)
//				completion(fetchCurrent())
//		}
//	}
//
//	@discardableResult class func createOrUpdate(snapshot: DataSnapshot) -> Election {
//		defer {
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving election\n\(error)")
//			}
//		}
//		if let election = fetchWithID(snapshot.key) {
//			election.updateFrom(snapshot: snapshot)
//			return election
//		} else {
//			let election = Election(snapshot: snapshot)
//			return election
//		}
//	}
//
//	var reference: DatabaseReference {
//		return Database.database().reference().child("electionInfo").child(id!)
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
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		updateFrom(snapshot: snapshot)
//	}
//
//	private func updateFrom(snapshot: DataSnapshot) {
//		if let dict = snapshot.value as? [String: String] {
//			for (key, value) in dict {
//				if let date = Objects.dateFormatter.date(from: value) {
//					setValue(date, forKey: key)
//				} else {
//					setValue(value, forKey: key)
//				}
//			}
//		}
//	}
//
//	func racesForState(_ state: String, activeOnly: Bool = false) -> [Race] {
//		return (races?.allObjects as? [Race])?.filter({ $0.state! == state && (!activeOnly || $0.isActive) }) ?? [Race]()
//	}
//
//	func racesForState(_ state: String, ofType type: RaceType, activeOnly: Bool = false) -> [Race] {
//		let races = racesForState(state, activeOnly: activeOnly)
//		return races.filter({ $0.raceType == type})
//	}
//
//	func racesOfType(_ type: RaceType, activeOnly: Bool = true) -> [Race] {
//		if let races = races?.allObjects as? [Race] {
//			return races.filter({ $0.raceType == type && (!activeOnly || $0.isActive) })
//		} else {
//			return []
//		}
//	}
//
//}
//
//extension Race: Comparable, Identifiable {
//
//	public static func < (lhs: Race, rhs: Race) -> Bool {
//		if lhs.state! != rhs.state! {
//			return lhs.state! < rhs.state!
//		} else if lhs.raceType != rhs.raceType {
//			return lhs.raceType < rhs.raceType
//		} else {
//			return lhs.id! < rhs.id!
//		}
//	}
//
//	class func fetchWithID(_ id: String) -> Race? {
//		let request: NSFetchRequest<Race> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching race with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	class func fetchAndCreateOrUpdateAll(forElection election: Election, completion: @escaping () -> Void) {
//		let since = UserData.data[.lastRaceUpdate] as? String ?? Objects.dateFormatter.string(from: Date.distantPast)
//		Database.database().reference().child("elections").child(election.id!).child("races")
//			.queryOrdered(byChild: "modified").queryStarting(atValue: since).observeSingleEvent(of: .value) { (snaps) in
//				var last = since
//				for child in snaps.children {
//					if let snap = child as? DataSnapshot {
//						createOrUpdate(snapshot: snap)
//						if let mod = snap.childSnapshot(forPath: "modified").value as? String, Objects.dateFormatter.date(from: mod) != nil {
//							last = mod
//						}
//					}
//				}
//				let date = Objects.dateFormatter.date(from: last)!.addingTimeInterval(0.001)
//				UserData.data[.lastRaceUpdate] = Objects.dateFormatter.string(from: date)
//				completion()
//		}
//	}
//
//	@discardableResult fileprivate class func createOrUpdate(snapshot: DataSnapshot) -> Race {
//		defer {
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving race\n\(error)")
//			}
//		}
//		if let race = fetchWithID(snapshot.key) {
//			race.updateFrom(snapshot: snapshot)
//			return race
//		} else {
//			let race = Race(snapshot: snapshot)
//			return race
//		}
//	}
//
//	var reference: DatabaseReference {
//		return Database.database().reference().child(election!.id!).child("races").child(id!)
//	}
//
//	var isActive: Bool {
//		return incumbency != nil
//	}
//
//	var raceType: RaceType {
//		return RaceType(rawValue: Int(type))!
//	}
//
//	var seats: Int {
//		if let incumbency = incumbency {
//			var count = 0
//			for numbers in incumbency.values {
//				count += numbers
//			}
//			return count
//		} else {
//			return 0
//		}
//	}
//
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		self.election = Election.fetchWithID(snapshot.ref.parent!.parent!.key!)
//		election?.addToRaces(self)
//		updateFrom(snapshot: snapshot)
//	}
//
//	private func updateFrom(snapshot: DataSnapshot) {
//		if let dict = snapshot.value as? [String: Any] {
//			for (key, value) in dict {
//				if let value = value as? String, let date = Objects.dateFormatter.date(from: value) {
//					setValue(date, forKey: key)
//				} else {
//					setValue(value, forKey: key)
//				}
//			}
//		}
//	}
//
//	func savePrediction(numbers: [String: Int], _ completion: ((Prediction?) -> Void)?) {
//		if let prediction = prediction {
//			prediction.save(newAssertion: numbers, completion: completion)
//		} else {
//			Prediction.createNew(forRace: self, withAssertion: numbers, completion: completion)
//		}
//	}
//
//}
//
//extension Prediction {
//
//	class func fetchWithID(_ id: String) -> Prediction? {
//		let request: NSFetchRequest<Prediction> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching prediction with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	// TODO: Fetch only updated Predictions; probably through callable
//	class func fetchAndCreateOrUpdateAll(forElection election: Election, forPlayer player: String, completion: @escaping () -> Void) {
////		let now = Objects.dateFormatter.string(from: Date())
////		let since = UserData.data[.lastPredictionUpdate] ?? Objects.dateFormatter.string(from: Date.distantPast)
//		Database.database().reference().child("elections").child(election.id!).child("predictions")
//			.queryOrdered(byChild: "owner")
//			.queryEqual(toValue: player).observeSingleEvent(of: .value) {
//				(snaps) in
//				for child in snaps.children {
//					if let snap = child as? DataSnapshot {
//						createOrUpdate(snapshot: snap)
//					}
//				}
////				UserData.data[.lastPredictionUpdate] = now
//				completion()
//		}
//	}
//
//	@discardableResult private class func createOrUpdate(snapshot: DataSnapshot) -> Prediction {
//		defer {
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving prediction\n\(error)")
//			}
//		}
//		if let prediction = fetchWithID(snapshot.key) {
//			prediction.updateFrom(snapshot: snapshot)
//			return prediction
//		} else {
//			let prediction = Prediction(snapshot: snapshot)
//			return prediction
//		}
//	}
//
//	class func createNew(forRace race: Race, withAssertion assertion: [String: Int], completion: ((Prediction?) -> Void)?) {
//		var payload: [String: Any] = ["prediction": assertion]
//		payload["election"] = race.election!.id!
//		payload["race"] = race.id!
//		Functions.functions().httpsCallable("makePrediction").call(payload) { (result, error) in
//			guard let result = result, let id = result.data as? String else {
//				print("Error creating prediction")
//				if let error = error {
//					print(error)
//				}
//				completion?(nil)
//				return
//			}
//			let prediction = Prediction(id: id, forRace: race, withAssertion: assertion)
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving new prediction\n\(error)")
//			}
//			completion?(prediction)
//		}
//	}
//
//	var demNumber: Int {
//		var number = 0
//		if let prediction = assertion {
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
//		if let prediction = assertion {
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
//		if let assertion = assertion {
//			for (key, value) in assertion {
//				if key.starts(with: "i") {
//					number += value
//				}
//			}
//		}
//		return number
//	}
//
//	var reference: DatabaseReference {
//		return Database.database().reference().child("elections").child(race!.election!.id!)
//			.child("predictions").child(id!)
//	}
//
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		if let dict = snapshot.value as? [String: Any] {
//			if let raceID = dict["race"] as? String {
//				race = Race.fetchWithID(raceID)
//				race?.prediction = self
//			}
//			player = Player.fetchWithID(dict["owner"] as! String)
//			player?.addToPredictions(self)
//		}
//		updateFrom(snapshot: snapshot)
//	}
//
//	private convenience init(id: String, forRace race: Race, withAssertion assertion: [String: Int]) {
//		self.init(context: Objects.moc)
//		self.id = id
//		self.race = race
//		race.prediction = self
//		player = Player.fetchWithID(UserData.userID)
//		player?.addToPredictions(self)
//		self.assertion = assertion
//	}
//
//	private func updateFrom(snapshot: DataSnapshot) {
//		if let dict = snapshot.value as? [String: Any] {
//			if let guess = dict["prediction"] as? [String: Int] {
//				assertion = guess
//			}
//			if let score = dict["rawScore"] as? Double {
//				rawScore = score
//			}
//			if let leagues = dict["leagueScores"] as? [String: Double] {
//				leagueScores = leagues
//			}
//		}
//	}
//
//	func save(newAssertion: [String: Int], completion: ((Prediction) -> Void)?) {
//		var payload: [String: Any] = ["prediction": newAssertion]
//		payload["election"] = race!.election!.id!
//		payload["race"] = race!.id!
//		Functions.functions().httpsCallable("makePrediction").call(payload) { (result, error) in
//			self.assertion = newAssertion
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error updating prediction for \(self.race!.state!)")
//			}
//			completion?(self)
//		}
//	}
//
//	func getColor() -> UIColor {
//		return Colors.getColor(for: assertion)
//	}
//
//	func getWinner() -> (String, Int)? {
//		// TODO: There is something screwy with this
//		if let prediction = assertion, prediction.count == 1, let winner = prediction.keys.first, let number = prediction[winner] {
//			return (winner, number)
//		} else {
//			return nil
//		}
//	}
//
//}
//
//extension League: Comparable {
//
//	public static func < (lhs: League, rhs: League) -> Bool {
//		if lhs.name! != rhs.name! {
//			return lhs.name! < rhs.name!
//		} else {
//			return lhs.owner! < rhs.owner!
//		}
//	}
//
//	fileprivate class func fetchWithID(_ id: String) -> League? {
//		let request: NSFetchRequest<League> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching prediction with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	class func createNew(named: String, forElection election: Election, forRaces races: [Int], isOpen: Bool, completion: @escaping (League?) -> Void) {
//		let payload: [String: Any] = ["name": named, "election": election.id!, "isOpen": isOpen, "races": races]
//		Functions.functions().httpsCallable("createLeague").call(payload) { (result, error) in
//			guard let result = result, let id = result.data as? String else {
//				print("Error creating league")
//				if let error = error {
//					print(error)
//				}
//				completion(nil)
//				return
//			}
//			let league = League(id: id, named: named, forElection: election, forRaces: races, isOpen: isOpen)
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving new league\n\(error)")
//			}
//			completion(league)
//		}
//	}
//
//	// TODO: Get membership for all leagues? Only for joined leagues?
//	//		 I would need to have a different structure to hide members until joined
//	//       I feel like it's okay to know membership of all leagues
//	class func fetchAndCreateOrUpdateAll(forElection election: Election, completion: @escaping () -> Void) {
//		let since =  UserData.data[.lastLeagueUpdate] as? String ?? Objects.dateFormatter.string(from: Date.distantPast)
//		Database.database().reference().child("elections").child(election.id!).child("leagues")
//			.queryOrdered(byChild: "modified").queryStarting(atValue: since).observeSingleEvent(of: .value) {
//				(snaps) in
//				var last = since
//				for child in snaps.children {
//					if let snap = child as? DataSnapshot {
//						createOrUpdate(snapshot: snap)
//						if let mod = snap.childSnapshot(forPath: "modified").value as? String, Objects.dateFormatter.date(from: mod) != nil {
//							last = mod
//						}
//					}
//				}
//				let date = Objects.dateFormatter.date(from: last)!.addingTimeInterval(0.001)
//				UserData.data[.lastLeagueUpdate] = Objects.dateFormatter.string(from: date)
//				do {
//					try Objects.moc.save()
//				} catch {
//					print("Error saving league\n\(error)")
//				}
//				completion()
//		}
//	}
//
//	@discardableResult private class func createOrUpdate(snapshot: DataSnapshot) -> League {
//		if let league = League.fetchWithID(snapshot.key) {
//			league.updateInfoFrom(snapshot: snapshot)
//			return league
//		} else {
//			let league = League(snapshot: snapshot)
//			return league
//		}
//	}
//
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		election = Election.fetchWithID(snapshot.ref.parent!.parent!.key!)
//		election?.addToLeagues(self)
//		updateInfoFrom(snapshot: snapshot)
//	}
//
//	private convenience init(id: String, named: String, forElection election: Election, forRaces races: [Int], isOpen: Bool) {
//		self.init(context: Objects.moc)
//		self.id = id
//		self.name = named
//		self.election = election
//		self.election?.addToLeagues(self)
//		self.races = races
//		self.isOpen = isOpen
//		self.owner = UserData.userID
//		let player = Player.fetchWithID(UserData.userID)!
//		let member = Member(player: player)
//		member.league = self
//		addToMembers(member)
//	}
//
//	private func updateInfoFrom(snapshot: DataSnapshot) {
//		if let dict = snapshot.value as? [String: Any] {
//			setValue(dict["leagueName"], forKey: "name")
//			setValue(dict["owner"], forKey: "owner")
//			setValue(dict["isOpen"], forKey: "isOpen")
//			if let types = dict["raceTypes"] as? NSArray {
//				races = [Int]()
//				for i in 0..<types.count {
//					if types[i] as? Bool ?? false {
//						races!.append(i)
//					}
//				}
//			}
//		}
//		let membersSnap = snapshot.childSnapshot(forPath: "members")
//		for child in membersSnap.children {
//			if let snap = child as? DataSnapshot {
//				Member.createOrUpdate(snapshot: snap)
//			}
// 		}
//	}
//
//	private func updateScores(snapshot: DataSnapshot) {
//		for child in snapshot.children {
//			if let snap = child as? DataSnapshot, let _ = snap.value as? [String: Any] {
//				Member.createOrUpdate(snapshot: snapshot)
//			}
//		}
//	}
//
//	func memberWith(id: String) -> Member? {
//		if let members = members?.allObjects as? [Member] {
//			for member in members {
//				if member.id! == id {
//					return member
//				}
//			}
//		}
//		return nil
//	}
//
//}
//
//extension Member {
//
//	private class func fetchWithID(_ id: String) -> Member? {
//		let request: NSFetchRequest<Member> = fetchRequest()
//		request.predicate = NSPredicate(format: "id = %@", id)
//		do {
//			return try Objects.moc.fetch(request).first
//		} catch {
//			print("Error fetching member with id \(id)\n\(error)")
//			return nil
//		}
//	}
//
//	@discardableResult class func createOrUpdate(snapshot: DataSnapshot) -> Member {
//		defer {
//			do {
//				try Objects.moc.save()
//			} catch {
//				print("Error saving new member\n\(error)")
//			}
//		}
//		let leagueID = snapshot.ref.parent!.parent!.key!
//		let league = League.fetchWithID(leagueID)!
//		if let member = league.memberWith(id: snapshot.key) {
//			member.updateFrom(snapshot: snapshot)
//			return member
//		} else {
//			let member = Member(snapshot: snapshot)
//			member.league = league
//			league.addToMembers(member)
//			return member
//		}
//	}
//
//	private convenience init(snapshot: DataSnapshot) {
//		self.init(context: Objects.moc)
//		id = snapshot.key
//		updateFrom(snapshot: snapshot)
//	}
//
//	fileprivate convenience init(player: Player) {
//		self.init(context: Objects.moc)
//		id = player.id
//		name = player.name
//	}
//
//	private func updateFrom(snapshot: DataSnapshot) {
//		if let dict = snapshot.value as? [String: Double] {
//			scores = dict
//		} else if let dict = snapshot.value as? [String: Any] {
//			name = dict["name"] as? String
//		}
//	}
//
//	func score(forRace race: Race) -> Double {
//		return scores?[race.id!] ?? 0
//	}
//
//	func score(forRaceType type: RaceType?) -> Double {
//		var total = 0.0
//		if let scores = scores {
//			if let type = type {
//				for (raceID, score) in scores {
//					if let race = Race.fetchWithID(raceID), race.raceType == type {
//						total += score
//					}
//				}
//			} else {
//				for score in scores.values {
//					total += score
//				}
//			}
//		}
//		return total
//	}
//
//}
