//
//  CarouselView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/20/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct CarouselView<Content: View>: View {
	var numberOfPages: Int
	var content: Content
	
	@Binding var currentIndex: Int

	var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 0) {
				self.content
			}
			.frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
			.offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
			.animation(.spring())
			.gesture(DragGesture()
			.onEnded({ (value) in
				if value.translation.width > 10 {
					self.currentIndex = max(self.currentIndex - 1, 0)
				} else if value.translation.width < -10 {
					self.currentIndex = min(self.currentIndex + 1, self.numberOfPages - 1)
				}
			}))
		}
	}
	
	init(numberOfPages: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
		self.numberOfPages = numberOfPages
		self._currentIndex = currentIndex
		self.content = content()
	}
	
}

//struct CarouselView_Previews: PreviewProvider {
//	static var previews: some View {
//		GeometryReader { geometry in
//			CarouselView(numberOfPages: 3) {
//				Image("president")
//					.resizable()
//					.scaledToFill()
//					.frame(width: geometry.size.width, height: geometry.size.height)
//					.clipped()
//				Image("senate")
//					.resizable()
//					.scaledToFill()
//					.frame(width: geometry.size.width, height: geometry.size.height)
//					.clipped()
//				Image("house_seal")
//					.resizable()
//					.scaledToFill()
//					.frame(width: geometry.size.width, height: geometry.size.height)
//					.clipped()
//			}
//		}
//	}
//}
