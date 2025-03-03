//
//  CreateGroupViewController.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/16/15.
//  Copyright (c) 2020 Logan Pratt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class CreateGroupViewController: UIViewController {

    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var groupCodeView: UITextView!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var createButtonConstraint: NSLayoutConstraint!
    @IBOutlet var topLabelConstraint: NSLayoutConstraint!

    var joinGroupVC: JoinGroupViewController?
    var ref = Database.database().reference(withPath: "groups")
    var groupCode = ""
    var codeAlreadyExists = false

    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameField.text = ""
        groupNameField.becomeFirstResponder()
        
        groupCode = generateCode()
        groupCodeView.text = groupCode
        
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        recognizer.direction = .right
        self.view.addGestureRecognizer(recognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        clearTextButton(button: createGroupButton, title: "Create Group")
    }
    
    
    @objc func swipeRight(recognizer: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "createToJoin", sender: self)
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
    
    @objc func randNum(_ num1: Int, to num2: Int) -> String{
        let num = Int(arc4random_uniform(10))
        return "\(num)"
    }
    
    
    @objc func generateCode() -> String {
        var randCode = ""
        for _ in 1...6 {
            randCode += randNum(0, to: 9)
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(randCode) {
                self.groupCode = self.generateCode()
            }
        })
        return randCode
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            clearTextButton(button: createGroupButton, title: "Create Group")
            createButtonConstraint.constant = keyboardFrame.height
            if keyboardFrame.height > 300 {
                createButtonConstraint.constant -= 35
            }
            topLabelConstraint.constant = 20
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        clearTextButton(button: createGroupButton, title: "Create Group")
        createButtonConstraint.constant = 0
        topLabelConstraint.constant = 44
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        createButtonConstraint.constant = 0.0
        topLabelConstraint.constant = 44
        return false
    }
     
    
    
    @IBAction func createGroup(_ sender: AnyObject) {
        let group = Group(name: groupNameField.text!, key: groupCode)
        let groupRef = self.ref.child(groupCode)
        groupRef.setValue(group.toAnyObject())
        
        for i in 0...5 {
            joinGroupVC?.textFields[i].text = group.key.stringAt(i)
        }
        joinGroupVC?.joinButton.isEnabled = true
        joinGroupVC?.joinButton.sendActions(for: .touchUpInside)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        groupNameField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

extension String {
    func stringAt(_ i: Int) -> String {
        return String(Array(self)[i])
    }
}
