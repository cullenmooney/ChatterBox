import UIKit
import Firebase


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
    
    // Declare instance variables here

    
    // IB outlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting self as the tableview delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        
        //setting self as the textfield delegate
        messageTextfield.delegate = self
        
        
    
        //tap gesture for when user taps out of the messagefield
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        

        //registering the custom message cell
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        // calling the custom message cell height function
        configureTableView()
        
    }
    
    //declaring cell for row at index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let messageArray = ["First Message", "Second Message", "Third Message"]
        
        cell.messageBody.text = messageArray[indexPath.row]
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    
    //this will call message did end editing so that keyboard goes back down
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }

    
    
    // setting the message cell up with the constraint that allows it to expand based on message length
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    //when chat textfield is pressed --> bring the keyboard up
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
             //keyboard is 258 points height, so we add that to our height constraint of 50
            self.heightConstraint.constant = 308
            
            //if a constraint or something in view has changed --> redraw it
            self.view.layoutIfNeeded()
        }
    }
    
    
    //when chat textfield is done editing --> bring the keyboard down
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        // dropping the keyboard when send it hit
        messageTextfield.endEditing(true)
        
        // disabling the textfield and send button when message is sending so you can't send the message twice
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email,
                                 "MessageBody" : messageTextfield.text!]
        
        //saving our message dictionary inside our messages db
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully")
                //enabling our textfield and send button and making our textfield empty
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    

    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //logging out the user and sending them back to the homepage
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("there was an error signing out")
        }
    }
    
}
