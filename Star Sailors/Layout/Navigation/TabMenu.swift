//
//  TabMenu.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 19/6/2025.
//

import SwiftUI

struct TabMenu: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            
            CameraScene()
                .tabItem {
                    Label("Explore", systemImage: "camera.fill")
                }
            
            Inventory()
                .tabItem {
                    Label("Holdings", systemImage: "lightbulb.fill")
                }
            
            AnomalyListView()
                .tabItem {
                    Label("Map", systemImage: "lightbublb.fill")
                }
        }
        
        .accentColor(.gardenGreen)
    }
}

#Preview {
    TabMenu()
}
