//
//  ElectionRepresentation.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 9/18/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ElectionRepresentation {
	
	var races: [Race]
	var type: RaceType
	var mapLayers: [Race: CALayer]
	var mapNumbers: [String: Int]
	var graphLayers: [CALayer]
	var graphNumbers: [String: Int]
	
	init(races: [Race], type: RaceType) {
		self.races = races
		self.type = type
		mapLayers = [Race: CALayer]()
		mapNumbers = [String: Int]()
		graphLayers = [CALayer]()
		graphNumbers = [String: Int]()
		createMap()
	}
	
	private func createMap() {
		var time = CACurrentMediaTime()
		debugPrint("Creating map at \(time)")
		
		mapLayers.removeAll()
		for race in races {
			var stateImage = UIImage(named: "\(race.state!)_piece")
			stateImage = stateImage?.mask(withColor: UIColor.darkGray)
			let layer = CALayer()
			layer.contents = stateImage?.cgImage
			mapLayers[race] = layer
		}
		drawMap()
		
		time = CACurrentMediaTime() - time
		debugPrint("Create map took \(time) seconds")
	}
	
	private func drawMap() {
		for race in races {
			let color: UIColor
			if race.isActive {
				if let prediction = race.prediction {
					color = prediction.getColor()
				} else {
					color = .white
				}
			} else {
				//TODO: Do I need to redraw the inactive races? I think no
				color = .darkGray
			}
			let layer = mapLayers[race]!
			let image = UIImage(cgImage: layer.contents as! CGImage).mask(withColor: color)
			layer.contents = image?.cgImage
		}
		updateMapNumbers()
	}
	
	private func resize(bounds: CGRect) {
		for layer in mapLayers.values {
			layer.frame = bounds
		}
		for layer in graphLayers {
			layer.frame = bounds
		}
	}
	
	private func updateMapNumbers() {
		mapNumbers = ["d": 0, "i": 0, "r": 0]
		for race in races {
			//TODO: Do I need to check for active race?
			if let prediction = race.prediction {
				if type == .house {
					mapNumbers["d"]! += prediction.demNumber
					mapNumbers["i"]! += prediction.repNumber
					mapNumbers["r"]! += prediction.indNumber
				} else {
					let winner = String(prediction.getWinner()!.0.prefix(1))
					mapNumbers[winner]! += 1
				}
			}
		}
	}
	
	private func drawGraph(bounds: CGRect) {
		//TODO: Update for incumbency, presidency, governors...
		graphNumbers = ["d": 0, "i": 0, "r": 0]
		if type == .house {
			for race in races {
				//TODO: Do I need to check for active race?
				if let prediction = race.prediction {
					graphNumbers["d"]! += prediction.demNumber
					graphNumbers["i"]! += prediction.repNumber
					graphNumbers["r"]! += prediction.indNumber
				}
			}
		} else if type == .senate {
			for race in races {
				if let (winner, _) = race.prediction?.getWinner() {
					let w = String(winner.prefix(1))
					graphNumbers[w]! += 1
				}
				if let incumbents = race.incumbency {
					for party in incumbents.keys {
						let i = String(party.prefix(1))
						graphNumbers[i]! += 1
					}
				}
			}
		}
		let totalPossible: CGFloat
		switch type {
		case .president: totalPossible = 538
		case .senate: totalPossible = 100
		case .house: totalPossible = 435
		case .governor: totalPossible = 50
		}
		
		graphLayers.removeAll()
		
		let radius = min(bounds.width / 2, bounds.height)
		let center = CGPoint(x: bounds.width / 2, y: bounds.height)
		
		let backSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: 0, color: UIColor.gray)
		graphLayers.append(backSlice)
		
		let demAngle = .pi + (CGFloat(graphNumbers["d"]!) / totalPossible) * .pi
		let demSlice = pieSlice(center: center, radius: radius, startAngle: .pi, endAngle: demAngle, color: Colors.democrat)
		graphLayers.append(demSlice)
		
		let indAngle = demAngle + (CGFloat(graphNumbers["i"]!) / totalPossible) * .pi
		let indSlice = pieSlice(center: center, radius: radius, startAngle: demAngle, endAngle: indAngle, color: Colors.independent)
		graphLayers.append(indSlice)
		
		let repAngle = (CGFloat(graphNumbers["r"]!) / totalPossible) * .pi
		let repSlice = pieSlice(center: center, radius: radius, startAngle: -repAngle, endAngle: 0, color: Colors.republican)
		graphLayers.append(repSlice)
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
	
}
