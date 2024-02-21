//
//  SwiftUIView.swift
//  
//
//  Created by Mohan Singh Thagunna on 21/02/2024.
//

import SwiftUI


@available(iOS 14.0, *)
public struct AppDesignView<Content: View>: View {
    
    @ViewBuilder public var content: () -> Content
    
    @StateObject private var designSystem: AppDesign = AppDesign()
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        MainAppDesignView(content: content, designSystem: designSystem)
    }
}

@available(iOS 13.0, *)
public struct AppDesignViewIOS13<Content: View>: View {
    @ViewBuilder public var content: () -> Content
    
    @ObservedObject private var designSystem: AppDesign = AppDesign()

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        MainAppDesignView(content: content, designSystem: designSystem)
    }
}


struct MainAppDesignView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.locale) var locale
    
    @ViewBuilder var content: () -> Content
    @ObservedObject var designSystem: AppDesign
    
    var body: some View {
        Group {
            content()
              
        }
        
        .environmentObject(designSystem)
        .environment(\.locale, .init(identifier: designSystem.localization.appLocale.identifier))
        .environment(\.colorScheme, designSystem.theme.currentTheme.colorScheme)
        .onAppear(perform: {
            print(colorScheme)
            print(locale)
        })
        
    }
}
