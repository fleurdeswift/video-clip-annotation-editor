//
//  VideoClipPreviewCache.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import ExtraDataStructures
import Foundation

public let VideoClipPreviewCacheUpdated = "VideoClipPreviewCacheUpdated";

public class VideoClipPreviewCache : NSObject {
    private struct Entry : Hashable {
        let clip: VideoClip;
        let time: Int;

        init(clip: VideoClip, time: NSTimeInterval) {
            self.clip = clip;
            self.time = Int(time * 10);
        }

        var hashValue: Int {
            get {
                return unsafeAddressOf(clip).hashValue ^ time;
            }
        }
    }

    private var disposed = false;
    private let sampleRate: NSTimeInterval;

    private func allocCaptureBlock(current: VideoClip, remaining: [VideoClip]) -> (image: CGImageRef?, error: NSError?) -> NSTimeInterval {
        var time: NSTimeInterval = 0;

        return {
            (image: CGImageRef?, error: NSError?) -> NSTimeInterval in
                if self.disposed || (error != nil) {
                    return -1;
                }

                if let image = image {
                    self.set(current, time: time, image: image)
                }

                time += self.sampleRate;

                if time >= current.duration {
                    self.captureNextBlock(remaining);
                    return -1;
                }

                return time;
        }
    }

    private func captureNextBlock(clips: [VideoClip]) {
        if clips.count == 0 {
            return;
        }

        var remaining = clips;
        let current   = clips[0];

        remaining.removeAtIndex(0);
        current.imageAtTime(0, completionBlock: allocCaptureBlock(current, remaining: remaining));
    }

    public init(clips: [VideoClip], sampleRate: NSTimeInterval) {
        self.sampleRate = sampleRate;
        super.init();
        self.captureNextBlock(clips);
    }

    public func dispose() {
        return dispatch_async(queue) {
            self.disposed = true;
            self.cache.removeAll();
        }
    }

    private let queue = dispatch_queue_create("VideoClipCache", DISPATCH_QUEUE_SERIAL);
    private var cache = [Entry: CGImageRef]();

    public func get(clip: VideoClip, time: NSTimeInterval) -> CGImageRef? {
        let entry = Entry(clip: clip, time: time);

        return dispatch_sync(queue) {
            return self.cache[entry];
        }
    }

    public func set(clip: VideoClip, time: NSTimeInterval, image: CGImageRef) -> Void {
        let entry = Entry(clip: clip, time: time);

        dispatch_async(queue) {
            self.cache[entry] = image;

            dispatch_async_main {
                NSNotificationCenter.defaultCenter().postNotificationName(VideoClipPreviewCacheUpdated, object: self, userInfo: [
                    "Time":  time,
                    "Image": image
                ]);
            }
        }
    }
}

private func == (e1: VideoClipPreviewCache.Entry, e2: VideoClipPreviewCache.Entry) -> Bool {
    return e1.clip === e2.clip && e1.time == e2.time;
}
