//
//  VideoClipView.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import AppKit
import ExtraAppKit
import ExtraDataStructures

public typealias VideoClipPreviewConfiguration = (size: NSSize, sampleRate: NSTimeInterval);

public class VideoClipView : ScrollableView {
    internal(set) public var cache = VideoClipPreviewCache(clips: [], sampleRate: 5);

    public class func numberOfImagesForClipDuration(duration: NSTimeInterval, sampleRate: NSTimeInterval = 5) -> Int {
        return max(1, Int(round(duration / sampleRate)));
    }

    // MARK: IBOutlets
    public var dataSource: VideoClipDataSource? {
        didSet {
            reloadData();
            reloadCache();
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

    public var delegate: VideoClipDelegate?;

    @IBOutlet
    public var delegateIB: VideoClipDelegateIB? {
        get {
            return self.delegate as? VideoClipDelegateIB;
        }

        set {
            self.delegate = newValue as? VideoClipDelegate;
        }
    }
    
    // MARK: Annotation Style
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

    // MARK: Layout
    internal var _contentSize: CGSize = CGSize(width: 100, height: 100)
    
    public override var contentSize: CGSize {
        get {
            return _contentSize;
        }
    }
    
    public var margin:           Int = 12;
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
                let previewConfig  = VideoClipPreviewConfiguration(size: NSSize(width: clip.previewWidth, height: dataSource.previewHeight), sampleRate: sampleRate);
                
                while clipWidth > 0 {
                    let use = min(spaceLeft, clipWidth);
                    
                    line.placeClip(clip,
                        time:          TimeRange(
                                           start: NSTimeInterval(clipX)       / NSTimeInterval(clipTotalWidth) * duration,
                                           end:   NSTimeInterval(clipX + use) / NSTimeInterval(clipTotalWidth) * duration),
                        position:      NSRange(location: x, length: use),
                        previewConfig: previewConfig);
                    
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
                var newClipView: VideoClipLineEntryView;
                
                if let clipView = clipViews.first {
                    clipView.entry = entry;
                    clipView.frame = entryRect;
                    clipViews.removeAtIndex(0);
                    lineDigest.clips.append(clipView);
                    newClipView = clipView;
                }
                else {
                    let clipView = VideoClipLineEntryView(frame: entryRect, entry: entry);
                    self.addSubview(clipView);
                    lineDigest.clips.append(clipView);
                    newClipView = clipView;
                }
                
                if let ct = _currentTime {
                    if ct.clip === entry.clip {
                        newClipView.currentTime = ct.time;
                    }
                    else {
                        newClipView.currentTime = nil;
                    }
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
                                height: threadRect.size.height - 1));
                        self.addSubview(blockView);
                    }
                    
                    blockView.configure(block.clip,
                        annotation: block.annotation,
                        edge:       block.edge,
                        selected:   self.annotationSelection.contains(HashAnnotation(block.annotation)))
                    
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

    public func reloadCache() {
        cache.dispose();
        NSNotificationCenter.defaultCenter().removeObserver(self, name: nil, object: cache);

        if let dataSource = dataSource {
            cache = VideoClipPreviewCache(clips: dataSource.clips, sampleRate: dataSource.sampleRate);
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("previewCacheUpdated:"), name: VideoClipPreviewCacheUpdated, object: cache);
        }
        else {
            cache = VideoClipPreviewCache(clips: [], sampleRate: 5);
        }
    }

    public override func viewDidMoveToWindow() {
        if self.window == nil {
            cache.dispose();
        }
    }

    @objc
    private func previewCacheUpdated(notification: NSNotification) -> Void {
        var time: NSTimeInterval = -1;

        if let userInfo = notification.userInfo {
            if let t = userInfo["Time"] as? NSTimeInterval {
                time = t;
            }
            else {
                return;
            }
        }
        else {
            return;
        }

        for view in self.subviews {
            if let clipView = view as? VideoClipLineEntryView {
                clipView.previewCacheUpdated(time);
            }
        }
    }

