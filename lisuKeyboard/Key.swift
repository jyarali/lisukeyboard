//
//  Key.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/21/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

class Key{
    enum KeyType {
        case character
        case specialCharacter
        case shift
        case backspace
        case modeChange
        case keyboardChange
        case period
        case space
        case num
        case sym
        case enter
        case settings
        case other
    }
    
    var type: KeyType
    var keyValue: String
    var button = UIButton()
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var color = UIColor()
    var parentView = UIView()
    var tag: Int = 0 // Tag is 0 by default
    
    init() {
        // Place holder
        self.type = KeyType.character
        self.keyValue = ""
    }
    
    init(type: KeyType, keyValue: String , width: CGFloat, height: CGFloat, color:UIColor, parentView: UIView, tag: Int? = nil) {
        self.type = type
        self.width = width
        self.height = height
        self.color = color
        self.parentView = parentView
        
        if tag != nil {
            self.tag = tag!
        }
        
        // This assign a parent view to the button
        // This is need to set the constraints.
        parentView.addSubview(self.button)
        
        self.button.backgroundColor = UIColor.init(white: 1, alpha: 1)
        self.button.layer.borderWidth = 1
        self.button.layer.borderColor = UIColor.black.cgColor
        self.button.isHidden = true
        self.button.tag = self.tag
        
        self.keyValue = keyValue
        self.button.setTitle(self.keyValue, for: [])
        self.button.setTitleColor(color, for: [])
    
        self.button.sizeToFit()
        
        self.button.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.button.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func copy(keyValue: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, color: UIColor? = nil) -> Key{
        let copyObj = Key(type: self.type, keyValue: (keyValue != nil ? keyValue! : self.keyValue), width: (width != nil ? width! : self.width), height: (height != nil ? height! : self.height), color: (color != nil ? color! : self.color), parentView: self.parentView, tag: self.tag)
        return copyObj
    }
    
    var isCharacter: Bool {
        get {
            switch self.type {
            case
            .character,
            .specialCharacter,
            .period:
                return true
            default:
                return false
            }
        }
    }
    
    var isSpecial: Bool {
        get {
            switch self.type {
            case .shift:
                return true
            case .backspace:
                return true
            case .modeChange:
                return true
            case .keyboardChange:
                return true
            case .enter:
                return true
            case .settings:
                return true
            default:
                return false
            }
        }
    }
}
