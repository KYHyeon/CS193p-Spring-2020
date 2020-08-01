//
//  Array+Only.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/30.
//  Copyright © 2020 현기엽. All rights reserved.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
