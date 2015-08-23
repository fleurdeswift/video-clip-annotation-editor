//
//  VideoClipLine.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraDataStructures

internal class VideoClipLine {
    var threads: [VideoClipAnnotationThread] = [];
    var entries: [VideoClipLineEntry]        = [];
    
    func placeAnnotation(clip: VideoClip, annotation: VideoClipAnnotation, position: NSRange, edge: EdgeType) -> VideoClipAnnotationThread {
        for thread in threads {
            if thread.reserveAnnotation(clip, annotation: annotation, position: position, edge: edge) {
                return thread;
            }
        }
        
        let newThread = VideoClipAnnotationThread();
        
        newThread.reserveAnnotation(clip, annotation: annotation, position: position, edge: edge);
        threads.append(newThread);
        return newThread;
    }
    
    func placeClip(clip: VideoClip, time: TimeRange, position: NSRange, previewConfig: VideoClipPreviewConfiguration) -> VideoClipLineEntry {
        let full  = TimeRange(start: 0, end: clip.duration);
        let entry = VideoClipLineEntry(clip: clip, time: time, position: position, edge: full.edge(time), previewConfig: previewConfig);
        
        entries.append(entry);
        
        for annotation in clip.annotations {
            let intersect = time.intersection(annotation.time);
            
            if !intersect.isValid {
                continue;
            }
            
            placeAnnotation(clip, annotation: annotation, position: entry.position(intersect), edge: annotation.time.edge(intersect))
        }
        
        return entry;
    }
}
