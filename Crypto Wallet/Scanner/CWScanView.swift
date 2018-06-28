//
//  CWScanView.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/27/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

open class CWScanView: UIView
{
    var viewStyle:CWScanViewStyle = CWScanViewStyle()
    
    var scanRetangleRect:CGRect = CGRect.zero
    
    var scanLineAnimation:CWScanLineAnimation?
    
    var scanNetAnimation:CWScanNetAnimation?
    
    var scanLineStill:UIImageView?
    
    var activityView:UIActivityIndicatorView?
    
    var labelReadying:UILabel?
    
    var isAnimationing:Bool = false

    public init(frame:CGRect, vstyle:CWScanViewStyle )
    {
        viewStyle = vstyle
        
        switch (viewStyle.anmiationStyle)
        {
        case CWScanViewAnimationStyle.LineMove:
            //scanLineAnimation = CWScanLineAnimation.instance()
            break
        case CWScanViewAnimationStyle.NetGrid:
            //scanNetAnimation = CWScanNetAnimation.instance()
            break
        case CWScanViewAnimationStyle.LineStill:
            //scanLineStill = UIImageView()
            //scanLineStill?.image = viewStyle.animationImage
            break
            
            
        default:
            break
        }
        
        var frameTmp = frame;
        frameTmp.origin = CGPoint.zero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        
        var frameTmp = frame;
        frameTmp.origin = CGPoint.zero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        self.init()
       
    }
    
    deinit
    {
        if (scanLineAnimation != nil)
        {
            scanLineAnimation!.stopStepAnimating()
        }
        if (scanNetAnimation != nil)
        {
            scanNetAnimation!.stopStepAnimating()
        }
        
        
//        print("CWScanView deinit")
    }
    
    
  
