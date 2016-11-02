//
//  KCTError.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-11-01.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import Foundation

enum KCTError: Error {
	case networkError(Error) // This case is basically to forward a network error
	case notStringConvertable
	case malformedType
	case unknownError
}
