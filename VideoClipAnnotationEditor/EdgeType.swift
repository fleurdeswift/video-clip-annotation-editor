//
//  EdgeType.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraDataStructures

public enum EdgeType {
    case Complete, Partial, Start, End
}

public let NSTimeThreshold: NSTimeInterval = 1.0 / 60.0;

public extension TimeRange {
    public func edge(sub: TimeRange) -> EdgeType {
        if abs(start - sub.start) < NSTimeThreshold {
            if abs(self.end - sub.end) < NSTimeThreshold {
                return .Complete;
            }
            
            return .Start;
        }
        else if abs(self.end - sub.end) < NSTimeThreshold {
            return .End;
        }
        
        return .Partial;
    }
}
