import UIKit
import Kingfisher
import Rswift
import Geth

class WalletCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var receive: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var rateBalanceLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    @IBOutlet weak var collectionView: TabularCollectionView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentDocumentPartTitle: String!
    var currentIndex: Int = 0
    var etherAmount: Double = 0
    
    var rateAmount: Double = 0 {
        didSet {
            self.rateBalanceLabel.text = "$" + String(rateAmount * etherAmount)
        }
    }
    
    let nc = NotificationCenter.default

    var currentBalance: String = "" {
        didSet {
            self.balanceLabel.text = currentBalance
        }
    }
    
    var currentAddress: String = "" {
        didSet {
            self.addressLabel.text = currentAddress
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius  = 10
        contentView.layer.masksToBounds = true
        presentedDidUpdate()
        
    }
    
    override var presented: Bool { didSet { presentedDidUpdate() } }
    
    func presentedDidUpdate() {
        contentView.backgroundColor = UIColor.white
        contentView.addTransitionFade()
        iconImageView.image = UIImage(named: "Ethereum-icon")?.withRenderingMode(.alwaysTemplate)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
        self.headerView.addGestureRecognizer(gesture)
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        tapped()
    }
    
    @IBOutlet weak var removeCardViewButton: UIButton!
    
    @IBAction func send(_ sender: Any) {
        do {
            let addressGeth: GethAccount = try appDelegate.keyStore.getAccount(at: currentIndex)
            let address = addressGeth.getAddress().getHex()
            nc.post(name:.send, object: nil, userInfo: ["address":address!,"index":currentIndex])
        } catch {
            print(error as Error)
        }
    }
    
    @IBAction func receive(_ sender: Any) {
        do {
            let addressGeth: GethAccount = try appDelegate.keyStore.getAccount(at: currentIndex)
            let address = addressGeth.getAddress().getHex()
            nc.post(name:.receive, object: nil, userInfo: ["address":address!,"index":currentIndex])
        } catch {
           print(error as Error)
        }
    }
}
