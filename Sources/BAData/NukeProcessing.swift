//
//  File.swift
//  
//
//  Created by Bryan on 2/18/20.
//

import Foundation
import Nuke
import UIKit

public final class ImageFilterDrawInCircle: NSObject, ImageProcessing {
    public var identifier: String = "ImageFilterDrawInCircle"
    
    public func process(image: Image, context: ImageProcessingContext?) -> Image? {
        return drawImageInCircle(image: cropImageToSquare(image: image))
    }
    
}

public func drawImageInCircle(image: UIImage?) -> UIImage? {
    guard let image = image else {
        return nil
    }
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
    let radius = min(image.size.width, image.size.height) / 2.0
    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
    image.draw(in: rect)
    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return processedImage
}

public func cropImageToSquare(image: UIImage?) -> UIImage? {
    guard let image = image else {
        return nil
    }
    func cropRectForSize(size: CGSize) -> CGRect {
        let side = min(floor(size.width), floor(size.height))
        let origin = CGPoint(x: floor((size.width - side) / 2.0), y: floor((size.height - side) / 2.0))
        return CGRect(origin: origin, size: CGSize(width: side, height: side))
    }
    let bitmapSize = CGSize(width: image.cgImage!.width, height: image.cgImage!.height)
    guard let croppedImageRef = image.cgImage!.cropping(to: cropRectForSize(size: bitmapSize)) else {
        return nil
    }
    return UIImage(cgImage: croppedImageRef, scale: image.scale, orientation: image.imageOrientation)
}

