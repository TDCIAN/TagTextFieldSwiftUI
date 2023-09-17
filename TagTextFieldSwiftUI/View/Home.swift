//
//  Home.swift
//  TagTextFieldSwiftUI
//
//  Created by 김정민 on 2023/09/17.
//

import SwiftUI

struct Home: View {
    /// View Properties
    @State private var tags: [Tag] = []
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    TagField(tags: $tags)                    
                }
                .padding()
            }
            .navigationTitle("Tag Field")
        }
    }
}

#Preview {
    Home()
}
