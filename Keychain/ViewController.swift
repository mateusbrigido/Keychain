import UIKit

class ViewController: UIViewController {

    let keychain = Keychain()
    
    @IBOutlet weak var passwordTypeSwitch: UISwitch!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var serviceTextField: UITextField!
    
    @IBOutlet weak var serverStackView: UIStackView!
    @IBOutlet weak var serviceStackView: UIStackView!
    
    @IBOutlet weak var resultTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        try? keychain.addOrUpdateItem(with: setupOptions())
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        try? keychain.deletePassword(with: setupOptions())
    }
    
    @IBAction func readButtonTapped(_ sender: UIButton) {
        if let result = keychain.getPassword(options: setupOptions()) {
            resultTextField.text = "\(result.account) - \(result.password)"
        } else {
            resultTextField.text = "Not Found"
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        serverStackView.isHidden = !passwordTypeSwitch.isOn
        serviceStackView.isHidden = passwordTypeSwitch.isOn
    }
    
    private func setupOptions() -> Keychain.Options {
        var options: Keychain.Options!
        if passwordTypeSwitch.isOn {
            options = Keychain.Options(itemClass: .internetPassword)
            options.server = serverTextField.text
        } else {
            options = Keychain.Options(itemClass: .genericPassword)
            options.service = serviceTextField.text
        }
        
        options.account = usernameTextField.text
        options.data = passwordTextField.text?.data(using: .utf8)
        
        return options
    }
    
}

