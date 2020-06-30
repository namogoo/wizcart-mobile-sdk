//
//  UIView + CornerRadius.swift
//  Holocaust Survivors Immediate Assist
//
//  Created by Amir Zucker on 27/07/2019.
//  Copyright © 2019 Amir Zucker. All rights reserved.
//

import UIKit

extension UIView
{
    func drawRoundedCorners(with cornerRadius: Double, lineWidth: CGFloat = 1.0, and lineColor: CGColor? = nil, shouldMaskToBound : Bool = false)
    {
        let radiusSize              = CGSize(width: cornerRadius, height: cornerRadius)
        let path                    = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: radiusSize)
        let shapeLayer              = CAShapeLayer()
        shapeLayer.strokeColor      = lineColor ?? UIColor.clear.cgColor
        shapeLayer.path             = path.cgPath
        shapeLayer.lineWidth        = lineWidth
        shapeLayer.fillColor        = UIColor.clear.cgColor

        layer.addSublayer(shapeLayer)

        layer.cornerRadius          = CGFloat(cornerRadius)
        layer.masksToBounds         = shouldMaskToBound
    }
    
    func drawShadow()
    {
        let shadowPath      = UIBezierPath(rect: self.bounds)
        layer.shadowPath    = shadowPath.cgPath
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowRadius  = 2
        layer.shadowOffset  = CGSize(width: 0, height: self.layer.shadowRadius)
        layer.shadowOpacity = 0.2
    }
    
    func drawNamogooGradient()
    {
        let gradient        = CAGradientLayer()
        gradient.type       = .radial
        gradient.colors     = [App.Colors.namogooCubeInnerGradientColor.color.cgColor, App.Colors.namogooCubeOuterGradientColor.color.cgColor]
        gradient.locations  = [0.0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        gradient.frame      = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.layer.addSublayer(gradient)
    }
    
    func removeLayers()
    {
        layer.sublayers = nil
    }
}
