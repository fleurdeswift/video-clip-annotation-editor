//
//  VideoClipDelegate.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public protocol VideoClipDelegate : class {
    func currentTimeChanged(videoClipView: VideoClipView, point: VideoClipPoint?);
    func selectionChanged(videoClipView: VideoClipView, range: VideoClipRange?)
}

@objc
public protocol VideoClipDelegateIB {
}
