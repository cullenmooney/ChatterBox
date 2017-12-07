import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]()

    
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
        
        // calling the function to get the messages from the db
        retrieveMessages()
        
        // no lines between rows
        messageTableView.separatorStyle = .none

    }
    
    //declaring cell for row at index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        // defining our messages, username, and avatar
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "avatar")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            // Messages we sent
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            // Messages we didn't send
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        return cell
        
        
    }
    
    // setting the number of cells in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of cells should be equal to how many messages are in the message array
        
        return messageArray.count
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
            
            //keyboard is 258 points height, so we add that to our height constraint of 50 -- 308 before
            self.heightConstraint.constant = 270
            
            //if a constraint or something in view has changed --> redraw it
            self.view.layoutIfNeeded()
        }
        
        chatScrollUp()
        
    }
    
    //when chat textfield is done editing --> bring the keyboard down
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        
        chatScrollUp()
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
                self.chatScrollUp()
            }
        }
        
    }
    
    //retrieving the message and user email from the db
    // changing the snapchot to a dictionary because that's how we sent to it to the db
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
                message.sender = sender
                message.messageBody = text
            
            // appending the message object into the messageArray
            self.messageArray.append(message)
            
            // reconfiguring the table view
            self.configureTableView()
            
            // reloading the table view
            self.messageTableView.reloadData()
            
            // making the chats scroll to the bottom upon loading
            self.chatScrollUp()
        })
       
    }
    
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
    
    // used when keyboard textfield is pressed and exited so that user sees most recent message
    func chatScrollUp() {
        if messageArray.count > 1 {
            let indexPath = NSIndexPath(row: messageArray.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
        else {
            
        }
    }
    
}
