//
//  CoreDataStack.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/24/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import CoreData

enum Constants: String {
	case lastElectionUpdate
	case lastRaceUpdate
	case lastPredictionUpdate
	case lastLeagueUpdate
	case currentElection
	case setName
}

enum RaceType: Int, CaseIterable, Comparable, Identifiable
{
	var id: Int { return rawValue }
	
	static func < (lhs: RaceType, rhs: RaceType) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	case president = 0
	case senate
	case house
	case governor
}

struct Objects {
	static let dateFormatter: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions.formUnion(.withFractionalSeconds)
		return formatter
	}()
	static let suiteName = "group.com.lsapps.Electoral-College-Fantasy-League"
}

class CoreDataStack {
	
	static var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "Electoral_College_Fantasy_League")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	static var managedObjectContext: NSManagedObjectContext = {
		return persistentContainer.viewContext
	}()

}
