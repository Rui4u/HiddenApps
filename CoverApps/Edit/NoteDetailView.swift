//
//  NoteDetailView.swift
//  CoverApps
//
//  Created by sharui on 2023/1/18.
//

import SwiftUI
import module_SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State var item :  NoteModel
    var body: some View {
        VStack {
            TextField("标题", text: $item.title)
                .padding(EdgeInsets(top: 0, leading: 17, bottom: 0, trailing: 17))
                .fontWeight(.bold)
                .font(.title2)
            TextEditingView(fullText: $item.content)
                .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
        }
        .toolbar {
            Button{
                NoteManager.save(note: item)
                coordinator.pop()
                
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}


struct TextEditingView: View {
    @Binding var fullText: String
    
    var body: some View {
        TextEditor(text: $fullText)
            .foregroundColor(Color.black)
            .font(.custom("HelveticaNeue", size: 13))
            .lineSpacing(5)
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(item:  NoteModel(title: "测试", content: "我是内容我是内容我是内容我是内容", time: Date.now))
    }
}
