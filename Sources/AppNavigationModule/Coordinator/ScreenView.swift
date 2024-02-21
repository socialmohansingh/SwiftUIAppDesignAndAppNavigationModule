//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//

import SwiftUI

public struct ScreenView : Hashable, Identifiable {
    public let id = UUID()
    public let view: AnyView
    
    public init(view: AnyView) {
        self.view = view
    }
    
    public func hash(into hasher: inout Hasher) {
           hasher.combine(id)
    }
    
    public static func == (lhs: ScreenView, rhs: ScreenView) -> Bool {
        return lhs.id == rhs.id
    }
}

