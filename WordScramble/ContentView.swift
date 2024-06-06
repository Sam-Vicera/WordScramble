//
//  ContentView.swift
//  WordScramble
//
//  Created by Samuel Hernandez Vicera on 3/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var trackedScore: Int {
        var currentscore = 0
        var wordlength = newWord.count
      
        usedWords.forEach { word in
            currentscore += word.count
        }
        return currentscore * usedWords.count
    }
    
    var body: some View {
        NavigationStack{
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New word"){startGame()}
                }
                ToolbarItem(placement: .bottomBar){
                    Text("Your current score is \(trackedScore)")
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("Ok"){}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already!", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up you know!")
            return
        }
        guard isNotStarterWord(word: answer) else {
            wordError(title: "Starter word used", message: "Using the starter word is not allowed!")
            return
        }
        
        guard isLongerThanTwo(word: answer) else {
            wordError(title: "Word Length Issue", message: "The word must be longer than two characters.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        
        newWord = ""
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") { // looking for the file in the bundle
            if let startWords = try? String(contentsOf: startWordsURL){ // can the file be loaded into a string
                let allWordsArray = startWords.components(separatedBy: "\n")
                rootWord = allWordsArray.randomElement() ?? "silksong"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord // store a copy of the rootword
        
        for letter in word { // loop over the word entered
            if let pos = tempWord.firstIndex(of: letter) { // check if the first letter in the entered word  exists inisde the rootword
                tempWord.remove(at: pos) // remove that letter from the copied root word
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isNotStarterWord(word: String) -> Bool {
        word != rootWord
    }
    
    func isLongerThanTwo(word: String) -> Bool {
        word.count > 2
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
   
}

#Preview {
    ContentView()
}
