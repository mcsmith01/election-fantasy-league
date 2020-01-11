//
//  MultiPickerView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/6/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct MultiPickerView: View {
	var options: [String]
	@State var selected: Set<Int>
	
    var body: some View {
		Form {
			MultiPickerViewRow(option: "All", selected: self.selected.count == self.options.count)
			.onTapGesture {
				if self.selected.count == self.options.count {
					self.selected.removeAll()
				} else {
					for i in 0..<self.options.count {
						self.selected.insert(i)
					}
				}
				debugPrint("Selected All")
			}
			List(0..<options.count) { optionIndex in
				MultiPickerViewRow(option: self.options[optionIndex], selected: self.selected.contains(optionIndex))
				.onTapGesture {
					if self.selected.contains(optionIndex) {
						self.selected.remove(optionIndex)
					} else {
						self.selected.insert(optionIndex)
					}
				}
			}
		}
	}
}

struct MultiPickerView_Previews: PreviewProvider {
    static var previews: some View {
		MultiPickerView(options: ["President", "Senate", "House", "Governor"], selected: Set<Int>([0, 3]))
    }
	
	init() {
		UITableView.appearance().separatorColor = .clear
	}
}

struct MultiPickerViewRow: View {
	var option: String
	var selected: Bool
	
	var body: some View {
		ZStack {
			Color.primary.colorInvert()
			HStack {
				Text(option)
				Spacer()
				if selected {
					Image(systemName: "checkmark")
					.foregroundColor(.accentColor)
				}
			}
		}
	}
	
}
