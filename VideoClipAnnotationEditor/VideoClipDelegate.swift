//
//  VideoClipDelegate.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public protocol VideoClipDelegate : class {
    func currentTimeChanged(videoClipView: VideoClipView, point: VideoClipPoint?, event: NSEvent?);
    func selectionChanged(videoClipView: VideoClipView, range: VideoClipRange?)
    func selectionChanged(videoClipView: VideoClipView, annotations: Set<HashAnnotation>?)
}

@objc
public protocol VideoClipDelegateIB {
}
