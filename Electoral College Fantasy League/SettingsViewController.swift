//
//  SettingsViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/3/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var versionLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let player = Player.fetchWithID(UserData.userID)
		nameLabel.text = "Name: \(player?.name ?? "None")"
		emailLabel.text = "Email: \(player?.email ?? "None")"
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			let buildString: String
			if let buildNum = Int(build) {
				buildString = " (\(buildNum))"
			} else {
				buildString = ""
			}
			versionLabel.text = "Version \(version)\(buildString)"
		} else {
			versionLabel.text = "Unknown Version"
		}
	}
	
	@IBAction func done(_ sender: AnyObject?) {
		navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 2
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let userDefaults = UserDefaults.standard
		if indexPath.section == 2 {
			let alert = UIAlertController(title: "Log out?", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Yes", style: .destructive) {
				(_) in
				userDefaults.removeObject(forKey: "username")
				self.logout()
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}
}
