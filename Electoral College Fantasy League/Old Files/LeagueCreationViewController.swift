//
//  LeagueCreationViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/17/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class LeagueCreationViewController: UITableViewController {
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var openSwitch: UISwitch!
	@IBOutlet var switches: [UISwitch]!
	
	var election: Election!
	
	var leagueCreation: ((League) -> Void)!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let types = election.raceTypes
		for raceSwitch in switches {
			if types.contains(RaceType(rawValue: raceSwitch.tag)!) {
				raceSwitch.isOn = true
				raceSwitch.isEnabled = true
			} else {
				raceSwitch.isOn = false
				raceSwitch.isEnabled = false
			}
		}
	}
	
	@IBAction func createLeague(_ sender: AnyObject?) {
		let name = nameField.text!
		var races = [Int]()
	
		for raceSwitch in switches {
			if raceSwitch.isOn {
				races.append(raceSwitch.tag)
			}
		}
		League.createNew(named: name, forElection: election, forRaces: races, isOpen: true) { (league) in
			guard let league = league else {
				print("Unable to create league")
				return
			}
			self.leagueCreation(league)
			self.dismiss(animated: true, completion: nil)
		}
		//TODO: Create league as callable

	}
	
	@IBAction func cancel(_ sender: AnyObject?) {
		dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}

extension LeagueCreationViewController: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if var text = textField.text, let range: Range<String.Index> = Range<String.Index>.init(range, in: text) {
			text.replaceSubrange(range, with: string)
			if text != "" {
				saveButton.isEnabled = true
			} else {
				saveButton.isEnabled = false
			}
		} else {
			saveButton.isEnabled = false
		}
		return true
	}
	
}
