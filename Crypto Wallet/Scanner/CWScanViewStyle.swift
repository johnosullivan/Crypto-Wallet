//
//  CWScanViewStyle.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/27/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

public enum CWScanViewAnimationStyle
{
   case LineMove
   case NetGrid
   case LineStill
   case None
}


public enum CWScanViewPhotoframeAngleStyle
{
    case Inner
    case Outer
    case On
}


public struct CWScanViewStyle
{
    

    public var isNeedShowRetangle:Bool = true
    
    public var whRatio:CGFloat = 1.0
    
    public var centerUpOffset:CGFloat = 44
    
    public var xScanRetangleOffset:CGFloat = 60
    
    public var colorRetangleLine = UIColor.white
    
    public var photoframeAngleStyle = CWScanViewPhotoframeAngleStyle.Outer
    
    public var colorAngle = UIColor.red
    
    public var photoframeAngleW:CGFloat = 24.0
    public var photoframeAngleH:CGFloat = 24.0

    public var photoframeLineW:CGFloat = 6
    
    public var anmiationStyle = CWScanViewAnimationStyle.NetGrid
    
    public var animationImage:UIImage?
    
    public var color_NotRecoginitonArea:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5);
    
    public init()
    {
        
    }
    

}
















