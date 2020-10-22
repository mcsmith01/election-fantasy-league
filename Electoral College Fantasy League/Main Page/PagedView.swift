//
//  PagedView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 9/25/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct PagedView<Content: View>: View {
	@Binding var index: Int
	@Binding var showView: Bool
	@State var offset: CGFloat = 0
	@State var isGestureActive = false
	
	var pages: [Content]
	
    var body: some View {
		ZStack {
			GeometryReader { geometry in
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(alignment: .center, spacing: 0) {
						ForEach(0..<pages.count) { index in
							let page = pages[index]
							page.frame(width: geometry.size.width)
						}
					}
				}
				.content.offset(x: isGestureActive ? self.offset : -geometry.size.width * CGFloat(index))
				.frame(width: geometry.size.width, alignment: .leading)
				.gesture(DragGesture().onChanged({ value in
					// TODO: Remove external views until drag begins
					// TODO: Make the views wrap
					isGestureActive = true
					offset = value.translation.width + -geometry.size.width * CGFloat(index)
				}).onEnded({ value in
					if -value.predictedEndTranslation.height > geometry.size.height / 2 {
						showView = false
					}
					if -value.predictedEndTranslation.width > geometry.size.width / 3 {
						index = min(index + 1, pages.count - 1)
					}
					if value.predictedEndTranslation.width > geometry.size.width / 3 {
						index = max(index - 1, 0)
					}
					withAnimation {
						offset = -geometry.size.width * CGFloat(index)
						DispatchQueue.main.async {
							isGestureActive = false
						}
					}
				}))
				
			}
//			VStack {
//				Spacer()
//				HStack {
//					ForEach(0..<pages.count) { i in
//						Image(systemName: i == index ? "dot.square.fill" : "dot.square")
//					}
//				}
//			}
		}
	}
}

struct PagedView_Previews: PreviewProvider {
	@State static var index = 0
	@State static var showView = true
    static var previews: some View {
		PagedView(index: $index, showView: $showView, pages: [Text("Hello"), Text("World")])
    }
}

