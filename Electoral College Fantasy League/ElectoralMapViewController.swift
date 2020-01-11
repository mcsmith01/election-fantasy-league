//
//  ElectoralMapViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/12/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ElectoralMapViewController: UIViewController {
	
	@IBOutlet weak var mapView: UIImageView!
	@IBOutlet weak var graphView: UIView!
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

	var pageController: ElectionPageViewController!
	var type: RaceType! {
		didSet {
			races = election.racesOfType(type).sorted()
		}
	}
	var election: Election!
	var stateList: [String]!
	var races: [Race]!
	var mapLayers: [CALayer]!
	var currentBounds: CGRect!
	var tableView: UITableView!
	var showGraph = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		currentBounds = view.bounds
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if showGraph {
			graphView.isHidden = false
			mapView.isHidden = true
		} else {
			graphView.isHidden = true
			mapView.isHidden = false
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		if mapLayers != nil && mapView.layer.sublayers == nil {
			for layer in mapLayers {
				mapView.layer.addSublayer(layer)
			}
			mapLayers = nil
		}
		resize(to: view.bounds)
	}
	
	private func resize(to rect: CGRect) {
		if currentBounds != rect {
			currentBounds = rect
			if let sublayers = mapView.layer.sublayers {
				for layer in sublayers {
					layer.frame = currentBounds
					layer.bounds = currentBounds
				}
			}
		}
		racesSet()
	}
	
	func racesSet() {
		// TODO: Is this a necessary function?
		self.loadingIndicator?.startAnimating()
		createMap()
		if type != .governor {
			createGraph()
		}
		self.loadingIndicator?.stopAnimating()
	}
	
	private func createMap() {
		var time = CACurrentMediaTime()
		debugPrint("Creating map at \(time)")
		self.mapLayers = [CALayer]()
		for state in self.stateList {
			let layer = layerFor(state: state)
			self.mapLayers.append(layer)
		}
		let outline = UIImage(named: "map_outline")?.cgImage
		let layer = CALayer()
		layer.frame = self.mapView.bounds
		layer.contents = outline
		self.mapLayers.append(layer)
		
		if let map = self.mapView {
			map.layer.sublayers = nil
			for layer in self.mapLayers {
				map.layer.addSublayer(layer)
			}
		}
		time = CACurrentMediaTime() - time
		debugPrint("Create map took \(time) seconds")
	}
	
	private func createGraph() {
		var rep = 0
		var dem = 0
		var ind = 0
		if type == .house {
			for race in races {
				if let prediction = race.prediction {
					rep += prediction.repNumber
					dem += prediction.demNumber
					ind += prediction.indNumber
				}
			}
		} else if type == .senate {
			for race in races {
				if let prediction = race.prediction, let (winner, _) = prediction.getWinner() {
					if winner.starts(with: "d") {
						dem += 1
					} else if winner.starts(with: "r") {
						rep += 1
					} else {
						ind += 1
					}
				}
				if let incumbents = race.incumbency {
					for incumbent in incumbents.keys {
						if incumbent.starts(with: "d") {
							dem += 1
						} else if incumbent.starts(with: "r") {
							rep += 1
						} else if incumbent.starts(with: "i") {
							ind += 1
						}
					}
				}
			}
		}
		let totalSeats: CGFloat = type == .house ? 435.0 : 100.0
		
		if let graphView = graphView {
			graphView.layer.sublayers?.removeAll()
			let radius = min(graphView.bounds.width / 2, graphView.bounds.height)
			let center = CGPoint(x: graphView.bounds.width / 2, y: graphView.bounds.height)
			
			//TODO: Create function that creates pie slice layer
			let backSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: 0, color: UIColor.gray)
			graphView.layer.addSublayer(backSlice)
			
			let demAngle = .pi + (CGFloat(dem) / totalSeats) * .pi
			let demSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: demAngle, color: Colors.democrat)
			graphView.layer.addSublayer(demSlice)
			
			let indAngle = demAngle + (CGFloat(ind) / totalSeats) * .pi
			let indSlice = pieSlice(center: center, radius: radius, startAngle: demAngle, endAngle: indAngle, color: Colors.independent)
			graphView.layer.addSublayer(indSlice)
			
			let repAngle = (CGFloat(rep) / totalSeats) * .pi
			let repSlice = pieSlice(center: center, radius: radius, startAngle: -repAngle, endAngle: 0, color: Colors.republican)
			graphView.layer.addSublayer(repSlice)
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
	
	private func layerFor(state: String) -> CALayer {
		let color: UIColor
		if let race = election.racesForState(state, ofType: type).first, race.isActive {
			if let prediction = race.prediction {
				color = prediction.getColor()
			} else {
				color = .white
			}
		} else {
			color = .darkGray
		}
		var stateImage = UIImage(named: "\(state)_piece")
		stateImage = stateImage?.mask(withColor:color)
		let layer = CALayer()
		layer.frame = self.view.bounds
		layer.contents = stateImage?.cgImage
		return layer
	}
	
	func updatePredictionForRace(_ race: Race) {
		if type == .house || showGraph {
			createGraph()
		} else {
			let state = race.state!
			let index = stateList!.firstIndex(where: { $0 == state } )!
			let oldLayer = mapView.layer.sublayers![index]
			let color: UIColor
			if let race = election.racesForState(state, ofType: type).first, race.isActive {
				if let prediction = race.prediction {
					color = prediction.getColor()
				} else {
					color = .white
				}
			} else {
				color = .darkGray
			}
			var image = UIImage(cgImage: oldLayer.contents as! CGImage)
			image = image.mask(withColor: color)!
			oldLayer.contents = image.cgImage
		}
		let raceIndex = races.firstIndex(of: race)!
		tableView.reloadRows(at: [IndexPath(row: raceIndex, section: 0)], with: .automatic)		
	}
	
	@IBAction func tapped(_ recognizer: UITapGestureRecognizer) {
		if type != .governor {
			showGraph = !showGraph
			let animation = CATransition()
			animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
			animation.type = CATransitionType.fade
			animation.duration = 0.25
			graphView.layer.add(animation, forKey: "kCATransitionFade")
			mapView.layer.add(animation, forKey: "kCATransitionFade")
			if showGraph {
				graphView.isHidden = false
				mapView.isHidden = true
			} else {
				graphView.isHidden = true
				mapView.isHidden = false
			}
			pageController.updateLabels(withIncumbents: showGraph)
		}
	}
	
}

