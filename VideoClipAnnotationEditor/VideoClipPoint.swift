//
//  VideoClipPointà.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public struct VideoClipPoint {
    public let clip: VideoClip;
    public let time: NSTimeInterval;
    
    public init(clip: VideoClip, time: NSTimeInterval) {
        self.clip = clip;
        self.time = time;
    }
}

public struct VideoClipRange {
    public let clip: VideoClip;
    public let time: TimeRange;

    public init(clip: VideoClip, time: TimeRange) {
        self.clip = clip;
        self.time = time;
    }
}
