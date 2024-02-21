//
//  HomeCoordinator.swift
//  Example
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//

import SwiftUI
import AppNavigationModule
import AppDesign

struct HomeCoordinator: Coordinator {
    @EnvironmentObject var navigation: AppNavigation
    @EnvironmentObject var designSystem: AppDesign
   
    
    var body: some View {
        VStack {
            Button {
                navigation.push(ScreenView(view: AnyView(HomeDetailView())))
            } label: {
                Text("goto home detail".localized()) .foregroundColor(Color("blueColor"))
            }

        }
    }
}

#Preview {
    HomeCoordinator()
}
