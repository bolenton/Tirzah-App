import Foundation

struct EasterEgg: Identifiable, Codable {
    let id: String
    let levelId: Int
    let type: EasterEggType
    let hint: String
    let rewardType: String
    let rewardContent: String

    enum EasterEggType: String, Codable {
        case tap
        case sequence
        case speed
        case exploration
    }
}
