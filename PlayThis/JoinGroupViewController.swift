//
//  JoinGroupViewController.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2020 Logan Pratt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class JoinGroupViewController: UIViewController {
    
    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var fourthField: UITextField!
    @IBOutlet weak var fifthField: UITextField!
    @IBOutlet weak var sixthField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    
    var textFields: Array<UITextField>!
    var ref: DatabaseReference!
    var group: Group!
    let defaults: UserDefaults = UserDefaults.standard
    var previousCodes: [String] = []
    var previousCount = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        joinButton.isEnabled = false
        
        textFields = [firstField, secondField, thirdField, fourthField, fifthField, sixthField]
        ref = Database.database().reference(withPath: "groups")
        group = Group()
        clearTextButton(button: joinButton, title: "Join Group")
        if let previousData = UserDefaults.standard.object(forKey: "previousCodes") as? NSData {
            //if let previousData = previousData {
            previousCodes = (NSKeyedUnarchiver.unarchiveObject(with: previousData as Data) as? [String])!
            previousCount = previousCodes.count-1
            previousButton.isHidden = false
            //}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = PlaybackHelper.sharedInstance.storedPVC {
            PlaybackHelper.sharedInstance.storedPVC.dismiss(animated: false, completion: nil)
            if let _ = PlaybackHelper.sharedInstance.storedPVC.timer {
                PlaybackHelper.sharedInstance.storedPVC.timer.invalidate()
            }
        }
    }
    
    @objc func clearTextButton(button: UIButton, title: NSString) {
        button.titleLabel?.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.clear, for: .normal)
        button.setTitle(title as String, for: [])
        let buttonSize: CGSize = button.bounds.size
        let font: UIFont = button.titleLabel!.font
        let attribs: [String : AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let textSize: CGSize = title.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attribs))
        UIGraphicsBeginImageContextWithOptions(buttonSize, false, UIScreen.main.scale)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        let center: CGPoint = CGPoint(x: buttonSize.width / 2 - textSize.width / 2, y: buttonSize.height / 2 - textSize.height / 2)
        let path: UIBezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.destinationOut)
        title.draw(at: center, withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]))
        let viewImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let maskLayer: CALayer = CALayer()
        maskLayer.contents = ((viewImage.cgImage) as AnyObject)
        maskLayer.frame = button.bounds
        button.layer.mask = maskLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearCode(_ sender: AnyObject) {
        clearCode()
    }
    
    @objc func clearCode() {
        for textField in textFields {
            textField.text = ""
        }
        joinButton.isEnabled = false
        firstField.becomeFirstResponder()
    }
    
    @IBAction func previousCode(_ sender: Any) {
        for (i, c) in previousCodes[previousCount].enumerated() {
            textFields[i].text = c.description
        }
        joinButton.isEnabled = true
        if previousCount > 0 {
            previousCount -= 1
        } else {
            previousCount = previousCodes.count-1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    public func dismissKeyboard() {
        var allFieldsFull = true
        
        for textField in textFields {
            textField.resignFirstResponder()
            if textField.text!.count == 0 {
                allFieldsFull = false
            }
        }
        
        if allFieldsFull {
            joinButton.isEnabled = true
        } else {
            joinButton.isEnabled = false
        }
    }
    
    @IBAction func unwindToJoin(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func joinGroup(_ sender: AnyObject) {
        var enteredCode = ""
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
                SongsHelper.sharedInstance.groupCode = self.group.key
                
                if let dupeIndex = self.previousCodes.index(of: self.group.key) {
                    self.previousCodes.remove(at: dupeIndex)
                }
                self.previousCodes.append(self.group.key)
                let previousData = NSKeyedArchiver.archivedData(withRootObject: self.previousCodes)
                self.defaults.set(previousData, forKey: "previousCodes")
                self.defaults.synchronize()
                self.previousButton.isHidden = false
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-\(self.group.key)",
                    AnalyticsParameterItemName: "join",
                    AnalyticsParameterContentType: self.group.name
                ])
                
                playlistViewController.modalPresentationStyle = .fullScreen
                self.present(playlistViewController, animated: true, completion: nil)
            } else {
                _ = SweetAlert().showAlert("Incorrect code", subTitle: "Please enter the group code again.", style: AlertStyle.error)
                self.clearCode()
            }
        })
    }
    
    @IBAction func createGroup(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let createGroupVC = storyBoard.instantiateViewController(withIdentifier: "createGroup") as! CreateGroupViewController
        createGroupVC.joinGroupVC = self
        self.present(createGroupVC, animated: true, completion: nil)
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

extension JoinGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldProcess = false
        var shouldMoveToNextField = false
        
        let insertStringLength = string.count
        if insertStringLength == 0 {
            shouldProcess = true
        } else {
            if textField.text!.count == 0 {
                shouldProcess = true
            }
        }
        
        if shouldProcess {
            var newString = textField.text
            
            if newString!.count == 0 {
                newString = "\(string)"
                shouldMoveToNextField = true
            } else {
                if insertStringLength > 0 {
                    newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                } else {
                    newString = ""
                }
            }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
