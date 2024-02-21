//
//  File.swift
//
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//


import SwiftUI
import AppDesign

public protocol Coordinator: View {
    
}

@available(iOS 14.0, *)
public struct AppCoordinator<MyCoordinator: Coordinator>: Coordinator {
    @StateObject public var navigation: AppNavigation = AppNavigation()
    var rootView: ScreenView?
    
    public init(@ViewBuilder coordinator: () -> MyCoordinator) {
        rootView = ScreenView(view: AnyView(coordinator()))
    }
    
    public var body: some View {
        AppDesignView {
            NavigationStackView(navigation: navigation, rootView: rootView)
        }
    }
}

@available(iOS 13.0, *)
public struct AppCoordinatorIOS13<MyCoordinator: Coordinator>: Coordinator {
    @ObservedObject var navigation: AppNavigation = AppNavigation()
    var rootView: ScreenView?
    
    public init(@ViewBuilder coordinator: () -> MyCoordinator) {
        rootView = ScreenView(view: AnyView(coordinator()))
    }
    
    public var body: some View {
        AppDesignViewIOS13 {
            NavigationStackView(navigation: navigation, rootView: rootView)
        }
    }
}

struct NavigationStackView: View {
    @ObservedObject var navigation: AppNavigation = AppNavigation()
    var rootView: ScreenView?
   
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack(path: $navigation.screens, root: {
                    VStack {
                        navigation.rootView?.view ?? rootView?.view ?? AnyView(Text("Root view not found"))
                    }
                    .navigationDestination(for: ScreenView.self) { value in
                        value.view
                    }
                })
            } else {
                ZStack {
                    //ROOT VIEW
                    navigation.rootView?.view ?? rootView?.view ?? AnyView(Text("Root view not found"))
                    
                    //STACK VIEW
                    ForEach(navigation.screens, id: \.self) { screen in
                        screen.view.transition(.slide)
                    }
                }.edgesIgnoringSafeArea(.all)
                
            }
        }
        .onAppear(perform: {
            navigation.rootView = rootView
        })
        .environmentObject(navigation)
    }
}
