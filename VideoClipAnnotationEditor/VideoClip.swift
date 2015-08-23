//
//  VideoClip.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public protocol VideoClip : class {
    var duration:     NSTimeInterval        { get };
    var annotations:  [VideoClipAnnotation] { get };
    var previewWidth: Int                   { get };

    func imageAtTime(time: NSTimeInterval, completionBlock: (image: CGImageRef?, error: NSError?) -> NSTimeInterval);
}
