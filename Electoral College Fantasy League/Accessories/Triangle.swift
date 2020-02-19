//
//  Triangle.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 2/15/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct Triangle: Shape {
	
	func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: CGPoint(x: rect.width, y: 0))
			path.addLine(to: CGPoint(x: rect.width, y: rect.height))
			path.addLine(to: CGPoint(x: 0, y: rect.height))
		}
	}
}


struct Triangle_Previews: PreviewProvider {
    static var previews: some View {
        Triangle()
    }
}
