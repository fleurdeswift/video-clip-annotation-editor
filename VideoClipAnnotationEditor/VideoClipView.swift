//
//  VideoClipView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import AppKit
import ExtraAppKit

public class VideoClipView : ScrollableView {
    public class func numberOfImagesForClipDuration(duration: NSTimeInterval, sampleRate: NSTimeInterval = 5) -> Int {
        return max(1, Int(round(duration / sampleRate)));
    }

    public var dataSource: VideoClipDataSource? {
        didSet {
            reloadData();
        }
    }

    @IBOutlet
    public var dataSourceIB: VideoClipDataSourceIB? {
        get {
            return self.dataSource as? VideoClipDataSourceIB;
        }

        set {
            self.dataSource = newValue as? VideoClipDataSource;
        }
    }
    
    internal var clipViews: [NSView] = [];
    internal var _contentSize: CGSize = CGSize(width: 100, height: 100)
    
    public override var contentSize: CGSize {
        get {
            return _contentSize;
        }
    }
    
    public var margin: Int = 12;
    public var spaceBetweenClip: Int = 15;
    
    private func buildLines() -> [VideoClipLine] {
        if let dataSource = self.dataSource {
            let sampleRate = dataSource.sampleRate;
            var lines      = [VideoClipLine]();
            var line       = VideoClipLine();
            var x          = margin;
            let width      = Int(ceil(max(CGFloat((spaceBetweenClip * 3) + (margin * 2)), self.clipBounds.width - CGFloat(margin * 2))));
            var spaceLeft  = width;
            
            lines.append(line);
        
            for clip in dataSource.clips {
                let imageCount     = VideoClipView.numberOfImagesForClipDuration(clip.duration, sampleRate: sampleRate);
                let duration       = clip.duration;
                var clipX          = 0;
                let clipTotalWidth = imageCount * clip.previewWidth;
                var clipWidth      = clipTotalWidth;
                
                while clipWidth > 0 {
                    let use = min(spaceLeft, clipWidth);
                    
                    line.placeClip(clip,
                        time:     TimeRange(
                                      start: NSTimeInterval(clipX)       / NSTimeInterval(clipTotalWidth) * duration,
                                      end:   NSTimeInterval(clipX + use) / NSTimeInterval(clipTotalWidth) * duration),
                        position: NSRange(location: x, length: use));
                    
                    clipX     += use;
                    clipWidth -= use;
                    x         += use;
                    spaceLeft -= use;
                    
                    if spaceLeft <= 0 {
                        line      = VideoClipLine();
                        x         = margin;
                        spaceLeft = width;
                        lines.append(line);
                    }
                }
                
                if spaceLeft < (spaceBetweenClip * 2) {
                    line      = VideoClipLine();
                    x         = margin;
                    spaceLeft = width;
                    lines.append(line);
                }
                else {
                    x         += spaceBetweenClip;
                    spaceLeft -= spaceBetweenClip;
                }
            }
            
            if let last = lines.last {
                if last.entries.count == 0 {
                    lines.removeAtIndex(lines.count - 1);
                }
            }
            
            return lines;
        }
        
        return [];
    }
    
    public var annotationFont: NSFont = NSFont.systemFontOfSize(NSFont.smallSystemFontSize()) {
        didSet {
            _annotationStyle = nil;
        }
    }
    
    private var _annotationStyle: [String: AnyObject]?;
    public var annotationStyle: [String: AnyObject] {
        get {
            if let a = _annotationStyle {
                return a;
            }
            
            let p = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle;
            
            p.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
            
            let a = [
                NSFontAttributeName:           self.annotationFont,
                NSParagraphStyleAttributeName: p.copy()
            ];
            
            _annotationStyle = a;
            return a;
        }
    }
    
    private var _annotationHeight: CGFloat?;
    public var annotationHeight: CGFloat {
        get {
            if let a = _annotationHeight {
                return a;
            }
            
            let p = ("X" as NSString).sizeWithAttributes(self.annotationStyle).height;
            
            _annotationHeight = p;
            return p;
        }
    }
    
