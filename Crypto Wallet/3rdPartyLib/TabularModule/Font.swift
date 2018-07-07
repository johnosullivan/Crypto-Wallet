//
//  Font.swift
//  AssesmentTable
//
//  Created by Manikandan r on 05/12/17.
//  Copyright © 2017 Manikandan r. All rights reserved.
//

import Foundation
import UIKit

enum Font: String {
    
    //case avenirHeavy = "Avenir-Light"
    //case avenirMedium = "Avenir-Light"
    case avenirLight = "Avenir-Light"

    func font(ofSize size:CGFloat = 12) -> UIFont { return UIFont(name: self.rawValue, size: size)! }
}
