
import UIKit
import Kingfisher
import Rswift
import Geth

class ColoredCardView: CardView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var receive: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var rateBalanceLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var i = 0
    
    var index: Int = 0 {
        didSet {
            i = index
        }
    }
    
    let hueValue: CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
    let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
    
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius  = 10
        contentView.layer.masksToBounds = true
        
        print("index -> ", i)
        
        do {
            var ethBalance = Ether(weiString: "0.0")
            let address: GethAccount = try appDelegate.keyStore.getAccount(at: index)
            let address_str = address.getAddress().getHex()
            print("address -> ", address_str ?? "")
            addressLabel.text = address_str
            appDelegate.getBalance(address: address_str!) { result in
                switch result {
                case .success(let balance):
                    ethBalance.update(weiString: balance)
                    self.balanceLabel.text = ethBalance.symbol + " " + String(ethBalance.value)
                case .failure(let error):
                    print(error)
                }
            }
            
            let rate = RatesNetworkService()
            let currencies_array = ["ETH","USD"]
            rate.getRate(currencies: currencies_array) { result in
                switch result {
                case .success(let rates):
                    let rate_array = rates.filter { $0.from == "ETH" }
                    for index in 0...rate_array.count - 1 {
                        let current:Rate = rate_array[index]
                        if (current.to == "USD") {
                            self.rateBalanceLabel.text = "$" + String(Double(ethBalance.value) * current.value)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } catch {
        
        }
        
        presentedDidUpdate()
        
    }
    
    override var presented: Bool { didSet { presentedDidUpdate() } }
    
    func presentedDidUpdate() {
        
        //let color = UIColor(hue: hueValue, saturation: saturation, brightness: brightness, alpha: 1)
        //#f08b16 UIColor(red:0.94, green:0.55, blue:0.09, alpha:1.0)
        //removeCardViewButton.isHidden = !presented
        
        
        
        contentView.backgroundColor = UIColor.white
        contentView.addTransitionFade()
        
        iconImageView.image = UIImage(named: "Ethereum-icon")?.withRenderingMode(.alwaysTemplate)
        //iconImageView.tintColor = coin.color
        
    }
    
    @IBOutlet weak var removeCardViewButton: UIButton!
    @IBAction func removeCardView(_ sender: Any) {
        walletView?.remove(cardView: self, animated: true)
    }
    
}
