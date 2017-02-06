//
//  Constants.swift
//  MathPix
//
//  Created by Michael Lee on 3/25/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import Foundation

struct Constants {
    static let sendImageTitleError = "Error"
    
    
    //URLS
    static let requestURL = "https://api.mathpix.com/v2/latex"
    
    //Request
    static let boundaryConstant = "----------V2ymHFg03ehbqgZCaKO6jy"
    
    //Request body
    static let bodyDetails = "--\(boundaryConstant)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n" + "Content-Type: image/jpeg\r\n\r\n"
    static let bodyEnd = "\r\n--\(boundaryConstant)--\r\n"
    
    //Web API Key
    // Change these values to yours
    static let appID = "mathpix"
    static let webAPIKey = "139ee4b61be2e4abcfb1238d9eb99902"

}

