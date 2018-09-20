//
//  CWScanViewController.swift
//  Crypto Wallet
//
//  Created by John O'Sullivan on 6/27/18.
//  Copyright © 2018 John O'Sullivan. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol CWScanViewControllerDelegate {
     func scanFinished(scanResult: CWScanResult, error: String?)
}


open class CWScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   open var scanResultDelegate: CWScanViewControllerDelegate?
    
   open var scanObj: CWScanWrapper?
    
   open var scanStyle: CWScanViewStyle? = CWScanViewStyle()
    
   open var qRScanView: CWScanView?

    
   open var isOpenInterestRect = false
    
   public var arrayCodeType:[AVMetadataObject.ObjectType]?
    
   
   public  var isNeedCodeImage = false
    
    public var readyString:String! = ""

    override open func viewDidLoad() {
        super.viewDidLoad()

       
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }

    
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
 
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
       
        perform(#selector(CWScanViewController.startScan), with: nil, afterDelay: 0.3)
        
    }
    
    @objc open func startScan()
    {
   
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = CWScanView.getScanRectWithPreView(preView: self.view, style:scanStyle! )
            }
            
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObject.ObjectType.qr ,AVMetadataObject.ObjectType.ean13 ,AVMetadataObject.ObjectType.code128]
            }
            
            scanObj = CWScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    strongSelf.qRScanView?.stopScanAnimation()
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
             })
        }
        
        qRScanView?.deviceStopReadying()
        
        qRScanView?.startScanAnimation()
        
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = CWScanView(frame: self.view.frame,vstyle:scanStyle! )
            self.view.addSubview(qRScanView!)
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)
        
    }
   
    
    open func handleCodeResult(arrayResult:[CWScanResult])
    {
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:CWScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)

        }else{
            
            for result:CWScanResult in arrayResult
            {
                print("%@",result.strScanned ?? "")
            }
            
            let result:CWScanResult = arrayResult[0]
            
            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    open func openPhotoAlbum()
    {
        CWPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
           self?.present(picker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        if (image == nil )
        {
            image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = CWScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
      
        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }
    
    func showMsg(title:String?,message:String?)
    {
        
            let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default) { (alertAction) in
                
            }
            
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
    }
    deinit
    {
//        print("CWScanViewController deinit")
    }
    
}






// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
