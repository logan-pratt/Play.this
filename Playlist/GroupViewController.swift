//
//  GroupViewController.swift
//  Playlist
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse
//import IJReachability
import Crashlytics
import Firebase
import FirebaseDatabase

class GroupViewController: UIViewController {
    
    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var fourthField: UITextField!
    @IBOutlet weak var fifthField: UITextField!
    @IBOutlet weak var sixthField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    var textFields: Array<UITextField>!
    var ref: FIRDatabaseReference!
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinButton.isEnabled = false
        textFields = [firstField, secondField, thirdField, fourthField, fifthField, sixthField]
        ref = FIRDatabase.database().reference(withPath: "groups")
        group = Group()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearCode(_ sender: AnyObject) {
        clearCode()
    }
    
    func clearCode() {
        for textField in textFields {
            textField.text = ""
        }
        joinButton.isEnabled = false
        //firstField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    public func dismissKeyboard() {
        var allFieldsFull = true
        
        for textField in textFields {
            textField.resignFirstResponder()
            if textField.text!.characters.count == 0 {
                allFieldsFull = false
            }
        }
        
        if allFieldsFull {
            joinButton.isEnabled = true
        } else {
            joinButton.isEnabled = false
        }
    }
    
    @IBAction func unwindToGroup(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func joinGroup(_ sender: AnyObject) {
        // if IJReachability.isConnectedToNetwork() {
        var enteredCode = ""
//        var groupCode = ""
//        var groupName = ""
//        var groupId = ""

        for textField in textFields {
            enteredCode += textField.text!
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(enteredCode) {
                self.group = Group(name: snapshot.childSnapshot(forPath: "\(enteredCode)/name").value as! String, key: enteredCode)
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let playlistViewController = storyBoard.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
                playlistViewController.groupName = self.group.name
                playlistViewController.groupCode = self.group.key
                self.present(playlistViewController, animated: true, completion: nil)
            } else {
                SweetAlert().showAlert("Incorrect code", subTitle: "Please enter the group code again.", style: AlertStyle.error)
                self.clearCode()
            }
        })
//
        print(enteredCode)
    
//        let query = PFQuery(className: "Group")
//        query.whereKey("groupCode", equalTo: enteredCode)
//        query.findObjectsInBackground { (groups: [PFObject]?, error: Error?) in
//            if error == nil {
//                if let groups = groups as? [PFObject] {
//                    for group in groups {
//                        groupCode = group["groupCode"] as! String
//                        groupName = group["groupName"] as! String
//                        groupId = group.objectId!
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//            
//            if groupCode != "" {
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let playlistViewController = storyBoard.instantiateViewController(withIdentifier: "playlist") as! PlaylistViewController
//                playlistViewController.groupName = groupName
//                playlistViewController.groupCode = groupCode
//                self.present(playlistViewController, animated: true, completion: nil)
//            } else {
//                SweetAlert().showAlert("Incorrect code", subTitle: "Please enter the group code again.", style: AlertStyle.error)
//                self.clearCode()
//            }
//        }HERE
                //        } else {
        //            SweetAlert().showAlert("No connection", subTitle: "Please check your internet connection and try again.", style: AlertStyle.Error)
        //        }
        
        
    }
    
    /*
    // MARK: - Navigation////////////////
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
extension GroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldProcess = false
        var shouldMoveToNextField = false
        
        let insertStringLength = string.characters.count
        if insertStringLength == 0 {
            shouldProcess = true
        } else {
            if textField.text!.characters.count == 0 {
                shouldProcess = true
            }
        }
        
        if shouldProcess {
            var newString = textField.text
            
            if newString!.characters.count == 0 {
                newString = "\(string)"
                shouldMoveToNextField = true
            } else {
                if insertStringLength > 0 {
                    newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                } else {
//                    newString?.deleteCharactersInRange(range)
                    newString = ""
                }
            }
            //print(newString)
            textField.text = newString!
            
            if shouldMoveToNextField {
                let nextResponder = textField.superview?.viewWithTag(textField.tag + 1)
                
                if let nextResponder = nextResponder {
                    nextResponder.becomeFirstResponder()
                } else {
                    dismissKeyboard()
                }
            }
        }
        return false
    }
}

//extension String {
//    mutating func deleteCharactersInRange(_ range: NSRange) {
//        let startIndex = self.index(self.startIndex, offsetBy: range.location)
//        let length = range.length
//        self.removeSubrange(Range<String.Index>(start: startIndex, end:startIndex.advancedBy(n: length)))
////        self.removeSubrange((startIndex ..< String.CharacterView corresponding to `startIndex`.index(startIndex, offsetBy: length)))
//    }
//}





