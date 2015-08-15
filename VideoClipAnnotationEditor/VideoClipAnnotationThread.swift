//
//  VideoClipAnnotationThread.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

internal class VideoClipAnnotationThread {
    var blocks: [(position: NSRange, clip: VideoClip, annotation: VideoClipAnnotation, edge: EdgeType)] = [];

    init() {
    }
    
    func reserveAnnotation(clip: VideoClip, annotation: VideoClipAnnotation, position: NSRange, edge: EdgeType) -> Bool {
        for block in blocks {
            if NSIntersectionRange(block.position, position).length > 0 {
                return false;
            }
        }
        
        blocks.append((position, clip, annotation, edge));
        return true;
    }
}
