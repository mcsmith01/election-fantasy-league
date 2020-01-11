//
//  MainViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/15/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
	
	@IBOutlet weak var mapViews: UIView!
	@IBOutlet weak var tableViews: UIView!
	@IBOutlet weak var demDelegatesLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var repDelegatesLabel: UILabel!
	
	var mapPageViewController: ElectionPageViewController!
	var tableViewController: TabbedTableViewController!
	var displayedElection: ElectoralMapViewController!
	var election: Election!
	var states: [String]!
	var races: [Race]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableViewController.setStateTableDataSourceAndDelegate(displayedElection)
		view.layoutSubviews()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "embedTables" {
			tableViewController = segue.destination as! TabbedTableViewController
		} else if segue.identifier == "embedMaps" {
			mapPageViewController = segue.destination as! ElectionPageViewController
			mapPageViewController.election = election
			mapPageViewController.delegate = self
		}
	}
	
	func updateLabels(withIncumbents incumbents: Bool = false) {
		//TODO: Update to make more efficient
		let type = displayedElection.type!
		let typeName: String
		var demCount = 0
		var repCount = 0
		switch type {
		case .president:
			typeName = "President"
		case .senate:
			typeName = "Senate"
			for state in states {
				for race in election.racesForState(state, ofType: type) {
					if let prediction = race.prediction, let (winner, _) = prediction.getWinner() {
						if winner.starts(with: "d") {
							demCount += 1
						} else if winner.starts(with: "r") {
							repCount += 1
						}
					}
					if incumbents, let incs = race.incumbency {
						for incumbent in incs.keys {
							if incumbent.starts(with: "d") {
								demCount += 1
							} else if incumbent.starts(with: "r") {
								repCount += 1
							}
						}
					}
				}
			}
		case .house:
			typeName = "House"
			for state in states {
				for race in election.racesForState(state, ofType: type) {
					if let prediction = race.prediction {
						demCount += prediction.demNumber
						repCount += prediction.repNumber
					}
				}
			}
		case .governor:
			typeName = "Governors"
			for state in states {
				for race in election.racesForState(state, ofType: type) {
					if let prediction = race.prediction, let (winner, _) = prediction.getWinner() {
						if winner.starts(with: "d") {
							demCount += 1
						} else if winner.starts(with: "r") {
							repCount += 1
						}
					}
				}
			}
		}

		let animation = CATransition()
		animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType.fade
		animation.duration = 0.25
		titleLabel.layer.add(animation, forKey: "kCATransitionFade")
		demDelegatesLabel.layer.add(animation, forKey: "kCATransitionFade")
		repDelegatesLabel.layer.add(animation, forKey: "kCATransitionFade")
		titleLabel.text = typeName
		demDelegatesLabel.text = String(format: "%.2d", demCount)
		repDelegatesLabel.text = String(format: "%.2d", repCount)
	}

}

extension MainViewController: UIPageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		displayedElection = pendingViewControllers.last as! ElectoralMapViewController
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			updateLabels(withIncumbents: displayedElection.showGraph)
			tableViewController.setStateTableDataSourceAndDelegate(displayedElection)
		} else {
			print("Transition aborted")
		}
	}
	
}
