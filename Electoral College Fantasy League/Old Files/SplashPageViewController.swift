//
//  SplashPageViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/16/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import FirebaseUI

class SplashPageViewController: UIViewController {
	
	var handle: AuthStateDidChangeListenerHandle!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		deleteAllData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		view.layoutSubviews()
	}
		
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let authUI = FUIAuth.defaultAuthUI()
		authUI?.delegate = self
		authUI?.providers = [FUIEmailAuth()]
		handle = Auth.auth().addStateDidChangeListener() {
			(auth, user) in
			if let user = user {
				UserData.userID = user.uid
				Player.fetchOrCreate(user: user, completion: { (player) in
					self.performSegue(withIdentifier: "verifiedSegue", sender: player)
				})
			} else {
				self.performSegue(withIdentifier: "loginSegue", sender: nil)
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		Auth.auth().removeStateDidChangeListener(handle)
	}

	func deleteAllData() {
		Election.deleteAll(context: Objects.moc)
		Race.deleteAll(context: Objects.moc)
		Prediction.deleteAll(context: Objects.moc)
		League.deleteAll(context: Objects.moc)
		Member.deleteAll(context: Objects.moc)
		Player.deleteAll(context: Objects.moc)
		let userDefaults = UserDefaults.standard
		for (key, _) in userDefaults.dictionaryRepresentation() {
			userDefaults.removeObject(forKey: key)
		}
	}
	
	@objc override func logout() {
		do {
			try Auth.auth().signOut()
		} catch {
			print("Error logging out\n\(error)")
		}
	}
	
}

extension SplashPageViewController: FUIAuthDelegate {
	
	func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
		if let error = error {
			print("Error logging in\n\(error)")
			return
		}
	}
	
}

extension UIViewController {
	
	@objc func logout() {
		print("Logging out of \(self)")
		if let navigation = self as? UINavigationController {
			print("Presenting \(navigation.topViewController!)")
		}
		if let presenter = presentingViewController {
			dismiss(animated: false) {
				presenter.logout()
			}
		} else {
			print("No one is presenting me")
		}
	}
	
	func topMostController() -> UIViewController {
		if let controller = self as? UINavigationController, let top = controller.topViewController {
			return top.topMostController()
		} else if let controller = presentedViewController {
			return controller.topMostController()
		} else {
			return self
		}
	}
	
}
