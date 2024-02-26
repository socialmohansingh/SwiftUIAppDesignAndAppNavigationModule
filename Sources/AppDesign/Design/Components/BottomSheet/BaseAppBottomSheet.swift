//
//  AppBottomSheet.swift
//
//
//  Created by Mohan Singh Thagunna on 26/02/2024.
//

import SwiftUI

import SwiftUI

public class BottomSheetConfiguration: ObservableObject {
    
    public var backgroundColor: Color
    public var dragIndigatorSize: CGSize
    public var dragIndicatorColor: Color
    public var dragIndicatorTopPadding: Double
    public var topCornerRadius: Double
    
    public init(backgroundColor: Color = .white,
                dragIndigatorSize: CGSize = CGSizeMake(60, 6),
                dragIndicatorColor: Color = Color.gray,
                dragIndicatorTopPadding: Double = 12,
                topCornerRadius: Double = 16) {
        self.backgroundColor = backgroundColor
        self.dragIndigatorSize = dragIndigatorSize
        self.dragIndicatorColor = dragIndicatorColor
        self.dragIndicatorTopPadding = dragIndicatorTopPadding
        self.topCornerRadius = topCornerRadius
    }
}

public enum BottomSheetDisplayType: Equatable {
    case expanded
    case expandFromTop(Double)
    case expandFromBottom(Double)
    case collapsed
    case hidden
}

public enum SlideMovement {
    case up, down
}

public class BaseAppButtomSheetViewModel: ObservableObject {
    @Published public var steps: [BottomSheetDisplayType]
    @Published public var maxHeight: CGFloat
    @Published public var translationHeight: CGFloat
    @Published public var disableDragIndicatorView: Bool
    @Published public var disableDragToHideSheet: Bool
    @Published public var disableDragToExpanded: Bool
    @Published public var disableDragIndicatorTapGesture: Bool
    @Published public var dragIndicatorConfig: BottomSheetConfiguration
    @Published public var lastMovement: SlideMovement = .up
    
    public init(steps: [BottomSheetDisplayType] = [],
                maxHeight: CGFloat = UIScreen.main.bounds.height - 60,
                translationHeight: CGFloat = 100,
                disableDragToHideSheet: Bool = false,
                disableDragToExpanded: Bool = false,
                disableDragIndicatorView: Bool = false,
                disableDragIndicatorTapGesture: Bool = false,
                dragIndicatorConfig: BottomSheetConfiguration = BottomSheetConfiguration()
    ) {
        self.steps = steps
        self.maxHeight = maxHeight > UIScreen.main.bounds.height - 60 ? UIScreen.main.bounds.height - 60 : maxHeight
        self.translationHeight = translationHeight
        self.disableDragToHideSheet = disableDragToHideSheet
        self.disableDragToExpanded = disableDragToExpanded
        self.disableDragIndicatorView = disableDragIndicatorView
        self.dragIndicatorConfig = dragIndicatorConfig
        self.disableDragIndicatorTapGesture = disableDragIndicatorTapGesture
    }
}

public struct BaseAppButtomSheet<Header: View, Content: View>: View {
    @Binding var displayType: BottomSheetDisplayType
    @ObservedObject var viewModel: BaseAppButtomSheetViewModel
    let content: Content
    let header: Header
    
    @State private var headerHeight: CGFloat = 80
    @GestureState private var translation: CGFloat = 0
    
    //MARK:- Offset from top edge
    private var offset: CGFloat {
        switch displayType {
        case .collapsed:
            return viewModel.maxHeight - headerHeight
        case .expanded :
            return 0
        case .expandFromTop(let topOffset) :
            return topOffset
        case .expandFromBottom(let bottomHeight) :
            let offset = viewModel.maxHeight - headerHeight - bottomHeight
            return offset < 0 ? 0 : offset
        case .hidden :
            return viewModel.maxHeight
        }
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: viewModel.dragIndicatorConfig.topCornerRadius)
            .fill(viewModel.dragIndicatorConfig.dragIndicatorColor)
            .frame(
                width: viewModel.dragIndicatorConfig.dragIndigatorSize.width,
                height: viewModel.dragIndicatorConfig.dragIndigatorSize.height
            ).onTapGesture {
                if !viewModel.disableDragIndicatorTapGesture {
                    nextDisplayType()
                }
            }
    }
    
    public func nextDisplayType() {
        if viewModel.lastMovement == .up {
            if displayType == .expanded {
                nextDisplayType(directionIsUp: false, movement: viewModel.translationHeight+1)
            } else {
                nextDisplayType(directionIsUp: true, movement: -(viewModel.translationHeight+1))
            }
            
        } else if viewModel.lastMovement == .down {
            if displayType == .collapsed {
                nextDisplayType(directionIsUp: true, movement: viewModel.translationHeight+1)
            } else {
                nextDisplayType(directionIsUp: false, movement: -(viewModel.translationHeight+1))
            }
        }
    }
    
    public init(displayType: Binding<BottomSheetDisplayType>,
                viewModel: BaseAppButtomSheetViewModel = BaseAppButtomSheetViewModel(),
                @ViewBuilder content: () -> Content,
                @ViewBuilder header: () -> Header) {
        self.viewModel = viewModel
        self.content = content()
        self.header = header()
        self._displayType = displayType
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !viewModel.disableDragIndicatorView {
                    self.indicator.padding()
                }
                self.header.id("APP_BOTTOM_SHEET_HEADER")
                    .background(GeometryReader { geometry in
                        Color.clear.preference(key: HeaderHeightKey.self, value: geometry.size.height)
                    })
                self.content.id("APP_BOTTOM_SHEET_CONTENT")
            }
            .onPreferenceChange(HeaderHeightKey.self) { height in
                self.headerHeight = height
            }
            .frame(width: geometry.size.width, height: viewModel.maxHeight, alignment: .top)
            .background(viewModel.dragIndicatorConfig.backgroundColor)
            .cornerRadius(viewModel.dragIndicatorConfig.topCornerRadius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, -30))
            .animation(.bouncy(extraBounce: 0.15))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    if value.translation.height < -viewModel.translationHeight {
                        nextDisplayType(directionIsUp: true, movement: value.translation.height)
                    } else if value.translation.height > viewModel.translationHeight {
                        nextDisplayType(directionIsUp: false, movement: value.translation.height)
                    }
                }
            )
        }
    }
    
    private func nextDisplayType(directionIsUp: Bool, movement: Double) {
        let steps = viewModel.steps
        let distances = steps.map { type in
            switch type {
            case .expanded:
                return 0.0
            case .collapsed:
                return viewModel.maxHeight - headerHeight
            case .hidden:
                return viewModel.maxHeight
            case .expandFromBottom(let value):
                let offset = viewModel.maxHeight - headerHeight - value
                return offset < 0 ? 0 : offset
            case .expandFromTop(let value):
                return value
            }
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
        let upDistances = distances.filter({$0 < offset})
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
        let downDistances = distances.filter({$0 > offset})
        let finalOffset = offset + movement
        if finalOffset >= viewModel.maxHeight && !viewModel.disableDragToHideSheet {
            return BottomSheetDisplayType.hidden
        } else if let nearestDistance = downDistances.nearestValue(target: finalOffset) {
            return .expandFromTop(nearestDistance)
        }
        
        if displayType != .collapsed {
            return BottomSheetDisplayType.collapsed
        }
        
        return nil
        
        
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}


struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
