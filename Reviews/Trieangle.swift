//
//  UIView.swift
//  Moviethete
//
//  Created by Admin on 26/07/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit

class Triangle: UIView {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        
        var ctx : CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, (CGRectGetMaxX(rect)/2.0), CGRectGetMinY(rect))
        CGContextClosePath(ctx)
        
        CGContextSetRGBFillColor(ctx, 1.0, 0.5, 0.0, 0.60);
        CGContextFillPath(ctx);
    }

}
