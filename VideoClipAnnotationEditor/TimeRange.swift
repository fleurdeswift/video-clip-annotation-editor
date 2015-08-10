//
//  TimeRange.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public struct TimeRange {
    public var start:  NSTimeInterval;
    public var length: NSTimeInterval;

    public init(start: NSTimeInterval, length: NSTimeInterval) {
        self.start  = start;
        self.length = length;
    }

    public init(start: NSTimeInterval, end: NSTimeInterval) {
        self.start  = start;
        self.length = end - start;
    }
    
    public func contains(t: NSTimeInterval) -> Bool {
        return (t >= start) && (t < end);
    }

    public func intersects(range2: TimeRange) -> Bool {
        return (self.start < range2.start + range2.length && range2.start < self.start + self.length);
    }
    
    public func intersection(range2: TimeRange) -> TimeRange {
        let max1   = self.start + self.length;
        let max2   = range2.start + range2.length;
        let minend = (max1 < max2) ? max1 : max2;
        
        if range2.start <= self.start && self.start < max2 {
            return TimeRange(start: self.start, length: minend - self.start);
        }
        else if self.start <= range2.start && range2.start < max1 {
            return TimeRange(start: range2.start, length: minend - range2.start);
        }
        
        return TimeRange(start: -1, length: 0);
    }
    
    public var isValid: Bool {
        get {
            return start >= 0 && length > 0;
        }
    }
    
    public var end: NSTimeInterval {
        get {
            return start + length;
        }
    }
}
