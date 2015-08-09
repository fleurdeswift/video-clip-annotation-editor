//
//  VideoClipLineEntryView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public class VideoClipLineEntryView : NSView {
    internal var entry: VideoClipLineEntry?;

    internal init(frame: NSRect, entry: VideoClipLineEntry) {
        self.entry = entry;
        super.init(frame: frame);
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        if let entry = self.entry {
            let s = "\(entry.time.start) - \(entry.time.end)" as NSString

            s.drawAtPoint(NSPoint(x: 0, y: 0), withAttributes: nil);
        }
        else {
            let s = "<NIL>" as NSString

            s.drawAtPoint(NSPoint(x: 0, y: 0), withAttributes: nil);
        }
        
        NSColor.blueColor().setFill();
        NSRectFill(self.bounds);
    }
}
