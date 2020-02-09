//
//  SingleCandidateChoiceView.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 12/2/19.
//  Copyright © 2019 ls -applications. All rights reserved.
//

import SwiftUI

struct SingleCandidateChoiceView: View {
	@ObservedObject var model: StateChoiceModel
	
	var candidates: [String: String] {
		return model.race.candidates ?? [:]
	}
	var partyList: [String] {
		var list = candidates.keys.sorted()
		list.append("t")
		return list
	}
	
	var body: some View {
		VStack {
			Picker(selection: $model.candidateID, label: EmptyView()) {
				ForEach(partyList, id: \.self) { party in
					Text(self.candidates[party] ?? "Too Close to Call")
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			Spacer()
		}
	}
	
}

//struct SingleCandidateChoiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleCandidateChoiceView()
//    }
//}
