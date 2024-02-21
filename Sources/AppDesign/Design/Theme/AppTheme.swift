//
//  Theme.swift
//
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//

import SwiftUI

public enum ThemeType: Int {
    case system
    case light
    case dark
}

extension ThemeType {
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    public var colorScheme: ColorScheme {
        @Environment(\.colorScheme) var colorScheme
        switch self {
        case .system:
            return colorScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

public class AppTheme {
    
    public var currentTheme: ThemeType
    public var currentScheme: ColorScheme
    public var current: ThemeType {
        return currentTheme
    }
    
    init() {
        let tempThemeType = UserDefaults.standard.themeType
        currentTheme = tempThemeType
        currentScheme = tempThemeType.colorScheme
    }
    
    
    
    public func changeTheme(to themeType: ThemeType) {
        currentScheme = themeType.colorScheme
        currentTheme = themeType
        UserDefaults.standard.themeType = themeType
        UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = themeType.userInterfaceStyle
    }
}

extension UserDefaults {
    var themeType: ThemeType {
        get {
            register(defaults: [#function: ThemeType.system.rawValue])
            return ThemeType(rawValue: integer(forKey: #function)) ?? .system
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
}
