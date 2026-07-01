import Foundation

struct SpecialRule: Codable, Identifiable, Equatable {
    var id = UUID()
    var triggerNumber: Int
    var newSecondMin: Int
    var newSecondMax: Int
}

struct RandomScheme: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var firstMin: Int
    var firstMax: Int
    var secondMin: Int
    var secondMax: Int
    var specialRules: [SpecialRule] = []
}