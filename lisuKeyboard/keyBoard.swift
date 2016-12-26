//
//  keyBoard.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

class Keyboard {
    
    // There are three pages unshift, shift, 123
    var keys: [String:[[Key]]] = [:]
    
    // Each key is hashed with an ID. 
    // This is to work around with the fact that Button
    // addTarget can't send custom data. So, tag is
    // used as an unique id for each key.
    var keyHash : [Int:Key] = [:]
}
