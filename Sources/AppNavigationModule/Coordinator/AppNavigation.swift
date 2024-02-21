//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//


import SwiftUI

protocol NavigationRoute {
    var rootView: ScreenView? { get set }
    func push(_ view: ScreenView)
    func setRoot(_ view: ScreenView)
    func pop()
    func popToRoot()
    func popToRootAndPush(_ view: ScreenView)
}


public class AppNavigation: NavigationRoute, ObservableObject {
   @Published public var rootView: ScreenView?
   @Published public var screens: [ScreenView] = []
    
    public func push(_ view: ScreenView) {
        screens.append(view)
    }
    
    public func popToRootAndPush(_ view: ScreenView) {
        screens.removeAll()
        screens.append(view)
    }
    
    public func setRoot(_ view: ScreenView) {
        screens.removeAll()
        rootView = view
    }
    
    public func pop() {
        let _ = screens.popLast()
    }
    
    public func popToRoot() {
        let _ = screens.removeAll()
    }
}


