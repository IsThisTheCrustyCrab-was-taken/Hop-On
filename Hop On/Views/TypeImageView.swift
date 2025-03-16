//
//  TypeImageView.swift
//  Hop On
//
//  Created by Bennet Kampe on 16/3/25.
//

import SwiftUI

struct TypeImageView: View {
    let type: RotationDetail
    let image: Image
    let refreshAction: () async -> Void
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .overlay {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }

            VStack(alignment: .leading){
                HStack {
                    Text(type.map)
                    Spacer()
                    CountdownTextField(targetDate: Date(timeIntervalSince1970: TimeInterval(type.end)), onTimerComplete:{ Task {
                        await refreshAction()
                    }})
                }
                Spacer()
                if let eventName = type.eventName {
                    Text(eventName)
                }
            }
            .fontWeight(.heavy)
            .padding([.leading, .bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