    internal struct LayoutDigestLine {
        var rect: NSRect;
        var clips = [VideoClipLineEntryView]();
        var annotations = [VideoClipAnnotationView]();
        
        init(rect: NSRect) {
            self.rect = rect;
        }
    }
    
    internal struct LayoutDigest {
        var lines = [LayoutDigestLine]();
    }
    
    internal var layoutDigest = LayoutDigest();
    
    public func reloadData() {
        let lines         = buildLines();
        var previewHeight = CGFloat(80);
        
        if let dataSource = dataSource {
            previewHeight = CGFloat(dataSource.previewHeight);
        }
        
        var clipViews:       [VideoClipLineEntryView]  = [];
        var annotationViews: [VideoClipAnnotationView] = [];
        
        for view in self.subviews {
            if let clipView = view as? VideoClipLineEntryView {
                clipViews.append(clipView);
            }
            else if let fieldView = view as? VideoClipAnnotationView {
                annotationViews.append(fieldView);
            }
        }
        
        let annotationHeight = self.annotationHeight + 2;
        var y                = CGFloat(margin);

        let width = ceil(max(CGFloat(spaceBetweenClip) * 3, self.clipBounds.width))
        
        layoutDigest.lines.removeAll();
        
        let spaceBetweenClipD2: CGFloat = CGFloat(spaceBetweenClip) / 2;
        
        for line in lines {
            let threadDown = line.threads.count / 2;
            let threadUp   = line.threads.count - threadDown;
            let lineRect = NSRect(
                                x:      CGFloat(0),
                                y:      y + (CGFloat(threadUp) * annotationHeight),
                                width:  width,
                                height: previewHeight)

            var lineDigest = LayoutDigestLine(rect: NSRect(
                                x:      CGFloat(0),
                                y:      y - spaceBetweenClipD2,
                                width:  width,
                                height: previewHeight + (CGFloat(line.threads.count) * annotationHeight) + spaceBetweenClipD2));
            
            for entry in line.entries {
                let position  = entry.position;
                let entryRect = NSRect(x: CGFloat(position.location), y: lineRect.origin.y, width: CGFloat(position.length), height: lineRect.size.height);
            
                if let clipView = clipViews.first {
                    clipView.entry = entry;
                    clipView.frame = entryRect;
                    clipViews.removeAtIndex(0);
                    lineDigest.clips.append(clipView);
                }
                else {
                    let clipView = VideoClipLineEntryView(frame: entryRect, entry: entry);
                    self.addSubview(clipView);
                    lineDigest.clips.append(clipView);
                }
            }
            
            for (threadIndex, thread) in line.threads.enumerate() {
                let i = threadIndex / 2;
            
                var threadRect = NSRect(
                                    x:      lineRect.origin.x,
                                    y:      lineRect.origin.y,
                                    width:  lineRect.width,
                                    height: annotationHeight);
                
                if threadIndex % 2 == 0 {
                    threadRect.origin.y -= (CGFloat(i + 1) * annotationHeight);
                }
                else {
                    threadRect.origin.y += lineRect.height + 1 + (CGFloat(i) * annotationHeight);
                }
                
                for block in thread.blocks {
                    let blockView: VideoClipAnnotationView;
                
                    if let annotationView = annotationViews.first {
                        blockView = annotationView;
                        blockView.annotation = block.annotation;
                        blockView.frame = NSRect(
                                x:      CGFloat(block.position.location),
                                y:      threadRect.origin.y,
                                width:  CGFloat(block.position.length),
                                height: threadRect.size.height - 1);
                        annotationViews.removeAtIndex(0);
                    }
                    else {
                        blockView = VideoClipAnnotationView(frame: NSRect(
                                x:      CGFloat(block.position.location),
                                y:      threadRect.origin.y,
                                width:  CGFloat(block.position.length),
                                height: threadRect.size.height - 1), annotation: block.annotation);
                        self.addSubview(blockView);
                    }
                    
                    blockView.edge = block.edge;
                    lineDigest.annotations.append(blockView);
                }
            }
            
            y += previewHeight + (CGFloat(line.threads.count) * annotationHeight) + CGFloat(spaceBetweenClip);
            
            layoutDigest.lines.append(lineDigest);
        }
        
        for view in clipViews {
            view.removeFromSuperview()
        }
        
        for view in annotationViews {
            view.removeFromSuperview()
        }
        
        _contentSize = CGSize(width: width, height: y + CGFloat(margin));
        invalidateContentSize();
    }
    
