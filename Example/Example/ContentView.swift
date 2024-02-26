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
    @State var displayStyle: BottomSheetDisplayType = .collapsed
    @ObservedObject var vm = ContentViewModel()
    
    var body: some View {
        ZStack {
            AppCoordinatorIOS13 {
                HomeCoordinator()
            }
            
            AppButtomSheetView(displayType: $displayStyle,
                               viewModel: BaseAppButtomSheetViewModel(bottomSheepPadding: 120)
            ) {
                Color.blue
            } header: {
                ZStack {
                    Color.red
                }.frame(height: 100)
            }

        }
    }
}

#Preview {
    ContentView()
}
