//
//  VideoClipView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
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
    
    public var annotationFont: NSFont = NSFont.systemFontOfSize(NSFont.smallSystemFontSize());
    
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
        
        let annotationHeight = ("X" as NSString).sizeWithAttributes([NSFontAttributeName: annotationFont]).height + 2;
        var y                = CGFloat(margin);

        let width = ceil(max(CGFloat(spaceBetweenClip) * 3, self.clipBounds.width))
        
        for line in lines {
            let threadDown = line.threads.count / 2;
            let threadUp   = line.threads.count - threadDown;
            let lineRect = NSRect(
                                x:      CGFloat(0),
                                y:      y + (CGFloat(threadUp) * annotationHeight),
                                width:  width,
                                height: previewHeight)
            
            for entry in line.entries {
                let position  = entry.position;
                let entryRect = NSRect(x: CGFloat(position.location), y: lineRect.origin.y, width: CGFloat(position.length), height: lineRect.size.height);
            
                if let clipView = clipViews.first {
                    clipView.entry = entry;
                    clipView.frame = entryRect;
                    clipViews.removeAtIndex(0);
                }
                else {
                    let clipView = VideoClipLineEntryView(frame: entryRect, entry: entry);
                    self.addSubview(clipView);
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
                    threadRect.origin.y += lineRect.height + (CGFloat(i) * annotationHeight);
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
                                height: threadRect.size.height);
                        annotationViews.removeAtIndex(0);
                    }
                    else {
                        blockView = VideoClipAnnotationView(frame: NSRect(
                                x:      CGFloat(block.position.location),
                                y:      threadRect.origin.y,
                                width:  CGFloat(block.position.length),
                                height: threadRect.size.height), annotation: block.annotation);
                        self.addSubview(blockView);
                    }
                }
            }
            
            y += previewHeight + (CGFloat(line.threads.count) * annotationHeight) + CGFloat(spaceBetweenClip);
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
    
    public override func frameDidChange() {
        reloadData();
    }
}
