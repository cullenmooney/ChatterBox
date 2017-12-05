import UIKit
import Firebase
import SVProgressHUD


class RegisterViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        // Showing loading icon after registering
        SVProgressHUD.show()
        
        // Creating a user in our db
        
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            (user, error) in
            if error != nil {
                print(error!)
            }
            else {
                //success
                print("regristration successful")
                
                // Dismissing loading icon after registration
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }

    }
}
