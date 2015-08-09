//
//  VideoClipLineEntry.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraAppKit

internal class VideoClipLineEntry {
    var clip:     VideoClip;
    var time:     TimeRange;
    var position: NSRange;
    
    init(clip: VideoClip, time: TimeRange, position: NSRange) {
        assert(time.length > 0);
        self.clip     = clip;
        self.time     = time;
        self.position = position;
    }
    
    func location(t: NSTimeInterval) -> CGFloat {
        return CGFloat(position.location) + CGFloat(NSTimeInterval(position.length) / time.length * (t - time.start));
    }

    func position(t: TimeRange) -> NSRange {
        return NSRange(start: location(t.start), end: location(t.end));
    }
}