    @objc
    public override var flipped: Bool {
        get {
            return true;
        }
    }


    // MARK: Hit Testing
    public override func frameDidChange() {
        reloadData();
    }

    public override func updateTrackingAreas() {
        let options = NSTrackingAreaOptions([
                            NSTrackingAreaOptions.ActiveInActiveApp,
                            NSTrackingAreaOptions.InVisibleRect,
                            NSTrackingAreaOptions.MouseEnteredAndExited,
                            NSTrackingAreaOptions.MouseMoved
        ]);
        
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil));
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
                    
                    hitTest.handle = clip.selectionHandle(npoint.x - clipFrame.origin.x);
                    return hitTest;
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

    private var mouseMoveEvent: NSEvent?;
    private var mouseMoveEventBlock: dispatch_block_t?;

    public override func mouseMoved(ev: NSEvent) {
        mouseMoveEvent = ev;
        
        if mouseMoveEventBlock != nil {
            return;
        }

        mouseMoveEventBlock = {
            let h: HitTest = self.hitTest(self.convertPoint(self.mouseMoveEvent!.locationInWindow, fromView: nil));
        
            if let clip = h.clip, let time = h.time {
                if h.area == .Clip {
                    self.setCurrentTime(VideoClipPoint(clip: clip, time: time), event: ev);
                }
            }

            self.window?.title = h.description;
            self.mouseMoveEvent      = nil;
            self.mouseMoveEventBlock = nil;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 20)), dispatch_get_main_queue(), mouseMoveEventBlock!);
    }

    private var mouseDownHitTest: HitTest?;

    public override func mouseDown(event: NSEvent) {
        var h: HitTest = hitTest(self.convertPoint(event.locationInWindow, fromView: nil));
        
        if h.clip != nil && h.time != nil && h.area == .Clip {
            if let sel = _currentSelection {
                if h.handle == .Right {
                    h.time = sel.time.start;
                }
                else if h.handle == .Left {
                    h.time = sel.time.end;
                }
            }

            if event.clickCount > 1 {
                self.setCurrentTime(VideoClipPoint(clip: h.clip!, time: h.time!), event: event);
            }

            mouseDownHitTest = h;
        }
        else {
            mouseDownHitTest = nil;
        }
        
        dragging = false;
    }
    
    internal var dragging = false;
    
    public override func mouseDragged(event: NSEvent) {
        if let mouseDownHitTest = self.mouseDownHitTest {
            dragging = true;
            
            let h: HitTest = hitTest(self.convertPoint(event.locationInWindow, fromView: nil));
            
            if h.clip != nil && h.time != nil && h.area == .Clip && mouseDownHitTest.clip === h.clip {
                self.selection = VideoClipRange(clip: mouseDownHitTest.clip!, time: TimeRange(t0: mouseDownHitTest.time!, t1: h.time!))
                self.setCurrentTime(VideoClipPoint(clip: mouseDownHitTest.clip!, time: h.time!), event: event);
            }
        }
    }
    
    public override func mouseUp(event: NSEvent) {
        if dragging {
            if let selection = self.selection {
                if self.annotationSelection.count == 1 {
                    if let annotation = self.annotationSelection.first {
                        annotation.ref.time = selection.time;
                        reloadData();
                    }
                }
            }
        
            dragging = false;
        }
        else {
            self.selection = nil;
            self.annotationSelection.removeAll();
        }
    }

    // MARK: Current Time
    private var _currentTime: VideoClipPoint?;
    public var currentTime: VideoClipPoint? {
        get {
            return _currentTime;
        }
    }

    private func setCurrentTime(newValue: VideoClipPoint?, event: NSEvent?) {
        let oldValue = _currentTime;

        if event?.clickCount > 1 {
            // Force process.
        }
        else if let v = newValue, let ov = oldValue {
            if abs(v.time - ov.time) < NSTimeThreshold {
                return;
            }
        }
        else if newValue == nil {
            if _currentTime == nil {
                return;
            }
        }
        
        _currentTime = newValue;
        updateCurrentTime(oldValue, new: newValue);
        
        if let delegate = self.delegate {
            delegate.currentTimeChanged(self, point: newValue, event: event);
        }
    }
    
    func viewsForClip(clip: VideoClip) -> [VideoClipLineEntryView] {
        var clips: [VideoClipLineEntryView] = [];
    
        for view in self.subviews {
            if let clipView = view as? VideoClipLineEntryView {
                if let clipInView = clipView.entry?.clip {
                    if clipInView === clip {
                        clips.append(clipView);
                    }
                }
            }
        }
        
        return clips;
    }
    
    private func updateCurrentTime(old: VideoClipPoint?, new: VideoClipPoint?) {
        if let oldClip = old?.clip, newClip = new?.clip {
            if oldClip === newClip {
                for clipView in viewsForClip(newClip) {
                    clipView.currentTime = new!.time;
                }
                
                return;
            }
        }

        if let oldClip = old?.clip {
            for clipView in viewsForClip(oldClip) {
                clipView.currentTime = nil;
            }
        }

        if let newClip = new?.clip {
            for clipView in viewsForClip(newClip) {
                clipView.currentTime = new!.time;
            }
        }
    }
    
    // MARK: Selection
    private var _currentSelection: VideoClipRange?;
    public var selection: VideoClipRange? {
        get {
            return _currentSelection;
        }
        
        set {
            let oldValue = _currentSelection;
        
            if newValue == nil && _currentTime == nil {
                return;
            }
            
            _currentSelection = newValue;
            updateSelection(oldValue, new: newValue);
            
            if let delegate = self.delegate {
                delegate.selectionChanged(self, range: newValue);
            }
        }
    }
    
    private func updateSelection(old: VideoClipRange?, new: VideoClipRange?) {
        if let oldClip = old?.clip, newClip = new?.clip {
            if oldClip === newClip {
                for clipView in viewsForClip(newClip) {
                    clipView.selection = new!.time;
                }
                
                return;
            }
        }

        if let oldClip = old?.clip {
            for clipView in viewsForClip(oldClip) {
                clipView.selection = nil;
            }
        }

        if let newClip = new?.clip {
            for clipView in viewsForClip(newClip) {
                clipView.selection = new!.time;
            }
        }
    }
    
    // MARK: Annotation Selection
    private var _currentAnnotationSelection: Set<HashAnnotation> = Set<HashAnnotation>();
    public var annotationSelection: Set<HashAnnotation> {
        get {
            return _currentAnnotationSelection;
        }
        
        set {
            let oldValue = _currentAnnotationSelection;
        
            if oldValue == newValue {
                return;
            }
            
            _currentAnnotationSelection = newValue;
            updateSelection(oldValue, new: newValue);
            
            if let delegate = self.delegate {
                delegate.selectionChanged(self, annotations: newValue);
            }
        }
    }
    
    private func updateSelection(old: Set<HashAnnotation>, new: Set<HashAnnotation>) {
        for view in self.subviews {
            if let annotationView = view as? VideoClipAnnotationView {
                if let annotation = annotationView.annotation {
                    annotationView.selected = new.contains(HashAnnotation(annotation));
                }
                else {
                    annotationView.selected = false;
                }
            }
        }
    }

    public override var acceptsFirstResponder: Bool {
        get {
            return true;
        }
    }
}

public struct HashAnnotation : Hashable {
    public let ref: VideoClipAnnotation;
    
    public init(_ ref: VideoClipAnnotation) {
        self.ref = ref;
    }

    public var hashValue: Int {
        get {
            return unsafeAddressOf(ref).hashValue;
        }
    }
}

public func == (p1: HashAnnotation, p2: HashAnnotation) -> Bool {
    return p1.ref === p2.ref;
}
