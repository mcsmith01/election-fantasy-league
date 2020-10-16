//
//  StateChoiceViewConroller.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/12/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class StateChoiceViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var stateImage: UIImageView!
	@IBOutlet weak var candidatePicker: UISegmentedControl!
	@IBOutlet weak var demNameLabel: UILabel!
	@IBOutlet weak var demLabel: UILabel!
	@IBOutlet weak var repNameLabel: UILabel!
	@IBOutlet weak var repLabel: UILabel!
	@IBOutlet weak var indNameLabel: UILabel!
	@IBOutlet weak var indLabel: UILabel!
	@IBOutlet weak var remLabel: UILabel!
	@IBOutlet weak var racePicker: UISegmentedControl!
	@IBOutlet weak var sealImage: UIImageView!
	@IBOutlet weak var slidersView: UIView!
	@IBOutlet weak var demSlider: UISlider!
	@IBOutlet weak var repSlider: UISlider!
	@IBOutlet weak var indSlider: UISlider!
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var predictionOrResults: UISegmentedControl!
	
	var endDate: Date!
	private var allRaces: [Race]!
	private var raceKeys: [String]!

	private var state: String! {
		didSet {
			allRaces = race.election!.racesForState(state, activeOnly: false).sorted()
		}
	}
	private var type: RaceType! {
		return race.raceType
	}
	var race: Race! {
		didSet {
			state = race.state!
			if let candidates = race.candidates {
				raceKeys = candidates.keys.sorted()
			}
			updateForType()
		}
	}
	var adjusted = false {
		didSet {
			saveButton?.isEnabled = adjusted
		}
	}
	var showResults  = false {
		didSet {
			updateForType()
		}
	}
	var demCount: Int! = 0 {
		didSet {
			demLabel?.text = String(format: "%.2d", Int(demCount))
			remaining = race.seats - (demCount + repCount + indCount)
		}
	}
	var repCount: Int! = 0 {
		didSet {
			repLabel?.text = String(format: "%.2d", Int(repCount))
			remaining = race.seats - (demCount + repCount + indCount)
		}
	}
	var indCount: Int = 0 {
		didSet {
			indLabel?.text = String(format: "%.2d", Int(indCount))
			remaining = race.seats - (demCount + repCount + indCount)
		}
	}
	var remaining: Int = 0 {
		didSet {
			remLabel?.text = String(format: "%.2d", Int(remaining))
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		nameLabel.text = state
		stateImage.image = UIImage(named: state)

		racePicker.removeAllSegments()
		for i in 0..<allRaces.count {
			let segRace = allRaces[i]
			racePicker.insertSegment(withTitle: String(describing: segRace.raceType).capitalized, at: i, animated: false)
			racePicker.setEnabled(segRace.isActive, forSegmentAt: i)
		}

		racePicker.selectedSegmentIndex = type.rawValue
		predictionOrResults.selectedSegmentIndex = showResults ? 1 : 0
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateForType()
	}
	
	func updateForType() {
		// If it's election day or later, cancel become dismiss, all other buttons disapper, and the slider is disabled
		if let endDate = endDate {
			let hideChanges = showResults || Calendar.current.isDate(Date(), inSameDayAs: endDate) || Date() > endDate
			saveButton?.isHidden = hideChanges
			demSlider?.isEnabled = !hideChanges
			repSlider?.isEnabled = !hideChanges
			indSlider?.isEnabled = !hideChanges
			candidatePicker?.isEnabled = !hideChanges
		}
		candidatePicker?.removeAllSegments()
		if let candidates = race.candidates {
			candidatePicker?.insertSegment(withTitle: "Too Close", at: 0, animated: false)
			for key in raceKeys.reversed() {
				candidatePicker?.insertSegment(withTitle: candidates[key], at: 0, animated: false)
			}
		}
		if !showResults, let predicted = race.prediction {
			if type == .house {
				demCount = predicted.demNumber
				repCount = predicted.repNumber
				indCount = predicted.indNumber
			} else if let (winner, prediction) = predicted.getWinner() {
				if let index = raceKeys.firstIndex(of: winner) {
					candidatePicker?.selectedSegmentIndex = index
				} else {
					candidatePicker?.selectedSegmentIndex = (candidatePicker?.numberOfSegments ?? 0) - 1
				}
				demCount = prediction
			}
		} else if showResults, let results = race.results {
			if type == .house {
				demCount = results["d"] ?? 0
				repCount = results["r"] ?? 0
				indCount = results["i"] ?? 0
			} else if let (winner, amount) = results.first {
				let index = raceKeys.firstIndex(of: winner)!
				candidatePicker?.selectedSegmentIndex = index
				if amount >= 0 {
					demCount = amount
				} else {
					demCount = 0
				}
			}
		} else {
			demCount = 0
			repCount = 0
			indCount = 0
		}
		demSlider?.setValue(Float(demCount), animated: true)
		repSlider?.setValue(Float(repCount), animated: true)
		indSlider?.setValue(Float(indCount), animated: true)
		demSlider?.maximumValue = Float(race.seats)
		repSlider?.maximumValue = Float(race.seats)
		indSlider?.maximumValue = Float(race.seats)
		updateView()
		adjusted = false
	}
	
	func updateView() {
		let animation = CATransition()
		animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType.fade
		animation.duration = 0.3
		stateImage?.layer.add(animation, forKey: "kCATransitionFade")
		slidersView?.layer.add(animation, forKey: "kCATransitionFade")
		sealImage?.layer.add(animation, forKey: "kCATransitionFade")
		
		sealImage?.image = UIImage(named: "\(type!)")
		let multi = type == .house || race.splits
		
		candidatePicker?.isHidden = multi
		slidersView?.isHidden = !multi
		// TODO: Update to make a little less obtuse
		let numbers = showResults ? race.results : race.prediction?.assertion
		if !multi {
			let winner = numbers?.keys.first ?? ""
			let index = raceKeys.firstIndex(of: winner) ?? -1
			candidatePicker?.selectedSegmentIndex = index
		}
		
//		if type != .house, !showResults, let (winner, _) = race.prediction?.getWinner() {
//			if let index = raceKeys.firstIndex(of: winner) {
//				candidatePicker?.selectedSegmentIndex = index
//			} else {
//				candidatePicker?.selectedSegmentIndex = (candidatePicker?.numberOfSegments ?? 0) - 1
//			}
//			//TODO: Assign index based on sorted keys
//			//candidatePicker?.selectedSegmentIndex = winner.rawValue
//		} else if type != .house, showResults, let (winner, _) = race.results?.first {
//			let index = raceKeys.firstIndex(of: winner)!
//			candidatePicker?.selectedSegmentIndex = index
//		} else {
//			candidatePicker?.selectedSegmentIndex = -1
//		}
		colorForPrediction()
	}
	
	@IBAction func countChanged(_ slider: UISlider) {
		adjusted = true
		slider.setValue(Float(Int(slider.value + 0.5)), animated: false)
		let number = Int(demSlider.value) + Int(repSlider.value) + Int(indSlider.value)
		if slider == demSlider {
			if number > race.seats {
				demSlider.setValue(Float(demCount), animated: false)
			} else {
				demCount = Int(demSlider.value)
			}
		} else if slider == repSlider {
			if number > race.seats {
				repSlider.setValue(Float(repCount), animated: false)
			} else {
				repCount = Int(repSlider.value)
			}
		} else if slider == indSlider {
			if number > race.seats {
				indSlider.setValue(Float(indCount), animated: false)
			} else {
				indCount = Int(indSlider.value)
			}
		}
		colorForPrediction()
	}
	
	
	@IBAction func candidateChosen(_ sender: UISegmentedControl) {
		adjusted = true
		colorForPrediction()
	}
	
	func colorForPrediction() {
		stateImage?.image = stateImage?.image?.withRenderingMode(.alwaysTemplate)
		let color: UIColor
		if type == .house {
			color = Colors.getColor(for: ["d": demCount, "i": indCount, "r": repCount, "t": remaining])
		} else if let winnerInt = candidatePicker?.selectedSegmentIndex, winnerInt != -1 {
			if winnerInt < raceKeys.count {
				let winner = raceKeys[winnerInt]
				color = Colors.getColor(for: [winner: race.seats])
			} else {
				color = Colors.getColor(for: ["t": race.seats])
			}
		} else {
			color = Colors.getColor(for: nil)
		}
		stateImage?.tintColor = color
	}
	
	func savePrediction(_ completion: ((Prediction?) -> Void)?) {
		var numbers = [String: Int]()
		if type == .house {
			numbers = ["d": demCount, "r": repCount, "i": indCount]
		} else if let winnerInt = candidatePicker?.selectedSegmentIndex, winnerInt != -1 {
			if winnerInt < raceKeys.count {
				let winner = raceKeys[winnerInt]
				numbers = [winner: race.seats]
			} else {
				numbers = ["t": race.seats]
			}
		} else {
			numbers = [:]
		}
		
		if let prediction = race.prediction {
			prediction.save(newAssertion: numbers, completion: completion)
		} else {
			Prediction.createNew(forRace: race, withAssertion: numbers, completion: completion)
		}
	}
	
	@IBAction func saveChoice(_ sender: AnyObject?) {
		savePrediction() { (_) in
			self.dismiss(animated: true, completion: nil)
		}
		
	}
	
	@IBAction func cancelChoice(_ sender: AnyObject?) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func changeRace(_ sender: UISegmentedControl) {
		if adjusted {
			let alertController = UIAlertController(title: "Save Prediction?", message: nil, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Save", style: .default) {
				(_) in
				self.savePrediction() { (_) in
					self.race = self.allRaces[sender.selectedSegmentIndex]
				}
			})
			alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) {
				(_) in
				self.race = self.allRaces[sender.selectedSegmentIndex]
			})
			present(alertController, animated: true, completion: nil)
		} else {
			self.race = allRaces[sender.selectedSegmentIndex]
		}
	}
	
	@IBAction func toggleShowResults(_ sender: UISegmentedControl) {
		showResults = sender.selectedSegmentIndex == 1
	}
	
	@IBAction func tappedState(_ recognizer: UITapGestureRecognizer) {
//		var nextIndex = (racePicker.selectedSegmentIndex + 1) % racePicker.numberOfSegments
//		while !racePicker.isEnabledForSegment(at: nextIndex) {
//			nextIndex += 1
//		}
//		racePicker.selectedSegmentIndex = nextIndex
//		changeRace(racePicker)
	}

}
