//
//  VideoClipLine.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

internal class VideoClipLine {
    var threads: [VideoClipAnnotationThread] = [];
    var entries: [VideoClipLineEntry]        = [];
    
    func placeAnnotation(annotation: VideoClipAnnotation, position: NSRange, edge: EdgeType) -> VideoClipAnnotationThread {
        for thread in threads {
            if thread.reserveAnnotation(annotation, position: position, edge: edge) {
                return thread;
            }
        }
        
        let newThread = VideoClipAnnotationThread();
        
        newThread.reserveAnnotation(annotation, position: position, edge: edge);
        threads.append(newThread);
        return newThread;
    }
    
    func placeClip(clip: VideoClip, time: TimeRange, position: NSRange) -> VideoClipLineEntry {
        let full  = TimeRange(start: 0, end: clip.duration);
        let entry = VideoClipLineEntry(clip: clip, time: time, position: position, edge: full.edge(time));
        
        entries.append(entry);
        
        for annotation in clip.annotations {
            let intersect = time.intersection(annotation.time);
            
            if !intersect.isValid {
                continue;
            }
            
            placeAnnotation(annotation, position: entry.position(intersect), edge: annotation.time.edge(intersect))
        }
        
        return entry;
    }
}