extension ElectoralMapViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return races.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		cell = tableView.dequeueReusableCell(withIdentifier: "undecidedCell")!
		let race = races[indexPath.row]
		let stateName = race.state!

		cell.textLabel?.text = stateName
		cell.textLabel?.backgroundColor = UIColor.clear

		if cell.layer.sublayers?.first is CAGradientLayer {
			cell.layer.sublayers?.remove(at: 0)
		}

		if let prediction = race.prediction {
			if type == .house {
				let gradient = Colors.gradient(dems: prediction.demNumber, inds: prediction.indNumber, reps: prediction.repNumber)
				gradient.frame = cell.bounds
				cell.layer.insertSublayer(gradient, at: 0)
				cell.textLabel?.textColor = UIColor.white
			} else {
				let color = prediction.getColor()
				var alpha: CGFloat = 1.0
				color.getWhite(nil, alpha: &alpha)
				cell.backgroundColor = color
				if alpha > 0.5 {
					cell.textLabel?.textColor = UIColor.white
				} else {
					cell.textLabel?.textColor = UIColor.black
				}
			}
		} else {
			cell.backgroundColor = UIColor.white
			cell.textLabel?.textColor = UIColor.black
		}
		
		return cell
	}
}

extension ElectoralMapViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return true
		//		if predictionList == nil {
		//			return false
		//		} else {
		//			return true
		//		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "stateChoiceViewController") as! StateChoiceViewController
		self.tableView = tableView
		let race = races[indexPath.row]
		controller.race = race
		//TODO: Change so that table view updates
		controller.modalPresentationStyle = .fullScreen
		present(controller, animated: true, completion: nil)
	}
}
