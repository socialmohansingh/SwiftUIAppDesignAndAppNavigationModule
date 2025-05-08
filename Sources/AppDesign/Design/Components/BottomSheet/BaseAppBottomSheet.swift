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
    func updateOffset(offset: CGFloat, velocity: CGSize)
    func lastOffset(offset: CGFloat, velocity: CGSize)
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
    @State private var lastScrollContentOffset: CGFloat = 0
    @State private var safeAreaInsets = EdgeInsets()
    @State private var contentScrolling = false
    @GestureState private var translation: CGFloat = 0
    
    @State private var isScrollViewAtTop: Bool = true
    @State private var isScrollViewAtBottom: Bool = false
    @State private var isScrollEnabled: Bool = true
    
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
        
       
        UIScrollView.appearance().bounces = false
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
        ZStack {
            VStack {
                Spacer()
                if self.offset + self.translation <= self.topHeader.minVisibleOffset {
                    viewModel.dragIndicatorConfig.backgroundColor .frame(height: self.topHeader.height + 100)
                }
            }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                Spacer()
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        self.topHeader.topView
                            .frame(height: self.topHeader.height)
                            .opacity((self.offset + self.translation > self.topHeader.minVisibleOffset) && displayType != BottomSheetDisplayType.hidden ? 1 : 0)
                        ZStack(alignment: .topLeading) {
                            VStack(spacing: 0) {
                                if !viewModel.disableDragIndicatorView {
                                    HStack(spacing: 0) {
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
                                    }.padding(.horizontal, 8)
                                        .contentShape(Rectangle())
                                        .gesture(viewModel.enableDrag ? dragGesture(forContentView: false) : nil)
                                }
                                self.header
                                    .id("APP_BOTTOM_SHEET_HEADER")
                                    .background(GeometryReader { geometry in
                                        Color.clear.preference(key: HeaderHeightKey.self, value: geometry.size.height)
                                    })
                                    .contentShape(Rectangle())
                                    .gesture(viewModel.enableDrag ? dragGesture(forContentView: false) : nil)
                                
                                ScrollViewWithDelegate(isScrollEnabled: $isScrollEnabled) {
                                    VStack(spacing: 0) {
                                        ZStack{
                                            Spacer().frame(height: 0.01)
                                            HStack {
                                                Spacer().frame(height: 0.01)
                                            }
                                        }.frame(width: geometry.size.width)
                                        .id("APP_BOTTOM_SHEET_CONTENT_TOP")
                                        self.content
                                            .id("APP_BOTTOM_SHEET_CONTENT")
                                            .opacity(displayType == .collapsed ? 0 : 1)
                                        
                                        Spacer().frame(height: viewModel.bottomSheetPadding)
                                        Spacer()
                                        Spacer().frame(height: 0.01)
                                            .id("APP_BOTTOM_SHEET_CONTENT_BOTTOM")
                                    } .background(viewModel.dragIndicatorConfig.backgroundColor)
                                    
                                } onScrollEnd: { offset, scrollView, contentSize in
                                    scrollViewProertiesAfterAnimationEnd(offset, scrollView, contentSize)
                                }
                                .simultaneousGesture(
                                    viewModel.enableDrag ?  dragGesture(forContentView: true) : nil
                                )
                            }
                            
                            .background(viewModel.dragIndicatorConfig.backgroundColor)
                            .cornerRadius(viewModel.dragIndicatorConfig.topCornerRadius, corners: [.topLeft, .topRight])
                            .background(
                                VStack {
                                    Rectangle()
                                        .fill(viewModel.dragIndicatorConfig.backgroundColor)
                                        .cornerRadius(viewModel.dragIndicatorConfig.topCornerRadius, corners: [.topLeft, .topRight])
                                        .frame(height: 100)
                                        .shadow(radius: 6, y: 4)
                                    Spacer()
                                }
                            )
                           
                            
                            VStack {
                                HStack(spacing: 0) {
                                    ZStack {
                                        if let leftView = self.leftDragView {
                                            leftView
                                        }
                                    }.frame(width: 150)
                                    Spacer()
                                    ZStack {
                                        if let rightView = self.rightDragView {
                                            rightView
                                        }
                                    }.frame(width: 150)
                                }.padding(.horizontal, 8)
                                Spacer()
                            }
                        }
                    }
                    .padding(geometry.safeAreaInsets)
                    .onPreferenceChange(HeaderHeightKey.self) { height in
                        self.headerHeight = viewModel.headerHeight ?? height
                    }
                    .opacity(displayType == .hidden ? 0 : 1)
                    .frame(width: geometry.size.width, height: viewModel.maxHeight, alignment: .bottom)
                    
                    .offset(y: self.offset + self.translation > 60 - self.topHeader.height ? self.offset + self.translation : 60 - self.topHeader.height)
                    .frame(height: geometry.size.height, alignment: .bottom)
                    .animation(.bouncy())
                    
                }
                .onAppear {
                    let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                    safeAreaInsets = EdgeInsets(top: keyWindow?.safeAreaInsets.top ?? 0,
                                                leading: keyWindow?.safeAreaInsets.left ?? 0,
                                                bottom: keyWindow?.safeAreaInsets.bottom ?? 0,
                                                trailing: keyWindow?.safeAreaInsets.right ?? 0)
                    viewModel.maxHeight = UIScreen.main.bounds.height
                }
            }
        }
    }
    
    private func dragGesture(forContentView: Bool) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .updating(self.$translation) { value, state, _ in
                if forContentView && !isScrollViewAtTop && value.translation.height > 0 {
                    contentScrolling = true
                    return
                } else if forContentView && !isScrollViewAtBottom && value.translation.height < 0 {
                    contentScrolling = true
                    return
                } else {
                    if contentScrolling {
                        return
                    }
                    state = value.translation.height
                    let topOffset = self.offset + self.translation > 60 ? self.offset + self.translation : 60
                    
                    delegate?.updateOffset(offset: topOffset, velocity: value.velocity)
                }
            }.onEnded { value in
                if !contentScrolling {
                    if value.translation.height < -viewModel.translationHeight {
                        nextDisplayType(directionIsUp: true, movement: value.translation.height)
                    } else if value.translation.height > viewModel.translationHeight {
                        nextDisplayType(directionIsUp: false, movement: value.translation.height)
                    }
                    let topOffset = self.offset + self.translation > 60 ? self.offset + self.translation : 60
                    delegate?.lastOffset(offset: topOffset, velocity: value.velocity)
                }
                
                contentScrolling = false
            }
    }
    
    private func getOffsetValue(type: BottomSheetDisplayType) -> Double {
        let defaultTop = Double(safeAreaInsets.top)
        let dragHeightFromComponent = viewModel.dragIndicatorConfig.dragIndicatorTopPadding + viewModel.dragIndicatorConfig.dragIndigatorSize.height
        
        let dragHeight: Double = viewModel.disableDragIndicatorView ? 0 : dragHeightFromComponent
        switch type {
        case .collapsed:
            let offset =  viewModel.maxHeight - headerHeight - viewModel.bottomSheetPadding - defaultTop - dragHeight
            return (offset < defaultTop ? defaultTop : offset) - self.topHeader.height
        case .fullyCollapsed:
            let offset =  viewModel.maxHeight - headerHeight - viewModel.bottomSheetPadding - defaultTop
            return (offset < defaultTop ? defaultTop : offset)
        case .expanded:
            return defaultTop - self.topHeader.height
        case .expandFromTop(let topOffset) :
            let offset =  topOffset - viewModel.bottomSheetPadding - dragHeight - defaultTop
            return (offset < defaultTop ? defaultTop : offset) - self.topHeader.height
        case .expandFromBottom(let bottomHeight) :
            let offset = viewModel.maxHeight - headerHeight - bottomHeight - viewModel.bottomSheetPadding - defaultTop - dragHeight
            return (offset < defaultTop ? defaultTop : offset)
        case .hidden :
            return UIScreen.main.bounds.height + 15.0
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
        let finalOffset = currentOffset + movement
       
        if ((finalOffset <= 0 && !viewModel.disableDragToExpanded) || (!viewModel.disableDragToExpanded && upDistances.isEmpty)){
            return BottomSheetDisplayType.expanded
        } else if let nearestDistance = upDistances.nearestValue(target: finalOffset) {
            return .expandFromTop(nearestDistance)
        }
        return nil
    }
    
    private func nearestDown(distances: [Double], movement: Double) -> BottomSheetDisplayType? {
        
        viewModel.lastMovement = .down
        let currentOffset = getOffsetValue(type: displayType) + 70
        let downDistances = distances.filter({$0 > currentOffset})
        let finalOffset = currentOffset + movement
        
        if finalOffset + self.topHeader.height >= viewModel.maxHeight {
            if viewModel.disableDragToHideSheet  {
                return !viewModel.disableDragToFullyCollapsed ? BottomSheetDisplayType.fullyCollapsed : BottomSheetDisplayType.collapsed
            } else {
                return BottomSheetDisplayType.hidden
            }
        }
        else if let nearestDistance = downDistances.nearestValue(target: finalOffset) {
            let collapsedTop = getOffsetValue(type: .collapsed)
            if finalOffset > collapsedTop {
                return BottomSheetDisplayType.collapsed
            }
            return .expandFromTop(nearestDistance)
        }
        
        if displayType == .collapsed {
            return BottomSheetDisplayType.fullyCollapsed
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
    
    func scrollViewProertiesAfterAnimationEnd(_ offset: CGPoint, _ scrollFrame: CGRect, _ contentSize: CGSize) {
        let bottom = contentSize.height - scrollFrame.height - offset.y
        
//        print("Scroll momentum ended! Content offset: \(offset) and size: \(contentSize) bottom: \(bottom)")
        
        if offset.y <= 0 {
            isScrollViewAtTop = true
        } else {
            isScrollViewAtTop = false
        }
        
        
        if bottom <= 0 {
            isScrollViewAtBottom = true
        } else {
            isScrollViewAtBottom = false
        }
        
        isScrollEnabled = isScrollViewAtTop && isScrollViewAtBottom
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

struct SampleView: View {
    @State var displayType: BottomSheetDisplayType = .fullyCollapsed
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            Button("Title") {
                print("asdf")
            }
            AppBottomSheetView(displayType: $displayType, viewModel: BaseAppBottomSheetViewModel(
                disableDragIndicatorView: false,
                dragIndicatorConfig: BottomSheetConfiguration(backgroundColor: .green)),
                               rightDragView: AnyView(ZStack{}.frame(width: 5, height: 5).background(Color.red)
                                                     )) {
                VStack {
                    Text("Hello, World!")
                    VStack {
                        Text("Hello, World!>>").frame(height: 60)
                        Color.yellow.padding(.bottom, 4)
                    }.frame(height: 906)
                        .background(Color.white)
                    Text("Hello, World!")
                    Spacer()
                    Text("LAST")
                } .background(Color.purple)
                
            } header: {
                ZStack {
                    Color.blue
                        .padding(.bottom, 4)
                }.frame(height: 122)
                    .background(Color.red)
            }
        }
    }
}


#Preview {
    ZStack {
        Color.orange.edgesIgnoringSafeArea(.all)
        Button("Title") {
            print("asdf")
        }
        AppBottomSheetView(displayType: .constant(.fullyCollapsed), viewModel: BaseAppBottomSheetViewModel(
            disableDragIndicatorView: false,
            dragIndicatorConfig: BottomSheetConfiguration(backgroundColor: .green)),
                           rightDragView: AnyView(ZStack{}.frame(width: 5, height: 5).background(Color.red)
                                                 )) {
            VStack {
                Text("Hello, World!")
                VStack {
                    Text("Hello, World!>>").frame(height: 60)
                    Color.yellow.padding(.bottom, 4)
                }.frame(height: 906)
                    .background(Color.white)
                Text("Hello, World!")
                Spacer()
                Text("LAST")
            } .background(Color.purple)
            
        } header: {
            ZStack {
                Color.blue
                    .padding(.bottom, 4)
            }.frame(height: 122)
                .background(Color.red)
        }
    }
}

