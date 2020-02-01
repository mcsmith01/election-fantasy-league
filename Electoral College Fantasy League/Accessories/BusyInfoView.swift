//
//  BusyInfoView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/25/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct BusyInfoView: View {
	var text: String
	
	var body: some View {
		VStack {
			ActivityView(isAnimating: .constant(true), style: .large)
				.foregroundColor(.primary)
			Text(text)
				.padding(.horizontal)
		}
		.padding()
		.background(Color.primary.colorInvert())
		.cornerRadius(25)
		.padding()
		.shadow(color: .gray, radius: 5)
	}
}

struct BusyInfoView_Previews: PreviewProvider {
	static var previews: some View {
		BusyInfoView(text: "Saving...")
	}
}
