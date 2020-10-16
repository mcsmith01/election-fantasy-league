//
//  DataLoadingViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/24/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class DataLoadingViewController: UIViewController {
	
	@IBOutlet weak var progressLabel: UILabel!
	
	var elections: [Election]!
	var election: Election!
	var races: [Race]!
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadData()
	}
	
	func loadData() {
		DispatchQueue.main.async {
			self.progressLabel.text = "Loading Election Data..."
		}
		Election.fetchAndCreateOrUpdateAll { (current) in
			self.election = current
			DispatchQueue.main.async {
				self.progressLabel.text = "Loading Race Data..."
			}
			Race.fetchAndCreateOrUpdateAll(forElection: self.election, completion: {
				self.races = self.election.races?.allObjects as? [Race] ?? []
				DispatchQueue.main.async {
					self.progressLabel.text = "Loading User Data..."
				}
				Prediction.fetchAndCreateOrUpdateAll(forElection: self.election, forPlayer: UserData.userID, completion: {
					DispatchQueue.main.async {
						self.progressLabel.text = "Loading League Data..."
					}
					League.fetchAndCreateOrUpdateAll(forElection: self.election, completion: {
						self.performSegue(withIdentifier: "presentMain", sender: nil)
					})
				})
			})
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		DispatchQueue.main.async {
			self.progressLabel.text = "Loading Election Maps..."
		}
		if let mainController = segue.destination as? MainViewController {
			mainController.election = election
			mainController.races = races
		} else if let destination = segue.destination as? ElectionsViewController {
			destination.election = election
			let allRaces = races.reduce(into: [RaceType: [Race]]()) { (dict, race) in
				if dict[race.raceType] == nil {
					dict[race.raceType] = [race]
				} else {
					dict[race.raceType]!.append(race)
				}
			}
			destination.allRaces = allRaces
		}
	}
	
}
