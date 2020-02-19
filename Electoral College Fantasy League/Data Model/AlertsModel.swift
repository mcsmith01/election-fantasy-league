//
//  AlertsModel.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/8/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import Foundation

class AlertsModel: NSObject, ObservableObject {
	
	var alerts = [ElectionAlert]()
	@Published var unreadAlerts = 0

	func updateOrCreateAlert(withID id: String, data: [String: Any]) {
		if let alert = alerts.first(where: {$0.id == id}) {
			alert.updateFrom(data)
		} else if let alert = ElectionAlert(id: id, data: data) {
			alerts.append(alert)
			alerts.sort()
		}
		unreadAlerts = alerts.filter({ !$0.read }).count
	}
	
	func clearAll() {
		alerts.removeAll()
		unreadAlerts = 0
	}
	
}
