//
//  AppLocalization.swift
//
//
//  Created by Mohan Singh Thagunna on 20/02/2024.
//

import Foundation
import SwiftUI

public class AppLocalization {
    public static var defaultLanguage: Locale = Locale(identifier: "en")
    var appLocale: Locale
    
    init() {
        let currentLocale = UserDefaults.standard.localization
        appLocale = currentLocale
    }
    
    public var current: Locale {
        return appLocale
    }
    
    public func changeLocale(_ locale: Locale) {
        appLocale = locale
        UserDefaults.standard.localization = locale
    }
    
    
}

extension String {
    public func localized() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}

extension UserDefaults {
  var localization: Locale {
    get {
        register(defaults: [#function: AppLocalization.defaultLanguage.identifier])
      return Locale(identifier: string(forKey: #function) ?? AppLocalization.defaultLanguage.identifier)
    }
    set {
      set(newValue.identifier, forKey: #function)
    }
  }
}
