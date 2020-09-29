//
//  Notice.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class ElectionAlert: NSObject, Comparable, Identifiable {
	
	static func < (lhs: ElectionAlert, rhs: ElectionAlert) -> Bool {
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
	var read: Bool
	var time: Date
	
	init?(id: String, data: [String: Any]) {
		guard let text = data["message"] as? String, let rawStatus = data["status"] as? Int, let status = Status(rawValue: rawStatus), let timeString = data["time"] as? String, let time = Objects.dateFormatter.date(from: timeString) else { return nil }
		self.id = id
		self.text = text
		self.read = data["read"] as? Bool ?? false
		self.status = status
		self.time = time
	}
	
	func updateFrom(_ data: [String: Any]) {
		guard let read = data["read"] as? Bool else { return }
		self.read = read
	}
	
	class func testAlert(status: ElectionAlert.Status, message: String? = nil) -> ElectionAlert {
		var data: [String: Any] = ["message": "This is a test message. It should be long enough to run to the second line", "status": status.rawValue, "time": "2020-02-20T01:42:16.446Z"]
		if let message = message {
			data["message"] = message
		}
		return ElectionAlert(id: "A0", data: data)!
	}
}
