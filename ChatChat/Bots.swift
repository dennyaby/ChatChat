//
//  Bots.swift
//  ChatChat
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation

let englishAlphabet = "A B C D E F G H I K L M N O P Q R S T V X Y Z"
let numbers = "1 2 3 4 5 6 7 8 9"
let russianAlphabet = "А Б В Г Д Е Ж З И Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я"
let punctuationMarks = "< , > . ? / \" ' ; : \\ } ] { [ ! @ # $ % ^ & * ( ) _ - + ="


class BotManager: Bot {
    static let sharedInstance = BotManager()
    
    var bots = [Bot]()
    
    
    func addBot(name: String) {
        switch name {
        default:
            break
        }
    }
    
    func removeBot(name: String) {
        switch name {
        default:
            break
        }
    }
    
    func refactorInput(text: String) -> String? {
        return nil
    }
    
}

class BotCityGame: Bot {
    
    var isPlaying = false
    
    func refactorInput(text: String) -> String? {
        
        if(isPlaying) {
            if (text == "Хватит играть!") || (text == "Мне надоело!") || (text == "Я не хочу больше играть") || (text == "Стоп") || (text == "Давай перестанем") || (text == "Давай лучше пообщаемся!") {
                isPlaying = false
                return "Хорошо, давай пообщаемся"
            } else {
                
                if botUsedCities.contains(text) {
                    return "Ха, я уже называл этот город! Давай другой."
                }
                
                if userUsedCities.contains(text) {
                    return "Ты уже вроде называл этот город"
                }
                
                userUsedCities.append(text)
                
                let lastChar = String(text.lowercaseString.characters.last)
                let chosenCityArray = cities[lastChar]
                
                if var array = chosenCityArray {
                    let city = array[randomInt(min: 0, max: array.count)]
                    botUsedCities.append(city)
                    array.removeAtIndex(array.indexOf(city)!)
                    return city
                } else {
                    return "Я не знаю городов на эту букву!"
                }
            }
        } else {
            if (text == "Давай сыграем") || (text == "Сыграем?") || (text == "Давай поиграем") || (text == "Давай сыграем в города") {
                isPlaying = true
                return "Давай, с удовольствием! Начинай"
            }
            
            for (question, answer) in defaultAnswersDict {
                if question == text {
                    return answer
                }
            }
            
            if text.hasPrefix("bot learn") {
                
            }
            
            return nil
        }
        
        
    }
    
    //Data
    
    var usedWords = [String]()
    let cities = getCityNames()
    
    var botUsedCities = [String]()
    var userUsedCities = [String]()
    
    var defaultAnswersDict: [String: String]
    
    init() {
        defaultAnswersDict = ["Привет": "Привет", "Как дела?": "Хорошо, а у тебя?", "Какой у тебя пол?": "Я девушка!", "Кто твой создатель?": "Dennya"]
    }
    
    func randomInt(min min: Int, max: Int) -> Int {
        let num = arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min)
        return Int(num)
    }
    
    
    
    
}

protocol Bot {
    func refactorInput(text: String) -> String?
}


class EnglishLanguageBot: Bot {
    
    
    
    func refactorInput(text: String) -> String? {
        return nil
    }
}