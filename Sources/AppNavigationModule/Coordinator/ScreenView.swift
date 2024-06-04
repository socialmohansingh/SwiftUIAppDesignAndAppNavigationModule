//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//

import SwiftUI

public struct ScreenView : Hashable, Identifiable {
    public let id: String
    public let view: AnyView
    let showFullScreen: Bool
    let hideNav: Bool
    
    public init(view: AnyView, showFullScreen: Bool = false, hideNav: Bool = false) {
        self.view = view
        self.showFullScreen = showFullScreen
        self.hideNav = hideNav
        self.id = UUID().uuidString
    }
    
    public init(id: String, view: AnyView, showFullScreen: Bool = false, hideNav: Bool = false) {
        self.view = view
        self.showFullScreen = showFullScreen
        self.hideNav = hideNav
        self.id = id
    }
    
    public func hash(into hasher: inout Hasher) {
           hasher.combine(id)
    }
    
    public static func == (lhs: ScreenView, rhs: ScreenView) -> Bool {
        return lhs.id == rhs.id
    }
}

