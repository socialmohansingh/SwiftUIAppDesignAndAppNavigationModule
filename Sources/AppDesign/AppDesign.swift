// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public class AppDesign: ObservableObject {
    @Published public var theme = AppTheme()
    @Published public var localization = AppLocalization()
    @Published var refreshId = UUID()
    
    public func changeLocale(_ locale: Locale) {
        localization.changeLocale(locale)
        refreshId = UUID()
    }
    
    public func changeTheme(to themeType: ThemeType) {
        theme.changeTheme(to: themeType)
        refreshId = UUID()
    }
}
