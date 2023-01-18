//
//  Route.swift
//  CoverApps
//
//  Created by sharui on 2023/1/18.
//

import SwiftUI

class Router: ObservableObject {
  @ViewBuilder
  func route(to note:  NoteModel) -> some View {
    NavigationLink(value: note) {
        NoteListItem(item: note)
    }
  }
}
