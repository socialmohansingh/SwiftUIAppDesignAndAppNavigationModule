//
//  ContentView.swift
//  Example
//
//  Created by Mohan Singh Thagunna on 30/01/2024.
//

import SwiftUI
import AppDesign
import AppNavigationModule

struct ContentView: View {
    @ObservedObject var vm = ContentViewModel()
    
    var body: some View {
        AppCoordinatorIOS13 {
            HomeCoordinator()
        }
    }
}

#Preview {
    ContentView()
}
