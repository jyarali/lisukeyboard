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
        
        self.togglePageView(currPage: "", newPage: self.currPage)
    }
    
    // Set keyboard custom height
    func setCustomWidthHeight(){
        
        // Determine the device
        let deviceType = UIDevice.current.userInterfaceIdiom
        
        if deviceType == .phone || deviceType == .pad {
            // Set the width and height based on the initial orientation of the device.
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
                // Display the currPage
                self.togglePageView(currPage: "", newPage: self.currPage)
            }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                //Done animation
            })
        }
    }
    
    // Remove key from the sub view.
    func removeAllSubView() {
        for v in self.view.subviews{
            v.removeFromSuperview()
        }
    }
    
    // Attempt to optimize stage change
    // Toggle pages for the button
    func togglePageView(currPage : String, newPage : String) {
        
        // Hide the current
        if !currPage.isEmpty {
            for row in keyboard.keys[currPage]! {
                for key in row {
                    key.button.isHidden = true
                }
            }
        }
        
        // Show the next
        if !newPage.isEmpty {
            for row in keyboard.keys[newPage]! {
                for key in row {
                    key.button.isHidden = false
                }
            }
        }
    }
    
    // Render Keys
    func renderKeys() {
        
        // Remove all of the existing keys before rendering
        self.removeAllSubView()
        
        // Set up a keyboard with the custom width and height
        keyboard = lisuKeyboardLayout(controller: self, viewWidth: viewWidth, viewHeight: viewHeight)
        
        // Add all the keys to the View
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
                for key in row {
                    self.view.addSubview(key.button)
                }
            }
        }
        
        // Add listeners to the keys
        self.addEventListeners()
    }
    
    // Add event listeners to the keys.
    func addEventListeners() {
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
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
                    } else if key.type == .backspace {
                        // Chaning to 123 page
                        key.button.addTarget(self, action: #selector(self.backspacePressedOnce(sender:)), for: .touchUpInside)
                        key.button.addTarget(self, action: #selector(self.backspacePressedLong(sender:)), for: .touchDown)
                    }
                }
            }
        }
    }
    
    // After shift is pressed toggle the view.
    func shiftPressedOnce(sender: UIButton){
        if currPage == "shift" {
            togglePageView(currPage: currPage, newPage: "unshift")
            currPage = "unshift"
        } else {
            togglePageView(currPage: currPage, newPage: "shift")
            currPage = "shift"
        }
    }
    
    // 123 button is pressed
    func modeChangePressedOnce(sender: UIButton){
        if currPage == "abc" {
            togglePageView(currPage: currPage, newPage: "123")
            currPage = "123"
        } else {
            togglePageView(currPage: currPage, newPage: "abc")
            currPage = "abc"
        }
    }
    
    // Trigger for delete on hold and press once
    func backspacePressedLong(sender: UIButton) {
        backspaceButtonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.backspaceDelete), userInfo: nil, repeats: true)
    }
    
    func backspacePressedOnce(sender: UIButton) {
        backspaceButtonTimer.invalidate()
        self.backspaceDelete()
    }
    
    func backspaceDelete() {
        self.textDocumentProxy.deleteBackward()
    }
    
    // Trigger for character key press.
    func keyPressedOnce(sender: UIButton) {
        textDocumentProxy.insertText((sender.titleLabel?.text)!)
    }
    
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
