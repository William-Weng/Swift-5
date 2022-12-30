//
//  SwiftUICharts.swift
//  ThreadSafety
//
//  Created by William.Weng on 2022/11/8.
//

import SwiftUI

class UserDashboardModel: ObservableObject {
    @Published var markdownString = String()
}

@available(iOS 15, *)
struct SwiftUIText: View {
    
    @ObservedObject var model: UserDashboardModel
    
    var body: some View {
        Text(try! model.markdownString._markdownAttributedString())
            .padding()
            .background(Color.yellow)
    }
}

//struct SwiftUIText_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        return SwiftUIText()
//    }
//}
