
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
    @IBOutlet weak var indexLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentDocumentPartTitle: String!

    var currentIndex:Int = 0
    
    func update(index: Int) {
        currentIndex = index
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
            
            /*let rate = RatesNetworkService()
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
            }*/
        } catch {
            
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
    }
    
    @IBOutlet weak var removeCardViewButton: UIButton!
    
    @IBAction func send(_ sender: Any) {
        
        let nc = NotificationCenter.default
        nc.post(name:.send, object: nil, userInfo: ["message":"Hello there!", "date":Date()])
        print("send: ", currentIndex)
        
        
    }
    
    @IBAction func receive(_ sender: Any) {
        
        let nc = NotificationCenter.default
        nc.post(name:.receive, object: nil, userInfo: ["message":"Hello there!", "date":Date()])
        print("receive: ", currentIndex)
        
    }
    
}
