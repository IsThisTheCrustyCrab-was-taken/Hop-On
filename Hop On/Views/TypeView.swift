//
//  TypeView.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import SwiftUI

struct TypeView: View {
    let type: ModeRotation
    let name: String
    let refreshAction: () async -> Void
    var body: some View {
        let current = type.current
        let next = type.next
        VStack {
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Group{
                if let url = URL(string: current.asset) {
                    AsyncImage(url: url) { img in
                        TypeImageView(type: current, image: img, refreshAction: refreshAction)
                            .frame(maxHeight: .infinity)
                    } placeholder: {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    }

                } else {
                    Rectangle().foregroundStyle(.gray.gradient)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            HStack(){
                Text("Next: ")
                if let next {
                    Text("\(next.map)")
                    if let eventName = next.eventName {
                        Spacer()
                        Text("(\(eventName))")
                    }
                }
            }
            .fontWeight(.medium)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity)

    }
}
