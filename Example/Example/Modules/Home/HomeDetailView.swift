//
//  HomeDetailView.swift
//  Example
//
//  Created by Mohan Singh Thagunna on 21/02/2024.
//

import SwiftUI
import AppDesign
import AppNavigationModule

struct HomeDetailView: View {
    @EnvironmentObject var navigation: AppNavigation
    @EnvironmentObject var appDesign: AppDesign
    
    @State var isEnglish: Bool = true
    var body: some View {
        VStack {
            Text("The current color scheme is: \(appDesign.theme.currentTheme.rawValue)")
              
            Text("tap me".localized())
                .foregroundColor(Color("blueColor"))
                .onTapGesture {
                    print(appDesign.theme.current)
                    if appDesign.theme.current == .dark {
                        appDesign.changeTheme(to: .light)
                    } else {
                        appDesign.changeTheme(to: .dark)
                    }
                }
            Text("tap me local".localized())
                .foregroundColor(Color("blueColor"))
                .onTapGesture {
                    
                    isEnglish.toggle()
                    if isEnglish {
                        appDesign.changeLocale(Locale(identifier: "en"))
                    } else {
                        appDesign.changeLocale(Locale(identifier: "ne-NP"))
                    }
                    
                }
        }.onAppear(perform: {
            isEnglish = appDesign.localization.current.identifier == "en"
        })
    }
}

#Preview {
    HomeDetailView()
}
