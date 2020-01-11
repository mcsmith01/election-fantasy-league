//
//  AppDelegate.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/12/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		
		UNUserNotificationCenter.current().delegate = self
		
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: {_, _ in })
	
		application.registerForRemoteNotifications()
//		application.applicationIconBadgeNumber = 0
		Messaging.messaging().delegate = self
		return true
	}
	
	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

//	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//		Messaging.messaging().apnsToken = deviceToken
//	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
		let userDefaults = UserDefaults.standard
		userDefaults.setValue("Token", forKey: "token")
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		debugPrint("aadRRNuI")
//		print(userInfo)
//		let managedObjectContext = persistentContainer.viewContext
//		let raceId = userInfo["race"] as! String
//		let resultString = userInfo["results"] as! String
//		do {
//			if let json = try JSONSerialization.jsonObject(with: resultString.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: String] {
//				let results = json.reduce(into: [String: Int]()) { (result, pair) in
//					let (key, value) = pair
//					result[key] = Int(value)!
//				}
//				let race = Race.fetchWithID(raceId, moc: managedObjectContext)!
//				race.results = results
//				let content = UNMutableNotificationContent()
//				let type: String
//				switch race.raceType {
//				case .president: type = "President"
//				case .senate: type = "senate"
//				case .house: type = "house"
//				case .governor: type = "governor"
//				}
//				content.title = "The race for \(type) in \(race.name) is over"
//				if race.raceType == .house {
//					if let reps = results["r"], Int32(reps) == race.state!.representatives {
//						if reps == 1 {
//							content.body = "The republican won the seat"
//						} else {
//							content.body = "The republicans won every race"
//						}
//					} else if let dems = results["d"], Int32(dems) == race.state!.representatives {
//						if dems == 1 {
//							content.body = "The democrat won the seat"
//						} else {
//							content.body = "The democrats won every race"
//						}
//					} else if let inds = results["i"], Int32(inds) == race.state!.representatives {
//						if inds == 1 {
//							content.body = "The independent won the seat"
//						} else {
//							content.body = "The independents won every race"
//						}
//					} else {
//						var body = "The seats were split\n"
//						if let dems = results["d"], dems > 0 {
//							body += "Dem: \(dems) "
//						}
//						if let inds = results["i"], inds > 0 {
//							body += "Ind: \(inds) "
//						}
//						if let reps = results["r"], reps > 0 {
//							body += "Rep: \(reps)"
//						}
//						content.body = body
//					}
//				} else {
//					let party = results.keys.first!
//					let winner = race.candidates![party]!
//					let percent = results[party]!
//					if percent < 0 {
//						content.body = "\(winner) won, but the percent has not been verified"
//					} else {
//						content.body = "\(winner) won with \(percent)% of the vote"
//					}
//				}
//				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//				let request = UNNotificationRequest(identifier: race.id!, content: content, trigger: trigger)
//				UNUserNotificationCenter.current().add(request) { (error) in
//					if let error = error {
//						print("Error sending notification\n\(error)")
//					}
//				}
//				completionHandler(UIBackgroundFetchResult.newData)
//			} else {
//				debugPrint("Bad JSON")
//				completionHandler(UIBackgroundFetchResult.failed)
//			}
//		} catch {
//			print("Error decoding race results\n\(error)")
//			completionHandler(UIBackgroundFetchResult.failed)
//		}
	}
	
