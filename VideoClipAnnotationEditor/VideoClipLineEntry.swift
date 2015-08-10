//
//  VideoClipLineEntry.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraAppKit

public func clamp<T : Comparable>(value: T, _ min: T, _ max: T) -> T {
    if value < min {
        return min;
    }
    else if value > max {
        return max;
    }
    
    return value;
}

public func between<T : Comparable>(value: T, _ min: T, _ max: T) -> Bool {
    return value >= min && value <= max;
}

internal class VideoClipLineEntry {
    var clip:     VideoClip;
    var time:     TimeRange;
    var position: NSRange;
    var edge:     EdgeType = .Complete;
    
    init(clip: VideoClip, time: TimeRange, position: NSRange, edge: EdgeType) {
        assert(time.length > 0);
        self.clip     = clip;
        self.time     = time;
        self.position = position;
        self.edge     = edge;
    }
    
    func position(t: NSTimeInterval) -> CGFloat {
        return CGFloat(position.location) + clamp(CGFloat(NSTimeInterval(position.length) / time.length * (t - time.start)), 0, CGFloat(position.length));
    }

    func position(t: TimeRange) -> NSRange {
        return NSRange(start: position(t.start), end: position(t.end));
    }

    func positionInView(t: NSTimeInterval) -> CGFloat {
        return clamp(CGFloat(NSTimeInterval(position.length) / time.length * (t - time.start)), 0, CGFloat(position.length));
    }

    func positionInView(t: TimeRange) -> NSRange {
        return NSRange(start: positionInView(t.start), end: positionInView(t.end));
    }

    func positionInViewUnclampled(t: NSTimeInterval) -> CGFloat {
        return CGFloat(NSTimeInterval(position.length) / time.length * (t - time.start));
    }

    func positionInViewUnclampled(t: TimeRange) -> NSRange {
        return NSRange(start: positionInViewUnclampled(t.start), end: positionInViewUnclampled(t.end));
    }
    
    func time(x: CGFloat) -> NSTimeInterval {
        return time.start + clamp(NSTimeInterval(CGFloat(time.length) * (x - CGFloat(position.location)) / CGFloat(position.length)), 0, time.length);
    }
    
    func time(t: NSRange) -> TimeRange {
        return TimeRange(
            start: time(CGFloat(t.location)),
            end:   time(CGFloat(t.location + t.length)));
    }
}
