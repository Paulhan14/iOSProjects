//
//  Helpers.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 11/10/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

class Helpers {
    static func checkPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        return emailTest.evaluate(with: email)
    }
}
