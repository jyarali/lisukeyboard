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
        case enter
        case settings
        case other
    }
    
    var type: KeyType
    var toMode: Int? //If the key is a mode button, this idnicates which page it links to
    var keyValue: String?
    var button = UIButton()
    
    init(type: KeyType, keyValue: String? = nil , keyIcon: FontAwesome? = nil , controlState: UIControlState? = nil, width: CGFloat, height: CGFloat, color:UIColor, parentView: UIView) {
        self.type = type
        
        // This assign a parent view to the button
        parentView.addSubview(self.button)
        
        self.button.backgroundColor = UIColor.init(white: 1, alpha: 1)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        // Check if it's character or icon
        if keyIcon == nil {
            self.keyValue = keyValue
            self.button.setTitle(self.keyValue, for: [])
            self.button.setTitleColor(color, for: [])
        } else {
            self.button.setImage(UIImage.fontAwesomeIcon(name: keyIcon!, textColor: color, size: CGSize(width: width,  height: height)), for: controlState!)
        }
        
        self.button.sizeToFit()
        
        self.button.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.button.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
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
