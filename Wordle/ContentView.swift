//
//  ContentView.swift
//  Wordle
//
//  Created by Home on 8/2/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                GameView(viewModel: viewModel)
                KeyboardView(viewModel: viewModel)
            }
            if viewModel.bannerType != nil {
                BannerView(bannerType: viewModel.bannerType!)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