    @objc
    public override var flipped: Bool {
        get {
            return true;
        }
    }
    
    internal var tracking: NSTrackingArea?;
    
    public override func frameDidChange() {
        reloadData();
    }

    public override func updateTrackingAreas() {
        let options = NSTrackingAreaOptions([
                            NSTrackingAreaOptions.ActiveAlways,
                            NSTrackingAreaOptions.InVisibleRect,
                            NSTrackingAreaOptions.MouseEnteredAndExited,
                            NSTrackingAreaOptions.MouseMoved
        ]);

        if let tracking = self.tracking {
            self.removeTrackingArea(tracking);
        }
        
        tracking = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil);
        self.addTrackingArea(tracking!);
    }

    public enum HitArea {
        case Background, Annotation, Clip, Thread
    }
    
    public enum HitHandle {
        case None, Left, Right
    }

    public struct HitTest : CustomStringConvertible {
        public var area:       HitArea;
        public var clip:       VideoClip?
        public var time:       NSTimeInterval?;
        public var annotation: VideoClipAnnotation?;
        public var handle:     HitHandle = .None;
    
        internal init(area: HitArea) {
            self.area = area;
        }
        
        public var description: String {
            get {
                return "\(area) \(handle) \(time) \(annotation?.text)";
            }
        }
    }

    public func hitTest(point: NSPoint) -> HitTest {
        for line in layoutDigest.lines {
            if !line.rect.contains(point) {
                continue;
            }
            
            var npoint  = point;
            var hitTest = HitTest(area: .Thread)

            if let first = line.clips.first {
                let ox = first.frame.origin.x;
            
                if npoint.x < ox {
                    npoint.x     = ox;
                    hitTest.time = first.time(0);
                }
            }

            if let last = line.clips.last {
                let mx = last.frame.maxX;
            
                if npoint.x > mx {
                    npoint.x     = mx;
                    hitTest.time = last.time(CGFloat.max);
                }
            }
            
            for clip in line.clips {
                let clipFrame = clip.frame;
            
                if between(npoint.x, clipFrame.origin.x, clipFrame.origin.x + clipFrame.size.width) {
                    hitTest.time = clip.time(point.x);
                    hitTest.clip = clip.entry?.clip;
                    
                    if clipFrame.contains(npoint) {
                        hitTest.area = .Clip;
                    }
                    else {
                        hitTest.area = .Thread;
                    }
                    
                    break;
                }
            }
            
            for annotation in line.annotations {
                let annotationFrame = annotation.frame;

                if annotationFrame.contains(npoint) {
                    hitTest.annotation = annotation.annotation;
                    hitTest.area       = .Annotation;
                    
                    if abs(annotationFrame.minX - npoint.x) < 4 {
                        hitTest.handle = .Left;
                        
                        if abs(annotationFrame.maxX - npoint.x) < 4 {
                            // Hummm... It touches both...
                            if abs(annotationFrame.maxX - npoint.x) < (annotationFrame.size.width / 2) {
                                hitTest.handle = .Right;
                            }
                        }
                    }
                    else if abs(annotationFrame.maxX - npoint.x) < 4 {
                        hitTest.handle = .Right;
                    }
                }
            }
            
            return hitTest;
        }
    
        return HitTest(area: .Background);
    }
    
    public override func mouseMoved(event: NSEvent) {
        self.window?.title = hitTest(self.convertPoint(event.locationInWindow, fromView: nil)).description;
    }
}
