//
//  AdaptiveSize.swift
//  
//
//  Created by Mohan Singh Thagunna on 27/02/2024.
//

import Foundation
import UIKit

extension Int {
    public var w: Double {
        return Double(self).w
    }
    
    public var h: Double {
        return Double(self).h
    }
    
    public var sp: Double {
        return Double(self).sp
    }
}

extension Double {
    public var w: Double {
        return self * UIScreen.main.bounds.size.width / AppDesign.defaultScreenDesignSize.width
    }
    
    public var h: Double {
        return self * UIScreen.main.bounds.size.height / AppDesign.defaultScreenDesignSize.height
    }
    
    public var sp: Double {
        return self
    }
}
