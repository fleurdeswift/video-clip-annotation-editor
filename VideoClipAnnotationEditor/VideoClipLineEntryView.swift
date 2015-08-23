//
//  VideoClipLineEntryView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraDataStructures

private func generateSelectionBlock(cornerRadius: CGFloat) -> (rect: NSRect) -> Bool {
    let borderColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1);
    let lineColor   = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1);

    return { (rect: NSRect) -> Bool in
        var nrect = rect;
        
        nrect.origin.x    += 1;
        nrect.origin.y    += 1;
        nrect.size.width  -= 2;
        nrect.size.height -= 2;
        
        let bezierPath = NSBezierPath(roundedRect:nrect, radius:cornerRadius);
        
        bezierPath.lineWidth = 2;
        borderColor.set();
        bezierPath.stroke();
        
        let t = rect.height / 3;
        let leftLine = NSBezierPath(rect: NSRect(x: rect.origin.x + 0.5, y: rect.origin.y + t + 4, width: 1, height: t))
        lineColor.set();
        leftLine.fill();

        let rightLine = NSBezierPath(rect: NSRect(x: rect.maxX - 1.5, y: rect.origin.y + t + 4, width: 1, height: t))
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
    internal var entry: VideoClipLineEntry!;

    // MARK: Current Time
    internal var currentTime: NSTimeInterval? {
        didSet {
            if NSTimeInterval.equalsWithAccuracy(oldValue, currentTime, accuracy: 0.01) {
                return;
            }

            if let t = currentTime {
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
            if let t = selection {
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

    public func previewCacheUpdated(time: NSTimeInterval) {
        if entry.previews.count == 0 {
            return;
        }

        if (time >= entry.previews[0].time) &&
           (time <= entry.time.end) {
            self.needsDisplay = true;
        }
    }

    public override func drawRect(dirtyRect: NSRect) {
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
        
        if let context = NSGraphicsContext.currentContext()?.CGContext, let cache = (self.superview as? VideoClipView)?.cache {
            var rect = CGRect(x: 0, y: 0, width: entry.previewWidth, height: rect.size.height);

            for preview in entry.previews {
                rect.origin.x = preview.x;

                if let image = cache.get(entry.clip, time: preview.time) {
                    CGContextDrawImage(context, rect, image);
                }
                else {
                    NSColor.blackColor().setFill();
                    NSRectFill(rect);
                }
            }
        }
        else {
            NSColor.blackColor().setFill();
            NSRectFill(rect);
        }

        // Current time
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

        // Selection
        if let selx = selectionX {
            selectionImage.drawInRect(NSRect(
                x:      CGFloat(selx.location),
                y:      rect.origin.y,
                width:  CGFloat(selx.length),
                height: rect.size.height));
        }
    }
    
    public func time(x: CGFloat) -> NSTimeInterval {
        return entry.time(x);
    }
    
    public func position(t: NSTimeInterval) -> CGFloat {
        return entry.positionInView(t);
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
