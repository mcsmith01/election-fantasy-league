//
//  AcivityView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/30/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI
import UIKit

struct ActivityView: UIViewRepresentable {
	typealias UIViewType = UIActivityIndicatorView
	
    @Binding var isAnimating: Bool
	let style: UIActivityIndicatorView.Style

	func makeUIView(context: UIViewRepresentableContext<ActivityView>) -> ActivityView.UIViewType {
		let indicator = UIActivityIndicatorView(style: style)
		if isAnimating {
			indicator.startAnimating()
		}
		return indicator
	}
	
	func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityView>) {
		
	}
	
}

struct AcivityView_Previews: PreviewProvider {
    static var previews: some View {
		ActivityView(isAnimating: .constant(true), style: .large)
    }
}
