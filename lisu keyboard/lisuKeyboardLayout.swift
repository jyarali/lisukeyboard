//
//  lisuKeyboardLayout.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

struct page {
    var keyboard : [[String]] = []
}

func lisuKeyboardLayout(controller: UIInputViewController, viewWidth: CGFloat, viewHeight: CGFloat) -> Keyboard {
    
    
    // Just to save myself from typos
    struct specialKey {
        static let shift = "shift"
        static let backspace = "backspace"
        static let num = "123"
        static let change = "keyboardchange"
        static let space = "space"
        static let sym = "Sym"
        static let enter = "return"
        static let ABC = "ABC"
    }
    
    struct MODE_CHANGE_ID {
        static let unshift = 1
        static let shift = 2
        static let sym = 3
        static let num = 4
    }
    
    var keyboardLayout : [Int: page] = [:]
    // Unshift
    var unshiftPage = page()
    unshiftPage.keyboard = [["ʼ", "ꓪ", "ꓰ", "ꓣ", "ꓔ", "ꓬ", "ꓴ", "ꓲ", "ꓳ", "ꓑ"],
                            ["ꓮ", "ꓢ", "ꓓ", "ꓝ", "ꓖ", "ꓧ", "ꓙ", "ꓗ", "ꓡ"],
                            ["shift","ꓜ", "ꓫ", "ꓚ", "ꓦ", "ꓐ", "ꓠ", "ꓟ","backspace"],
                            ["123","keyboardchange", "space","=", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.unshift] = unshiftPage
    // Shift
    var shiftPage = page()
    shiftPage.keyboard = [["\"", "ꓼ", "ꓱ", "ꓤ", "ꓕ", "ꓻ", "ꓵ", "꓾", "ˍ", "ꓒ"],
                          ["ꓯ", "ꓸꓼ", "ꓷ", "ꓞ", "ꓨ", "ꓺ", "ꓩ", "ꓘ", "ꓶ"],
                          ["unshift","ꓹ", "ꓸ", "ꓛ", "ꓥ", "ꓭ", "-", "'","backspace"],
                          ["123","keyboardchange", "space","?", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.shift] = shiftPage
    // 123
    var numPage = page()
    numPage.keyboard = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                        ["/", ":", ";", "(", ")", "$", "&", "@","!"],
                        ["sym","#", "+", "=", "-", "+", "<", ">","backspace"],
                        ["ABC","keyboardchange", "space",",", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.num] = numPage
    // Sym
    var symPage = page()
    symPage.keyboard = [["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                        ["~", "`", "{", "}", "_", "-", "=", "|", "§"],
                        ["123", "|", "~", "<", ">", "€", "£", "¥", "backspace"],
                        ["ABC","keyboardchange", "space", "•", "return"]
    ]
    keyboardLayout[MODE_CHANGE_ID.sym] = symPage

    // Determine button width
    // The total size of all buttons must be < viewWidth and < viewHeight
    let characterSize = CGSize(width: viewWidth/10, height: viewHeight/4)
    let shiftDeleteSize = CGSize(width: (viewWidth - (characterSize.width * 7))/2, height: characterSize.height )
    
    // Icons
    let changeKeyboardIcon = "\u{0001F310}"
    let enterIcon = "\u{000023CE}"
    let backspaceIcon = "\u{0000232B}"
    let shiftIcon = "\u{00021E7}"
    
    // Keyboard with associated pages
    let keyboard = Keyboard()
    keyboard.keys[MODE_CHANGE_ID.unshift] = []
    keyboard.keys[MODE_CHANGE_ID.shift] = []
    keyboard.keys[MODE_CHANGE_ID.num] = []
    keyboard.keys[MODE_CHANGE_ID.sym] = []
    
    // Reusable Keys
    let charKey = Key(type: .character, keyValue: "", width: characterSize.width, height: characterSize.height, color: UIColor.darkGray, parentView: controller.view)
    let backspaceKey = Key(type: .backspace, keyValue: backspaceIcon, width: shiftDeleteSize.width, height: shiftDeleteSize.height, color: UIColor.darkGray, parentView: controller.view)
    let enterKey = Key(type: .enter, keyValue: enterIcon, width: characterSize.width, height: characterSize.height, color: UIColor.darkGray, parentView: controller.view)
    let changeKeyboardKey = Key(type: .keyboardChange, keyValue: changeKeyboardIcon, width: characterSize.width, height: characterSize.height, color: UIColor.darkGray, parentView: controller.view)
    
    // Mode change buttons
    let unshiftKey = Key(type: .modeChange, keyValue: specialKey.ABC, width: shiftDeleteSize.width, height: shiftDeleteSize.height, color: UIColor.darkGray, parentView: controller.view, tag: MODE_CHANGE_ID.unshift)
    let shiftKey = Key(type: .modeChange, keyValue: shiftIcon, width: shiftDeleteSize.width, height: shiftDeleteSize.height, color: UIColor.darkGray, parentView: controller.view, tag: MODE_CHANGE_ID.shift)
    let symKey = Key(type: .modeChange, keyValue: specialKey.sym, width: characterSize.width, height: characterSize.height, color: UIColor.darkGray, parentView: controller.view, tag: MODE_CHANGE_ID.sym)
    let numKey = Key(type: .modeChange, keyValue: specialKey.num, width: characterSize.width, height: characterSize.height, color: UIColor.darkGray, parentView: controller.view, tag: MODE_CHANGE_ID.num)
    
    //============================================//
    // UNSHIFT PAGE
    //============================================//
    // First Row
    var firstRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[0]
    var firstRowKeys : [Key] = []
    // Create keys
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    var secondRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[1]
    var secondRowKeys : [Key] = []
    // Create keys
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
        secondRowKeys.append(currKey)
    }
    // Add Padding before Second Row
    // Padding left
    let paddingLeft = (viewWidth - (characterSize.width * CGFloat((secondRow?.count)!)))/2
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
    var thirdRow = keyboardLayout[MODE_CHANGE_ID.unshift]?.keyboard[2]
    var thirdRowKeys : [Key] = []
    // Create keys
    for currChar in thirdRow! {
        var currKey = Key()
        if currChar == specialKey.shift {
            // Shift
            currKey = shiftKey.copy()
        } else if currChar == specialKey.backspace {
            // Backspace
            currKey = backspaceKey.copy()
        }else {
            currKey = charKey.copy(keyValue: currChar)
        }
        thirdRowKeys.append(currKey)
    }
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
    lastRowKeys.append(numKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(keyValue: " ", width: characterSize.width * 6))
    // Period button
    lastRowKeys.append(charKey.copy(keyValue: "꓿"))
    // Return button
    lastRowKeys.append(enterKey.copy())
    // Add constraints for Last row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    // Add the keys to the keybaord with their associated state
    keyboard.keys[MODE_CHANGE_ID.unshift] = []
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.unshift]?.append(lastRowKeys)
 
    //============================================//
    // SHIFTPAGE
    //============================================//
    // Shift Page
    firstRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[0]
    firstRowKeys = []
    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    secondRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    thirdRow = keyboardLayout[MODE_CHANGE_ID.shift]?.keyboard[2]
    thirdRowKeys = []
    // Shift key
    thirdRowKeys.append(unshiftKey.copy())
    // Keys between shift and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
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
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(numKey.copy())
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(keyValue: " ", width: characterSize.width * 6))
    // Period button
    lastRowKeys.append(charKey.copy(keyValue: "?"))
    // Return button
    lastRowKeys.append(enterKey.copy())
    
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
    
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.shift]?.append(lastRowKeys)
    
    //============================================//
    // 123 PAGE
    //============================================//
    firstRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[0]
    firstRowKeys = []
//    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    secondRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
//    
//    // Third Row
    thirdRow = keyboardLayout[MODE_CHANGE_ID.num]?.keyboard[2]
    thirdRowKeys = []
    // Sym key
    thirdRowKeys.append(symKey.copy(width:shiftDeleteSize.width, height:shiftDeleteSize.height))
    // Keys between sym and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
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
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(unshiftKey.copy(width:characterSize.width, height: characterSize.height))
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(keyValue: " ", width: characterSize.width * 6))
    // Comma button
    lastRowKeys.append(charKey.copy(keyValue: ","))
    // Return button
    lastRowKeys.append(enterKey.copy())
    
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
    
    keyboard.keys[MODE_CHANGE_ID.num]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.num]?.append(lastRowKeys)
    
    
    //============================================//
    // SYM PAGE
    //============================================//
    firstRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[0]
    firstRowKeys = []
    //    // First Row
    for currChar in firstRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    secondRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[1]
    secondRowKeys = []
    // Add Padding before Second Row
    for currChar in secondRow! {
        let currKey = charKey.copy(keyValue: currChar)
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
    thirdRow = keyboardLayout[MODE_CHANGE_ID.sym]?.keyboard[2]
    thirdRowKeys = []
    // SYM key
    thirdRowKeys.append(numKey.copy(width:shiftDeleteSize.width, height: shiftDeleteSize.height))
    // Keys between sym and backspace
    for i in 1...(thirdRow!.count - 2) {
        let currKey = charKey.copy(keyValue: thirdRow?[i])
        thirdRowKeys.append(currKey)
    }
    // Backspace key
    thirdRowKeys.append(backspaceKey.copy())
    // Add constraints for third row.
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
    lastRowKeys = []
    // Change to number button
    lastRowKeys.append(unshiftKey.copy(width:characterSize.width, height: characterSize.height))
    // Change keyboard button
    lastRowKeys.append(changeKeyboardKey.copy())
    // Spacebar button
    lastRowKeys.append(charKey.copy(keyValue: " ", width: characterSize.width * 6))
    // BulletPoint button
    lastRowKeys.append(charKey.copy(keyValue: "•"))
    // Return button
    lastRowKeys.append(enterKey.copy())
    // Add constraints for Last row
    for (i,_) in lastRowKeys.enumerated() {
        lastRowKeys[i].button.topAnchor.constraint(equalTo: thirdRowKeys[0].button.bottomAnchor).isActive = true
        
        // Top left
        if i == 0 {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
        } else {
            lastRowKeys[i].button.leftAnchor.constraint(equalTo: lastRowKeys[i-1].button.rightAnchor).isActive = true
        }
    }
    
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(firstRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(secondRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(thirdRowKeys)
    keyboard.keys[MODE_CHANGE_ID.sym]?.append(lastRowKeys)
    
    return keyboard
}
