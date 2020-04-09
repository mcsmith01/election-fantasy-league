//
//  TutorialHomeView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/19/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct TutorialHomeView: View {
	var numberOfPages = 3
	@State var pageIndex = 0
	
	var body: some View {
		ZStack {
			GeometryReader { geometry in
				CarouselView(numberOfPages: self.numberOfPages, currentIndex: self.$pageIndex) {
					Image("president")
						.resizable()
						.scaledToFit()
						.padding()
						.frame(width: geometry.size.width, height: geometry.size.height)
						.clipped()
					Image("senate")
						.resizable()
						.scaledToFit()
						.padding()
						.frame(width: geometry.size.width, height: geometry.size.height)
						.clipped()
					Image("house_seal")
						.resizable()
						.scaledToFit()
						.padding()
						.frame(width: geometry.size.width, height: geometry.size.height)
						.clipped()
				}
			}
			VStack {
				Spacer()
				HStack {
					ForEach(0..<numberOfPages) { index in
						Text("•")
							.foregroundColor(index == self.pageIndex ? .democrat : .gray)
					}
				}
				.padding(.horizontal)
				.background(Color.white)
				.clipShape(Capsule())
			}
		}
	}
}

struct TutorialHomeView_Previews: PreviewProvider {
	static var previews: some View {
		TutorialHomeView()
	}
}
