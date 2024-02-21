//
//  ContentViewModel.swift
//  Example
//
//  Created by Mohan Singh Thagunna on 30/01/2024.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()
    
    init() {
       loadData()
    }
    
    func loadData() {
      

    }
}
