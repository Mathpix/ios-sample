//
//  CropControl.swift
//  SliderTest
//
//  Created by Gilbert Jolly on 30/04/2016.
//  Copyright © 2016 Gilbert Jolly. All rights reserved.
//

import PureLayout
import Foundation


class CropControlOverlay: UIView {
    let cropControl = CropControl()
    let statusLabel = UILabel()
    fileprivate let flashView = UIView()
    var wasUsedToTakeImage: Bool = false
    var regionSelectedCallback: (()->(Bool))?
    var draggingBeganCallback: (()->())?
    var draggingCallback: ((_ bottomCenter : CGPoint?)->())?
    
    fileprivate var errors : [Error] = []
    fileprivate var errorAnimationInProgress = false

    fileprivate let flashCropAnimationDuration = 0.18
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        
        addSubview(cropControl)
        cropControl.autoCenterInSuperview()
        cropControl.panStateCallback = { [unowned self] state in
            if state == .began {
                
                self.draggingBeganCallback?()
            }
            if state == .ended {
                self.wasUsedToTakeImage = true
//                self.statusLabel.text = "Click on capture button when ready"
                
                if let callback = self.regionSelectedCallback?(), callback {
                    self.statusLabel.text = "Shake to cancel!"
                }
            }
        }
        
        cropControl.cropFrameDidChangedCallback = { [unowned self] bottomCenter in
            self.draggingCallback?(bottomCenter)
        }

        
        cropControl.addSubview(flashView)
        flashView.backgroundColor = UIColor.white
        flashView.alpha = 0
        self.flashView.isHidden = true
        flashView.autoPinEdgesToSuperviewEdges()
        
        
        
        addSubview(statusLabel)
        statusLabel.minimumScaleFactor = 0.5
        statusLabel.textColor = UIColor.white
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.autoPinEdge(.top, to: .bottom, of: cropControl, withOffset: 5)
//        statusLabel.autoAlignAxis(.vertical, toSameAxisOf: cropControl)
        statusLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 20)
        statusLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -20)
        resetView()
    }
    
    
    func flashCrop() {
        self.flashView.isHidden = false
        UIView.animateKeyframes(withDuration: flashCropAnimationDuration, delay: 0, options: [], animations: {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                self.flashView.alpha = 1.0
            }, completion: nil)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                self.flashView.alpha = 0.0
            }, completion: { (finished) in
                if finished {
                    self.flashView.isHidden = true
                }
            })
            
        }, completion: nil)
    }
    
    func resetStatusLabel() {
        self.statusLabel.text = nil
    }
    
    func resetView(){
//        statusLabel.text = "Drag box around equation"
        wasUsedToTakeImage = false
        cropControl.resetView()
    }
    
    func displayError(_ error: Error) {
        self.errors.insert(error, at: 0)
        self.animateErrorMessage()
    }
    
    
    fileprivate func animateErrorMessage() {
        guard !errorAnimationInProgress else { return }
        if let error = self.errors.popLast() {
            self.errorAnimationInProgress = true
            self.statusLabel.text = error.localizedDescription
            self.statusLabel.alpha = 1
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                self.statusLabel.alpha = 0
            }, completion: { _ in
                self.statusLabel.text = nil
                self.errorAnimationInProgress = false
                self.animateErrorMessage()
            })
        }
    }
    
    
    func cropImageAndUpdateDisplay(_ image: UIImage, superview: UIView) -> UIImage{
        let croppedImage = cropImage(image, superview: superview)
        return croppedImage
    }
    
    func cropImage(_ image: UIImage, superview: UIView) -> UIImage{
        let cropRect = cropControl.convert(cropControl.bounds, to: superview)
        
        let imageSize = image.size
        let xScale = imageSize.width / superview.bounds.size.width
        let yScale = imageSize.height / superview.bounds.size.height
        
        let cropX = cropRect.origin.x * xScale
        let cropWidth = cropRect.width * xScale
        let cropY = cropRect.origin.y * yScale
        let cropHeight = cropRect.height * yScale
        
        let scaledCropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        return image.fixOrientation().croppedImage(scaledCropRect)
    }
    
    //We only want to allow the cropView to get hit events,
    //this view should let them fall through to buttons below
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let cropViewPoint = cropControl.convert(point, from: self)
        return cropControl.hitTest(cropViewPoint, with: event)
    }
    
    //Swift... ¯\_(ツ)_/¯
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
