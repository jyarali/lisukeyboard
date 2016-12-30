//
//  keyBoard.swift
//  lisuKeyboard
//
//  Created by Amos Gwa on 12/22/16.
//  Copyright © 2016 Amos Gwa. All rights reserved.
//

import Foundation
import UIKit

struct MODE_CHANGE_ID {
    static let unshift = 1
    static let shift = 2
    static let sym = 3
    static let num = 4
}

class Keyboard {
    // There are three pages unshift, shift, 123
    var keys: [Int:[[Key]]] = [:]
}
