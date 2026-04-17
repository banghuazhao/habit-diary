//
//  Constants.swift
//  Habit Diary
//
//  Created by Lulin Yang on 2025/6/27.
//

import Foundation
import UIKit

struct Constants {
    static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    static let isMac = UIDevice.current.userInterfaceIdiom == .mac
    
    struct AppID {
        static let appID = "1550484411"
    }
}

let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    return formatter
}()
