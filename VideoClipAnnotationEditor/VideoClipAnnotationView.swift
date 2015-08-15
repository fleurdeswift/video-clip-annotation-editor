//
//  VideoClipAnnotationView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraAppKit

public class VideoClipAnnotationView : NSView {
    internal var clip:       VideoClip?;
    internal var annotation: VideoClipAnnotation?
    internal var edge:       EdgeType = .Complete;
    
    public var selected: Bool = false {
        didSet {
            self.needsDisplay = true;
        }
    }

    public func configure(clip: VideoClip, annotation: VideoClipAnnotation, edge: EdgeType, selected: Bool) {
        self.clip       = clip;
        self.annotation = annotation;
        self.edge       = edge;
        self.selected   = selected;
    }
    
    public override func resetCursorRects() {
        let b = self.bounds;
        
        switch (edge) {
        case .Partial:
            break;
        case .Start:
            addCursorRect(NSRect(x: 0, y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeLeftCursor());
            break;
        case .End:
            addCursorRect(NSRect(x: b.size.width - 4, y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeRightCursor());
            break;
        case .Complete:
            addCursorRect(NSRect(x: 0,                y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeLeftCursor());
            addCursorRect(NSRect(x: b.size.width - 4, y: 0, width: 4, height: b.size.height), cursor: NSCursor.resizeRightCursor());
            break;
        }
    }
    
    public override func mouseDown(event: NSEvent) {
        if let annotation = self.annotation, let clip = self.clip, let superview = self.superview as? VideoClipView {
            if event.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask) {
                superview.annotationSelection.insert(HashAnnotation(annotation))
                superview.selection = nil;
            }
            else {
                superview.annotationSelection = Set<HashAnnotation>([HashAnnotation(annotation)])
                superview.selection = VideoClipRange(clip: clip, time: annotation.time);
            }
        }
    }

    public override func mouseDragged(event: NSEvent) {
    }
    
    public override func mouseUp(event: NSEvent) {
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        if let annotation = self.annotation, let superview = self.superview as? VideoClipView {
            let text = NSAttributedString(
                string:     annotation.text,
                attributes: superview.annotationStyle);
            
            var rect = self.bounds;
            var path: NSBezierPath?;
            
            switch (edge) {
            case .Complete:
                path = NSBezierPath(roundedRect: rect, radius: 2.5);
                break;
            case .Partial:
                break;
            case .Start:
                path = NSBezierPath(roundedLeftRect: rect, radius: 2.5);
                break;
            case .End:
                path = NSBezierPath(roundedRightRect: rect, radius: 2.5);
                break;
            }
            
            if selected {
                annotation.color.selectedColor.setFill();
                annotation.color.selectedColor.setStroke();
            }
            else {
                annotation.color.backgroundColor.setFill();
                annotation.color.selectedColor.setStroke();
            }
            
            if let path = path {
                path.fill();
                path.stroke();
            }
            else {
                NSRectFill(rect);
            }
            
            rect.origin.x    += 5;
            rect.size.width  -= 10;
            text.drawInRect(rect);
        }
    }
}
