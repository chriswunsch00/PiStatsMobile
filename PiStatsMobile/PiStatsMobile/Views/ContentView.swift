//
//  ContentView.swift
//  PiStatsMobile
//
//  Created by Fernando Bunn on 02/07/2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                PiholeStatsList()
            }
            .tabItem {
                Image(systemName: "shield")
                Text(UIConstants.Strings.piholesNavigationTitle)
            }.tag(0)
            .navigationViewStyle(StackNavigationViewStyle())

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text(UIConstants.Strings.settingsNavigationTitle)
            }.tag(1)
            .navigationViewStyle(StackNavigationViewStyle())

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .environment(\.locale, .init(identifier: "pt_br"))
            ContentView()
                .preferredColorScheme(.dark)
        }
        
    }
}

