//
//  ElectionGraphView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/23/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct ElectionGraphView: View {
	@ObservedObject var model: NumbersModel

	var dems: Double {
		return Double(model.dems + model.safeDems)
	}
	var inds: Double {
		return Double(model.inds + model.safeInds)
	}
	var reps: Double {
		return Double(model.reps + model.safeReps)
	}
	var total: Double {
		return Double(model.total)
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				GraphWedge(offset: 0, number: self.total, total: self.total)
					.fill(Color.gray)
				GraphWedge(offset: 0.0, number: self.dems, total: self.total)
					.fill(Color.democrat)
				GraphWedge(offset: self.dems, number: self.inds, total: self.total)
					.fill(Color.independent)
				GraphWedge(offset: self.total - self.reps, number: self.reps, total: self.total)
					.fill(Color.republican)
			}
			.frame(width: geometry.size.width, height: geometry.size.width / 2)
		}

	}

}

struct GraphWedge: Shape {
	
	var offset: Double
	var number: Double
	var total: Double
	var radius: CGFloat {
		get {
			100.0
		}
	}
	var center: CGPoint {
		get {
			CGPoint(x: radius, y: radius)
		}
	}
	
	var wedge: Path {
		get {
			return Path { path in
				let start = 180.0 + 180 * (offset / total)
				let end = 180.0 + 180 * ((offset + number) / total)
				path.move(to: center)
				path.addArc(center: center, radius: radius, startAngle: .degrees(start), endAngle: .degrees(end), clockwise: false)
				path.addLine(to: center)
			}
		}
	}
	
	func path(in rect: CGRect) -> Path {
		let scale = min(rect.size.width / (radius * 2), rect.size.height / radius)
		return wedge.applying(CGAffineTransform(scaleX: scale, y: scale))
	}
	
}

//struct ElectionGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElectionGraphView(dems: 135, inds: 2, reps: 110, total: 435)
//    }
//}
