//
//  ElectoralGraphViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 9/13/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

// Maybe merge this with the EMVC and allow switching between graphView and mapView
class ElectoralGraphViewController: UIViewController {

	@IBOutlet weak var graphView: UIView?
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

	var pageController: ElectionPageViewController!
	var type: RaceType!
	var election: Election!
	var stateList: [String]!
	var races: [Race]!
	var mapLayers: [CALayer]!
	var currentBounds: CGRect!

	override func viewDidLoad() {
		super.viewDidLoad()
		currentBounds = view.bounds
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		resize(to: view.bounds)
	}

	private func resize(to rect: CGRect) {
		if currentBounds != rect {
			currentBounds = rect
		}
		racesSet()
	}

	func racesSet() {
		//		DispatchQueue.main.async {
		self.loadingIndicator?.startAnimating()
		races = election.racesOfType(type)
		races.sort() {
			$0.state! < $1.state!
		}
		var rep = 0
		var dem = 0
		var ind = 0
		for race in races {
			if let prediction = race.prediction {
				for (key, value) in prediction.assertion! {
					if key.starts(with: "d") {
						dem += value
					} else if key.starts(with: "r") {
						rep += value
					} else {
						ind += value
					}
				}
			}
		}
		let totalSeats: CGFloat = type == .house ? 435.0 : 100.0

		if let graphView = graphView {
			graphView.layer.sublayers?.removeAll()
			let radius = min(graphView.bounds.width / 2, graphView.bounds.height)
			let center = CGPoint(x: graphView.bounds.width / 2, y: graphView.bounds.height)

			let backPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: .pi, endAngle: 0, clockwise: true)
			let backLayer = CAShapeLayer()
			backLayer.path = backPath.cgPath
			backLayer.fillColor = UIColor.gray.cgColor
			graphView.layer.addSublayer(backLayer)

			let demAngle = .pi + (CGFloat(dem) / totalSeats) * .pi
			let demPath = UIBezierPath()
			demPath.move(to: center)
			demPath.addArc(withCenter: center, radius: radius, startAngle: .pi, endAngle: demAngle, clockwise: true)
			demPath.close()
			let demLayer = CAShapeLayer()
			demLayer.path = demPath.cgPath
			demLayer.fillColor = Colors.democrat.cgColor
			graphView.layer.addSublayer(demLayer)

			let indAngle = demAngle + (CGFloat(ind) / totalSeats) * .pi
			let indPath = UIBezierPath()
			indPath.move(to: center)
			indPath.addArc(withCenter: center, radius: radius, startAngle: demAngle, endAngle: indAngle, clockwise: true)
			indPath.close()
			let indLayer = CAShapeLayer()
			indLayer.path = indPath.cgPath
			indLayer.fillColor = Colors.independent.cgColor
			graphView.layer.addSublayer(indLayer)

			let repAngle = (CGFloat(rep) / totalSeats) * .pi
			let repPath = UIBezierPath()
			repPath.move(to: center)
			repPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: -repAngle, clockwise: false)
			repPath.close()
			let repLayer = CAShapeLayer()
			repLayer.path = repPath.cgPath
			repLayer.fillColor = Colors.republican.cgColor
			graphView.layer.addSublayer(repLayer)
		}

		self.loadingIndicator?.stopAnimating()


		//		}
	}

	func updatePredictionForState(_ state: String) {
		racesSet()
	}

}

extension ElectoralGraphViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return races.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		cell = tableView.dequeueReusableCell(withIdentifier: "undecidedCell")!
		let state = races[indexPath.row].state!

		cell.textLabel?.text = state
		cell.textLabel?.backgroundColor = UIColor.clear
		cell.textLabel?.textColor = UIColor.black

		if cell.layer.sublayers?.first is CAGradientLayer {
			cell.layer.sublayers?.remove(at: 0)
		}
		// TODO: Update this so that it only takes effect for House races
		if let race = election.racesForState(state, ofType: type).first, let prediction = race.prediction {
			let demPer = CGFloat(prediction.demNumber) / CGFloat(race.seats)
			let repPer = CGFloat(prediction.repNumber) / CGFloat(race.seats)
			let indPer = CGFloat(prediction.indNumber) / CGFloat(race.seats)
			let gradient = CAGradientLayer()
			gradient.frame = cell.bounds
			gradient.locations = [0.0]
			gradient.colors = []
			if prediction.demNumber != 0 {
				gradient.locations?.append(contentsOf: [demPer, demPer] as [NSNumber])
				gradient.colors?.append(contentsOf: [Colors.democrat.cgColor, Colors.democrat.cgColor])
			}
			if prediction.indNumber != 0 {
				gradient.locations?.append(contentsOf: [demPer + indPer, demPer + indPer] as [NSNumber])
				gradient.colors?.append(contentsOf: [Colors.independent.cgColor, Colors.independent.cgColor])
			}
			if prediction.repNumber != 0 {
				gradient.locations?.append(contentsOf: [1 - repPer, 1 - repPer] as [NSNumber])
				gradient.colors?.append(contentsOf: [Colors.republican.cgColor, Colors.republican.cgColor])
			}
			gradient.locations?.append(1.0)

			gradient.startPoint = CGPoint(x: 0, y: 0.5)
			gradient.endPoint = CGPoint(x: 1, y: 0.5)
			cell.layer.insertSublayer(gradient, at: 0)
			cell.textLabel?.textColor = UIColor.white
		}

		return cell
	}

}

//extension ElectoralGraphViewController: UITableViewDelegate {
//
//	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//		return true
//		//		if predictionList == nil {
//		//			return false
//		//		} else {
//		//			return true
//		//		}
//	}
//
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
//		let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "stateChoiceViewController") as! StateChoiceViewController
//		let race = races[indexPath.row]
//		controller.user = user
//		controller.race = race
//		controller.raceUpdate = pageController.predictionChanged
//		controller.modalPresentationStyle = .fullScreen
//		present(controller, animated: true, completion: nil)
//	}
//
//}
