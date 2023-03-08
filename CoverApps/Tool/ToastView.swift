//
//  ToastView.swift
//  CoverApps
//
//  Created by sharui on 2023/3/7.
//

import SwiftUI

struct TWToastView: View {
    @Binding var isShow: Bool
    let info: String
    @State private var isShowAnimation: Bool = true
    @State private var duration : Double
    
    init(isShow:Binding<Bool>,info: String = "", duration:Double = 2.0) {
        self._isShow = isShow
        self.info = info
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            Text(info)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.white)
                        .shadow(color: .init(white: 0.95), radius: 10, x: 0, y: 0)
                )
            
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isShowAnimation = false
            }
        }
        .padding()
        .animation(.easeIn(duration: 0.8),value: 2)
        .opacity(isShowAnimation ? 1 : 0)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isShowAnimation) { e in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isShow = false
            }
        }
    }
}

struct TWToastView_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
struct Test: View {
    @State var show  =  false
    var body: some View {
        Button("214") {
            show.toggle()
        }
        .toast(isShow: $show, info: "测试")
    }
}



extension View {
    func toast(isShow:Binding<Bool>, info:String = "",  duration:Double = 1.0) -> some View {
        ZStack {
            self
            if isShow.wrappedValue {
                TWToastView(isShow:isShow, info: info, duration: duration)
            }
        }
     }
}
