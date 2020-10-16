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
							.foregroundColor(index == self.pageIndex ? Color("democrat") : .gray)
					}
				}
				.padding(.horizontal)
				.background(Color.white)
				.clipShape(Capsule())
			}
			ZStack {
				HStack {
					Color.white
				}
				VStack {
					Text("Welcome to the Election Fantasy League 2020!")
						.font(.largeTitle)
						.multilineTextAlignment(.center)
						.padding()
					Spacer()
//					List {
						Text("Test your knowledge of political races by making predictions and winning points.")
							.font(.headline)
							.padding([.horizontal, .bottom])
						Text("Create individualized leagues to challenge friends, family, and coworkers for supremacy.")
							.font(.headline)
							.padding([.horizontal, .bottom])
						Text("The only question now is: how accurate can you be?")
							.font(.headline)
							.padding([.horizontal, .bottom])
//					}
					.font(.headline)
					.padding([.horizontal, .bottom])
					Spacer()
				}
				.background(Image("american_flag").resizable().aspectRatio(contentMode: .fill).opacity(0.2))
//				.background(StackedSealsView().opacity(0.3))
			}
		}
	}
}

struct StackedSealsView: View {
	var body: some View {
		VStack {
			Group {
				Image("president")
					.resizable()
					.aspectRatio(contentMode: .fit)
				Image("senate")
					.resizable()
					.aspectRatio(contentMode: .fit)
				Image("house_seal")
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
	}
}

struct TutorialHomeView_Previews: PreviewProvider {
	static var previews: some View {
		TutorialHomeView()
	}
}

