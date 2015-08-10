//
//  VideoClipLineEntryView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

private func generateSelectionBlock(cornerRadius: CGFloat) -> (rect: NSRect) -> Bool {
    let borderColor = NSColor(red: 1,   green: 0.83, blue: 0.03, alpha: 1);
    let lineColor   = NSColor(red: 0.2, green: 0.2,  blue: 0.2,  alpha: 1);

    return { (rect: NSRect) -> Bool in
        var nrect = rect;
        
        nrect.origin.x    += 5;
        nrect.origin.y    += 1;
        nrect.size.width  -= 10;
        nrect.size.height -= 2;
        
        let bezierPath = NSBezierPath(roundedRect:nrect, radius:cornerRadius);
        
        bezierPath.lineWidth = 2;
        borderColor.set();
        bezierPath.stroke();
        
        let t = rect.height / 3;
        
        let leftHandle = NSBezierPath(roundedLeftRect: NSRect(x: rect.origin.x, y: rect.origin.y + t, width: 4, height: t), radius: cornerRadius / 2);
        leftHandle.fill();

        let rightHandle = NSBezierPath(roundedRightRect: NSRect(x: rect.maxX - 4, y: rect.origin.y + t, width: 4, height: t), radius: cornerRadius / 2);
        rightHandle.fill();

        let leftLine = NSBezierPath(rect: NSRect(x: rect.origin.x + 2, y: rect.origin.y + t + 4, width: 1, height: t - 8))
        lineColor.set();
        leftLine.fill();

        let rightLine = NSBezierPath(rect: NSRect(x: rect.maxX - 3, y: rect.origin.y + t + 4, width: 1, height: t - 8))
        rightLine.fill();
        return true;
    };
}

private func generateSelectionImage(cornerRadius: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: 32, height: 80), flipped: true, drawingHandler: generateSelectionBlock(cornerRadius))
    
    image.capInsets    = NSEdgeInsetsMake(35, 14, 35, 14);
    image.resizingMode = NSImageResizingMode.Tile;
    return image;
}

private let selectionImage = generateSelectionImage(4);

public class VideoClipLineEntryView : NSView {
    internal var entry: VideoClipLineEntry?;
    
    // MARK: Current Time
    internal var currentTime: NSTimeInterval? {
        didSet {
            if let t = currentTime, let entry = entry {
                if entry.time.contains(t) {
                    currentTimeX = entry.positionInView(t);
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
    
    // MARK: Selection
    internal var selection: TimeRange? {
        didSet {
            if let t = selection, let entry = entry {
                if entry.time.intersects(t) {
                    selectionX = entry.positionInViewUnclampled(t);
                }
                else {
                    selectionX = nil;
                }
            }
            else {
                selectionX = nil;
            }
            
            self.window?.invalidateCursorRectsForView(self);
            self.needsDisplay = true;
        }
    }
    
    internal var selectionX: NSRange?;
    
    public override func resetCursorRects() {
        if let selx = selectionX {
            let b = self.bounds;
            
            addCursorRect(NSRect(x: CGFloat(selx.location), y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeLeftCursor());
            addCursorRect(NSRect(x: CGFloat(selx.end  - 4), y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeRightCursor());
        }
    }
    
    // MARK: Drawing
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
                var skip = false;
            
                if let superview = self.superview as? VideoClipView {
                    skip = superview.dragging;
                }
            
                if !skip {
                    NSColor.whiteColor().set();
                    NSRectFill(NSRect(x: ctx, y: 0, width: 1, height: rect.size.height))
                }
            }
            
            if let selx = selectionX {
                selectionImage.drawInRect(NSRect(
                    x:      CGFloat(selx.location),
                    y:      rect.origin.y,
                    width:  CGFloat(selx.length),
                    height: rect.size.height));
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
    
    internal func selectionHandle(x: CGFloat) -> VideoClipView.HitHandle {
        if let selx = selectionX {
            if between(x, CGFloat(selx.location), CGFloat(selx.location + 4)) {
                return .Left;
            }
            else if between(x, CGFloat(selx.end - 4), CGFloat(selx.end)) {
                return .Right;
            }
        }
        
        return .None;
    }
}
