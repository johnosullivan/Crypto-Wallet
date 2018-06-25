import UIKit

public class PopupContainerView: UIView {
    var isAbleToTouchLower: Bool = false

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if isAbleToTouchLower && view == self { return nil }
            return view
        }
        return nil
    }
}
