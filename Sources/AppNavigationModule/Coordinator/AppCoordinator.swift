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
    @Environment(\.colorScheme) var colorScheme
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
                    GeometryReader { geo in
                        ForEach(navigation.screens, id: \.self) { screen in
                            VStack(spacing: 0) {
                                if screen.showFullScreen {
                                    ZStack {
                                        screen.view.edgesIgnoringSafeArea(.all)
                                        
                                        if !screen.hideNav {
                                            VStack {
                                                if geo.safeAreaInsets.top > 0 {
                                                    Spacer().frame(height: geo.safeAreaInsets.top)
                                                }
                                                HStack {
                                                    Image(systemName: "chevron.left")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .padding(.horizontal, 16)
                                                        .padding(.bottom, 16)
                                                        .frame(width: 45, height: 45)
                                                        .foregroundColor(.primary)
                                                        .onTapGesture {
                                                            navigation.screens.popLast()
                                                        }
                                                    Spacer()
                                                }.frame(height: 45)
                                                Spacer()
                                            }
                                        }
                                    }.edgesIgnoringSafeArea(.all)
                                } else {
                                    if geo.safeAreaInsets.top > 0 {
                                        Spacer().frame(height: geo.safeAreaInsets.top)
                                    }
                                    if !screen.hideNav {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 16)
                                                .frame(width: 45, height: 45)
                                                .foregroundColor(.primary)
                                                .onTapGesture {
                                                    navigation.screens.popLast()
                                                }
                                            Spacer()
                                        }.frame(height: 45)
                                    }
                                    screen.view
                                    Spacer()
                                    if geo.safeAreaInsets.bottom > 0 {
                                        Spacer().frame(height: geo.safeAreaInsets.bottom)
                                    }
                                }
                            }
                            .background(colorScheme == .light ? Color.white : Color.black)
                            .edgesIgnoringSafeArea(.all)
                            
                        } 
                        .transition(.move(edge: .trailing))
                        .animation(.linear(duration: 0.1))
                    }
                }
            }
        }
        .onAppear(perform: {
            navigation.rootView = rootView
        })
        .environmentObject(navigation)
    }
}