//	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//		print("aadRRNuIfCH")
//		let managedObjectContext: NSManagedObjectContext
//			managedObjectContext = persistentContainer.viewContext
//		if let calledState = userInfo["called"] as? [String: AnyObject] {
//			do {
//				print("Called State")
//				let stateDict = calledState["state"] as! [String: AnyObject]
//				let stateFetch: NSFetchRequest<State> = State.fetchRequest()
//				stateFetch.predicate = NSPredicate(format: "name = %@", argumentArray: [stateDict["name"] as! String])
//				let stateResults = try managedObjectContext.fetch(stateFetch) as [State]
//				let state = stateResults.first!
//				state.percent = Float(stateDict["percentage"] as! String)!
//				state.winner = Int32(stateDict["winner"] as! String)!
//				state.rep_delegates = Int32(stateDict["rep_delegates"] as! String)!
//				state.called = true
//
//				let leagues = calledState["leagues"] as! [[String: AnyObject]]
//				for leagueDict in leagues {
//					let leagueFetch: NSFetchRequest<League> = League.fetchRequest()
//					leagueFetch.predicate = NSPredicate(format: "name = %@", argumentArray: [leagueDict["name"] as! String])
//					let leagueResults = try managedObjectContext.fetch(leagueFetch)
//					let league = leagueResults.first!
//					let members = leagueDict["members"] as! [String]
//					for member in members {
//						let split = member.components(separatedBy: "=")
//						let memberName = split[0]
//						let memberScore = Int32(split[1])!
//						let score = AppDelegate.scoreForPlayer(memberName, inLeague: league, context: managedObjectContext)
//						score?.score = memberScore
//					}
//					print("---")
//				}
//				saveContext()
//			} catch {
//				print("Error fetching state\n\(error)")
//			}
//		} else if let leagueRequest = userInfo["league_request"] as? [String: AnyObject] {
//			do {
//				let leagueFetch: NSFetchRequest<League> = League.fetchRequest()
//				leagueFetch.predicate = NSPredicate(format: "name = %@", argumentArray: [leagueRequest["league"] as!String])
//				let leagueResults = try managedObjectContext.fetch(leagueFetch) as [League]
//				let league = leagueResults.first!
//				let score = AppDelegate.scoreForPlayer(leagueRequest["player"] as! String, inLeague: league, context: managedObjectContext)
//				let player = score?.player
//				player?.pending = true
//				saveContext()
//			} catch {
//				print("Error fetching league\n\(error)")
//			}
//		} else if let leagueAddition = userInfo["league_addition"] as? [String: AnyObject] {
//			do {
//				let leagueFetch: NSFetchRequest<League> = League.fetchRequest()
//				leagueFetch.predicate = NSPredicate(format: "name = %@", argumentArray: [leagueAddition["league"] as! String])
//				let leagueResults = try managedObjectContext.fetch(leagueFetch) as [League]
//				let league = leagueResults.first!
//				_ = AppDelegate.scoreForPlayer(leagueAddition["player"] as! String, inLeague: league, context: managedObjectContext)
//				saveContext()
//			} catch {
//				print("Error fetching league\n\(error)")
//			}
//		} else if let leagueRequestResponse = userInfo["league_response"] as? [String: AnyObject] {
//			do {
//				let leagueFetch: NSFetchRequest<League> = League.fetchRequest()
//				leagueFetch.predicate = NSPredicate(format: "name = %@", argumentArray: [leagueRequestResponse["name"] as! String])
//				let leagueResults = try managedObjectContext.fetch(leagueFetch) as [League]
//				let league = leagueResults.first!
//				let success = leagueRequestResponse["accepted"] as! Int
//				if success == 1 {
//					league.pending = false
//					let members = leagueRequestResponse["members"] as! [String]
//					for member in members {
//						_ = AppDelegate.scoreForPlayer(member, inLeague: league, context: managedObjectContext)
//					}
//				} else {
//					let score = (league.scores?.allObjects as! [Score]).first!
//					let member = score.player!
//					member.removeFromScores(score)
//					league.removeFromScores(score)
//					managedObjectContext.delete(score)
//					managedObjectContext.delete(league)
//				}
//				saveContext()
//			} catch {
//				print("Error fetching league\n\(error)")
//			}
//		} else {
//			print("No matching request for userInfo")
//		}
//		print(userInfo["aps"]!)
//		completionHandler(.newData)
//
//	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//		// Saves changes in the application's managed object context before the application terminates.
//		self.saveContext()
	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentContainer = {
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
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

}


extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("uNCcwPwCH")
		debugPrint(notification)
		completionHandler([.alert, .badge, .sound])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//		let actionIdentifier = response.actionIdentifier
//		print(response)
		print("uNCcdRwCH")
		let userInfo = response.notification.request.content.userInfo
		//		if let messageID = userInfo[gcmMessageIDKey] {
		//			debugPrint(messageID)
		//		}
		print(userInfo)
		completionHandler()
	}
	
}

extension AppDelegate: MessagingDelegate {
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		debugPrint("FCM Token: \(fcmToken)")
		Messaging.messaging().subscribe(toTopic: "all")
	}
	
}

extension NSManagedObject {
	
	class func deleteAll(context: NSManagedObjectContext) {
		do {
			let objects = try context.fetch(fetchRequest()) as! [NSManagedObject]
			for object in objects {
				context.delete(object)
			}
			try context.save()
		} catch {
			print("Error deleting objects\n\(error)")
		}
	}
}

