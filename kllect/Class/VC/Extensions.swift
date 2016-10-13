//
//  Extensions.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-12.
//  Copyright © 2016 topmobile. All rights reserved.
//

import Foundation

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
