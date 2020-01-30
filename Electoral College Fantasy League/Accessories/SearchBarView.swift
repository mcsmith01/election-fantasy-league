//
//  SearchBarView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 1/29/20.
//  Copyright © 2020 ls -applications. All rights reserved.
//

import SwiftUI

struct SearchBarView: UIViewRepresentable {
	@Binding var text: String
	var color: UIColor?

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	   text = searchText
	}
	
	//Update UIViewcontrolleer Method
	func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBarView>) {
		uiView.text = text
	}
	
	//Make Coordinator which will commnicate with the Search bar
	func makeCoordinator() -> SearchBarView.Coordinator {
		return Coordinator(text: $text)
	}
	
	// Create UIViewController which we will display inside the View of the UIViewControllerRepresentable
	func makeUIView(context: UIViewRepresentableContext<SearchBarView>) -> UISearchBar {
		let searchBar = UISearchBar(frame: .zero)
		searchBar.delegate = context.coordinator
		return searchBar
	}
	
	class Coordinator: NSObject, UISearchBarDelegate {
		@Binding var text: String
		
		init(text: Binding<String>) {
			_text = text
		}
		
		func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
			text = searchText
		}
	}
}
