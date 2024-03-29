//
//  SwiftUIView.swift
//
//
//  Created by Mohan Singh Thagunna on 26/02/2024.
//

import SwiftUI

extension View {
   @ViewBuilder public func appBottomSheet<Content: View, Header: View>(displayType: Binding<BottomSheetDisplayType>,
                        viewModel: BaseAppBottomSheetViewModel = BaseAppBottomSheetViewModel(),
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

public struct AppBottomSheetView<Header: View, Content: View>: View {
    var displayType: Binding<BottomSheetDisplayType> = .constant(.collapsed)
    @ObservedObject var viewModel: BaseAppBottomSheetViewModel
    @ViewBuilder let content: () -> Content
    @ViewBuilder let header: () -> Header
    let leftDragView: AnyView?
    let rightDragView: AnyView?
    let delegate: BaseAppBottomSheetProtocol?
    
    public init(displayType: Binding<BottomSheetDisplayType>,
         viewModel: BaseAppBottomSheetViewModel = BaseAppBottomSheetViewModel(),
        delegate: BaseAppBottomSheetProtocol? = nil,
                leftDragView: AnyView? = nil,
                rightDragView: AnyView? = nil,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder header: @escaping () -> Header) {
        self.displayType = displayType
        self.viewModel = viewModel
        self.content = content
        self.header = header
        self.delegate = delegate
        self.leftDragView = leftDragView
        self.rightDragView = rightDragView
    }
    
    public var body: some View {
        GeometryReader { geometry in
            GeometryReader { _ in
                Color.clear.padding(geometry.safeAreaInsets)
                BaseAppButtomSheet(displayType: displayType, 
                                   viewModel: viewModel,
                                   delegate: delegate,
                                   leftDragView: leftDragView,
                                   rightDragView: rightDragView,
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
        AppBottomSheetView(displayType: .constant(.collapsed), viewModel: BaseAppBottomSheetViewModel(
            disableDragIndicatorView: false, dragIndicatorConfig: BottomSheetConfiguration(backgroundColor: .green)), rightDragView: AnyView(HStack {Spacer()
                ZStack{}.frame(width: 10, height: 25).background(Color.blue)})) {
                ZStack {
                    Color.red
                }.frame(height: 150)
        } header: {
            ZStack {
                Color.red
            }.frame(height: 150)
        }
    }

}
//
//#Preview {
//    ZStack {
//        Color.red.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/ ).appBottomSheet(displayType: .constant(.collapsed), viewModel: BaseAppBottomSheetViewModel(steps: [.expandFromBottom(200), .expandFromBottom(400),.expandFromTop(100)])) {
//            VStack {
//                Text("asdf")
//            }
//        } header: {
//            VStack {
//                Text("111")
//                Spacer()
//            }.frame(height: 150)
//        }
//
//    }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//
//}
