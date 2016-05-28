//
//  Data.swift
//  ChatChat
//
//  Created by Admin on 22.04.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation

let  cityArray = ["Амстердам", "Аяччо", "Астрахань", "Аллесандрия", "Абу-Даби", "Базель", "Барановичи", "Бобруйск", "Бейрут", "Белосток", "Варшава", "Воронеж", "Ватикан", "Валенсия", "Варна", "Гаага", "Гамбург", "Гент", "Гданьск", "Гродно", "Гомель", "Даллас", "Дубаи", "Детройт", "Джоржтаун", "Донецк", "Евпатория", "Елец", "Ереван", "Екатеринбург", "Женева", "Житомир", "Загреб", "Звенигород", "Запорожье", "Занзибар", "Зальцбург", "Иваново", "Иерусалим", "Ижевск", "Измир", "Йорк", "Йоханнесбург", "Карпаты", "Киев", "Калининград", "Кейптаун", "Курск", "Кишинев", "Корк", "Лагос", "Лейпциг", "Лидс", "Лиссабон", "Льеж", "Лондон", "Минск", "Москва", "Молодечно", "Майнц", "Манчестер", "Мельбурн", "Мехико", "Неаполь", "Норильск", "Ницца", "Нью-Йорк", "Ньюкасл", "Одесса", "Овьедо", "Омаха", "Омск", "Оттава", "Пиза", "Панама", "Памплона", "Париж", "Пекин", "Пермь", "Рига", "Рязань", "Рио-де-Женейро", "Ростов", "Росарио", "Смоленск", "Слуцк", "Сан-Диего", "Санкт-Петербург", "Сасово", "Севастополь", "Ташкент", "Токио", "Тольяти", "Торжок", "Тракаи", "Уральск", "Ульяновск", "Узда", "Утрехт", "Феодосия", "Флоренция", "Фрайбург", "Хабаровск", "Ханой", "Хельсинки", "Хьюстон", "Цюрих", "Чебоксары", "Чернигов", "Честер", "Чита", "Шанхай", "Шадринск", "Шацк", "Эдинбург", "Энгельс", "Юрмала", "Ялта", "Якутск", "Ярославль"]

func getCityNames() -> [String: [String]] {
    var dictionary = [String: [String]]()
    for city in cityArray {
        let key:String! = String(city.lowercaseString.characters.first)
        let forcedKey: String = key!
        let forcedForcedKey: String! = key
        print(forcedKey)
        if dictionary.keys.contains(key) {
            dictionary[forcedForcedKey]!.append(city)
        } else {
            dictionary[forcedForcedKey] = [city]
        }
    }
    print(dictionary)
    return dictionary
}