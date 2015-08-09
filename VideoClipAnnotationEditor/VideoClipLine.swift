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
    
    func placeAnnotation(annotation: VideoClipAnnotation, position: NSRange) -> VideoClipAnnotationThread {
        for thread in threads {
            if thread.reserveAnnotation(annotation, position: position) {
                return thread;
            }
        }
        
        let newThread = VideoClipAnnotationThread();
        
        newThread.reserveAnnotation(annotation, position: position);
        threads.append(newThread);
        return newThread;
    }
    
    func placeClip(clip: VideoClip, time: TimeRange, position: NSRange) -> VideoClipLineEntry {
        let entry = VideoClipLineEntry(clip: clip, time: time, position: position);
        
        entries.append(entry);
        
        for annotation in clip.annotations {
            let intersect = time.intersection(annotation.time);
            
            if !intersect.isValid {
                continue;
            }
            
            placeAnnotation(annotation, position: entry.position(intersect))
        }
        
        return entry;
    }
}
