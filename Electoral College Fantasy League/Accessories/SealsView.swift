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
					.modifier(SealModifier(viewWidth: geometry.size.width))
				HStack {
					Image("senate")
						.resizable()
						.modifier(SealModifier(viewWidth: geometry.size.width))
					Image("house_seal")
						.resizable()
						.modifier(SealModifier(viewWidth: geometry.size.width))
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

struct SealModifier: ViewModifier {
	var viewWidth: CGFloat
	
    func body(content: Content) -> some View {
        content
			.aspectRatio(contentMode: .fit)
			.frame(width: viewWidth / 2.5)
			.shadow(color: .gray, radius: 5)
			.opacity(0.75)
    }
}
