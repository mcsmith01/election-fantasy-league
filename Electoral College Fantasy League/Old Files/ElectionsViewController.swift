//
//  ElectionsViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 9/17/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ElectionsViewController: UIViewController {
	
	@IBOutlet weak var electionLabel: UILabel!
	@IBOutlet weak var racePicker: UISegmentedControl!
	@IBOutlet weak var graphView: UIView!
	@IBOutlet weak var mapView: UIImageView!
	@IBOutlet weak var demLabel: UILabel!
	@IBOutlet weak var repLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableTop: NSLayoutConstraint!
	@IBOutlet weak var predictionsResults: UISegmentedControl!
	
	var election: Election!
	var allRaces: [RaceType: [Race]]!
	var stateImages: [String: (image: UIImage, layer: CALayer?)]!
	var outlineLayer: CALayer!
	var showGraph = false {
		didSet {
			let mAlpha: CGFloat = showGraph ? 0.0 : 1.0
			updateNumbers()
			UIView.animate(withDuration: 0.5, animations: {
				self.mapView.alpha = mAlpha
				self.graphView.alpha = 1.0 - mAlpha
			})
		}
	}
	var mapNumbers: [String: Int]!
	var graphNumbers: [String: Int]!
	var mapBounds: CGRect!
	var type: RaceType! {
		didSet {
			races = allRaces[type]!.filter({ $0.isActive }).sorted()
			tableView.reloadSections(IndexSet(integer: 0) , with: .automatic)
			self.updateMapNumbers()
			UIView.animate(withDuration: 0.5, animations: {
				self.mapView.image = self.maps[self.type]
				self.drawGraph()
			})
			if type == .governor && showGraph {
				showGraph = false
			}
		}
	}
	var races: [Race]!
	var maps: [RaceType: UIImage]!
	var selectedRow: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		electionLabel.text = election.name
		mapBounds = mapView.bounds
		for type in allRaces.keys {
			racePicker.setEnabled(true, forSegmentAt: type.rawValue)
		}
		maps = [RaceType: UIImage]()
		//TODO: This should fix map crashing problem, but not worth it this time around
//		DispatchQueue.global(qos: .background).async {
		let outline = UIImage(named: "map_outline")?.cgImage
		outlineLayer = CALayer()
		outlineLayer.frame = self.mapView.bounds
		outlineLayer.contents = outline
		
			for key in self.allRaces.keys {
				self.maps[key] = self.createMapForRace(key)
			}
