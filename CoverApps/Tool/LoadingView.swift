//
//  LoadingView.swift
//  CoverApps
//
//  Created by sharui on 2023/3/7.
//

import SwiftUI

struct SRLoadingView: View {
    
    var body: some View {
        LoadingView(isShowing: .constant(true)) {
            VStack {
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                Text("ceshi")
                
            }
        }
    }
}

struct SRLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        SRLoadingView()
    }
}



struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var message: String = "Loading..."
    var content: () -> Content

    var body: some View {
        ZStack(alignment: .center) {
            
            self.content()
                .disabled(self.isShowing)
                .blur(radius: self.isShowing ? 3 : 0)
            
            VStack {
                Text(message)
                    .font(.body)
                    .fontWeight(.medium)
                    .padding()
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
            .frame(width: 150,
                   height: 150)
            .background(Color.white)
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .opacity(self.isShowing ? 1 : 0)
            .shadow(color: .init(white: 0.95), radius: 10, x: 0, y: 0)
            
        }
    }

}


struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
