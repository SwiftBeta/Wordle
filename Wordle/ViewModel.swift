//
//  ViewModel.swift
//  Wordle
//
//  Created by Home on 11/2/22.
//

import Foundation
import UIKit

enum BannerType {
    case error(String)
    case success
}

final class ViewModel: ObservableObject {
    var numOfRow: Int = 0
    @Published var bannerType: BannerType? = nil
    @Published var result: String = "REINA"
    @Published var word: [LetterModel] = []
    @Published var gameData: [[LetterModel]] = [
        [.init(""), .init(""), .init(""), .init(""), .init("")],
        [.init(""), .init(""), .init(""), .init(""), .init("")],
        [.init(""), .init(""), .init(""), .init(""), .init("")],
        [.init(""), .init(""), .init(""), .init(""), .init("")],
        [.init(""), .init(""), .init(""), .init(""), .init("")],
        [.init(""), .init(""), .init(""), .init(""), .init("")],
    ]
    
    func addNewLetter(letterModel: LetterModel) {
        bannerType = nil
        if letterModel.name == "🚀" {
            tapOnSend()
            return
        }
        
        if letterModel.name == "🗑" {
            tapOnRemove()
            return
        }
        
        if word.count < 5 {
            let letter = LetterModel(letterModel.name)
            word.append(letter)
            gameData[numOfRow][word.count-1] = letter
        }
    }
    
    private func tapOnSend() {
        print("Tap on send")
        guard word.count == 5 else {
            print("Añade más letras!")
            bannerType = .error("¡Añade más letras!")
            return
        }
        
        let finalStringWord = word.map { $0.name }.joined()
        
        if wordIsReal(word: finalStringWord) {
            print("Correct word")
            
            for (index, _) in word.enumerated() {
                let currentCharacter = word[index].name
                var status: Status
                
                if result.contains(where: { String($0) == currentCharacter }) {
                    status = .appear
                    print("\(currentCharacter) .appear")
                    
                    if currentCharacter == String(result[result.index(result.startIndex, offsetBy: index)]) {
                        status = .match
                        print("\(currentCharacter) .match")
                    }
                } else {
                    status = .dontAppear
                    print("\(currentCharacter) .dontAppear")
                }
                
                // Update GameView
                var updateGameBoardCell = gameData[numOfRow][index]
                updateGameBoardCell.status = status
                gameData[numOfRow][index] = updateGameBoardCell
                
                // Update KeyboardView
                let indexToUpdate = keyboardData.firstIndex(where: { $0.name == word[index].name })
                var keyboardKey = keyboardData[indexToUpdate!]
                if keyboardKey.status != .match {
                    keyboardKey.status = status
                    keyboardData[indexToUpdate!] = keyboardKey
                }
            }
            
            let isUserWinner = gameData[numOfRow].reduce(0) { partialResult, letterModel in
                if letterModel.status == .match {
                    return partialResult + 1
                }
                return 0
            }
            
            if isUserWinner == 5 {
                bannerType = .success
            } else {
                // Clean word and move to the new row
                word = []
                numOfRow += 1
            }
            
        } else {
            print("Incorrect word")
            bannerType = .error("¡Palabra incorrecta, no existe!")
        }
    }
    
    func hasError(index: Int) -> Bool {
        guard let bannerType = bannerType else {
            return false
        }
        
        switch bannerType {
        case .error(_):
            return index == numOfRow
        case .success:
            return false
        }
    }
    
    private func tapOnRemove() {
        guard word.count > 0 else {
            return
        }
        gameData[numOfRow][word.count-1] = .init("")
        word.removeLast()
    }
    
    private func wordIsReal(word: String) -> Bool {
        UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word)
    }
}
