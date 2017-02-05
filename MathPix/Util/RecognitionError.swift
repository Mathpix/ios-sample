//
//  RecognitionError.swift
//  MathPix-API-Sample
//
//  Created by Дмитрий Буканович on 05.02.17.
//  Copyright © 2017 MathPix. All rights reserved.
//

import Foundation
public enum RecognitionError: Error {

    /// Failed parse JSON
    case failedParseJSON
    /// Not connected to the internet.
    case notMath(String)
    
}
