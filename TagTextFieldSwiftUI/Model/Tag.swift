//
//  Tag.swift
//  TagTextFieldSwiftUI
//
//  Created by 김정민 on 2023/09/17.
//

import SwiftUI

/// Tag Model
struct Tag: Identifiable, Hashable {
    var id: UUID = .init()
    var value: String
    var isInitial: Bool = false
}
