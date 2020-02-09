//
//  AlertsView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/30/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct AlertsView: View {
	@ObservedObject var alertsModel: AlertsModel
	@EnvironmentObject var electionModel: ElectionModel
	@State var viewedAlerts = Set<String>()
	
    var body: some View {
		NavigationView {
			List {
				ForEach(alertsModel.alerts) { alert in
					AlertRow(alert: alert)
//						.modifier(RectangleBorder())
						.onAppear() {
							if !alert.read {
								self.viewedAlerts.insert(alert.id)
							}
					}
				}
			}
			.navigationBarTitle("Alerts")
			.onAppear() {
				self.viewedAlerts = Set<String>()
			}
			.onDisappear() {
				self.electionModel.markAlertsRead(self.viewedAlerts)
			}
		}
    }
}

//struct AlertsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertsView()
//    }
//}

struct AlertRow: View {
	
	var alert: ElectionAlert
	
	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEE MMM dd, h:mm:ss a"
		return formatter
	}()
	
	var body: some View {
		VStack {
			Text(dateFormatter.string(from: alert.time))
				.font(.caption)
				.foregroundColor(.gray)
				.frame(alignment: .center)
				.multilineTextAlignment(.leading)
			HStack {
				if alert.status == .info {
					Image(systemName: "info.circle.fill")
						.foregroundColor(.green)
				} else if alert.status == .alert {
					Image(systemName: "exclamationmark.triangle.fill")
						.foregroundColor(.orange)
				} else if alert.status == .critical {
					Image(systemName: "exclamationmark.octagon.fill")
						.foregroundColor(.red)
				}
				Text(alert.text)
					.font(alert.read ? Font.body : Font.body.bold())
					.frame(alignment: .leading)
				Spacer()
			}
			.padding()
			.modifier(RectangleBorder())
		}
		.padding(.bottom)
	}
}
