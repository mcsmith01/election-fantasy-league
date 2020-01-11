//
//  MapPageViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/12/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ElectionPageViewController: UIPageViewController {

	var orderedElectionMaps: [UIViewController]!
	var election: Election!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		orderedElectionMaps = [UIViewController]()
		for typeNum in 1..<4 {
			let type = RaceType(rawValue: typeNum)!
			orderedElectionMaps.append(newMapViewController(forType: type))
		}
		dataSource = self
		if let firstController = orderedElectionMaps.first {
			setViewControllers([firstController], direction: .forward, animated: true, completion: nil)
			(delegate as! MainViewController).displayedElection = firstController as? ElectoralMapViewController
		}
		racesSet()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateLabels()
	}
	
	func updateLabels(withIncumbents incumbents: Bool = false) {
		(delegate as? MainViewController)?.updateLabels(withIncumbents: incumbents)
	}
	
	func racesSet() {
		for controller in orderedElectionMaps {
			(controller as! ElectoralMapViewController).racesSet()
		}
	}
	
	func predictionChanged(for race: Race) {
		for controller in orderedElectionMaps{
			if let type = (controller as! ElectoralMapViewController).type?.rawValue, type == race.type {
				(controller as! ElectoralMapViewController).updatePredictionForRace(race)
				let mainController = (delegate as! MainViewController)
				if mainController.displayedElection == controller {
					mainController.updateLabels()
				}
			}
		}
	}
	
	func newMapViewController(forType type: RaceType) -> ElectoralMapViewController {
		let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "electoralMapViewController") as! ElectoralMapViewController
		controller.election = election
		controller.type = type
		controller.pageController = self
		return controller
	}

}

extension ElectionPageViewController: UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		let index = orderedElectionMaps.firstIndex(of: viewController)! - 1
		if (index >= 0) {
			return orderedElectionMaps[index]
		} else {
			return orderedElectionMaps.last
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let index = orderedElectionMaps.firstIndex(of: viewController)! + 1
		if (index < orderedElectionMaps.count) {
			return orderedElectionMaps[index]
		} else {
			return orderedElectionMaps.first
		}
	}
	
}
