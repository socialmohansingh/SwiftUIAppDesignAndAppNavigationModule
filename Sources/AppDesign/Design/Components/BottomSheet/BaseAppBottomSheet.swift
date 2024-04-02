//
//  AppBottomSheet.swift
//
//
//  Created by Mohan Singh Thagunna on 26/02/2024.
//

import SwiftUI

public protocol BaseAppBottomSheetProtocol {
    func startAnimation(start: BottomSheetDisplayType?, current: BottomSheetDisplayType)
    func endAnimation(start: BottomSheetDisplayType?, current: BottomSheetDisplayType)
    func updateOffset(offset: CGFloat)
}

extension BaseAppBottomSheetProtocol {
    func startAnimation(start: BottomSheetDisplayType?, current: BottomSheetDisplayType) {}
}

public struct TopHeader {
    public let topView: AnyView
    public let height: Double
    public let minVisibleOffset: Double
    
    public init(topView: AnyView, height: Double, minVisibleOffset: Double = 140) {
        self.topView = topView
        self.height = height
        self.minVisibleOffset = minVisibleOffset
    }
}

public struct BaseAppButtomSheet<Header: View, Content: View>: View {
    @State private var lastDisplayType: BottomSheetDisplayType? = nil
    @Binding var displayType: BottomSheetDisplayType {
        didSet {
            if lastDisplayType != displayType {
                triggerHapticFeedback()
            }
            delegate?.startAnimation(start: lastDisplayType, current: displayType)
            delegate?.endAnimation(start: lastDisplayType, current: displayType)
            lastDisplayType = displayType
        }
    }
    @ObservedObject var viewModel: BaseAppBottomSheetViewModel
    
    let content: Content
    let header: Header
    
    let leftDragView: AnyView?
    let rightDragView: AnyView?
    let topHeader: TopHeader
    let delegate: BaseAppBottomSheetProtocol?
    
    @State private var headerHeight: CGFloat = 80
    @State private var safeAreaInsets = EdgeInsets()
    @GestureState private var translation: CGFloat = 0
    
