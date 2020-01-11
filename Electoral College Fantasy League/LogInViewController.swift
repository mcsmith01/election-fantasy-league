//
//  LogInViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/16/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI

class LogInViewController: UIViewController {
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var mapContainer: UIView!

	var handle: AuthStateDidChangeListenerHandle!
	var electoralMap: ElectoralMapViewController!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		view.layoutSubviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if handle != nil {
			createOrLogin(nil)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		Auth.auth().removeStateDidChangeListener(handle)
	}
	
	@IBAction func createOrLogin(_ sender: AnyObject?) {
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
				let authViewController = authUI!.authViewController()
				self.present(authViewController, animated: true, completion: nil)
			}
		}
	}

}

extension LogInViewController: FUIAuthDelegate {
	
	func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
		if let error = error {
			print("Error logging in\n\(error)")
			return
		}
	}
	
}
