//
//  LeagueChoiceViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/17/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class LeagueChoiceViewController: UITableViewController {

	@IBOutlet weak var leagueTable: UITableView!
	
	var myLeagues: [League]!
	var otherLeagues: [League]!
	var election: Election!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		myLeagues = [League]()
		otherLeagues = [League]()
		let leagueList = election.leagues?.allObjects as? [League] ?? []
		for league in leagueList {
			if let members = league.members?.allObjects as? [Member], members.contains(where: { (member) -> Bool in
				return member.id! == UserData.userID
			}) {
				self.myLeagues.append(league)
			} else {
				self.otherLeagues.append(league)
			}
		}
		myLeagues.sort()
		otherLeagues.sort()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? LeagueCreationViewController {
			destination.election = election
			destination.leagueCreation = addLeague
		} else if let destination = segue.destination as? LeagueViewController {
			destination.league = sender as? League
			destination.election = election
		}
	}
	
	func addLeague(_ league: League) {
		if league.memberWith(id: UserData.userID) != nil {
			myLeagues.append(league)
			myLeagues.sort()
			leagueTable.reloadSections(IndexSet(integer: 0), with: .automatic)
		} else {
			otherLeagues.append(league)
			otherLeagues.sort()
			leagueTable.reloadSections(IndexSet(integer: 1), with: .automatic)
		}
	}
	
	@IBAction func done(_ sender: AnyObject?) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: UITableViewDataSource functions
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return myLeagues.count
		} else if section == 1 {
			return otherLeagues.count
		} else {
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "My Leagues"
		} else if section == 1 {
			return "Available Leagues"
		} else {
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "leagueChoiceCell")!
		let league: League
		if indexPath.section == 0 {
			league = myLeagues[indexPath.row]
			cell.accessoryType = .disclosureIndicator
		} else {
			league = otherLeagues[indexPath.row]
			cell.accessoryType = .none
		}
		let prefix = league.owner! == UserData.userID ? "• " : ""
		cell.textLabel?.text = "\(prefix)\(league.name!) - \(league.members!.count) members - "
		cell.textLabel?.text?.append(league.isOpen ? "Open" : "Closed")
		return cell
	}

	// MARK: UITableViewDelegate functions
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 0 {
			performSegue(withIdentifier: "showLeague", sender: myLeagues[indexPath.row])
		} else if indexPath.section == 1 {
			let league = otherLeagues[indexPath.row]
			debugPrint(league.owner ?? "No Owner")
			let alert = UIAlertController(title: "Join \(league.name!)", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Join", style: .default) {
				(_) in
				// TODO: Join league via callable
				
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}

}
