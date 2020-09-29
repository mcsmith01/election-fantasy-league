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
	let notificationCenter = UNUserNotificationCenter.current()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = true
		
		notificationCenter.delegate = self
		
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		notificationCenter.requestAuthorization(options: authOptions) {
			(didAllow, error) in
			if !didAllow {
				debugPrint("User declined notificationos")
			}
		}
	
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

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print(error)
		let userDefaults = UserDefaults.standard
		userDefaults.setValue("Token", forKey: "token")
	}
	
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
		completionHandler([.alert, .sound])
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
		print(response.actionIdentifier)
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

