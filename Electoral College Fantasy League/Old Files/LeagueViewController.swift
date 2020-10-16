//
//  LeagueViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/16/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class LeagueViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var raceSegmented: UISegmentedControl!
	
	var election: Election!
	var league: League!
	var members = [Int: [Member]]()
	var raceCount = [RaceType: Int]()
	
	// TODO: Listen for updates from election?
	
	override func viewDidLoad() {
		navigationItem.title = league.name
		if let races = league.races {
			for i in 1..<4 {
				raceSegmented.setEnabled(races.contains(i - 1), forSegmentAt: i)
			}
		}
		let races = election.races?.allObjects as? [Race] ?? []
		for race in races {
			if race.isActive {
				if raceCount[race.raceType] != nil {
					raceCount[race.raceType]! += 1
				} else {
					raceCount[race.raceType] = 1
				}
			}
		}
		let players = (league.members!.allObjects as! [Member])
		members[0] = [Member]()
		members[0]!.append(contentsOf: players)
		for type in league.races ?? [] {
			members[type + 1] = [Member]()
			members[type + 1]!.append(contentsOf: players)
		}
		for (type, _) in members {
			members[type]!.sort() {
				let raceType = RaceType(rawValue: type - 1)
				return $0.score(forRaceType: raceType) < $1.score(forRaceType: raceType)
			}
		}
	}
	
	@IBAction func changedRace(_ sender: AnyObject?) {
		tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
	
}

extension LeagueViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return members[raceSegmented.selectedSegmentIndex]?.count ?? 0
	}
	
}

extension LeagueViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell")!
		let playerList = members[raceSegmented.selectedSegmentIndex] ?? []
		let player = playerList[indexPath.row]
		
		let name = player.name!
		let raceType = RaceType(rawValue: raceSegmented.selectedSegmentIndex - 1)
		let total = player.score(forRaceType: raceType)
		if raceType == nil {
			let newTotal = round(total * 10000) / 100.0
			cell.textLabel?.text = "\(name) - \(newTotal)%"
		} else {
			if total == floor(total) {
				cell.textLabel?.text = "\(name) - \(Int(total))"
			} else {
				cell.textLabel?.text = "\(name) - \(total)"
			}
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
}
