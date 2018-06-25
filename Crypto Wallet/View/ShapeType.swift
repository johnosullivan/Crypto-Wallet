import UIKit

public enum ShapeType {
    //Corner square
    case normal

    //Corner rounded
    case rounded(cornerSize: CGFloat)

    //Corner rounded only top
    case roundedCornerTop(cornerSize: CGFloat)

    //Corner rounded only bottom
    case roundedCornerBottom(cornerSize: CGFloat)
}
