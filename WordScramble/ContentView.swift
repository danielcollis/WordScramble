//
//  ContentView.swift
//  WordScramble
//
//  Created by Daniel Collis on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        //extra validation
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    //supposed to run as soon as the app opens
    func startGame() {
        //finds the start.txt file and pulls the strings from it
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "encoding"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    //checks if word has been used
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //checks if a subword can be created from the root
    func canBeCreated(word: String) -> Bool {
        var rootCopy = rootWord
        
        for letter in word {
            if let index = rootCopy.firstIndex(of: letter) {
                rootCopy.remove(at: index)
            } else {return false}
        }
        return true
    }
}

#Preview {
    ContentView()
}
