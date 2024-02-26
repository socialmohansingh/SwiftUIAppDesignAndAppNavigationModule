//
//  SwiftUIView.swift
//
//
//  Created by Mohan Singh Thagunna on 26/02/2024.
//

import SwiftUI

extension View {
   @ViewBuilder public func appBottomSheet<Content: View, Header: View>(displayType: Binding<BottomSheetDisplayType>,
                        viewModel: BaseAppButtomSheetViewModel = BaseAppButtomSheetViewModel(),
                        @ViewBuilder content: @escaping () -> Content,
                        @ViewBuilder header: @escaping () -> Header) -> some View {
            GeometryReader { geometry in
                GeometryReader { _ in
                    self.padding(geometry.safeAreaInsets)
                    BaseAppButtomSheet(displayType: displayType, viewModel: viewModel, content: content, header: header)
                }.edgesIgnoringSafeArea(.all)
            }
        
    }
}

public struct AppButtomSheetView<Header: View, Content: View>: View {
    var displayType: Binding<BottomSheetDisplayType> = .constant(.collapsed)
    @ObservedObject var viewModel: BaseAppButtomSheetViewModel
    @ViewBuilder let content: () -> Content
    @ViewBuilder let header: () -> Header
    
    public init(displayType: Binding<BottomSheetDisplayType>,
         viewModel: BaseAppButtomSheetViewModel = BaseAppButtomSheetViewModel(),
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder header: @escaping () -> Header) {
        self.displayType = displayType
        self.viewModel = viewModel
        self.content = content
        self.header = header
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GeometryReader { _ in
                Color.clear.padding(geometry.safeAreaInsets)
                BaseAppButtomSheet(displayType: displayType, viewModel: viewModel,
                                   content: content, header: header)
            }.edgesIgnoringSafeArea(.all)
            
        }
    }
}


#Preview {
    ZStack {
        Color.orange.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        Button("Title") {
            print("asdf")
        }
        AppButtomSheetView(displayType: .constant(.collapsed), viewModel: BaseAppButtomSheetViewModel(steps: [.expandFromBottom(200), .expandFromBottom(400),.expandFromTop(100)], disableDragIndicatorView: false)) {
            ZStack {
                Color.red
            }
        } header: {
            ZStack {
                Color.blue
            }.frame(height: 150)
        }
    }

}

#Preview {
    ZStack {
        Color.red.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/ ).appBottomSheet(displayType: .constant(.collapsed), viewModel: BaseAppButtomSheetViewModel(steps: [.expandFromBottom(200), .expandFromBottom(400),.expandFromTop(100)])) {
            VStack {
                Text("asdf")
            }
        } header: {
            VStack {
                Text("111")
                Spacer()
            }.frame(height: 150)
        }

    }

}
