import UIKit

extension CGRect {
    func addBottomInset(_ insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: origin.x, y: origin.y - insets.bottom, width: width, height: height)
    }

    func addTopInset(_ insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: origin.x, y: origin.y + insets.bottom, width: width, height: height)
    }
}
