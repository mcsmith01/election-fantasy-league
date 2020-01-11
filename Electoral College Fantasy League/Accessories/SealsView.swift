//
//  SealsView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 11/30/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct SealsView: View {
	var body: some View {
		GeometryReader { geometry in
			VStack {
				Image("president")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: geometry.size.width / 2.5)
					.shadow(color: .gray, radius: 5)
					.opacity(0.75)
				HStack {
					Image("senate")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width / 2.5)
						.shadow(color: .gray, radius: 5)
						.opacity(0.75)
					Image("house")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: geometry.size.width / 2.5)
						.shadow(color: .gray, radius: 5)
						.opacity(0.75)
				}
			}
		}
	}
}

struct SealsView_Previews: PreviewProvider {
	static var previews: some View {
		SealsView()
	}
}
