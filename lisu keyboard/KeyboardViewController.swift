//
//  KeyboardViewController.swift
//  lisu keyboard
//
//  Created by Amos Gwa on 12/21/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import UIKit
import Foundation

// Extension for the UILabel to change font size.
extension UILabel {
    func setSizeFont (sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
}

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    var backspaceButtonTimer: Timer? = nil
    var thresholdTimer: Timer? = nil
    
    // Custom height for keyboard
    var heightConstraint:NSLayoutConstraint? = nil
    
    // viewWidth and viewHeight of the keyboard view
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    
    var portraitSize: CGSize = CGSize(width: 0, height: 0)
    var landscapeSize: CGSize = CGSize(width: 0, height: 0)
    
    // Check if the device is in portrait mode initially.
    var isPortrait = UIScreen.main.bounds.height > UIScreen.main.bounds.width
    
    // Check the device type
    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    // Current popup view.
    var currPopup : [UIView] = []
    
    // darkened keys needs to be whitened.
    var pressedCharacterKeys : [UIButton] = []
    var pressedSpecialKeys : [UIButton] = []
    
    // Keyborard current page : unshift, shift, 123
    var currPage = MODE_CHANGE_ID.unshift
    var keyboard : Keyboard = Keyboard()
    
    // Set the top bar Height
    var topBarHeight : CGFloat = 0
    
