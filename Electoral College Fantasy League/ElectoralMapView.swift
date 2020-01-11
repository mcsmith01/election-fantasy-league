//
//  ElectoralMapViewController.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/16/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ElectoralMapView: UIView {
	
	@IBOutlet weak var mapView: UIImageView!
	@IBOutlet weak var loadingView: UIActivityIndicatorView!
	
	var election: Election!
	var states: [String]!
	var type: RaceType!
	var mapLayer: CALayer!
	var predictions: [Prediction]?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		Bundle.main.loadNibNamed("ElectoralMapView", owner: self, options: nil)
		mapView.backgroundColor = UIColor.white
		self.addSubview(mapView)
		self.addSubview(loadingView)
	}
	
	override func draw(_ rect: CGRect) {
		if mapView.frame.width != rect.width {
			debugPrint("Resizing map")
			let newBounds = CGRect(origin: CGPoint.zero, size: rect.size)
			mapView.frame = newBounds
			mapView.bounds = newBounds
			loadingView.center = mapView.center
			if let layers = mapView.layer.sublayers {
				for layer in layers {
					layer.frame = newBounds
					layer.bounds = newBounds
				}
			} else {
				debugPrint("Pieceing together map for first time")
				DispatchQueue.main.async {
					self.pieceTogetherMap()
				}
			}
		}
	}
	
	func racesSet() {
		debugPrint("Races Set")
		DispatchQueue.main.async {
			self.loadingView.startAnimating()
			self.pieceTogetherMap()
			self.loadingView.stopAnimating()
		}
	}
	
	private func pieceTogetherMap() {
		debugPrint("There are \(states?.count ?? 0) states")
		guard states != nil else { return }
		for i in 0..<states.count {
			let state = states[i]
			var stateImage = UIImage(named: "\(state)_piece")
			if election.racesForState(state, ofType: type).count != 0 {
				stateImage = stateImage?.mask(withColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
			} else {
				stateImage = stateImage?.mask(withColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
			}
			let layer = CALayer()
			layer.frame = mapView.bounds
			layer.contents = stateImage?.cgImage
			if mapView.layer.sublayers == nil || i >= mapView.layer.sublayers!.count {
				mapView.layer.insertSublayer(layer, at: UInt32(i))
			} else {
				let sublayer = mapView.layer.sublayers![i]
				mapView.layer.replaceSublayer(sublayer, with: layer)
			}
		}
		let outline = UIImage(named: "map_outline")?.cgImage
		let layer = CALayer()
		layer.frame = mapView.bounds
		layer.contents = outline
		mapView.layer.insertSublayer(layer, at: UInt32(states.count))

		
//		for i in 0..<states.count {
//			let state = states[i]
//			let prediction = predictions?.filter({ $0.state == state }).first
//			var stateImage = UIImage(named: "\(state.name!)_piece")
//			let layer = CALayer()
//			layer.frame = mapView.bounds
//			var candidate = Int32(-1)
//			var percent = Float(-1)
//			if let predictedState: Prediction = prediction {
//				candidate = predictedState.winner
//				percent = predictedState.percent
//			} else if predictions == nil && state.called {
//				candidate = state.winner
//				percent = state.percent
//			}
//			if candidate == Candidate.republican.rawValue {
//				stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: (percent / 200.0) + 0.25))
//			} else if candidate == Candidate.democrat.rawValue {
//				stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: (percent / 200.0) + 0.25))
//			} else if candidate == Candidate.independent.rawValue {
//				stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 0, green: 1, blue: 0, alpha: (percent / 200.0) + 0.25))
//			}
//
//			layer.contents = stateImage?.cgImage
//			if mapView.layer.sublayers == nil || i >= mapView.layer.sublayers!.count {
//				mapView.layer.insertSublayer(layer, at: UInt32(i))
//			} else {
//				let sublayer = mapView.layer.sublayers![i]
//				mapView.layer.replaceSublayer(sublayer, with: layer)
//			}
//		}
	}
	
	func updateLayer(withPrediction prediction: Prediction) {
//		let state = prediction.state!
//		for i in 0..<states.count {
//			if state == states[i] {
//				var stateImage = UIImage(named: "\(state.name!)_piece")
//				let layer = CALayer()
//				layer.frame = mapView.bounds
//				if prediction.winner == Candidate.republican.rawValue {
//					stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: (state.percent / 200.0) + 0.25))
//				} else if state.winner == Candidate.democrat.rawValue {
//					stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: (state.percent / 200.0) + 0.25))
//				} else {
//					stateImage = stateImage?.mask(withColor: UIColor(colorLiteralRed: 0, green: 1, blue: 0, alpha: (state.percent / 200.0) + 0.25))
//					
//				}				
//				layer.contents = stateImage?.cgImage
//				mapView.layer.replaceSublayer(mapView.layer.sublayers![i], with: layer)
//				return
//			}
//		}
	}
}

extension UIImage {
	
	func mask(withColor color: UIColor) -> UIImage? {
		let maskImage = cgImage!
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let bitmapContext =  CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		bitmapContext.clip(to: bounds, mask: maskImage)
		bitmapContext.setFillColor(color.cgColor)
		bitmapContext.fill(bounds)
		
		if let cImage = bitmapContext.makeImage() {
			return UIImage(cgImage: cImage)
		} else {
			return nil
		}
	}
	
}
