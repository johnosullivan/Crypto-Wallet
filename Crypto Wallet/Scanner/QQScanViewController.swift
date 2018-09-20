//
//  QQScanViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/27/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit

class QQScanViewController: CWScanViewController {
    
    
    var topTitle:UILabel?

    var isOpenedFlash:Bool = false
    
    var bottomItemsView:UIView?
    
    var btnPhoto:UIButton = UIButton()
    
    var btnFlash:UIButton = UIButton()
    
    var btnMyQR:UIButton = UIButton()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedCodeImage(needCodeImg: true)
        
        scanStyle?.centerUpOffset += 10
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawBottomItems()
    }
    
    var addressHandler: ((_ result: CWScanResult) -> Void)?
  
    override func handleCodeResult(arrayResult: [CWScanResult]) {
        
        for result:CWScanResult in arrayResult
        {
            if let str = result.strScanned {
                print(str)
            }
        }
        
        let result:CWScanResult = arrayResult[0]
        
        //print(result)
        
        addressHandler!(result)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect(x: 0.0, y: yMax-100,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width/2, y: bottomItemsView!.frame.height/2)
        btnFlash.backgroundColor = UIColor.yellow
        btnFlash.addTarget(self, action: #selector(QQScanViewController.openOrCloseFlash), for: UIControl.Event.touchUpInside)
        
        
        self.btnPhoto = UIButton()
        btnPhoto.bounds = btnFlash.bounds
        btnPhoto.center = CGPoint(x: bottomItemsView!.frame.width/4, y: bottomItemsView!.frame.height/2)
        btnPhoto.backgroundColor = UIColor.red
        btnPhoto.addTarget(self, action: #selector(QQScanViewController.openLocalPhotoAlbum), for: UIControl.Event.touchUpInside)
        
        bottomItemsView?.addSubview(btnFlash)
        bottomItemsView?.addSubview(btnPhoto)
        //bottomItemsView?.addSubview(btnMyQR)
        
        self.view .addSubview(bottomItemsView!)
        
    }
    
    @objc func openLocalPhotoAlbum()
    {
       self.dismiss(animated: true, completion: nil)
    }

    
    @objc func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
    }
    
    @objc func myCode()
    {
        
    }


}

