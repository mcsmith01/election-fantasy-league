//
//  Notice.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class Notice: NSObject, Comparable, Identifiable {
	
	static func < (lhs: Notice, rhs: Notice) -> Bool {
		if lhs.time != rhs.time {
			return lhs.time > rhs.time
		} else {
			return lhs.id > rhs.id
		}
	}
	
	
	enum Status: Int {
		case info = 0
		case alert
		case critical
	}

	var id: String
	var text: String
	var status: Status
	var time: Date
	
	init?(id: String, data: [String: Any]) {
		guard let text = data["text"] as? String, let rawStatus = data["status"] as? Int, let status = Status(rawValue: rawStatus), let timeString = data["time"] as? String, let time = Objects.dateFormatter.date(from: timeString) else { return nil }
		self.id = id
		self.text = text
		self.status = status
		self.time = time
	}
	
}
