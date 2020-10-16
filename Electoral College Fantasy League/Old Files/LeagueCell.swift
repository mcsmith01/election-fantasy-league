//
//  LeagueCell.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/30/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class LeagueCell: UITableViewCell {
	
	@IBOutlet weak var alertLabel: UILabel!
	
	func roundAlertLabel() {
		let frame = alertLabel.frame
		alertLabel.layer.cornerRadius = frame.size.height / 2
		alertLabel.clipsToBounds = true
	}
	
}
