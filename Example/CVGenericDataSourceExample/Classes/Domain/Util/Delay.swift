//
//  Created by Stephan Schulz
//  http://www.stephanschulz.com
//
//
//  GitHub
//  https://github.com/mittenimraum/CVGenericDataSource
//
//
//  License
//  Copyright © 2016 Stephan Schulz
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

public typealias delay_result = (_ cancel: Bool) -> Void

@discardableResult public func delay(_ time: Double, _ closure: @escaping () -> Void) -> delay_result? {
    var result: delay_result?

    let resultClosure: delay_result? = { cancel in
        result = nil

        guard cancel == false else {
            return
        }
        DispatchQueue.main.async {
            closure()
        }
    }
    result = resultClosure

    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
        result?(false)
    }
    return result
}
