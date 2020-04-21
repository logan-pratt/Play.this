//
//  NVActivityIndicatorView.swift
//  NVActivityIndicatorViewDemo
//
//  Created by Nguyen Vinh on 7/21/15.
//  Copyright (c) 2015 Nguyen Vinh. All rights reserved.
//

import UIKit

enum NVActivityIndicatorType {
    case blank
    case ballPulse
    case ballGridPulse
    case ballClipRotate
    case squareSpin
    case ballClipRotatePulse
    case ballClipRotateMultiple
    case ballPulseRise
    case ballRotate
    case cubeTransition
    case ballZigZag
    case ballZigZagDeflect
    case ballTrianglePath
    case ballScale
    case lineScale
    case lineScaleParty
    case ballScaleMultiple
    case ballPulseSync
    case ballBeat
    case lineScalePulseOut
    case lineScalePulseOutRapid
    case ballScaleRipple
    case ballScaleRippleMultiple
    case ballSpinFadeLoader
    case lineSpinFadeLoader
    case triangleSkewSpin
    case pacman
    case ballGridBeat
    case semiCircleSpin
}

class NVActivityIndicatorView: UIView {
    private let DEFAULT_TYPE: NVActivityIndicatorType = .blank
    private let DEFAULT_COLOR = UIColor.white()
    private let DEFAULT_SIZE: CGSize = CGSize(width: 40, height: 40)
    
    private var type: NVActivityIndicatorType
    private var color: UIColor
    private var size: CGSize
    
    var animating: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        self.type = DEFAULT_TYPE
        self.color = DEFAULT_COLOR
        self.size = DEFAULT_SIZE
        super.init(coder: aDecoder);
    }
    
    init(frame: CGRect, type: NVActivityIndicatorType, color: UIColor?, size: CGSize?) {
        self.type = type
        self.color = DEFAULT_COLOR
        self.size = DEFAULT_SIZE
        super.init(frame: frame)
        
        if let _color = color {
            self.color = _color
        }
        if let _size = size {
            self.size = _size
        }
    }
    
    convenience init(frame: CGRect, type: NVActivityIndicatorType, color: UIColor?) {
        self.init(frame: frame, type: type, color: color, size: nil)
    }
    
    convenience init(frame: CGRect, type: NVActivityIndicatorType) {
        self.init(frame: frame, type: type, color: nil)
    }
    
    func startAnimation() {
        if (self.layer.sublayers == nil) {
            setUpAnimation()
        }
        self.layer.speed = 1
        self.animating = true
    }
    
    func stopAnimation() {
        self.layer.speed = 0
        self.animating = false
        self.isHidden = true
    }
    
    private func setUpAnimation() {
        let animation: protocol<NVActivityIndicatorAnimationDelegate> = animationOfType(self.type)
        
        self.layer.sublayers = nil
        animation.setUpAnimationInLayer(self.layer, size: self.size, color: self.color)
    }
    
    private func animationOfType(_ type: NVActivityIndicatorType) -> protocol<NVActivityIndicatorAnimationDelegate> {
        switch type {
        case .blank:
            return NVActivityIndicatorAnimationBlank()
        case .ballPulse:
            return NVActivityIndicatorAnimationBallPulse()
        case .ballGridPulse:
            return NVActivityIndicatorAnimationBallGridPulse()
        case .ballClipRotate:
            return NVActivityIndicatorAnimationBallClipRotate()
        case .squareSpin:
            return NVActivityIndicatorAnimationSquareSpin()
        case .ballClipRotatePulse:
            return NVActivityIndicatorAnimationBallClipRotatePulse()
        case .ballClipRotateMultiple:
            return NVActivityIndicatorAnimationBallClipRotateMultiple()
        case .ballPulseRise:
            return NVActivityIndicatorAnimationBallPulseRise()
        case .ballRotate:
            return NVActivityIndicatorAnimationBallRotate()
        case .cubeTransition:
            return NVActivityIndicatorAnimationCubeTransition()
        case .ballZigZag:
            return NVActivityIndicatorAnimationBallZigZag()
        case .ballZigZagDeflect:
            return NVActivityIndicatorAnimationBallZigZagDeflect()
        case .ballTrianglePath:
            return NVActivityIndicatorAnimationBallTrianglePath()
        case .ballScale:
            return NVActivityIndicatorAnimationBallScale()
        case .lineScale:
            return NVActivityIndicatorAnimationLineScale()
        case .lineScaleParty:
            return NVActivityIndicatorAnimationLineScaleParty()
        case .ballScaleMultiple:
            return NVActivityIndicatorAnimationBallScaleMultiple()
        case .ballPulseSync:
            return NVActivityIndicatorAnimationBallPulseSync()
        case .ballBeat:
            return NVActivityIndicatorAnimationBallBeat()
        case .lineScalePulseOut:
            return NVActivityIndicatorAnimationLineScalePulseOut()
        case .lineScalePulseOutRapid:
            return NVActivityIndicatorAnimationLineScalePulseOutRapid()
        case .ballScaleRipple:
            return NVActivityIndicatorAnimationBallScaleRipple()
        case .ballScaleRippleMultiple:
            return NVActivityIndicatorAnimationBallScaleRippleMultiple()
        case .ballSpinFadeLoader:
            return NVActivityIndicatorAnimationBallSpinFadeLoader()
        case .lineSpinFadeLoader:
            return NVActivityIndicatorAnimationLineSpinFadeLoader()
        case .triangleSkewSpin:
            return NVActivityIndicatorAnimationTriangleSkewSpin()
        case .pacman:
            return NVActivityIndicatorAnimationPacman()
        case .ballGridBeat:
            return NVActivityIndicatorAnimationBallGridBeat()
        case .semiCircleSpin:
            return NVActivityIndicatorAnimationSemiCircleSpin()
        }
    }
}