    //MARK:- Offset from top edge
    private var offset: CGFloat {
        return getOffsetValue(type: displayType)
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: viewModel.dragIndicatorConfig.topCornerRadius)
            .fill(viewModel.dragIndicatorConfig.dragIndicatorColor)
            .frame(
                width: viewModel.dragIndicatorConfig.dragIndigatorSize.width,
                height: viewModel.dragIndicatorConfig.dragIndigatorSize.height
            )
    }
    
    public init(displayType: Binding<BottomSheetDisplayType>,
                viewModel: BaseAppBottomSheetViewModel = BaseAppBottomSheetViewModel(),
                delegate: BaseAppBottomSheetProtocol? = nil,
                leftDragView: AnyView? = nil,
                rightDragView: AnyView? = nil,
                topHeader: TopHeader? = nil,
                @ViewBuilder content: () -> Content,
                @ViewBuilder header: () -> Header) {
        self.viewModel = viewModel
        self.content = content()
        self.header = header()
        self._displayType = displayType
        self.delegate = delegate
        self.leftDragView = leftDragView
        self.rightDragView = rightDragView
        self.topHeader = topHeader ?? TopHeader(topView: AnyView(Color.white), height: 0)
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        safeAreaInsets = EdgeInsets(top: keyWindow?.safeAreaInsets.top ?? 0,
                                    leading: keyWindow?.safeAreaInsets.left ?? 0,
                                    bottom: keyWindow?.safeAreaInsets.bottom ?? 0,
                                    trailing: keyWindow?.safeAreaInsets.right ?? 0)
    }
    
    public func nextDisplayType() {
        if !viewModel.disableUpdateDisplayType {
            if viewModel.lastMovement == .up {
                if displayType == .expanded {
                    nextDisplayType(directionIsUp: false, movement: viewModel.translationHeight+1)
                } else {
                    viewModel.lastMovement = .down
                    nextDisplayType(directionIsUp: true, movement: -(viewModel.translationHeight+1))
                }
                
            } else if viewModel.lastMovement == .down {
                if displayType == .collapsed {
                    nextDisplayType(directionIsUp: true, movement: viewModel.translationHeight+1)
                } else {
                    viewModel.lastMovement = .up
                    nextDisplayType(directionIsUp: false, movement: -(viewModel.translationHeight+1))
                }
            }
        }
    }
    
    public var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    self.topHeader.topView
                        .frame(height: self.topHeader.height)
                        .opacity((self.offset + self.translation > self.topHeader.minVisibleOffset) && displayType != BottomSheetDisplayType.hidden ? 1 : 0)
                    VStack(spacing: 0) {
                        if !viewModel.disableDragIndicatorView {
                            HStack(spacing: 0) {
                                ZStack {
                                    if let leftView = self.leftDragView {
                                        leftView
                                    }
                                }.frame(width: 150)
                                Spacer()
                                VStack(spacing: 0) {
                                    Spacer().frame(height: viewModel.dragIndicatorConfig.dragIndicatorTopPadding)
                                    self.indicator
                                    Spacer().frame(height: viewModel.dragIndicatorConfig.dragIndicatorBottomPadding)
                                }.onTapGesture {
                                    if !viewModel.disableDragIndicatorTapGesture {
                                        nextDisplayType()
                                    }
                                }
                                Spacer()
                                ZStack {
                                    if let rightView = self.rightDragView {
                                        rightView
                                    }
                                }.frame(width: 150)
                            }.padding(.horizontal, 8)
                        }
                        self.header.id("APP_BOTTOM_SHEET_HEADER")
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: HeaderHeightKey.self, value: geometry.size.height)
                            })
                        self.content
                            .id("APP_BOTTOM_SHEET_CONTENT")
                            .opacity(displayType == .collapsed ? 0 : 1)
                        
                        Spacer().frame(height: viewModel.bottomSheetPadding)
                        Spacer()
                    }
                        .background(viewModel.dragIndicatorConfig.backgroundColor)
                        .cornerRadius(viewModel.dragIndicatorConfig.topCornerRadius, corners: [.topLeft, .topRight])
                }.padding(geometry.safeAreaInsets)
                    .onPreferenceChange(HeaderHeightKey.self) { height in
                        self.headerHeight = viewModel.headerHeight ?? height
                    }
                    .opacity(displayType == .hidden ? 0 : 1)
                    .frame(width: geometry.size.width, height: viewModel.maxHeight, alignment: .bottom)
                    
                    .offset(y: self.offset + self.translation > 60 ? self.offset + self.translation : 60)
                
                    .frame(height: geometry.size.height, alignment: .bottom)
                    .animation(.bouncy())
                    .gesture(
                        DragGesture().updating(self.$translation) { value, state, _ in
                            state = value.translation.height
                            let topOffset = self.offset + self.translation > 60 ? self.offset + self.translation : 60
                            delegate?.updateOffset(offset: topOffset)

                        }.onEnded { value in
                            if value.translation.height < -viewModel.translationHeight {
                                nextDisplayType(directionIsUp: true, movement: value.translation.height)
                            } else if value.translation.height > viewModel.translationHeight {
                                nextDisplayType(directionIsUp: false, movement: value.translation.height)
                            }
                            let topOffset = self.offset + self.translation > 60 ? self.offset + self.translation : 60
                            delegate?.updateOffset(offset: topOffset)
                        }
                    )
            }.onAppear {
                let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                safeAreaInsets = EdgeInsets(top: keyWindow?.safeAreaInsets.top ?? 0,
                                            leading: keyWindow?.safeAreaInsets.left ?? 0,
                                            bottom: keyWindow?.safeAreaInsets.bottom ?? 0,
                                            trailing: keyWindow?.safeAreaInsets.right ?? 0)
                viewModel.maxHeight = UIScreen.main.bounds.height
            }
        }
    }
    
    private func getOffsetValue(type: BottomSheetDisplayType) -> Double {
        let defaultTop = Double(safeAreaInsets.top)
        let dragHeightFromComponent = viewModel.dragIndicatorConfig.dragIndicatorTopPadding + viewModel.dragIndicatorConfig.dragIndigatorSize.height
//        viewModel.dragIndicatorConfig.dragIndicatorBottomPadding
        let dragHeight: Double = viewModel.disableDragIndicatorView ? 0 : dragHeightFromComponent
        switch type {
        case .collapsed:
            let offset =  viewModel.maxHeight - headerHeight - viewModel.bottomSheetPadding - defaultTop - dragHeight
            return (offset < defaultTop ? defaultTop : offset) - self.topHeader.height
        case .expanded:
            return defaultTop - self.topHeader.height
        case .expandFromTop(let topOffset) :
            let offset =  topOffset - viewModel.bottomSheetPadding - dragHeight - defaultTop
            return (offset < defaultTop ? defaultTop : offset) - self.topHeader.height
        case .expandFromBottom(let bottomHeight) :
            let offset = viewModel.maxHeight - headerHeight - bottomHeight - viewModel.bottomSheetPadding - defaultTop - dragHeight
            return (offset < defaultTop ? defaultTop : offset)
        case .hidden :
            return UIScreen.main.bounds.height * 1.5
        }
    }
    
    private func nextDisplayType(directionIsUp: Bool, movement: Double) {
        var steps = viewModel.steps
        let distances = steps.map { type in
            return getOffsetValue(type: type)
        }
        
        if directionIsUp {
            if steps.isEmpty {
                if !viewModel.disableDragToExpanded {
                    displayType = .expanded
                }
            } else if let type = nearestUp(distances: distances, movement: movement) {
                displayType = type
            }
            
        } else {
            if  displayType == .collapsed {
                if !viewModel.disableDragToHideSheet {
                    displayType = .hidden
                }
            } else if let type = nearestDown(distances: distances, movement: movement) {
                displayType = type
            }
            
        }
    }
    
    private func nearestUp(distances: [Double], movement: Double) -> BottomSheetDisplayType? {
        viewModel.lastMovement = .up
        let currentOffset = getOffsetValue(type: displayType)
        let upDistances = distances.filter({$0 < currentOffset})
        let finalOffset = offset + movement
        if finalOffset <= 0 && !viewModel.disableDragToExpanded {
            return BottomSheetDisplayType.expanded
        } else if let nearestDistance = upDistances.nearestValue(target: finalOffset) {
            return .expandFromTop(nearestDistance)
        }
        return nil
    }
    
    private func nearestDown(distances: [Double], movement: Double) -> BottomSheetDisplayType? {
    
        viewModel.lastMovement = .down
        let currentOffset = getOffsetValue(type: displayType) + 60
        let downDistances = distances.filter({$0 > currentOffset})
        let finalOffset = currentOffset + movement
        if finalOffset >= viewModel.maxHeight {
            if viewModel.disableDragToHideSheet  {
                return BottomSheetDisplayType.collapsed
            } else {
                return BottomSheetDisplayType.hidden
            }
        } else if let nearestDistance = downDistances.nearestValue(target: finalOffset) {
            let collapsedTop = getOffsetValue(type: .collapsed)
            if finalOffset > collapsedTop {
                return BottomSheetDisplayType.collapsed
            }
            return .expandFromTop(nearestDistance)
        }
        
        if displayType != .collapsed {
            return BottomSheetDisplayType.collapsed
        }
        
        return nil
    }
    
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        if nextValue() > 0 {
            value = nextValue()
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
            disableDragIndicatorView: false, 
            dragIndicatorConfig: BottomSheetConfiguration(backgroundColor: .green)),
                           rightDragView: AnyView(ZStack{}.frame(width: 5, height: 5).background(Color.red)
        )) {
//            VStack {
//                
//                VStack {
//                    Color.yellow.padding(.bottom, 4)
//                }.frame(height: 100)
//                .background(Color.white)
//                Spacer()
//            } .background(Color.purple)
                
        } header: {
            ZStack {
                Color.blue
                    .padding(.bottom, 4)
            }.frame(height: 180)
                .background(Color.red)
        }
    }

}
