//
//  lisuKeyboardLayout.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

func lisuKeyboardLayout(controller: UIInputViewController, viewWidth: CGFloat, viewHeight: CGFloat) -> Keyboard {
    
    // Calcualte key width and height
    
    let keyboard = Keyboard()
    let firstRow = ["꓿", "ꓪ", "ꓰ", "ꓣ", "ꓔ", "ꓬ", "ꓴ", "ꓲ", "ꓳ", "ꓑ"]
    var firstRowKeys : [Key] = []
    
    let keyWidth = viewWidth / CGFloat(firstRow.count)
    let keyHeight = viewHeight / 4.0
    
    // First Row
    for currChar in firstRow {
        let currKey = Key(type: .character, keyValue: currChar, width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
        firstRowKeys.append(currKey)
    }
    // Add constraints for first row
    for (i,_) in firstRowKeys.enumerated() {
        firstRowKeys[i].button.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true

        // Top left
        if i == 0 {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        } else {
            firstRowKeys[i].button.leftAnchor.constraint(equalTo: firstRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    // Second Row
    let secondRow = ["ꓮ", "ꓢ", "ꓓ", "ꓝ", "ꓖ", "ꓧ", "ꓙ", "ꓗ", "ꓡ"]
    var secondRowKeys : [Key] = []
    // Add Padding before Second Row
    // Padding left
    let paddingLeft = (viewWidth - (keyWidth * CGFloat(secondRow.count)))/2
    
    // Create buttons
    for currChar in secondRow {
        let currKey = Key(type: .character, keyValue: currChar, width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
        secondRowKeys.append(currKey)
    }
    // Add constraints for second row
    for (i,_) in secondRowKeys.enumerated() {
        secondRowKeys[i].button.topAnchor.constraint(equalTo: firstRowKeys[0].button.bottomAnchor).isActive = true
        
        // Top left
        if i == 0 {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor, constant: paddingLeft).isActive = true
        } else {
            secondRowKeys[i].button.leftAnchor.constraint(equalTo: secondRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    // Third Row
    let thirdRow = ["ꓜ", "ꓫ", "ꓚ", "ꓦ", "ꓐ", "ꓠ", "ꓟ"]
    var thirdRowKeys : [Key] = []
    
    // Width for Shift and Backspace
    let shiftDeleteWidth = (viewWidth - (keyWidth * CGFloat(thirdRow.count)))/2
    
    // Shift
    let shiftKey = Key(type: .shift, keyValue: "⇧", width: shiftDeleteWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    thirdRowKeys.append(shiftKey)
    
    // Keys between shift and backspace
    for currChar in thirdRow {
        let currKey = Key(type: .character, keyValue: currChar, width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
        thirdRowKeys.append(currKey)
    }
    
    // Backspace
    let deleteKey = Key(type: .backspace, keyValue: "<", width: shiftDeleteWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    thirdRowKeys.append(deleteKey)
    
    // Add constraints for third row
    for (i,_) in thirdRowKeys.enumerated() {
        thirdRowKeys[i].button.topAnchor.constraint(equalTo: secondRowKeys[0].button.bottomAnchor).isActive = true
        
        // Left
        if i == 0 {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        } else {
            thirdRowKeys[i].button.leftAnchor.constraint(equalTo: thirdRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    // Last Row
    var lastRowKeys : [Key] = []
        
    // Change to number button
    let numberSwitchKey = Key(type: .modeChange, keyValue: "123", width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    lastRowKeys.append(numberSwitchKey)
    
    // Change keyboard button
    let changeKeyboard = Key(type: .keyboardChange, keyIcon: .keyboardO, controlState: [], width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    lastRowKeys.append(changeKeyboard)
    
    // Spacebar button
    let spaceKey = Key(type: .backspace, keyValue: "Space", width: keyWidth * 6.0, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    lastRowKeys.append(spaceKey)
    
    // Period button
    let periodKey = Key(type: .period, keyValue: "꓿", width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    lastRowKeys.append(periodKey)
    
    // Return button
    let enterKey = Key(type: .enter, keyValue: "E", width: keyWidth, height: keyHeight, color: UIColor.darkGray, parentView: controller.view)
    lastRowKeys.append(enterKey)
    
    // Add constraints for third row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    keyboard.keys.append(firstRowKeys)
    keyboard.keys.append(secondRowKeys)
    keyboard.keys.append(thirdRowKeys)
    keyboard.keys.append(lastRowKeys)
    
    return keyboard
}
