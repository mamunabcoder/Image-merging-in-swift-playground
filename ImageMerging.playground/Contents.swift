//: Playground - noun: a place where people can play

import UIKit
import CoreImage

func aspectFill(from: CGRect, to: CGRect) -> CGAffineTransform {
    let horizontalRatio = to.width / from .width
    let verticalRatio = to.height / from.height
    let scale = max(horizontalRatio, verticalRatio)
    let translationX = horizontalRatio < verticalRatio ? (to.width - from.width * scale) * 0.5 : 0
    let translationY = horizontalRatio > verticalRatio ? (to.height - from.height * scale) * 0.5 : 0
    return CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translationX, y: translationY)
}

func filter(image: UIImage, texture: UIImage) -> UIImage? {
    guard let imageCI = CIImage(image: image),
        let textureCI = CIImage(image: texture)
        else {
            return nil
    }

    let scaleFillTextureCI = textureCI.transformed(by: aspectFill(from: textureCI.extent, to: imageCI.extent))
    let crop = CIFilter(name: "CICrop")!
    crop.setValue(scaleFillTextureCI, forKey: "inputImage")
    crop.setValue(imageCI.extent, forKey: "inputRectangle")

    let alpha = CIFilter(name: "CIConstantColorGenerator")!
    alpha.setValue(CIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7), forKey: "inputColor")

    let mix = CIFilter(name: "CIBlendWithAlphaMask")!
    mix.setValue(imageCI, forKey: "inputImage")
    mix.setValue(crop.outputImage, forKey: "inputBackgroundImage")
    mix.setValue(alpha.outputImage, forKey: "inputMaskImage")

    let blend = CIFilter(name: "CIBlendWithMask")!
    blend.setValue(imageCI, forKey: "inputImage")
    blend.setValue(mix.outputImage, forKey: "inputBackgroundImage")
    blend.setValue(imageCI, forKey: "inputMaskImage")

    let context = CIContext(options: nil)
    guard let ciImage = blend.outputImage,
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
    }

    return UIImage(cgImage: cgImage)
}

let image = #imageLiteral(resourceName: "image.jpg")
let texture = #imageLiteral(resourceName: "texture.jpg")
let output = filter(image: image, texture: texture)
