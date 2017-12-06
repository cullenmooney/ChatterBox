import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var incorrectLoginMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        incorrectLoginMessage.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
       
        // show loading icon after pressing login button
        SVProgressHUD.show()
        
        //logging in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {(user, error) in
            if error != nil {
                print(error!)
                self.incorrectLoginMessage.isHidden = false
                SVProgressHUD.dismiss()
            }
            else {
                print("successful login")
                
                // dismiss loading icon after logging in
                SVProgressHUD.dismiss()
                self.incorrectLoginMessage.isHidden = true
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    }
    
}  
