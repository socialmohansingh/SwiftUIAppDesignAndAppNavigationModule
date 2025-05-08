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
    @State var text = ""
    var body: some View {
        ZStack {
            AppCoordinatorIOS13 {
                HomeCoordinator()
            }
            
            AppBottomSheetView(displayType: $displayStyle,
                               viewModel: BaseAppBottomSheetViewModel(disableDragToHideSheet: true)
            ) {
                Color.blue.frame(height: 1000)
            } header: {
                ZStack {
                    Color.red
                        .padding(.bottom, 4)
                    TextField("Mohan Singh", text: $text)
                    Spacer()
                }.frame(height: 100)
                    .background(Color.green)
            }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)

        }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ContentView()
}
