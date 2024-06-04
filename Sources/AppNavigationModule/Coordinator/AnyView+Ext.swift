//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 29/05/24.
//

import SwiftUI

protocol ViewIdentifiable {
    var viewType: String { get }
}

extension View {
    public func screen(showFullScreen: Bool = false, hideNav: Bool = false) -> ScreenView {
        return ScreenView(id: String(describing: type(of: self)), view: AnyView(self), showFullScreen: showFullScreen, hideNav: hideNav)
    }
}
