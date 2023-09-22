//
//  ImageService.swift
//  MathPix
//
//  Created by Sergey Glushchenko on 6/20/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit

class ImageService: NSObject {

    var submitImageTask: URLSessionDataTask? = nil
    
    func currentSessionConfiguration(_ uid: String?) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        return configuration
    }
    
    
    func cropImage(_ image: UIImage, bounds: CGRect) -> UIImage? {
        //Resize image with aspectRation to screen
        var rect = CGRect.zero
        let aspectX = image.size.width / bounds.size.width
        let aspectY = image.size.height / bounds.size.height
        var aspectRationImage: CGFloat = 0.0
        
        if aspectX > aspectY {
            aspectRationImage = bounds.size.width / bounds.size.height
            rect.origin.y = 0
            rect.size.height = image.size.height
            
            let widthOfImage = aspectRationImage * image.size.height
            let halfOriginalImage = image.size.width / 2
            let halfNewImage = widthOfImage / 2
            let offsetImageX = halfOriginalImage - halfNewImage
            rect.origin.x = offsetImageX
            rect.size.width = widthOfImage
        }
        else {
            aspectRationImage = bounds.size.height / bounds.size.width
            rect.origin.x = 0
            rect.size.width = image.size.width
            
            let heightOfImage = aspectRationImage * image.size.width
            let halfOriginalImage = image.size.height / 2
            let halfNewImage = heightOfImage / 2
            let offsetImageY = halfOriginalImage - halfNewImage
            rect.origin.y = offsetImageY
            rect.size.height = heightOfImage
        }
        
        //Crop image with aspectRation to screen. If it not make then result cropped image will scaled----
        let resultImage = image.fixOrientation().croppedImage(rect)
        
        return resultImage

    }
    
    
    
    func sendImageToServer(_ uid: String?, image:UIImage, complitionHandler:((_ jsonString: String?, _ error: Error? ) -> Void)?) {
        
        if let URL = Foundation.URL(string: Constants.requestURL) {
            var request = URLRequest(url: URL)
            
            let imageData = image.jpegData(compressionQuality: 0.9)
            let bodyFirst = Constants.bodyDetails as NSString
            let bodyLast = Constants.bodyEnd as NSString
            let body = NSMutableData()
            
            body.append(bodyFirst.data(using: String.Encoding.utf8.rawValue)!)
            body.append(imageData!)
            body.append(bodyLast.data(using: String.Encoding.utf8.rawValue)!)
            
            let bodyLength = String(body.length)
            
            
            request.addValue(Constants.appID, forHTTPHeaderField: "app_id")
            request.addValue(Constants.webAPIKey, forHTTPHeaderField: "app_key")
            request.setValue(
                "multipart/form-data; boundary=" + Constants.boundaryConstant,
                forHTTPHeaderField: "Content-Type"
            )
            request.setValue(bodyLength, forHTTPHeaderField: "Content-Length")
            
            
            request.httpMethod = "POST"
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.httpShouldHandleCookies = false
            request.timeoutInterval = 15
            request.httpBody = body as Data
            request.url = URL
            
            submitImageTask?.cancel()
            
            let session = URLSession(configuration: self.currentSessionConfiguration(uid))
            
            self.submitImageTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                var currentError: Error? = nil
                var jsonString: String?

                
                if error != nil {
                    // If error not nil then handle it as Network Error
                    currentError = NetworkError(error: error! as NSError)
                } else {
                    // If error nil then we have response data
                    if let resultData = data {
                        // Get string representation of json to send it to webview or you can parse response data to Dictionary
                        jsonString = NSString(data: resultData, encoding: String.Encoding.utf8.rawValue) as String?
                        
                        // Parse response data to check Parse Error or Image Recognition Error (not math)
                        var JSONObject: Any?
                        do {
                            JSONObject = try JSONSerialization.jsonObject(with: resultData, options: JSONSerialization.ReadingOptions.mutableLeaves)
                        } catch {
                            currentError = RecognitionError.failedParseJSON
                        }
                        
                        // Check if image not math
                        if let responseObject = JSONObject as? NSDictionary {
                            if let responseError = responseObject["error"] as? String , responseError.count > 0 {
                                currentError = RecognitionError.notMath(responseError)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    complitionHandler?(jsonString, currentError)
                })
            })
            
            submitImageTask?.resume()
        }
        else {
            DispatchQueue.main.async(execute: {
                complitionHandler?(nil, nil)
            })
        }
    }

    
    func clearLatex(_ latex: String) -> String {
        let resultLatex = latex.replacingOccurrences(of: "\\", with: "\\\\")
        return resultLatex
    }
    
}
