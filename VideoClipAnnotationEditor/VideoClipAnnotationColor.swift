//
//  ClipAnnotationColor.swift
//  VideoClipAnnotationEditor
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Cocoa

private let sRedColor = VideoClipAnnotationColor(
    background: NSColor(red: 1, green: 0.39, blue: 0.36, alpha: 1),
    text:       NSColor.blackColor());

private let sOrangeColor = VideoClipAnnotationColor(
    background: NSColor(red: 1, green: 0.67, blue: 0.28, alpha: 1),
    text:       NSColor.blackColor());

private let sYellowColor = VideoClipAnnotationColor(
    background: NSColor(red: 1, green: 0.84, blue: 0.29, alpha: 1),
    text:       NSColor.blackColor());

private let sGreenColor = VideoClipAnnotationColor(
    background: NSColor(red: 0.51, green: 0.89, blue: 0.39, alpha: 1),
    text:       NSColor.blackColor());

private let sBlueColor = VideoClipAnnotationColor(
    background: NSColor(red: 0.31, green: 0.74, blue: 0.98, alpha: 1),
    text:       NSColor.blackColor());

private let sPurpleColor = VideoClipAnnotationColor(
    background: NSColor(red: 0.84, green: 0.56, blue: 0.91, alpha: 1),
    text:       NSColor.blackColor());

private let sGrayColor = VideoClipAnnotationColor(
    background: NSColor(red: 0.65, green: 0.65, blue: 0.66, alpha: 1),
    text:       NSColor.blackColor());


public struct VideoClipAnnotationColor {
    public let backgroundColor: NSColor;
    public let textColor:       NSColor;
    
    public init(background: NSColor, text: NSColor) {
        self.backgroundColor = background;
        self.textColor       = text;
    }
    
    public static func redColor() -> VideoClipAnnotationColor {
        return sRedColor;
    }

    public static func orangeColor() -> VideoClipAnnotationColor {
        return sOrangeColor;
    }

    public static func yellowColor() -> VideoClipAnnotationColor {
        return sYellowColor;
    }
    
    public static func greenColor() -> VideoClipAnnotationColor {
        return sGreenColor;
    }

    public static func blueColor() -> VideoClipAnnotationColor {
        return sBlueColor;
    }

    public static func purpleColor() -> VideoClipAnnotationColor {
        return sPurpleColor;
    }

    public static func grayColor() -> VideoClipAnnotationColor {
        return sGrayColor;
    }
}
