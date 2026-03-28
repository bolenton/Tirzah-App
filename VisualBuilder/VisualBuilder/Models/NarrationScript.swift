import Foundation

struct NarrationScript {
    let text: String
    let voiceStyle: String
    let rate: Float
    let pitchMultiplier: Float

    /// Select a random progress narration for a given percentage milestone
    static func progressNarration(from scripts: NarrationScripts, at percent: Int, seed: UInt64) -> String? {
        let key = "\(percent)"
        guard let variants = scripts.progress[key], !variants.isEmpty else { return nil }
        var rng = SeededRNG(seed: seed &+ UInt64(percent))
        let index = Int(rng.next() % UInt64(variants.count))
        return variants[index]
    }

    /// Select a random tension narration for a given time threshold
    static func tensionNarration(from scripts: NarrationScripts, at threshold: String, seed: UInt64) -> String? {
        guard let variants = scripts.tension[threshold], !variants.isEmpty else { return nil }
        var rng = SeededRNG(seed: seed &+ UInt64(threshold.hashValue))
        let index = Int(rng.next() % UInt64(variants.count))
        return variants[index]
    }
}
