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
    let bottomRowNumButtons = 9
    
    // viewWidth and viewHeight of the keyboard view
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = UIScreen.main.bounds.height / 3
    
    // Custom height for keyboard
    var heightConstraint:NSLayoutConstraint? = nil
    
    var portraitSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    var landscapeSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    var isPortrait = true
    
    var keyboard : Keyboard?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
        
        // Change the view constraint
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine the device
        let deviceType = UIDevice.current.userInterfaceIdiom
        
        NSLog("DeviceType \(deviceType.rawValue)")
        
        if deviceType == .phone || deviceType == .pad {
            if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                // Portrait
                portraitSize.height = UIScreen.main.bounds.height * 0.32
                
                viewWidth = portraitSize.width
                viewHeight = portraitSize.height
                
                landscapeSize.height = UIScreen.main.bounds.width * 0.43
                landscapeSize.width = UIScreen.main.bounds.height
            } else {
                // Landscape
                isPortrait = false
                landscapeSize.height = UIScreen.main.bounds.height * 0.43
                
                viewWidth = landscapeSize.width
                viewHeight = landscapeSize.height
                
                portraitSize.height = UIScreen.main.bounds.height * 0.32
                portraitSize.width = UIScreen.main.bounds.height
            }
        }
        
        NSLog("UIScreen bounds \(UIScreen.main.bounds.width) x \(UIScreen.main.bounds.height)")
        
        NSLog("Portrait bounds \(portraitSize.width) x \(portraitSize.height)")
        
        NSLog("Landscape bounds \(landscapeSize.width) x \(landscapeSize.height)")
    }
    var count = 0
    
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
            
            // Change the view width and height
            coordinator.animateAlongsideTransition(in: self.view, animation: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.renderKeys()
            }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                //Done animation
            })
        }
    }
    
    // Check if the orientation has changed
    func orientationChanged(now: CGSize, to: CGSize) -> Bool {
        return  true
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
        for row in (keyboard?.keys)! {
            for key in row {
                self.view.addSubview(key.button)
            }
        }
        
        self.nextKeyboardButton = keyboard?.getChangeKyboardButton()
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.renderKeys()
        NSLog("Calling viewDidAppear")
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
