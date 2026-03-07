//
//  FlipdApp.swift
//  Flipd
//
//  Created by Prem kamble on 06/03/26.
//

import SwiftUI

@main
struct FlipdApp: App {
    @AppStorage("colorScheme") private var colorScheme: String = "system"

    var preferredColorScheme: ColorScheme? {
        switch colorScheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            LaunchView()
                .preferredColorScheme(preferredColorScheme)
        }
    }
}
