//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//


import SwiftUI
import Combine

protocol NavigationRoute {
    var rootView: ScreenView? { get set }
    func push(_ screen: ScreenView)
    func pushMany(_ screens: [ScreenView])
    func setRoot(_ screen: ScreenView)
    func popTo(_ screenType: any View.Type)
    func popTo(_ screenId: String)
    func pop()
    func popToRoot()
    func popToRootAndPush(_ screen: ScreenView)
    func popToRootAndPushMany(_ screens: [ScreenView])
}


public class AppNavigation: NavigationRoute, ObservableObject {
    
   @Published public var rootView: ScreenView?
   @Published public var screens: [ScreenView] = []
    private var subscriptions = Set<AnyCancellable>()
    @Published var currentScreen: ScreenView?
    
    public init() {
        if #available(iOS 16.0, *) {
            
        } else {
            $screens.sink { [weak self] screens in
                DispatchQueue.main.async {
                    if screens.isEmpty {
                        self?.currentScreen = nil
                    } else {
                        self?.currentScreen = self?.screens.last
                    }
                }
            }.store(in: &subscriptions)
        }
    }
    
    public func push(_ screen: ScreenView) {
        screens.append(screen)
    }
    
    public func pushMany(_ screens: [ScreenView]) {
        self.screens.append(contentsOf: screens)
    }
    
    public func popToRootAndPush(_ screen: ScreenView) {
        screens.removeAll()
        push(screen)
    }
    
    public func popToRootAndPushMany(_ screens: [ScreenView]) {
        self.screens.removeAll()
        pushMany(screens)
    }
    
    public func setRoot(_ screen: ScreenView) {
        screens.removeAll()
        rootView = screen
    }
    
    public func pop() {
        let _ = screens.popLast()
    }
    
    public func popTo(_ screenType: any View.Type) {
        if let index = screens.lastIndex(where: {$0.id == String(describing: screenType)}) {
            screens.removeLast(screens.count - index - 1)
        }
    }
    
    public func popTo(_ screenId: String) {
        if let index = screens.lastIndex(where: {$0.id == screenId}) {
            screens.removeLast(screens.count - index - 1)
        }
    }
    
    public func popToRoot() {
        let _ = screens.removeAll()
    }
}


