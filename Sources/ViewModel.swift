import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScheme = RandomScheme(name: "新方案", firstMin: 1, firstMax: 8, secondMin: 1, secondMax: 20)
    @Published var savedSchemes: [RandomScheme] = []
    @Published var result: String = ""
    
    private let defaults = UserDefaults.standard
    private let schemesKey = "savedSchemes"
    
    init() {
        loadSchemes()
        if savedSchemes.isEmpty {
            savedSchemes.append(currentScheme)
            saveSchemes()
        } else {
            currentScheme = savedSchemes[0]
        }
    }
    
    func loadSchemes() {
        guard let data = defaults.data(forKey: schemesKey),
              let schemes = try? JSONDecoder().decode([RandomScheme].self, from: data)
        else { return }
        savedSchemes = schemes
    }
    
    func saveSchemes() {
        if let data = try? JSONEncoder().encode(savedSchemes) {
            defaults.set(data, forKey: schemesKey)
        }
    }
    
    func addCurrentScheme() {
        if let index = savedSchemes.firstIndex(where: { $0.id == currentScheme.id }) {
            savedSchemes[index] = currentScheme
        } else {
            savedSchemes.append(currentScheme)
        }
        saveSchemes()
    }
    
    func deleteScheme(_ scheme: RandomScheme) {
        savedSchemes.removeAll { $0.id == scheme.id }
        saveSchemes()
        if currentScheme.id == scheme.id {
            currentScheme = savedSchemes.first ?? RandomScheme(name: "新方案", firstMin: 1, firstMax: 8, secondMin: 1, secondMax: 20)
        }
    }
    
    func selectScheme(_ scheme: RandomScheme) {
        currentScheme = scheme
    }
    
    func generateRandom() {
        let firstValue = Int.random(in: currentScheme.firstMin...currentScheme.firstMax)
        var secondMin = currentScheme.secondMin
        var secondMax = currentScheme.secondMax
        
        for rule in currentScheme.specialRules {
            if firstValue == rule.triggerNumber {
                secondMin = rule.newSecondMin
                secondMax = rule.newSecondMax
                break
            }
        }
        
        guard secondMin <= secondMax else {
            result = "错误：第二个数范围无效"
            return
        }
        let secondValue = Int.random(in: secondMin...secondMax)
        result = "\(firstValue)-\(secondValue)"
    }
}