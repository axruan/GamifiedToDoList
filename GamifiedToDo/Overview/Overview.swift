//
//OverView.swift
//
///This view presents 2 tab views. One for ToDo list, one for Award.
///
import SwiftUI

struct Overview: View {
    
    @State var selectedTab = "TODos"
        
    var body: some View {
        ZStack {
            TabView (selection: $selectedTab){
                Group {
                    ToDoView()
                        .tabItem {
                            Label("To Do's", systemImage: "checkmark.square.fill")
                        }
                        .tag("TODos")
                    AvatarSelectionView()
                        .tabItem {
                            Label("Award", systemImage: "gift.fill")
                        }
                        .tag("Rewards")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color.yellow, for: .tabBar)
            }
            .tint(Color(middleViewBackgroundColor))
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview().environmentObject(DataModel())
    }
}