//			DispatchQueue.main.async {
//				UIView.animate(withDuration: 0.5, animations: {
//					self.mapView.image = self.maps[self.type.rawValue]
//					self.drawGraph()
//				})
//			}
//		}
		type = allRaces.keys.min()!
		racePicker.selectedSegmentIndex = type.rawValue
		changeRaceType(racePicker)
		if election.date!.timeIntervalSinceNow < 0 {
			predictionsResults.setEnabled(true, forSegmentAt: 1)
		}
		mapView.layer.addSublayer(outlineLayer)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let row = selectedRow {
			selectedRow = nil
			tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
			self.updateMapNumbers()
			maps[type] = updateLayer(forRace: races[row])
			UIView.animate(withDuration: 0.5, animations: {
				self.mapView.image = self.maps[self.type]
				self.drawGraph()
			})
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		resizeMap(to: mapView.bounds)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? StateChoiceViewController, let race = sender as? Race {
			destination.endDate = election.date!
			destination.race = race
			destination.showResults = predictionsResults.selectedSegmentIndex == 1
		} else if let navigation = segue.destination as? UINavigationController, let destination = navigation.topViewController as? LeagueChoiceViewController {
			destination.election = election
		}
	}
	
	private func resizeMap(to rect: CGRect) {
		if mapBounds != rect {
			mapBounds = rect
			if let sublayers = mapView.layer.sublayers {
				for layer in sublayers {
					layer.frame = rect
					layer.bounds = rect
				}
			}
		}
	}
	
	private func createMapForRace(_ type: RaceType) -> UIImage {
		// Run in main.async
		// Save map to disk, so only have to load updates

		var layers = [CALayer]()
		// TODO: Figure out why / if this is crashing
		for race in election.racesOfType(type) {
			if race.isActive {
				layers.append(createLayer(forRace: race))
			}
		}

		let background = UIImage(named: "outline 2016")?.mask(withColor: .black)?.cgImage
		let backgroundLayer = CALayer()
		backgroundLayer.frame = self.mapView.bounds
		backgroundLayer.contents = background

		UIGraphicsBeginImageContext(mapView.bounds.size)
		backgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
		for layer in layers {
			layer.render(in: UIGraphicsGetCurrentContext()!)
		}
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	private func createLayer(forRace race: Race) -> CALayer {
		let color: UIColor = race.prediction?.getColor() ?? .white
		let image = UIImage(named: "\(race.state!)_piece")?.mask(withColor: color)
		let layer = CALayer()
		layer.frame = self.mapView.bounds
		layer.contents = image?.cgImage
		return layer
	}
	
	private func updateLayer(forRace race: Race) -> UIImage {
		let backgroundLayer = CALayer()
		backgroundLayer.frame = self.mapView.bounds
		backgroundLayer.contents = maps[race.raceType]!.cgImage

		UIGraphicsBeginImageContext(mapView.bounds.size)
		backgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
		createLayer(forRace: race).render(in: UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	private func updateMapNumbers() {
		mapNumbers = ["d": 0, "i": 0, "r": 0]
		for race in races {
			if predictionsResults.selectedSegmentIndex == 0, let prediction = race.prediction {
				mapNumbers["d"]! += prediction.demNumber
				mapNumbers["i"]! += prediction.indNumber
				mapNumbers["r"]! += prediction.repNumber
			} else if predictionsResults.selectedSegmentIndex == 1, let results = race.results {
				mapNumbers["d"]! += results["d"] ?? 0
				mapNumbers["i"]! += results["i"] ?? 0
				mapNumbers["r"]! += results["r"] ?? 0
			}
		}
		if !showGraph {
			updateNumbers()
		}
	}
	
	private func drawGraph() {
		graphNumbers = ["d": 0, "i": 0, "r": 0]
		for race in allRaces[type]! {
			if predictionsResults.selectedSegmentIndex == 0, let prediction = race.prediction {
				graphNumbers["d"]! += prediction.demNumber
				graphNumbers["i"]! += prediction.indNumber
				graphNumbers["r"]! += prediction.repNumber
			} else if predictionsResults.selectedSegmentIndex == 1, let results = race.results {
				graphNumbers["d"]! += results["d"] ?? 0
				graphNumbers["i"]! += results["i"] ?? 0
				graphNumbers["r"]! += results["r"] ?? 0
			}
			if let safety = race.safety {
				for party in safety.keys {
					let i = String(party.prefix(1))
					graphNumbers[i]! += 1
				}
			}
		}
		let totalPossible: CGFloat
		switch type! {
		case .president: totalPossible = 538
		case .senate: totalPossible = 100
		case .house: totalPossible = 435
		case .governor: totalPossible = 50
		}
		
		graphView.layer.sublayers?.removeAll()
		
		let radius = min(graphView.bounds.width / 2, graphView.bounds.height)
		let center = CGPoint(x: graphView.bounds.width / 2, y: graphView.bounds.height)
		
		let backSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: 0, color: UIColor.gray)
		graphView.layer.addSublayer(backSlice)
		
		let demAngle = .pi + (CGFloat(graphNumbers["d"]!) / totalPossible) * .pi
		let demSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: demAngle, color: Colors.democrat)
		graphView.layer.addSublayer(demSlice)
		
		let indAngle = demAngle + (CGFloat(graphNumbers["i"]!) / totalPossible) * .pi
		let indSlice = pieSlice(center: center, radius: radius, startAngle: demAngle, endAngle: indAngle, color: Colors.independent)
		graphView.layer.addSublayer(indSlice)
		
		let repAngle = (CGFloat(graphNumbers["r"]!) / totalPossible) * .pi
		let repSlice = pieSlice(center: center, radius: radius, startAngle: -repAngle, endAngle: 0, color: Colors.republican)
		graphView.layer.addSublayer(repSlice)
		
		if showGraph {
			updateNumbers()
		}
	}
	
	private func pieSlice(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, color: UIColor) -> CAShapeLayer {
		let path = UIBezierPath()
		path.move(to: center)
		path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		path.close()
		let layer = CAShapeLayer()
		layer.path = path.cgPath
		layer.fillColor = color.cgColor
		return layer
	}
	
	private func updateNumbers() {
		if let numbers = showGraph ? graphNumbers : mapNumbers {
			let animation = CATransition()
			animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
			animation.type = CATransitionType.fade
			animation.duration = 0.5
			demLabel.layer.add(animation, forKey: "kCATransitionFade")
			repLabel.layer.add(animation, forKey: "kCATransitionFade")
			demLabel.text = String(format: "%.2d", numbers["d"]!)
			repLabel.text = String(format: "%.2d", numbers["r"]!)
		}
	}
	
	@IBAction func tapped(_ recognizer: UITapGestureRecognizer) {
		if type != .governor {
			showGraph = !showGraph
		}
	}
	
	@IBAction func expandCollapseTable(_ recognizer: UITapGestureRecognizer) {
		let firstItem = tableTop.firstItem!
		let alpha: CGFloat
		let newConstraint: NSLayoutConstraint
		if let second = tableTop.secondItem as? UIImageView, second == mapView {
			newConstraint = NSLayoutConstraint(item: firstItem, attribute: .top, relatedBy: .equal, toItem: racePicker, attribute: .bottom, multiplier: 1, constant: 8)
			alpha = 0.0
		} else {
			newConstraint = NSLayoutConstraint(item: firstItem, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1, constant: 8)
			alpha = 1.0
		}
		view.removeConstraint(tableTop)
		tableTop = newConstraint
		view.addConstraint(tableTop)
		UIView.animate(withDuration: 0.25, animations: {
			if self.showGraph {
				self.graphView.alpha = alpha
			} else {
				self.mapView.alpha = alpha
			}
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func togglePredictionsResults(_ sender: AnyObject?) {
		updateMapNumbers()
		drawGraph()
		tableView.reloadSections(IndexSet(integer: 0) , with: .automatic)
	}
	
	@IBAction func changeRaceType(_ picker: UISegmentedControl) {
		type = RaceType(rawValue: picker.selectedSegmentIndex)!
	}
	
//	func updatePredictionForRace(_ race: Race) {
//		let state = race.state!
//		var images = [UIImage]()
//		images.append(maps[Int(race.type)]!)
//		images.append(UIImage(named: "\(state)_piece")!)
//		if let prediction = race.prediction {
//			images.append(UIImage(named: "\(state.name!)_piece")!.mask(withColor: prediction.getColor())!)
//		}
//
//		UIGraphicsBeginImageContext(mapView.bounds.size)
//		for image in images {
//			let layer = CALayer()
//			layer.frame = self.mapView.bounds
//			layer.contents = image.cgImage
//			layer.render(in: UIGraphicsGetCurrentContext()!)
//		}
//		let image = UIGraphicsGetImageFromCurrentImageContext()!
//		UIGraphicsEndImageContext()
//
//		maps[Int(race.type)] = image
//		if type.rawValue == Int(race.type) {
//			mapView.image = image
//			drawGraph()
//			updateMapNumbers()
//			let raceIndex = races.index(of: race)!
//			tableView.reloadRows(at: [IndexPath(row: raceIndex, section: 0)], with: .automatic)
//		}
//	}
	
	@IBAction func changeElection(_ sender: AnyObject?) {
		let elections = Election.fetchAll()
		let alert = UIAlertController(title: "Change Election", message: nil, preferredStyle: .alert)
		for elec in elections {
			alert.addAction(UIAlertAction(title: elec.name!, style: .default) {
				(_) in
				UserData.data[.currentElection] = elec.id!
				self.dismiss(animated: true, completion: nil)
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	// TODO: Stop listening
	@objc override func logout() {
		super.logout()
	}
	
}

extension ElectionsViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return races.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UITableViewHeaderFooterView()
		if section == 0 {
			var numer: Double = 0
			let denom: Int
			let label: String
			if predictionsResults.selectedSegmentIndex == 0 {
				for race in races {
					if race.prediction != nil {
						numer += 1
					}
				}
				denom = races.count
				label = "Complete"
			} else {
				for race in races {
					if race.results != nil, let prediction = race.prediction {
						numer += prediction.rawScore
					}
				}
				switch type! {
				case .house: denom = 435
				case .president: denom = 538
				default: denom = races.count * 3
				}
				label = "Score"
			}
			if numer == floor(numer) {
				header.textLabel?.text = "\(label) - \(Int(numer))/\(denom)"
			} else {
				header.textLabel?.text = "\(label) - \(numer)/\(denom)"
			}
			let tap = UITapGestureRecognizer(target: self, action: #selector(expandCollapseTable(_:)))
			header.addGestureRecognizer(tap)
		}
		return header
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		let race = races[indexPath.row]
		let stateName = race.state
		
		if race.results != nil {
			cell = tableView.dequeueReusableCell(withIdentifier: "decidedCell")!
			let score = race.prediction?.rawScore ?? 0
			var scoreString = "Score: "
			if score == floor(score) {
				scoreString += "\(Int(score))"
			} else {
				scoreString += "\(score)"
			}
			cell.detailTextLabel?.text = scoreString
			cell.detailTextLabel?.backgroundColor = .clear
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "undecidedCell")!
		}
		cell.textLabel?.text = stateName
		cell.textLabel?.backgroundColor = .clear
		
		if cell.layer.sublayers?.first is CAGradientLayer {
			cell.layer.sublayers?.remove(at: 0)
		}

		let source = predictionsResults.selectedSegmentIndex == 0 ? race.prediction?.assertion : race.results
		if let source = source {
			if type == .house {
				let gradient = Colors.gradient(dems: source["d"]!, inds: source["i"]!, reps: source["r"]!)
				gradient.frame = cell.bounds
				cell.layer.insertSublayer(gradient, at: 0)
				cell.textLabel?.textColor = .white
				cell.detailTextLabel?.textColor = .white
			} else {
				let color = Colors.getColor(for: source)
				var alpha: CGFloat = 1.0
				color.getWhite(nil, alpha: &alpha)
				cell.backgroundColor = color
				if alpha > 0.5 {
					cell.textLabel?.textColor = .white
					cell.detailTextLabel?.textColor = .white
				} else {
					cell.textLabel?.textColor = .black
					cell.detailTextLabel?.textColor = .black
				}
			}
		} else {
			cell.backgroundColor = UIColor.white
			cell.textLabel?.textColor = .black
			cell.detailTextLabel?.textColor = .black
		}
		
		return cell
	}

}

extension ElectionsViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let race = races[indexPath.row]
		selectedRow = indexPath.row
		performSegue(withIdentifier: "showState", sender: race)
	}
	
}
