import UIKit

public class NotificationBar {
    
    public static var statusBarHeight: CGFloat {
        let bounds = UIScreen.main.bounds
        let height = max(bounds.height, bounds.width)
        if case 0..<812 = height {
            /// There is a regular status bar, and not a notch.
            return 25.0
        } else {
            /// There is a notch.
            return 50.0
        }
    }
    
    /// Use to set universal configuration for the Notification Bar
    public static let sharedConfig = NotificationBarConfiguration()
    
    private let presenter: UIViewController
    private let text: String
    private let style: NotificationBarStyle
    private let onDismiss: (() -> ())?
    private var view: UIView!
    
    // MARK: - Initializer
    
    /// Initialize the NotificationBar
    ///
    /// - Parameters:
    ///   - presenter: The view controller which presents the notification bar
    ///   - text: The text to be shown inside the notification bar
    ///   - style: The style of the notification bar
    ///   - onDismiss: Method of dismissing the notification bar
    public init(over presenter: UIViewController,
                text: String,
                style: NotificationBarStyle,
                onDismiss: (() -> ())? = nil) {
        
        self.presenter = presenter
        self.text = text
        self.style = style
        self.onDismiss = onDismiss
        setupView()
        subscribeForRotationChanges()
    }
    
    // MARK: - Public Methods
    
    /// Present the notification bar.
    /// **Don't forget to dismiss if dismiss style is .manual**
    public func show() {
        animateIn()
    }
    
    /// Dismiss the notification bar in case the dismiss method is .manual
    public func dismiss() {
        animateOut(withDelay: 0)
    }
    
    // MARK: - Private Methods
    
    // MARK: Setup
    
    private func setupView() {

        let width = presenter.view.frame.width
        let height = NotificationBar.statusBarHeight + NotificationBar.sharedConfig.bottomPadding + textHeight()
        view = UIView(frame: CGRect(x: 0,
                                    y: -height,
                                    width: width,
                                    height: height))
        view.backgroundColor = style.config().backgroundColor
        view.alpha = 0
        
        presenter.view.addSubview(view)
        
        setupLabel()
        setupLoader()
    }
    
    private func setupLabel() {
        
        let bottomPadding = NotificationBar.sharedConfig.bottomPadding
        let font = NotificationBar.sharedConfig.font
        let textColor = NotificationBar.sharedConfig.textColor
        
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = textColor
        label.sizeToFit()
        label.center = .init(x: view.bounds.midX, y: view.bounds.maxY - label.bounds.height - bottomPadding)

        view.addSubview(label)
    }
    
    private func setupLoader() {
        guard !style.config().isLoaderHidden else {
            return
        }
        let loader = UIActivityIndicatorView(style: .white)
        loader.center.x = view.frame.width - loader.frame.width
        loader.center.y = view.frame.height / 2
        view.addSubview(loader)
        loader.startAnimating()
    }
    
    // MARK: Animation
    
    private func animateIn() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1
            self.view.center.y += self.view.frame.height
        }, completion: nil)
        
        if style.config().dismiss == .auto {
            animateOut(withDelay: NotificationBar.sharedConfig.duration)
        }
    }
    
    private func animateOut(withDelay delay: TimeInterval) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            self.view.alpha = 0
            self.view.center.y -= self.view.frame.height
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.onDismiss?()
        })
    }
    
    // MARK: Text Height
    
    private func textHeight() -> CGFloat {
        let font = NotificationBar.sharedConfig.font
        let size = (text as NSString).size(withAttributes: [.font: font])
        let lines = Int(size.width / presenter.view.frame.width) + 1
        return CGFloat(lines) * size.height
    }
    
    // MARK: Rotation
    
    private func subscribeForRotationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleRotation() {
        setupView()
        animateIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
