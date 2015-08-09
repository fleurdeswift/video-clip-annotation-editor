//
//  VideoClipAnnotationView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import ExtraAppKit

public class VideoClipAnnotationView : NSView {
    internal var annotation: VideoClipAnnotation?

    internal init(frame: NSRect, annotation: VideoClipAnnotation) {
        self.annotation = annotation;
        super.init(frame: frame);
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    public override func drawRect(dirtyRect: NSRect) {
        if let annotation = self.annotation, let superview = self.superview as? VideoClipView {
            let text = NSAttributedString(
                string:     annotation.text,
                attributes: superview.annotationStyle);
            
            var rect = self.bounds;
            
            NSBezierPath(roundedRect: rect, radius: 2.5).setClip();
            
            annotation.color.backgroundColor.set();
            NSRectFill(self.bounds);
            
            rect.origin.x    += 5;
            rect.size.width  -= 10;
            text.drawInRect(rect);
        }
    }
}
