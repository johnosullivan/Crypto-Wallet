import UIKit

protocol Nibable: NSObjectProtocol {
    static var nibName: String { get }
    static func nib() -> UINib
}

extension Nibable where Self: UIView {
    static var nibName: String {
        return className
    }
    
    static func nib() -> UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    static func view() -> Self {
        return nib().instantiate(withOwner: nil, options: nil).first as! Self
    }
}

extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

enum DropShadowType {
    case rect, circle, dynamic
}

extension UIView {
    func addDropShadow(type: DropShadowType = .dynamic, color: UIColor = UIColor.black, opacity: Float = 0.3, radius: CGFloat = 4.0, shadowOffset: CGSize = CGSize.zero) {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = shadowOffset
        layer.shadowColor = color.cgColor
        
        switch type {
        case .circle:
            let halfWidth = frame.size.width * 0.5
            layer.shadowPath = UIBezierPath(arcCenter: CGPoint(x: halfWidth, y: halfWidth), radius: halfWidth, startAngle: 0.0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        case .rect:
            layer.shadowPath = UIBezierPath(roundedRect: frame, cornerRadius: layer.cornerRadius).cgPath
            layer.shouldRasterize = true
        case .dynamic:
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

extension UIColor {
    class func rgba(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func backgroundColor() -> UIColor {
        return UIColor.rgba(r: 235, g: 235, b: 235, alpha: 1.0)
    }
}

class ReceivedPopupView: UIView, PopupViewContainable, Nibable  {
    
    @IBOutlet weak var qrimageview: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    var addressStr: String = "" {
        didSet {
            address.text = addressStr
        }
    }
    
    var qrimage: UIImage? = nil {
        didSet {
            qrimageview.image = qrimage
        }
    }
    
    enum Const {
        static let height: CGFloat = 300
    }

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setImage(UIImage(named:"close"), for: .normal)
            closeButton.imageView?.tintColor = .black
        }
    }

    var receivedButtonTapHandler: (() -> Void)?
    var closeButtonTapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.backgroundColor()
        addDropShadow(type: .dynamic, color: .black, opacity: 0.5, radius: 3, shadowOffset: CGSize(width: 0, height: 5))
    }

    @IBAction func didTapRegisterButton() {
        receivedButtonTapHandler?()
    }

    @IBAction func didTapCloseButton() {
        closeButtonTapHandler?()
    }
}
