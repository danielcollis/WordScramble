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
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var gameScore = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    Text("Score: \(gameScore)")
                    Button("Restart") {
                        startGame()
                    }
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
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original")
            return
        }
        
        guard canBeCreated(word: answer) else {
            wordError(title: "Can't create from word", message: "This word cannot be created from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not a real word", message: "You can't just make words up!")
            return
        }
        
        gameScore += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    //supposed to run as soon as the app opens
    func startGame() {
        gameScore = 0
        usedWords = [String]()
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
    
    //checks if it's a real word
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