    func startScanAnimation()
    {
        if isAnimationing
        {
            return
        }
        
        isAnimationing = true
        
        let cropRect:CGRect = getScanRectForAnimation()
        
        switch viewStyle.anmiationStyle
        {
        case CWScanViewAnimationStyle.LineMove:
            
            
            scanLineAnimation!.startAnimatingWithRect(animationRect: cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case CWScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation!.startAnimatingWithRect(animationRect: cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case CWScanViewAnimationStyle.LineStill:
            
            let stillRect = CGRect(x: cropRect.origin.x+20,
                                   y: cropRect.origin.y + cropRect.size.height/2,
                                   width: cropRect.size.width-40,
                                   height: 2);
            self.scanLineStill?.frame = stillRect
            
            self.addSubview(scanLineStill!)
            self.scanLineStill?.isHidden = false
            
            break
            
        default: break
            
        }
    }
    

    func stopScanAnimation()
    {
        isAnimationing = false
        
        switch viewStyle.anmiationStyle
        {
        case CWScanViewAnimationStyle.LineMove:
            
            scanLineAnimation?.stopStepAnimating()
            break
        case CWScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation?.stopStepAnimating()
            break
        case CWScanViewAnimationStyle.LineStill:
             self.scanLineStill?.isHidden = true
            
            break
            
        default: break
            
        }
    }

    
    
 
    override open func draw(_ rect: CGRect)
    {
        // Drawing code
        drawScanRect()
    }
    
    func drawScanRect()
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2.0, height: self.frame.size.width - XRetangleLeft*2.0)
        if viewStyle.whRatio != 1.0
        {
            let w = sizeRetangle.width;
            var h:CGFloat = w / viewStyle.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let YMaxRetangle = YMinRetangle + sizeRetangle.height
        let XRetangleRight = self.frame.size.width - XRetangleLeft
        
        
        
        let context = UIGraphicsGetCurrentContext()!
        

        context.setFillColor(viewStyle.color_NotRecoginitonArea.cgColor)
        
        var rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: YMinRetangle)
            context.fill(rect)
            
            
        rect = CGRect(x: 0, y: YMinRetangle, width: XRetangleLeft, height: sizeRetangle.height)
            context.fill(rect)
            
        rect = CGRect(x: XRetangleRight, y: YMinRetangle, width: XRetangleLeft,height: sizeRetangle.height)
            context.fill(rect)
            
        rect = CGRect(x: 0, y: YMaxRetangle, width: self.frame.size.width,height: self.frame.size.height - YMaxRetangle)
            context.fill(rect)
            context.strokePath()
        
        
        if viewStyle.isNeedShowRetangle
        {
            context.setStrokeColor(viewStyle.colorRetangleLine.cgColor)
            context.setLineWidth(1);
            
            context.addRect(CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height))
            
            //CGContextMoveToPoint(context, XRetangleLeft, YMinRetangle);
            //CGContextAddLineToPoint(context, XRetangleLeft+sizeRetangle.width, YMinRetangle);
            
            context.strokePath()
            
        }
        scanRetangleRect = CGRect(x: XRetangleLeft, y:  YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
      
        let wAngle = viewStyle.photoframeAngleW;
        let hAngle = viewStyle.photoframeAngleH;
        
        let linewidthAngle = viewStyle.photoframeLineW;
        
        var diffAngle = linewidthAngle/3;
        diffAngle = linewidthAngle / 2;
        diffAngle = linewidthAngle/2;
        diffAngle = 0;
        
        switch viewStyle.photoframeAngleStyle
        {
        case CWScanViewPhotoframeAngleStyle.Outer:
                diffAngle = linewidthAngle/3
           
        case CWScanViewPhotoframeAngleStyle.On:
                diffAngle = 0
            
        case CWScanViewPhotoframeAngleStyle.Inner:
                diffAngle = -viewStyle.photoframeLineW/2
        }
        
        context.setStrokeColor(viewStyle.colorAngle.cgColor);
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
        
        context.setLineWidth(linewidthAngle);
        
        
        let leftX = XRetangleLeft - diffAngle
        let topY = YMinRetangle - diffAngle
        let rightX = XRetangleRight + diffAngle
        let bottomY = YMaxRetangle + diffAngle
        
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
        
        context.move(to: CGPoint(x: leftX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: topY+hAngle))
        
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
        
        context.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))

        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))
        
        context.move(to: CGPoint(x: rightX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))

        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))
        
        context.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))
        
        context.strokePath()
    }
    
    func getScanRectForAnimation() -> CGRect
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2, height: self.frame.size.width - XRetangleLeft*2)
        
        if viewStyle.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / viewStyle.whRatio
            
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let cropRect =  CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        return cropRect;
    }

    static func getScanRectWithPreView(preView:UIView, style:CWScanViewStyle) -> CGRect
    {
        let XRetangleLeft = style.xScanRetangleOffset;
        var sizeRetangle = CGSize(width: preView.frame.size.width - XRetangleLeft*2, height: preView.frame.size.width - XRetangleLeft*2)
        
        if style.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / style.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        let YMinRetangle = preView.frame.size.height / 2.0 - sizeRetangle.height/2.0 - style.centerUpOffset
        let cropRect =  CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
        var rectOfInterest:CGRect
        
        let size = preView.bounds.size;
        let p1 = size.height/size.width;
        
        let p2:CGFloat = 1920.0/1080.0
        if p1 < p2 {
            let fixHeight = size.width * 1920.0 / 1080.0;
            let fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRect(x: (cropRect.origin.y + fixPadding)/fixHeight,
                                    y: cropRect.origin.x/size.width,
                                    width: cropRect.size.height/fixHeight,
                                    height: cropRect.size.width/size.width)
            
            
        } else {
            let fixWidth = size.height * 1080.0 / 1920.0;
            let fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRect(x: cropRect.origin.y/size.height,
                                    y: (cropRect.origin.x + fixPadding)/fixWidth,
                                    width: cropRect.size.height/size.height,
                                    height: cropRect.size.width/fixWidth)
        }
        return rectOfInterest
    }
    
    func getRetangeSize()->CGSize
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2, height: self.frame.size.width - XRetangleLeft*2)
        
        let w = sizeRetangle.width;
        var h = w / viewStyle.whRatio;
        
        
        let hInt:Int = Int(h)
        h = CGFloat(hInt)
        
        sizeRetangle = CGSize(width: w, height:  h)
        
        return sizeRetangle
    }
    
    func deviceStartReadying(readyStr:String)
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        let sizeRetangle = getRetangeSize()
        
        
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        

        if (activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            activityView?.center = CGPoint(x: XRetangleLeft +  sizeRetangle.width/2, y: YMinRetangle + sizeRetangle.height/2)
            activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            
            addSubview(activityView!)
            
            
            let labelReadyRect = CGRect(x: activityView!.frame.origin.x + activityView!.frame.size.width + 10, y: activityView!.frame.origin.y, width: 100, height: 30);
            //print("%@",NSStringFromCGRect(labelReadyRect))
            self.labelReadying = UILabel(frame: labelReadyRect)
            labelReadying?.text = readyStr
            labelReadying?.backgroundColor = UIColor.clear
            labelReadying?.textColor = UIColor.white
            labelReadying?.font = UIFont.systemFont(ofSize: 18.0)
            //addSubview(labelReadying!)
        }
        
         addSubview(labelReadying!)
         activityView?.startAnimating()
        
    }
    
    func deviceStopReadying()
    {
        if activityView != nil
        {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            labelReadying?.removeFromSuperview()
            
            activityView = nil
            labelReadying = nil
            
        }
    }

}
