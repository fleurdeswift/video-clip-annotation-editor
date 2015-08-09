//
//  VideoClipAnnotationView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public class VideoClipAnnotationView : NSTextField {
    internal var annotation: VideoClipAnnotation? {
        didSet {
            if let annotation = self.annotation, let superview = self.superview as? VideoClipView {
                self.attributedStringValue = NSAttributedString(
                    string:     annotation.text,
                    attributes: [
                        NSFontAttributeName: superview.annotationFont,
                        NSForegroundColorAttributeName: NSColor.whiteColor(),
//                        NSBackgroundColorAttributeName: annotation.color
                    ]);
                
                self.backgroundColor = annotation.color;
            }
        }
    }

    internal init(frame: NSRect, annotation: VideoClipAnnotation) {
        self.annotation = annotation;
        super.init(frame: frame);
        self.bordered   = false;
        self.editable   = false;
        self.selectable = false;
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}
