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
    
    // Custom height for keyboard
    var heightConstraint:NSLayoutConstraint? = nil
    
    // viewWidth and viewHeight of the keyboard view
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    
    var portraitSize: CGSize = CGSize(width: 0, height: 0)
    var landscapeSize: CGSize = CGSize(width: 0, height: 0)
    
    // Check if the device is in portrait mode initially.
    var isPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
    
    // Keyborard current page : unshift, shift, 123
    var currPage = "unshift"
    var keyboard : Keyboard = Keyboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomWidthHeight()
        
        self.renderKeys()
    }
    
    func setCustomWidthHeight(){
        
        // Determine the device
        let deviceType = UIDevice.current.userInterfaceIdiom
        
        NSLog("DeviceType \(deviceType.rawValue)")
        
        if deviceType == .phone || deviceType == .pad {
            // Set the width and height based on the initial orientation.
            if isPortrait {
                // Portrait
                portraitSize.width = UIScreen.main.bounds.width
                portraitSize.height = UIScreen.main.bounds.height * 0.32
                
                viewWidth = portraitSize.width
                viewHeight = portraitSize.height
                
                // Landscape
                landscapeSize.height = UIScreen.main.bounds.width * 0.43
                landscapeSize.width = UIScreen.main.bounds.height
            } else {
                // Landscape
                landscapeSize.width = UIScreen.main.bounds.width
                landscapeSize.height = UIScreen.main.bounds.height * 0.43
                
                viewWidth = landscapeSize.width
                viewHeight = landscapeSize.height
                
                // Portrait
                portraitSize.height = UIScreen.main.bounds.height * 0.32
                portraitSize.width = UIScreen.main.bounds.height
            }
        }
        
        NSLog("UIScreen bounds \(UIScreen.main.bounds.width) x \(UIScreen.main.bounds.height)")
        
        NSLog("Portrait bounds \(portraitSize.width) x \(portraitSize.height)")
        
        NSLog("Landscape bounds \(landscapeSize.width) x \(landscapeSize.height)")
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Change the view constraint to custom.
        NSLog("Updating view constraint \(viewHeight)")
        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self.view,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: viewHeight)
            heightConstraint?.priority = UILayoutPriority(UILayoutPriorityRequired)
            self.view.addConstraint(heightConstraint!)
        } else {
            heightConstraint?.constant = viewHeight
        }
    }
    
    // When changing orientation, change the keyboard height and width
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Check if the orientation has definitely changed from landscape to portrait or viceversa.
        // This is to prevent flipping landscapes. The device will rotate with the same width.
        // viewWidth != size.width
        
        NSLog("change orientation \(viewWidth) x  \(viewHeight)")
        NSLog("change orientation \(size.width) x  \(size.height)")
        
        if size.width != viewWidth {
            
            isPortrait = !isPortrait
            
            if isPortrait {
                viewHeight = portraitSize.height
                viewWidth = portraitSize.width
            } else {
                viewHeight = landscapeSize.height
                viewWidth = landscapeSize.width
            }
            
            coordinator.animateAlongsideTransition(in: self.view, animation: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.renderKeys()
            }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                //Done animation
            })
        }
    }
    
    // Remove key from the sub view.
    func removeAllSubView() {
        NSLog("Cleaning subviews")
        for v in self.view.subviews{
            v.removeFromSuperview()
        }
    }
    
    // Render Keys
    func renderKeys() {
        
        // Remove all of the existing keys before rendering
        self.removeAllSubView()
        
        NSLog("Calling keyboard")
        keyboard = lisuKeyboardLayout(controller: self, viewWidth: viewWidth, viewHeight: viewHeight)
        NSLog("Called")
        
        // Add the keys to the View
        for row in keyboard.keys[currPage]! {
            for key in row {
                self.view.addSubview(key.button)
            }
        }
        
        // Add listeners to the keys
        self.addEventListeners()
    }
    
    // Add event listeners to the keys.
    func addEventListeners() {
        for row in keyboard.keys[currPage]! {
            for key in row {
                if key.isCharacter {
                    // Characters to be typed
                    key.button.addTarget(self, action: #selector(self.keyPressedOnce(sender:)), for: .touchUpInside)
                } else if key.type == .keyboardChange {
                    // Changing keyboard
                    self.nextKeyboardButton = key.button
                    self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
                } else if key.type == .shift {
                    // Changing page for shift
                    key.button.addTarget(self, action: #selector(self.shiftPressedOnce(sender:)), for: .touchUpInside)
                } else if key.type == .modeChange {
                    // Chaning to 123 page
                    key.button.addTarget(self, action: #selector(self.modeChangePressedOnce(sender:)), for: .touchUpInside)
                }
            }
        }
    }
    
    // After shift is pressed toggle the view.
    func shiftPressedOnce(sender: UIButton){
        if currPage == "shift" {
            currPage = "unshift"
        } else {
            currPage = "shift"
        }
        self.renderKeys()
    }
    
    // 123 button is pressed
    func modeChangePressedOnce(sender: UIButton){
        if currPage == "abc" {
            currPage = "123"
        } else {
            currPage = "abc"
        }
        self.renderKeys()
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
        textDocumentProxy.insertText((keyboard.keyHash[sender.tag]?.keyValue)!)
    }
    
    func makeButton(character: String, tag: Int) -> UIButton {
        
        // Add backspace button
        let backspaceKey = UIButton()
        // Add next keyboard
        backspaceKey.backgroundColor = UIColor.init(white: 1, alpha: 1)
        
        // Filter some keys
        
        backspaceKey.setTitle(character, for: [])
        backspaceKey.setTitleColor(UIColor.darkGray, for: [])
        backspaceKey.tag = tag
        //backspaceKey.setImage(UIImage.fontAwesomeIcon(name: .windowCloseO, textColor: UIColor.black, size: CGSize(width: 30, height: 30)), for: [])
        
        backspaceKey.sizeToFit()
        
        //backspaceKey.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        backspaceKey.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backspaceKey.translatesAutoresizingMaskIntoConstraints = false
        
        backspaceKey.addTarget(self, action: #selector(KeyboardViewController.keyPressedOnce), for: .touchUpInside)
        //backspaceKey.addTarget(self, action: #selector(KeyboardViewController.backspaceLongPressed), for: .touchDown)
    
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
        if (self.nextKeyboardButton != nil) {
            self.nextKeyboardButton.setTitleColor(textColor, for: [])
        }
    }
    
}
