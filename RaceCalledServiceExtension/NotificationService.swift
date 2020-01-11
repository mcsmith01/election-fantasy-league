//
//  NotificationService.swift
//  RaceCalledServiceExtension
//
//  Created by Chase Smith on 10/24/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
	
	var contentHandler: ((UNNotificationContent) -> Void)?
	var bestAttemptContent: UNMutableNotificationContent?
	
	override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
		self.contentHandler = contentHandler
		bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		
		if let bestAttemptContent = bestAttemptContent {
			// Modify the notification content here...
			
			let userInfo = bestAttemptContent.userInfo
			let userDefaults = UserDefaults.init(suiteName: Objects.suiteName)!
			if let stateID  = userInfo["state"] as? String, let resultString = userInfo["results"] as? String, let type = userInfo["type"] as? Int, let complete = userInfo["complete"] as? Bool {
				
				do {
					if let json = try JSONSerialization.jsonObject(with: resultString.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Int], let stateName = userDefaults.string(forKey: stateID) {
						let results = json.reduce(into: [String: Int]()) { (result, pair) in
							let (key, value) = pair
							result[key] = value
						}
						let typeString: String
						let raceType = RaceType(rawValue: type)!
						switch raceType {
						case .president: typeString = "Presidential"
						case .senate: typeString = "senate"
						case .house: typeString = "house"
						case .governor: typeString = "governor"
						}
						if complete {
							bestAttemptContent.title = "\(stateName) \(typeString) results:"
						} else {
							bestAttemptContent.title = "\(stateName) \(typeString) update:"
						}
						if raceType == .house {
							var body = "The seats "
							if complete {
								body += "were won as follows:\n"
							} else {
								body += "are currently:\n"
							}
							body += "Dem: \(results["d"] ?? 0) - "
							if let inds = results["i"], inds > 0 {
								body += "Ind: \(inds) - "
							}
							body += "Rep: \(results["r"] ?? 0)"
							bestAttemptContent.body = body
						} else {
							let candidates = userInfo["candidates"] as! [String: String]
							let party = results.keys.first!
							let winner = candidates[party]!
							let percent = results[party]!
							if complete {
								bestAttemptContent.body = "\(winner) wins with \(percent)% of the vote"
							} else {
								bestAttemptContent.body = "\(winner) wins, but the percent has not been verified"
							}
						}
						
					}
				} catch {
					print("Error fetching called race\n\(error)")
				}
			}
			contentHandler(bestAttemptContent)
		}
	}
	
	override func serviceExtensionTimeWillExpire() {
		// Called just before the extension will be terminated by the system.
		// Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
		//TODO: Remove this, original is generic on failure
		if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
			bestAttemptContent.title = "\(bestAttemptContent) [modified]"
			contentHandler(bestAttemptContent)
		}
	}
	
}
