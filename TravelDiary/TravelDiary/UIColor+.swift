//
//  UIColor+.swift
//  TravelDiary
//
//  Created by Jiaxing Han on 12/15/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//
import UIKit

extension UIColor {
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

class ColorTheme {
    let yankeesBlue: UIColor
    let seaBlue: UIColor
    let lapiz: UIColor
    let noflashWhite: UIColor
    
    init() {
        let uicolor = UIColor()
        self.yankeesBlue = uicolor.uicolorFromHex(rgbValue: 0x13293D)
        self.seaBlue = uicolor.uicolorFromHex(rgbValue: 0x006494)
        self.lapiz = uicolor.uicolorFromHex(rgbValue: 0x247BA0)
        self.noflashWhite = uicolor.uicolorFromHex(rgbValue: 0xE8F1F2)
    }
}
