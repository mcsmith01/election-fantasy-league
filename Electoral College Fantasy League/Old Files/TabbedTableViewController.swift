//
//  TabbedTableViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/11/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class TabbedTableViewController: UITabBarController {
	
	var stateTableViewController: StateTableViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		delegate = self
		for controller in viewControllers! {
			if let leagueController = controller as? LeagueViewController {
//				leagueController.managedObjectContext = managedObjectContext
			} else if let stateController = controller as? StateTableViewController {
//				stateController.managedObjectContext = managedObjectContext
				stateTableViewController = stateController
			}
		}
	}

	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//		if let leagueController = selectedViewController as? LeagueViewController {
//			leagueController.transitionToAllLeagues()
//		}
	}
	
	@IBAction func dismissSettings(segue: UIStoryboardSegue) {
		
	}
	
	func setStateTableDataSourceAndDelegate(_ source: ElectoralMapViewController) {
		stateTableViewController.tableView.dataSource = source
		stateTableViewController.tableView.delegate = source
		if selectedViewController == stateTableViewController {
			stateTableViewController.reloadTableViewData()
		}
	}
	
}

extension TabbedTableViewController: UITabBarControllerDelegate {
	
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		if let navigation = viewController as? UINavigationController {
			if navigation.topViewController is SettingsViewController {
				performSegue(withIdentifier: "showSettings", sender: nil)
				return false
			}
		}
		return true
	}
}
