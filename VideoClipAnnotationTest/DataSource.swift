//
//  DataSource.swift
//  VideoClipAnnotationTest
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation
import VideoClipAnnotationEditor

public class TestClipAnnotation : VideoClipAnnotation {
    public var text:  String;
    public var color: VideoClipAnnotationColor;
    public var time:  TimeRange;
    
    public init(text: String, color: VideoClipAnnotationColor, time: TimeRange) {
        self.text  = text;
        self.color = color;
        self.time  = time;
    }
}

public class TestClip : VideoClip {
    public var duration: NSTimeInterval {
        get {
            return 60 * 3 - 0.7;
        }
    };
    
    public var annotations: [VideoClipAnnotation] = [
        TestClipAnnotation(text: "1",  color: VideoClipAnnotationColor.redColor(),    time: TimeRange(start: 1,  end: 10)),
        TestClipAnnotation(text: "2",  color: VideoClipAnnotationColor.blueColor(),   time: TimeRange(start: 12, end: 60)),
        TestClipAnnotation(text: "3",  color: VideoClipAnnotationColor.yellowColor(), time: TimeRange(start: 65, end: 60 * 3)),
        TestClipAnnotation(text: "Excessivly long long long long long long long text", color: VideoClipAnnotationColor.greenColor(),  time: TimeRange(start: 2,  end: 9)),
        TestClipAnnotation(text: "Text", color: VideoClipAnnotationColor.purpleColor(),  time: TimeRange(start: 3,  end: 8)),
    ]
    
    public var previewWidth: Int {
        get {
            return 140;
        }
    };
}

public class DataSource : NSObject, VideoClipDataSource, VideoClipDataSourceIB {
    private var _clips: [VideoClip] = [];

    public override init() {
        super.init();
        _clips.append(TestClip());
        _clips.append(TestClip());
        _clips.append(TestClip());
        _clips.append(TestClip());
    }

    public var clips: [VideoClip] {
        get {
            return _clips;
        }
    }
    
    public var previewHeight: Int {
        get {
            return 80;
        }
    }
    
    public var sampleRate: NSTimeInterval {
        get {
            return 5;
        }
    };
}
