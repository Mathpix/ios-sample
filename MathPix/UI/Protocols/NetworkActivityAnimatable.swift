//
//  NetworkActivityAnimatable.swift
//  MathPix-API-Sample
//
//  Created by Дмитрий Буканович on 07.02.17.
//  Copyright © 2017 MathPix. All rights reserved.
//

import Foundation

protocol NetworkActivityAnimatable {
    func networkActivityDidStart()
    func networkActivityDidStop()
}


extension NetworkActivityAnimatable {
    func networkActivityDidStart() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func networkActivityDidStop() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
