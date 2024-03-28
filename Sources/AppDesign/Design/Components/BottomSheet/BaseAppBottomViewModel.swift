//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 29/02/2024.
//

import Foundation
import SwiftUI

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

public class BaseAppBottomSheetViewModel: ObservableObject {
    @Published public var steps: [BottomSheetDisplayType]
    @Published public var maxHeight: CGFloat
    @Published public var headerHeight: CGFloat? = nil
    @Published public var bottomSheetPadding: CGFloat
    @Published public var translationHeight: CGFloat
    @Published public var disableDragIndicatorView: Bool
    @Published public var disableDragToHideSheet: Bool
    @Published public var disableDragToExpanded: Bool
    @Published public var disableDragIndicatorTapGesture: Bool
    @Published public var disableUpdateDisplayType: Bool
    @Published public var dragIndicatorConfig: BottomSheetConfiguration
    @Published public var lastMovement: SlideMovement = .up
    
    public init(steps: [BottomSheetDisplayType] = [],
                maxHeight: CGFloat = UIScreen.main.bounds.height - 60,
                headerHeight: CGFloat? = nil,
                bottomSheetPadding: CGFloat = 0,
                translationHeight: CGFloat = 100,
                disableDragToHideSheet: Bool = false,
                disableDragToExpanded: Bool = false,
                disableDragIndicatorView: Bool = false,
                disableDragIndicatorTapGesture: Bool = false,
                disableUpdateDisplayType: Bool = false,
                dragIndicatorConfig: BottomSheetConfiguration = BottomSheetConfiguration()
    ) {
        self.steps = steps
        self.maxHeight = UIScreen.main.bounds.height - 60
        self.translationHeight = translationHeight
        self.disableDragToHideSheet = disableDragToHideSheet
        self.disableDragToExpanded = disableDragToExpanded
        self.disableDragIndicatorView = disableDragIndicatorView
        self.dragIndicatorConfig = dragIndicatorConfig
        self.disableDragIndicatorTapGesture = disableDragIndicatorTapGesture
        self.bottomSheetPadding = bottomSheetPadding
        self.headerHeight = headerHeight
        self.disableUpdateDisplayType = disableUpdateDisplayType
    }
}

public class BottomSheetConfiguration: ObservableObject {
    
    public var backgroundColor: Color
    public var dragIndigatorSize: CGSize
    public var dragIndicatorColor: Color
    public var dragIndicatorTopPadding: Double
    public var dragIndicatorBottomPadding: Double
    public var topCornerRadius: Double
    
    public init(backgroundColor: Color = .white,
                dragIndigatorSize: CGSize = CGSizeMake(60, 6),
                dragIndicatorColor: Color = Color.gray,
                dragIndicatorTopPadding: Double = 12,
                dragIndicatorBottomPadding: Double = 12,
                topCornerRadius: Double = 16) {
        self.backgroundColor = backgroundColor
        self.dragIndigatorSize = dragIndigatorSize
        self.dragIndicatorColor = dragIndicatorColor
        self.dragIndicatorTopPadding = dragIndicatorTopPadding
        self.dragIndicatorBottomPadding = dragIndicatorBottomPadding
        self.topCornerRadius = topCornerRadius
    }
}
