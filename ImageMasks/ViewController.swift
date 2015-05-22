//
//  ViewController.swift
//  ImageMasks
//
//  Created by Janusz Chudzynski on 5/21/15.
//  Copyright (c) 2015 Janusz Chudzynski. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {
    var inputImage1:CGImageRef?
    var blendImage1:CGImageRef?
    @IBAction func process(sender: AnyObject) {
        self.imageWithMaskingColors()
    }
    @IBOutlet weak var outputImage: UIImageView!
    @IBOutlet weak var inputImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       self.view.backgroundColor = UIColor(patternImage: UIImage(named: "emptyBackground")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imageWithMaskingColors(){
        //get uiimage
        let image:CGImageRef = self.inputImage.image!.CGImage
       // let maskingColors :[CGFloat] = [124, 255,  68, 222, 0, 165]
//        let maskingColors :[CGFloat] = [0,0,0,255,255,255]
        let maskingColors :[CGFloat] = [0,200,0,255,0,255]

        
        let newciimage = CGImageCreateWithMaskingColors(image,maskingColors)
        
        let newImage = UIImage(CGImage: newciimage)
        self.outputImage.image = newImage
        let w = CGFloat(CGImageGetWidth(newciimage))
        let h = CGFloat(CGImageGetHeight(newciimage))
        let size = CGSizeMake(w,h)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext();
        
//        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
//        let rect = self.inputImage.frame
//        let context = CGBitmapContextCreate(nil, Int(rect.size.width), Int(rect.size.height), 8, 0, colorSpace, bitmapInfo)
            //CGContextDrawImage(context, self.inputImage.frame, newciimage)
        newImage?.drawInRect(CGRectMake(0, 0, w, h))
//        let cgiimage = CGBitmapContextCreateImage(context)
//        self.inputImage1 = cgiimage
//        CGContextDrawImage(<#c: CGContext!#>, <#rect: CGRect#>, <#image: CGImage!#>)
        
        let result  = UIGraphicsGetImageFromCurrentImageContext();
        self.inputImage1 = result.CGImage
        UIGraphicsEndImageContext();
        
        
    }
    
    
    @IBAction func blendMode(){
        
       
        
        let context = CIContext(options: nil)
        let inputImage:CIImage = CIImage(CGImage:self.inputImage1)
        var filter = CIFilter(name: "CISourceOutCompositing")
        println(inputImage.debugDescription)
       
        //mix it with black
        let fileURL = NSBundle.mainBundle().URLForResource("black", withExtension: "jpg")
        var backgroundImage = CIImage(contentsOfURL: fileURL)
        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
         filter.setValue(backgroundImage, forKey: kCIInputImageKey)
        println(backgroundImage.debugDescription)
        let outputImage = filter.outputImage
        println(outputImage.debugDescription)
        let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
        
        blendImage1 = cgimg
        
        let newImage = UIImage(CGImage: cgimg)
       
        self.outputImage.image = newImage
        
    }
    
    
    @IBAction func applyGradient(sender: AnyObject) {
        let w = CGFloat(CGImageGetWidth(self.inputImage1))
        let h = CGFloat(CGImageGetHeight(self.inputImage1))
        let frame = CGRectMake(0, 0, w, h)
        let size = CGSizeMake(w,h)
        //let newImage = UIImage(CGImage: blendImage1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let cxt = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(cxt, 0, h);
        CGContextScaleCTM(cxt, 1.0, -1.0);
        CGContextDrawImage(cxt, frame , blendImage1)
        CGContextSetLineDash(cxt, 0, [2,1], 2)
        CGContextSetStrokeColorWithColor(cxt, UIColor.redColor().CGColor)
     
        CGContextSetFillColorWithColor(cxt, UIColor.redColor().CGColor)
        CGContextScaleCTM(cxt, 1.0, -1.0);
        CGContextTranslateCTM(cxt, 0, -h);
        CGContextSetLineWidth(cxt, 15.0);
        CGContextSetShadowWithColor(cxt, CGSizeMake(CGFloat(-2),CGFloat(2)), CGFloat(4), UIColor.redColor().CGColor)
        CGContextFillRect(cxt, CGRectMake(0, 0, 100, 100))
        CGContextStrokePath(cxt)
        CGContextFillPath(cxt)
        let result  = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext()
        
        let maskLayer:CALayer = CALayer()
        maskLayer.frame = frame
        maskLayer.borderColor = UIColor.redColor().CGColor
        maskLayer.borderWidth = 4
        

        
        let gpaPicture = GPUImagePicture(CGImage: blendImage1)
        let canny = GPUImageCannyEdgeDetectionFilter()
        //canny.upperThreshold = CGFloat(1125)
        canny.lowerThreshold = CGFloat(1)
        gpaPicture.addTarget(canny)
        canny.useNextFrameForImageCapture()
        gpaPicture.processImage()
        let gpuResult = canny.imageByFilteringImage(UIImage(CGImage:blendImage1))
        
  //      self.outputImage.layer.insertSublayer(maskLayer, atIndex: 0)//(maskLayer)
//
    
   //     self.outputImage.image = gpuResult
        
//        let context = CIContext(options: nil)
//        let inputImage:CIImage = CIImage(CGImage:self.blendImage1)
//        var filter = CIFilter(name: "CIEdges")
//        filter.setDefaults()
//        filter.setValue(inputImage, forKey: kCIInputImageKey)
//        let output = filter.outputImage
//        let cgimg = context.createCGImage(output, fromRect: output.extent())
//        
//        self.outputImage.image = UIImage(CGImage: cgimg)
        
        
        
        
    }
    
    
}