    // Delete key
    var deleteKey : UIButton? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Apply background style
        self.view.backgroundColor = theme.keyboardBackgroundColor
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.calc_customWidthHeight()
    }
  
    // Calculate the width and height of the keyboard based on the initial orientation of the device.
    func calc_customWidthHeight(){
        
        // I had to add top bar high at the end. Since the pop up key has to go beyond the keyboard. It's 15% increase.
        // Only applies to iPhones
        let topBarIncRatio : CGFloat = self.isIPad ? 1 : 1.15
      
        if isPortrait {
            portraitSize.width = UIScreen.main.bounds.width
            portraitSize.height = round(UIScreen.main.bounds.height * 0.32 * topBarIncRatio)
            
            viewWidth = portraitSize.width
            viewHeight = portraitSize.height
          
            landscapeSize.height = round(UIScreen.main.bounds.width * 0.43 * topBarIncRatio)
            landscapeSize.width = UIScreen.main.bounds.height
        } else {
            landscapeSize.width = UIScreen.main.bounds.width
            landscapeSize.height = round(UIScreen.main.bounds.height * 0.43 * topBarIncRatio)
            
            viewWidth = landscapeSize.width
            viewHeight = landscapeSize.height
          
            portraitSize.height = round(UIScreen.main.bounds.width * 0.32 * topBarIncRatio)
            portraitSize.width = UIScreen.main.bounds.height
        }
    }
  
    // Set the width and height of the keyboard
    func set_customWidthHeight() {
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
  
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      self.calc_customWidthHeight()
      
      self.renderKeys()
      
      self.togglePageView(currPage: 0, newPage: self.currPage)
    }
  
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Change the view constraint to custom.
        self.set_customWidthHeight()
    }
  
    // When changing orientation, change the keyboard height and width
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Check if the orientation has definitely changed from landscape to portrait or viceversa.
        // This is to prevent flipping landscapes. The device will rotate with the same width.
      
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
                self.togglePageView(currPage: 0, newPage: self.currPage)
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
    
    // Render Keys
    func renderKeys() {
        
        // Remove all of the existing keys before rendering
        self.removeAllSubView()
        
        // Set up a keyboard with the custom width and height
        keyboard = lisuKeyboardLayout(controller: self, totalWidth: self.viewWidth, totalHeight: self.viewHeight, isPortrait: self.isPortrait, isIPad: self.isIPad)
        
        // Add all the keys to the View
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
                for key in row {
                    self.view.addSubview(key.button)
                }
            }
        }
        
        // Extract out some keys.
        self.deleteKey = self.view.viewWithTag(MODE_CHANGE_ID.del) as? UIButton
        
        // Add listeners to the keys
        self.addEventListeners()
    }
    
    // Add event listeners to the keys.
    func addEventListeners() {
        for currKeyboard in keyboard.keys.values {
            for row in currKeyboard {
                for key in row {
                    if key.type == .character {
                        // Characters to be typed
                        key.button.addTarget(self, action: #selector(self.keyPressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.keyPressedHold(sender:)), for: .touchDown)
                    } else if key.type == .space {
                        // Listener for spacebar
                        key.button.addTarget(self, action: #selector(self.spacePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.spacePressedHold(sender:)), for: .touchDown)
                    } else if key.type == .keyboardChange {
                        // Changing keyboard
                        self.nextKeyboardButton = key.button
                      if #available(iOSApplicationExtension 10.0, *) {
                        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
                      } else {
                        // Fallback on earlier versions
                        self.nextKeyboardButton.addTarget(self, action: #selector(advanceToNextInputMode), for: .allTouchEvents)
                      }
                    } else if key.type == .modeChange {
                        // Chaning modes
                        key.button.addTarget(self, action: #selector(self.modeChangePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.modeChangePressedHold(sender:)), for: .touchDown)
                    } else if key.type == .backspace {
                        // Deleting characters
                        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.backspacePressedLong(gestureRecognizer:)))
                        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
                        key.button.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
                        key.button.addTarget(self, action: #selector(self.backspacePressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.backspacePressed(sender:)), for: .touchDown)
                    } else if key.type == .enter {
                        // Enter(Return) key
                        // Update the key value based on the returnType
                        key.button.addTarget(self, action: #selector(self.returnPressedOnce(sender:)), for: [.touchUpInside, .touchUpOutside])
                        key.button.addTarget(self, action: #selector(self.returnPressedHold(sender:)), for: .touchDown)
                    }
                }
            }
        }
    }
    
    // Return button is pressed.
    func returnPressedOnce(sender: UIButton) {
        self.releasedSpecialKey(sender: sender)
        self.textDocumentProxy.insertText("\n")
    }
    
    func returnPressedHold(sender: UIButton) {
        self.pressedSpecialKey(sender: sender)
    }
    
    // Mode change is pressed.
    func modeChangePressedOnce(sender: UIButton){
        self.releasedSpecialKey(sender: sender)
        togglePageView(currPage: currPage, newPage: sender.tag)
    }
    
    func modeChangePressedHold(sender: UIButton) {
        self.pressedSpecialKey(sender: sender)
    }
    
    // Attempt to optimize stage change
    // Toggle pages for the button
    func togglePageView(currPage: Int, newPage: Int) {
        // Hide the current
        if currPage != 0 {
            for row in keyboard.keys[currPage]! {
                for key in row {
                    key.button.isHidden = true
                }
            }
        }
    
        // Show the next
        if newPage != 0 {
            for row in keyboard.keys[newPage]! {
                for key in row {
                    key.button.isHidden = false
                }
            }
        }
        
        // Update the currPage
        self.currPage = newPage
    }
    
    // Trigger for delete on hold and press once.
    func backspacePressedOnce(sender: UIButton) {
        self.releasedSpecialKey(sender: sender)
        self.backspaceButtonTimer?.invalidate()
        //self.backspaceDelete()
    }
    
    func backspacePressed(sender: UIButton) {
        self.backspaceDelete()
        self.pressedSpecialKey(sender: sender)
    }
    
    func backspacePressedLong(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            if backspaceButtonTimer == nil {
                backspaceButtonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.backspaceDelete), userInfo: nil, repeats: true)
                backspaceButtonTimer!.tolerance = 0.01
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            // Release the key
            self.releasedSpecialKey(sender: gestureRecognizer.view as! UIButton)
            
            backspaceButtonTimer?.invalidate()
            backspaceButtonTimer = nil
        }
    }
    
    func backspaceDelete() {
        self.textDocumentProxy.deleteBackward()
    }
    
    // Triger for spacebar press.
    func spacePressedOnce(sender: UIButton) {
        self.whitenKey(sender: sender)
        self.textDocumentProxy.insertText((sender.titleLabel?.text)!)
    }
    
    func spacePressedHold(sender: UIButton) {
        self.darkenKey(sender: sender)
    }
    
    // Trigger for character key press.
    func keyPressedHold(sender: keyButton){
        if isIPad {
            self.darkenKey(sender: sender)
        } else {
            self.showKeyPopUp(sender: sender)
        }
    }
    
    func keyPressedOnce(sender: UIButton) {
        // Remove the popup keys
        if isIPad {
            self.whitenKey(sender: sender)
        } else {
            self.removePopUpKeys()
        }
        
        //self.showKeyPopUp(sender: sender)
        self.textDocumentProxy.insertText((sender.titleLabel?.text)!)
        
        // Return to unshift page if the currPage is shift.
        if currPage == MODE_CHANGE_ID.shift {
            togglePageView(currPage: self.currPage, newPage: MODE_CHANGE_ID.unshift)
        }
        
    }
    
    // Darken the key on press for chracters.
    func darkenKey(sender: UIButton){
        sender.backgroundColor = theme.keyPressedColor
        self.pressedCharacterKeys.append(sender)
    }
    
    func whitenKey(sender: UIButton) {
        let i = 0
        while self.pressedCharacterKeys.count > 0{
            self.pressedCharacterKeys[i].backgroundColor = theme.keyBackgroundColor
            self.pressedCharacterKeys.remove(at: i)
        }
    }
    
    func pressedSpecialKey(sender: UIButton){
        sender.backgroundColor = theme.keyBackgroundColor
        self.pressedSpecialKeys.append(sender)
    }
    
    func releasedSpecialKey(sender: UIButton) {
        let i = 0
        while self.pressedSpecialKeys.count > 0{
            self.pressedSpecialKeys[i].backgroundColor = theme.specialKeyBackgroundColor
            self.pressedSpecialKeys.remove(at: i)
        }
    }
    
    // Remove the pressed Views.
    func removePopUpKeys() {
        let i = 0
        while self.currPopup.count > 0{
            self.currPopup[i].removeFromSuperview()
            self.currPopup.remove(at: i)
        }
    }
    
    // Show the pop up for characters.
    func showKeyPopUp(sender: keyButton){
        let customView = UIView()
        let keyLabel = UILabel()
        
        keyLabel.setSizeFont(sizeFont: keyLabel.font.pointSize * 1.5)
        
        // Add the preview key label to the popup view.
        customView.addSubview(keyLabel)
        
        // Add constraint to the preview key label.
        keyLabel.widthAnchor.constraint(equalToConstant: sender.frame.size.width).isActive = true
        keyLabel.heightAnchor.constraint(equalToConstant: sender.frame.size.height).isActive = true
        keyLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        keyLabel.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        keyLabel.textAlignment = NSTextAlignment.center
        keyLabel.text = (sender.titleLabel?.text)!
        
        // Modify the preview label to center accordingly with the pressed button.
        customView.sizeToFit()
        customView.backgroundColor = UIColor.white
        
        // Add shadow to the button
        customView.layer.masksToBounds = false
        customView.layer.shadowColor = UIColor.darkGray.cgColor
        customView.layer.cornerRadius = 5
        customView.layer.shadowOffset = CGSize(width: 0, height: 0)
        customView.layer.shadowOpacity = 0.7
        customView.layer.shadowRadius = 1.5
        
        self.view.addSubview(customView)
        
        customView.widthAnchor.constraint(equalToConstant: sender.frame.size.width).isActive = true
        
        if sender.isFirstRow {
            customView.heightAnchor.constraint(equalToConstant: sender.frame.size.height * 2.0).isActive = true
        } else {
            customView.heightAnchor.constraint(equalToConstant: sender.frame.size.height * 2.5).isActive = true
        }
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        customView.bottomAnchor.constraint(equalTo: sender.bottomAnchor).isActive = true
        customView.leftAnchor.constraint(equalTo: sender.leftAnchor).isActive = true
        
        currPopup.append(customView)
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
