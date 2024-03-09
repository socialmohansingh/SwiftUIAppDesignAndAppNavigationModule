//
//  ViewExtension.swift
//
//
//  Created by Mohan Singh Thagunna on 27/02/2024.
//

import Foundation
import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    /// Add Corner radius in a specific cornor
    /// - Parameters:
    ///   - radius: Corner radius value
    ///   - corners: Corners of the view
    /// - Returns: it returns the new updated view
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    public func flipX(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 1.0, y: 0.0, z: 0.0))
    }
    
    public func flipY(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}
