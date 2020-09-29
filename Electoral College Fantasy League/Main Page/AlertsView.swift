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

struct AlertRow_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			AlertRow(alert: ElectionAlert.testAlert(status: .info))
			AlertRow(alert: ElectionAlert.testAlert(status: .alert))
			AlertRow(alert: ElectionAlert.testAlert(status: .critical))
			AlertRow(alert: ElectionAlert.testAlert(status: .info, message: "Short message"))
		}
	}
}

struct AlertRow: View {
	
	var alert: ElectionAlert
	var color: Color {
		switch alert.status {
		case .info: return .green
		case .alert: return .orange
		case .critical: return .red
		}
	}
	
	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEE MMM dd, h:mm:ss a"
		return formatter
	}()
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
//				if alert.status == .info {
//					Image(systemName: "exclamationmark.circle.fill")
//						.foregroundColor(.green)
//						.padding(.leading)
//				} else if alert.status == .alert {
//					Image(systemName: "exclamationmark.triangle.fill")
//						.foregroundColor(.orange)
//						.padding(.leading)
//				} else if alert.status == .critical {
//					Image(systemName: "exclamationmark.octagon.fill")
//						.foregroundColor(.red)
//						.padding(.leading)
//				}
				Text(dateFormatter.string(from: alert.time))
					.font(.caption)
					.foregroundColor(.gray)
					.padding()
//					.frame(alignment: .center)
			}
			HStack {
				Text(alert.text)
					.font(alert.read ? Font.body : Font.body.bold())
					.lineLimit(nil)
					.padding()
					.modifier(ColoredCell(color: color))
//				Spacer()
			}
			.padding(.horizontal)
		}
		.padding(.bottom)
	}
}
