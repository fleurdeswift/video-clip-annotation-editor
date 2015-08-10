//
//  VideoClipLineEntryView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public class VideoClipLineEntryView : NSView {
    internal var entry: VideoClipLineEntry?;
    
    internal var currentTime: NSTimeInterval? {
        didSet {
            if let t = currentTime, let entry = entry {
                if entry.time.contains(t) {
                    currentTimeX = entry.positionInView(t)
                }
                else {
                    currentTimeX = nil;
                }
            }
            else {
                currentTimeX = nil;
            }
            
            self.needsDisplay = true;
        }
    }
    
    internal var currentTimeX: CGFloat?;
    
    internal init(frame: NSRect, entry: VideoClipLineEntry) {
        self.entry = entry;
        super.init(frame: frame);
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        if let entry = self.entry {
            let rect = self.bounds;
            
            switch (entry.edge) {
            case .Complete:
                NSBezierPath(roundedRect: rect, radius: 2.5).setClip();
                break;
            case .Partial:
                break;
            case .Start:
                NSBezierPath(roundedLeftRect: rect, radius: 2.5).setClip();
                break;
            case .End:
                NSBezierPath(roundedRightRect: rect, radius: 2.5).setClip();
                break;
            }
            
            NSColor.blueColor().setFill();
            NSRectFill(rect);
            
            if let ctx = currentTimeX {
                NSColor.whiteColor().set();
                NSRectFill(NSRect(x: ctx, y: 0, width: 1, height: rect.size.height))
            }
        }
    }
    
    public func time(x: CGFloat) -> NSTimeInterval {
        if let entry = self.entry {
            return entry.time(x);
        }
        
        return NSTimeInterval(-1);
    }
    
    public func position(t: NSTimeInterval) -> CGFloat {
        if let entry = self.entry {
            return entry.positionInView(t);
        }
        
        return -CGFloat.max;
    }
}
