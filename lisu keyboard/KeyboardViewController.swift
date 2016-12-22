//
//  KeyboardViewController.swift
//  lisu keyboard
//
//  Created by Amos Gwa on 12/21/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    var backspaceButtonTimer: Timer!
    var alphaCharacters : [String] = []
    
    
    // Constants describing number of keys in each row
    // Bottom row will take up slack/overflow
    let topRowNumButtons = 10
    let midRowNumButtons = 9
    
    var viewWidth: CGFloat = 0.0
    var buttonWidth: CGFloat = 0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate the viewWidth
        viewWidth = UIScreen.main.bounds.width
        NSLog("viewWidth \(viewWidth)")
        buttonWidth = viewWidth/CGFloat(topRowNumButtons)
        NSLog("buttonWidth \(buttonWidth)")
        
        // Add next keyboard
        self.nextKeyboardButton = UIButton(type: .system)        
        self.nextKeyboardButton.backgroundColor = UIColor.init(white: 1, alpha: 1)        
        
        self.nextKeyboardButton.setImage(UIImage.fontAwesomeIcon(name: .keyboardO, textColor: UIColor.black, size: CGSize(width: 30, height: 30)), for: [])
        
        self.nextKeyboardButton.sizeToFit()
        
        self.nextKeyboardButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.nextKeyboardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        NSLog("Keyboard color \(self.nextKeyboardButton)")
        // Make Letter keys
        alphaCharacters = ["꓿", "ꓪ", "ꓰ", "ꓣ", "ꓔ", "ꓬ", "ꓴ", "ꓲ", "ꓳ", "ꓑ","ꓮ", "ꓢ", "ꓓ", "ꓝ", "ꓖ", "ꓧ", "ꓙ", "ꓗ", "ꓡ", "ꓜ", "ꓫ", "ꓚ", "ꓦ", "ꓐ", "ꓠ", "ꓳ"]
        
        // Make empty button array to append to letter
        var keys = [UIButton]()
        
        // Loop over alphaCharacters to create key butons
        for (i,alphaChar) in alphaCharacters.enumerated() {
            keys.append(makeButton(character: alphaChar, tag: i))
        }
        
        // Add button to self.view
        for key in keys {
            self.view.addSubview(key)
        }
      
        // Add letter key constraints
        
        
        // Loop over buttons array setting constrains
        for(i, button) in keys.enumerated() {
            // consider each row of the keyboard
            if i < topRowNumButtons {
                // Top ROW
                
                // Align the top of all buttons in row with the top of self.view
                button.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                
                if i == 0 {
                    // align the left most button left side with the left side of self.view
                    button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                } else {
                    // else align left side of button with right side of button to the left
                    button.leftAnchor.constraint(equalTo: keys[i-1].rightAnchor).isActive = true
                }
            } else if i < topRowNumButtons + midRowNumButtons {
                // Mid Row
                
                // Align top of all buttons in row with bottom of top row's first button
                button.topAnchor.constraint(equalTo: keys[0].bottomAnchor).isActive = true
                
                if i == topRowNumButtons {
                    // align the leftmost button's left side with the left side of self.view
                    button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                } else {
                    // Else align left side of button with right side of button to the left
                    button.leftAnchor.constraint(equalTo: keys[i-1].rightAnchor).isActive = true
                }
            } else {
                // BOTTOM ROW
                
                // align top of all buttons in row with bottom of mid row's first button
                button.topAnchor.constraint(equalTo: keys[topRowNumButtons].bottomAnchor).isActive = true
                
                if i == topRowNumButtons + midRowNumButtons {
                    // align the leftmost button's left side with the left side of self.view
                    button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                } else {
                    // else align left side of button with right side of button to the left
                    button.leftAnchor.constraint(equalTo: keys[i - 1].rightAnchor).isActive = true
                }
            }
        }
        
        // Add backspace button
        let backspaceKey = UIButton(type: .system)
        
        // Add next keyboard
        backspaceKey.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        backspaceKey.setImage(UIImage.fontAwesomeIcon(name: .windowCloseO, textColor: UIColor.black, size: CGSize(width: 30, height: 30)), for: [])
        
        backspaceKey.sizeToFit()
        
        backspaceKey.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backspaceKey.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backspaceKey.translatesAutoresizingMaskIntoConstraints = false
        
        backspaceKey.addTarget(self, action: #selector(KeyboardViewController.backspaceOnePressed), for: .touchUpInside)
        backspaceKey.addTarget(self, action: #selector(KeyboardViewController.backspaceLongPressed), for: .touchDown)
        
        self.view.addSubview(backspaceKey)
        
        backspaceKey.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        backspaceKey.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func backspaceLongPressed() {
        backspaceButtonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.backspaceDelete), userInfo: nil, repeats: true)
    }
    
    func backspaceOnePressed() {
        backspaceButtonTimer.invalidate()
        self.backspaceDelete()
    }
    
    func backspaceDelete() {
        self.textDocumentProxy.deleteBackward()
    }
    
    func keyPressedOnce(sender: UIButton) {
        textDocumentProxy.insertText(self.alphaCharacters[sender.tag])
    }
    
    func makeButton(character: String, tag: Int) -> UIButton {
        
        // Add backspace button
        let backspaceKey = UIButton()
        // Add next keyboard
        backspaceKey.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        backspaceKey.setTitle(character, for: [])
        backspaceKey.setTitleColor(UIColor.darkGray, for: [])
        backspaceKey.tag = tag
        //backspaceKey.setImage(UIImage.fontAwesomeIcon(name: .windowCloseO, textColor: UIColor.black, size: CGSize(width: 30, height: 30)), for: [])
        
        backspaceKey.sizeToFit()
        
        backspaceKey.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        backspaceKey.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backspaceKey.translatesAutoresizingMaskIntoConstraints = false
        
        backspaceKey.addTarget(self, action: #selector(KeyboardViewController.keyPressedOnce), for: .touchUpInside)
        //backspaceKey.addTarget(self, action: #selector(KeyboardViewController.backspaceLongPressed), for: .touchDown)
        
        
//        // Create the button
//        let button = UIView()
//        button.backgroundColor = UIColor.init(white: 1, alpha: 1)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Create button label
//        let buttonLabel = UILabel()
//        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
//        buttonLabel.text = character
//        
//        // Add button label to button
//        button.addSubview(buttonLabel)
//        
//        // Add button to self.view
//        self.view.addSubview(button)
//        
//        // Center button label within button
//        buttonLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
//        buttonLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
//        
//        // Center button with self.view
//        //button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        //button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//        
//        // Set button's width and height
//        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        
//        return button
        return backspaceKey
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // Call the super class
//        super.touchesBegan(touches, with: event)
//        
//        // Get user's touch
//        let touch = touches.first
//        // Get the coordinates of the touch
//        let touchPoint = touch?.location(in: self.view)
//        // Get the view (key) the touch is in
//        let touchView = self.view.hitTest(touchPoint!, with: nil)
//        // if key is backspace
//        if touchView?.tag == 10 {
//            // backspace one character and early return
//            self.textDocumentProxy.deleteBackward()
//            return
//        }
//        // Get the key's label
//        let touchViewLabel = touchView?.subviews[0]
//        // Downcast the label from UIView to UILabel so we can access the "text" property
//        let touchViewLabelRaw = touchViewLabel as! UILabel
//        // Insert the label's text into the text field
//        textDocumentProxy.insertText(touchViewLabelRaw.text!)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
}
