//
//  CameraSessionController.swift
//  MathPix
//
//  Created by Michael Lee on 3/25/16.
//  Copyright © 2016 MathPix. All rights reserved.
//

import UIKit
import PureLayout

/**
 * This class is the top-level of the app UI
 */
class CameraVC: UIViewController, CACameraSessionDelegate
{
    @IBOutlet weak var cameraView : CameraSessionView?
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var shutterBottomButton: UIButton!
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    
    @IBOutlet weak var shutterTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shutterCenterConstraint: NSLayoutConstraint!
    
    fileprivate let shutterReleaseAnimationScaleTransformMultiplier : CGFloat = 1.8
    fileprivate let shutterReleaseAnimationDuration = 0.27
    
    let cropOverlay = CropControlOverlay()

    var uid = DeviceUID.instance().uid()
    
    let imageService = ImageService()
    
    var previewViewController: PreviewWebViewController? = nil
    let networkActivityView = UIView()

    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        setupOverlay()
        setupButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cropOverlay.resetView()
    }
    
    
    // MARK:  -  SETUP METHODS
    fileprivate func setupButtons() {
        
        let color = self.view.tintColor
        flashButton.layer.borderWidth = 1.5
        flashButton.layer.borderColor = color!.cgColor
        flashButton.layer.cornerRadius = flashButton.bounds.size.height / 2.0
        flashButton.layer.masksToBounds = true
        
        shutterButton.layer.borderWidth = 2
        shutterButton.layer.borderColor = color!.cgColor
        shutterButton.layer.cornerRadius = shutterButton.bounds.size.height / 2.0
        
        shutterBottomButton.layer.borderWidth = 2
        shutterBottomButton.layer.borderColor = color!.cgColor
        shutterBottomButton.layer.cornerRadius = shutterBottomButton.bounds.size.height / 2.0

    }
    
    
    fileprivate func setupOverlay(){
        view.insertSubview(cropOverlay, belowSubview: containerView)
        let insets = UIEdgeInsetsMake(0, 0, containerHeightConstraint.constant + containerBottomOffsetConstraint.constant, 0)
        cropOverlay.autoPinEdgesToSuperviewEdges(with: insets)
        
        cropOverlay.draggingCallback = { [unowned self] bottomCenter in
            guard let point = bottomCenter else { return }
            let convertedPoint = self.view.convert(point, from: self.cropOverlay)
            self.shutterTopConstraint.constant = convertedPoint.y + 5
        }
        
    }
    
    

    func setupCamera() {
        self.cameraView?.delegate = self
        self.cameraView?.hideCameraToogleButton()
        DispatchQueue.main.async {
            self.cameraView?.hideFlashButton()
        }
        
    }
    
    
    // MARK: - Actions

    @IBAction func flashButtonClick(_ sender: AnyObject) {
        self.cameraView?.onTapFlashButton()
    }
    
    
    @IBAction func shutterButtonClick(_ sender: Any) {
        
        self.cropOverlay.flashCrop()
        
        self.cameraView?.onTapShutterButton()
        guard let button = sender as? UIButton else { return }
        self.animateShutterReleaseButton(button)
    }
    
    
    // MARK: - Image Capturing
    
    func didCapture(_ image: UIImage!) {
        
        if let cameraView = self.cameraView {
            if let resultImage = self.imageService.cropImage(image, bounds: cameraView.bounds) {
                let croppedImage = cropOverlay.cropImageAndUpdateDisplay(resultImage, superview: cameraView)
                sendImageToServer(croppedImage)
            }
        }
    }
    
    
    func sendImageToServer(_ image:UIImage) {
        networkActivityDidStart()
        imageService.sendImageToServer(self.uid, image: image) { [weak self] (jsonString, error) in
                // If error handle it, handle other type of errors as you need
                if error != nil {
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .notReachedServer:
                            let title = "Send image timeout"
                            let message = "Our servers are currently experiencing heavy load.  We apologize for the inconvenience.  Please try again later."
                            self?.displayError(title: title, error: message)
                        case .notConnectedToInternet:
                            let title = "Error"
                            let message = "No internet connection"
                            self?.displayError(title: title, error: message)
                        case .requestCanceled:
                            return
                        default:
                            break
                        }
                    } else if let recognitionError = error as? RecognitionError {
                        switch recognitionError {
                        case .failedParseJSON:
                            let title = "Error"
                            let message = "Error parse json"
                            self?.displayError(title: title, error: message)
                        case .notMath(let message):
                            let resultError = NSError(domain: "localhost", code: -1, userInfo: [NSLocalizedDescriptionKey : message, "title": "Image recognition error"])
                            self?.cropOverlay.displayError(resultError)
                        }
                    }
                    // If json object exist send it to webview
                } else {
                    self?.previewViewController?.jsonString = jsonString
                }
            self?.networkActivityDidStop()
        }
    }
    
    // MARK: - Error handling
    
    func displayError(title: String, error: String) {
        let alertView = UIAlertView(title: title, message: error, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        cropOverlay.resetView()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PreviewSegue") {
            if let vc = (segue.destination as? UINavigationController)?.topViewController as? PreviewWebViewController {
                self.previewViewController = vc;
                self.containerView.layer.cornerRadius = 5
                self.containerView.clipsToBounds = true
            }
        }
    }
    
    
    
    // MARK: - Animations

    
    func animateShutterReleaseButton(_ button: UIButton) {
        UIView.animateKeyframes(withDuration: shutterReleaseAnimationDuration, delay: 0, options: [], animations: {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                button.transform = CGAffineTransform(scaleX: self.shutterReleaseAnimationScaleTransformMultiplier, y: self.shutterReleaseAnimationScaleTransformMultiplier)
            }, completion: nil)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                button.transform = CGAffineTransform.identity
            }, completion: nil)
            
        }, completion: nil)
    }
    
}

extension CameraVC : NetworkActivityAnimatable {
    
}



























