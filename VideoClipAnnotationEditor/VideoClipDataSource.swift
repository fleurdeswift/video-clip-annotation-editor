//
//  VideoClipDataSource.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public protocol VideoClipDataSource : class {
    var clips:         [VideoClip]    { get };
    var previewHeight: Int            { get };
    var sampleRate:    NSTimeInterval { get };
}

@objc
public protocol VideoClipDataSourceIB {
}
