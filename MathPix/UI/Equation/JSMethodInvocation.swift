//
//  JSMethodInvocation.swift
//  MathPix
//
//  Created by Дмитрий Буканович on 08.11.16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import Foundation

enum JSMethodInvocation {
    case addResultJson(String?)
}


extension JSMethodInvocation: CustomStringConvertible {
    var description: String {
        var result : String = ""
        switch self {
        case let .addResultJson(arguments):
            if let arguments = arguments {
                result = "setResultJson(\(arguments));"
            }
            return result
        }
    }
}
