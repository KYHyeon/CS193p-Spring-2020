//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by 현기엽 on 2020/07/26.
//  Copyright © 2020 현기엽. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}
