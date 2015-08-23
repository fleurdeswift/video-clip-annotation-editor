//
//  VideoClipAnnotation.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraDataStructures

public protocol VideoClipAnnotation : class {
    var text:  String                   { get };
    var color: VideoClipAnnotationColor { get };
    var time:  TimeRange                { get set };
}
