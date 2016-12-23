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
    var keys: [[Key]] = []
    
    // Get the keyboardChange button
    func getChangeKyboardButton() -> UIButton? {
        for row in keys {
            for key in row{
                if key.type == .keyboardChange {
                    return key.button
                }
            }
        }
        return nil
    }
}
