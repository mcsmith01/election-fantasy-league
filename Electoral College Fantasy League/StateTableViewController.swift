//
//  StateTableViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/12/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import UIKit

class StateTableViewController: UITableViewController {
	
	var stateFilter: (String) -> Bool = { (_) in true }
	var total = 0
	var possible = 538
	var league: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		debugPrint("STVC: vDL")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadTableViewData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func reloadTableViewData() {
		tableView.reloadSections(IndexSet(integer: 0), with: .fade)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let stateChoice = segue.destination as? StateChoiceViewController {
			debugPrint("From State Table")
		}
	}
	
	func updateLayer(for state: String) {
		
	}
	
}
