import Foundation
import NaturalLanguage

/// Result of sentiment analysis on a text input
struct SentimentResult: Equatable {
    let score: Double         // -1.0 to +1.0
    let label: String         // "positive", "neutral", "negative"
    let confidence: Double    // 0.0 to 1.0
    let emotionalTones: [String]
    let tags: [String]
    
    static let neutral = SentimentResult(
        score: 0.0,
        label: "neutral",
        confidence: 0.0,
        emotionalTones: [],
        tags: []
    )
}

/// Handles all on-device NLP processing using Apple's Natural Language framework.
/// Understands casual texting language, slang, abbreviations, and context.
///
/// Key design: people write journals like they're texting a friend.
/// "bored... wanna watch a movie rn" is NOT negative — it's idle/chill.
/// The engine must understand CONTEXT, not just individual word sentiment.
actor SentimentService {
    
    // MARK: - Slang & Abbreviation Expansion
    
    /// Maps common texting abbreviations to their full meaning.
    /// This runs BEFORE analysis so the engine understands casual language.
    private let slangMap: [String: String] = [
        // Common abbreviations
        "rn": "right now", "rly": "really", "tbh": "to be honest",
        "ngl": "not gonna lie", "imo": "in my opinion", "imho": "in my honest opinion",
        "idk": "i dont know", "idc": "i dont care", "idgaf": "i dont care at all",
        "brb": "be right back", "btw": "by the way", "fyi": "for your information",
        "omg": "oh my god", "omfg": "oh my god", "lol": "laughing", "lmao": "laughing hard",
        "rofl": "laughing really hard", "smh": "shaking my head disappointed",
        "fml": "my life sucks", "af": "very", "nvm": "never mind",
        "ily": "i love you", "ilysm": "i love you so much",
        "ty": "thank you", "tysm": "thank you so much", "thx": "thanks",
        "pls": "please", "plz": "please", "bc": "because", "cuz": "because",
        "gonna": "going to", "wanna": "want to", "gotta": "got to",
        "kinda": "kind of", "sorta": "sort of", "dunno": "dont know",
        "prolly": "probably", "probs": "probably", "tho": "though",
        "abt": "about", "w": "with", "b4": "before",
        "fr": "for real", "frfr": "for real for real genuinely",
        "goated": "amazing the best", "bussin": "really good amazing",
        "slay": "amazing great", "slayed": "did amazing",
        "vibe": "feeling mood", "vibes": "feelings mood",
        "vibing": "feeling good relaxed", "chillin": "relaxing calm",
        "chilling": "relaxing calm", "lowkey": "kind of quietly",
        "highkey": "very really", "deadass": "seriously genuinely",
        "bet": "okay sure agreed", "cap": "lie fake", "no cap": "honestly truly",
        "sus": "suspicious sketchy", "salty": "annoyed upset bitter",
        "lit": "exciting amazing fun", "fire": "amazing great excellent",
        "mid": "mediocre average boring", "basic": "ordinary nothing special",
        "extra": "over the top dramatic", "mood": "relatable feeling",
        "oof": "that hurts uncomfortable", "yikes": "that is bad uncomfortable",
        "bruh": "expression of disbelief", "fam": "close friend family",
        "bae": "loved one partner", "bestie": "best friend",
        "toxic": "unhealthy harmful negative", "triggered": "upset bothered",
        "ghosted": "ignored abandoned", "flex": "show off brag",
        "periodt": "that is final absolutely", "sis": "friend",
        "tea": "gossip drama", "shade": "disrespect insult subtle",
        "clout": "popularity influence", "simp": "trying too hard for someone",
        "stan": "big fan obsessed supporter", "ship": "want them together",
        "cringe": "embarrassing uncomfortable awkward",
        "blessed": "grateful fortunate lucky",
        "wya": "where are you", "hmu": "hit me up contact me",
        "ftw": "for the win", "fomo": "fear of missing out anxious",
        "jomo": "joy of missing out peaceful content",
        "tl;dr": "summary", "irl": "in real life",
        "dm": "message", "dms": "messages",
        "smth": "something", "sth": "something",
        "obv": "obviously", "def": "definitely",
        "whatevs": "whatever", "perf": "perfect",
        "fab": "fabulous great", "adorbs": "adorable cute",
        "jk": "just kidding", "j/k": "just kidding",
        "np": "no problem", "nw": "no worries",
        "k": "okay", "kk": "okay", "mk": "okay",
        "ofc": "of course", "fs": "for sure",
        "tbf": "to be fair", "iirc": "if i remember correctly",
    ]
    
    // MARK: - Emotion Detection (expanded)
    
    /// Comprehensive emotion keywords including casual/texting language
    private let emotionKeywords: [String: Set<String>] = [
        "happy": Set(["happy", "joy", "joyful", "wonderful", "amazing", "fantastic", "great",
                       "excited", "delighted", "cheerful", "thrilled", "elated", "glad",
                       "laugh", "laughed", "laughing", "fun", "celebrate", "love", "loved",
                       "yay", "woohoo", "awesome", "incredible", "brilliant", "lol", "lmao",
                       "haha", "hehe", "perfect", "best", "beautiful", "lovely", "adorable",
                       "lit", "fire", "bussin", "goated", "slayed", "slay"]),
        "calm": Set(["calm", "peaceful", "serene", "relaxed", "tranquil", "quiet",
                      "mindful", "meditation", "meditate", "centered", "balanced",
                      "gentle", "soothing", "rest", "resting", "chill", "chillin",
                      "chilling", "vibing", "mellow", "zen", "cozy", "comfy",
                      "content", "settled", "steady", "easy", "breezy"]),
        "grateful": Set(["grateful", "thankful", "blessed", "appreciate", "appreciation",
                          "gratitude", "lucky", "fortunate", "thanks", "thank",
                          "tysm", "ty", "thx"]),
        "excited": Set(["excited", "thrilled", "pumped", "hyped", "stoked", "cant wait",
                         "looking forward", "anticipation", "eager", "buzzing",
                         "amped", "psyched", "ready"]),
        "anxious": Set(["anxious", "anxiety", "worried", "worry", "nervous", "panic",
                         "fear", "scared", "uneasy", "restless", "overthinking",
                         "racing", "dread", "fomo", "on edge", "tense", "jittery",
                         "freaking out", "spiraling"]),
        "stressed": Set(["stressed", "stress", "overwhelmed", "pressure", "deadline",
                          "deadlines", "overworked", "burnout", "exhausted", "hectic",
                          "chaos", "frantic", "swamped", "drowning", "too much",
                          "cant handle", "breaking point", "fml"]),
        "sad": Set(["sad", "unhappy", "depressed", "down", "lonely", "lonesome",
                     "miserable", "heartbroken", "grief", "crying", "cried", "tears",
                     "empty", "hopeless", "gutted", "devastated", "broken",
                     "numb", "lost", "hurting", "aching", "sobbing"]),
        "angry": Set(["angry", "anger", "furious", "mad", "irritated", "frustrated",
                       "annoyed", "rage", "hate", "hostile", "resentful", "pissed",
                       "livid", "fuming", "triggered", "salty", "bitter",
                       "infuriated", "outraged"]),
        "bored": Set(["bored", "boring", "boredom", "nothing to do", "meh",
                       "blah", "whatever", "dull", "tedious", "monotonous",
                       "same old", "mid", "basic", "uninterested"]),
        "energized": Set(["energized", "energy", "motivated", "driven", "productive",
                           "active", "vigorous", "pumped", "workout", "exercise",
                           "fired up", "lets go", "crushing it", "on fire"]),
        "tired": Set(["tired", "exhausted", "fatigued", "sleepy", "drained",
                       "weary", "lethargic", "sluggish", "burnt out", "wiped",
                       "dead tired", "knackered", "zonked"]),
        "proud": Set(["proud", "accomplished", "achieved", "achievement", "success",
                       "successful", "completed", "finished", "milestone", "nailed it",
                       "crushed it", "smashed it", "did it", "flex"]),
        "nostalgic": Set(["nostalgic", "nostalgia", "remember", "memories", "miss",
                           "missing", "childhood", "past", "throwback", "tbt",
                           "good old days", "back then", "used to"]),
        "playful": Set(["playful", "silly", "goofy", "joking", "kidding", "lol",
                         "haha", "funny", "hilarious", "messing around",
                         "goofing off", "teasing"]),
        "romantic": Set(["romantic", "love", "crush", "butterflies", "heart",
                          "date", "dating", "relationship", "bae", "partner",
                          "soulmate", "chemistry", "attracted", "flirting"]),
        "confused": Set(["confused", "confusing", "lost", "unsure", "uncertain",
                          "idk", "dont know", "conflicted", "torn", "mixed feelings",
                          "what do i do", "no idea", "cant decide"]),
        "hopeful": Set(["hopeful", "hope", "hoping", "optimistic", "positive",
                         "things will get better", "looking up", "bright side",
                         "silver lining", "faith", "believe", "trust the process"]),
        "indifferent": Set(["whatever", "meh", "idc", "dont care", "shrug",
                             "not bothered", "neutral", "fine", "okay", "alright",
                             "nothing special", "just another day"]),
    ]
    
    // MARK: - Sentiment Words (expanded with texting language)
    
    /// Strongly positive words/phrases
    private let positiveWords: Set<String> = Set([
        "good", "goood", "gooood", "great", "amazing", "awesome", "fantastic", "wonderful",
        "excellent", "perfect", "brilliant", "beautiful", "lovely", "nice", "sweet",
        "happy", "glad", "pleased", "enjoyed", "enjoy", "enjoying", "love",
        "loved", "loving", "best", "better", "incredible", "outstanding",
        "superb", "magnificent", "terrific", "fabulous", "delightful",
        "fun", "funny", "hilarious", "laugh", "laughed", "laughing",
        "blessed", "grateful", "thankful", "appreciate", "appreciated",
        "proud", "accomplished", "succeeded", "success", "successful",
        "excited", "thrilled", "ecstatic", "elated", "overjoyed",
        "yeah", "yay", "woohoo", "yess", "yesss",
        "satisfying", "satisfied", "comfortable", "confident",
        "refreshed", "recharged", "energized", "motivated", "inspired",
        "peaceful", "calm", "relaxed", "serene", "blissful",
        "productive", "achieved", "milestone", "progress", "growth",
        "celebrate", "celebration", "reward", "rewarding", "rewarded",
        "delicious", "tasty", "yummy",
        "lit", "fire", "bussin", "goated", "slayed", "slay",
        "dope", "sick", "epic", "legendary", "insane", "unreal",
        "vibing", "chillin", "cozy", "comfy",
        "fascinating", "interesting", "intriguing", "cool", "neat",
        "stoked", "hyped", "pumped", "psyched", "amped",
        "adorable", "cute", "precious", "wholesome",
        "grateful", "blessed", "fortunate",
        "chill", "relaxing", "soothing",
    ])
    
    /// Strongly negative words (NOT including contextual words like "bored")
    private let negativeWords: Set<String> = Set([
        "terrible", "horrible", "awful", "worst", "worse",
        "hate", "hated", "hating", "despise", "loathe", "disgusting",
        "unhappy", "miserable", "depressed", "depressing",
        "furious", "irritated", "frustrated",
        "anxious", "anxiety", "worried", "worry", "nervous", "panic",
        "stressed", "stress", "overwhelmed", "burnout",
        "lonely", "isolated", "abandoned", "rejected",
        "hurt", "pain", "painful", "suffering", "struggling",
        "failed", "failure", "disappointed", "disappointing",
        "crying", "cried", "tears", "heartbroken", "heartbreak",
        "sick", "ill", "headache", "migraine",
        "pointless", "hopeless", "helpless",
        "ugly", "stupid", "useless", "worthless", "pathetic",
        "toxic", "nightmare", "ruined", "destroyed",
        "devastated", "gutted", "shattered", "crushed",
        "betrayed", "manipulated", "gaslighted",
        "fml", "smh",
        "cringe", "yikes", "oof",
    ])
    
    /// Words that are CONTEXTUAL — not negative on their own.
    /// "bored" + wanting to do fun stuff = neutral/slightly positive (idle, looking for fun)
    /// "bored" + "nothing ever changes" = actually negative
    private let contextualWords: Set<String> = Set([
        "bored", "boring", "tired", "exhausted", "drained",
        "lazy", "free", "nothing", "empty", "alone",
        "bad", "sad", "mad", "angry", "annoyed",
    ])
    
    /// Words that indicate the person is thinking about POSITIVE activities
    /// These cancel out contextual negativity
    private let activityWords: Set<String> = Set([
        "movie", "movies", "watch", "watching", "netflix", "show", "series",
        "play", "playing", "game", "games", "gaming",
        "eat", "eating", "food", "pizza", "ice cream", "icecream", "burger",
        "chocolate", "snack", "snacks", "dessert", "cake", "coffee", "tea",
        "cook", "cooking", "bake", "baking",
        "gym", "workout", "exercise", "run", "running", "swim", "swimming",
        "tennis", "football", "basketball", "soccer", "cricket", "sports",
        "walk", "hike", "hiking", "bike", "cycling",
        "read", "reading", "book", "books",
        "music", "song", "songs", "playlist", "spotify", "listen",
        "draw", "drawing", "paint", "painting", "art",
        "shop", "shopping", "mall",
        "travel", "trip", "vacation", "holiday",
        "hang", "hangout", "meet", "friends", "friend",
        "party", "concert", "festival", "event",
        "sleep", "nap", "rest",
        "maybe", "should", "could", "want", "wanna", "gonna",
        "need", "thinking", "might",
    ])
    
    // MARK: - Public Methods
    
    /// Performs full sentiment analysis on the given text.
    /// First expands slang/abbreviations, then blends NLTagger with contextual keyword analysis.
    func analyze(text: String) -> SentimentResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .neutral
        }
        guard text.count >= 3 else {
            return .neutral
        }
        
        // Step 0: Expand slang and abbreviations for better understanding
        let expandedText = expandSlang(text)
        
        // Step 1: Context-aware sentiment scoring
        let (score, confidence) = analyzeWithContext(original: text, expanded: expandedText)
        
        // Step 2: Determine label
        let label = sentimentLabel(from: score)
        
        // Step 3: Detect emotional tones (from expanded text for better matching)
        let tones = detectEmotionalTones(in: expandedText, originalText: text)
        
        // Step 4: Extract tags
        let tags = extractTags(from: expandedText)
        
        return SentimentResult(
            score: score,
            label: label,
            confidence: confidence,
            emotionalTones: tones,
            tags: tags
        )
    }
    
    // MARK: - Slang Expansion
    
    /// Expands abbreviations and slang into full words for better NLP processing.
    /// e.g., "feeling good rn ngl" → "feeling good right now not gonna lie"
    private func expandSlang(_ text: String) -> String {
        var result = text.lowercased()
        
        // Sort by length descending so longer phrases match first
        let sortedSlang = slangMap.sorted { $0.key.count > $1.key.count }
        
        for (slang, expansion) in sortedSlang {
            // Match whole words only (using word boundaries)
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: slang))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: expansion
                )
            }
        }
        
        return result
    }
    
    // MARK: - Context-Aware Scoring
    
    /// Analyzes sentiment with full context awareness.
    /// Understands that "bored but wanna watch a movie" ≠ negative.
    private func analyzeWithContext(original: String, expanded: String) -> (Double, Double) {
        let nlScore = getNLTaggerScore(text: expanded)
        let keywordScore = getContextualKeywordScore(text: expanded, original: original)
        
        let keywordStrength = abs(keywordScore)
        let nlStrength = abs(nlScore)
        
        let finalScore: Double
        if keywordStrength > 0.05 && nlStrength < 0.2 {
            // Keywords have signal, NLTagger is weak — trust keywords more
            finalScore = max(-1.0, min(1.0, keywordScore * 0.65 + nlScore * 0.35))
        } else if keywordStrength > 0.05 {
            // Both have signal — blend
            finalScore = max(-1.0, min(1.0, keywordScore * 0.45 + nlScore * 0.55))
        } else {
            finalScore = nlScore
        }
        
        let lengthFactor = min(1.0, Double(original.count) / 120.0)
        let magnitudeFactor = abs(finalScore)
        let confidence = min(1.0, lengthFactor * 0.5 + magnitudeFactor * 0.5)
        
        return (finalScore, confidence)
    }
    
    /// NLTagger raw score
    private func getNLTaggerScore(text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let tag = tag, let score = Double(tag.rawValue) {
            return score
        }
        return 0.0
    }
    
    /// Context-aware keyword scoring.
    /// Key insight: words like "bored" are only negative if NOT followed by fun activity plans.
    private func getContextualKeywordScore(text: String, original: String) -> Double {
        let lowercased = text.lowercased()
        let words = lowercased.split(whereSeparator: { !$0.isLetter }).map(String.init)
        let wordSet = Set(words)
        
        var posScore: Double = 0
        var negScore: Double = 0
        
        // Count positive words
        for word in words {
            if positiveWords.contains(word) { posScore += 1.0 }
        }
        
        // Count negative words (only strongly negative ones)
        for word in words {
            if negativeWords.contains(word) { negScore += 1.0 }
        }
        
        // CONTEXT CHECK: Handle contextual words
        let hasActivityPlans = !wordSet.intersection(activityWords).isEmpty
        let contextWordsFound = wordSet.intersection(contextualWords)
        
        if !contextWordsFound.isEmpty {
            if hasActivityPlans {
                // "bored... wanna watch a movie" → the person is idle but thinking of fun stuff
                // This is neutral-to-slightly-positive, NOT negative
                posScore += 0.3 * Double(wordSet.intersection(activityWords).count)
                // Don't add the contextual words as negative
            } else {
                // "bored... nothing ever changes" → genuinely negative
                negScore += 0.4 * Double(contextWordsFound.count)
            }
        }
        
        // Check positive phrases
        let positivePhrases = [
            "hell yeah", "damn good", "so good", "really good",
            "feeling great", "feeling good", "good day", "great day",
            "cant wait", "looking forward", "feel like having",
            "feel like eating", "want to", "going to",
            "should be fun", "sounds fun", "sounds good",
            "pretty good", "not bad", "no complaints",
            "all good", "im good", "i'm good", "doing well",
            "so excited", "lets go", "let's go",
            "love it", "loved it", "love this", "love that",
            "best day", "best thing", "made my day",
            "ngl pretty", "tbh pretty good", "fr fr",
            "ice cream", "ice-cream",
        ]
        for phrase in positivePhrases {
            if lowercased.contains(phrase) { posScore += 1.5 }
        }
        
        // Check negative phrases
        let negativePhrases = [
            "really bad", "so bad", "can't stand", "fed up",
            "really terrible", "bad day", "worst day",
            "want to cry", "feel like crying", "breaking down",
            "cant take", "cant handle", "falling apart",
            "hate my", "hate this", "hate everything",
            "sick of", "tired of everything",
            "nothing matters", "whats the point", "give up",
            "so done", "im done", "i'm done",
            "feel like shit", "feel awful", "feel terrible",
        ]
        for phrase in negativePhrases {
            if lowercased.contains(phrase) { negScore += 1.5 }
        }
        
        let total = posScore + negScore
        guard total > 0 else { return 0.0 }
        
        let ratio = (posScore - negScore) / total
        return max(-1.0, min(1.0, ratio * min(1.0, total / 2.5)))
    }
    
    /// Label from score
    private func sentimentLabel(from score: Double) -> String {
        switch score {
        case 0.1...: return "positive"
        case -0.1..<0.1: return "neutral"
        default: return "negative"
        }
    }
    
    // MARK: - Emotion Detection
    
    /// Detects emotional tones from both expanded and original text.
    /// Uses expanded text for slang matching but original for authenticity.
    private func detectEmotionalTones(in expandedText: String, originalText: String) -> [String] {
        let combined = (expandedText + " " + originalText).lowercased()
        let words = Set(combined.split(whereSeparator: { !$0.isLetter }).map(String.init))
        
        var emotionScores: [(emotion: String, count: Int)] = []
        
        for (emotion, keywords) in emotionKeywords {
            let matchCount = words.intersection(keywords).count
            if matchCount > 0 {
                emotionScores.append((emotion, matchCount))
            }
        }
        
        // Also check for phrase-level emotions
        if combined.contains("feel like") && (combined.contains("movie") || combined.contains("eat") ||
            combined.contains("play") || combined.contains("ice cream") || combined.contains("food")) {
            emotionScores.append(("playful", 2))
        }
        
        return emotionScores
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map(\.emotion)
    }
    
    // MARK: - Tag Extraction
    
    private func extractTags(from text: String) -> [String] {
        var tags: [String] = []
        
        let categories: [String: Set<String>] = [
            "work": Set(["work", "office", "meeting", "meetings", "project", "boss",
                          "colleague", "deadline", "career", "job", "presentation",
                          "client", "team"]),
            "family": Set(["family", "mom", "dad", "mother", "father", "sister", "brother",
                            "kids", "children", "son", "daughter", "parents", "spouse",
                            "husband", "wife", "partner", "bae"]),
            "health": Set(["health", "doctor", "exercise", "workout", "gym", "sleep",
                            "medicine", "headache", "sick", "hospital", "dentist",
                            "yoga", "meditation", "tennis", "running", "swimming"]),
            "social": Set(["friends", "friend", "dinner", "party", "brunch", "coffee",
                            "hangout", "gathering", "social", "fam", "bestie", "bro"]),
            "nature": Set(["nature", "park", "garden", "hike", "hiking", "mountain",
                            "beach", "forest", "trees", "flowers", "sunset", "sunrise",
                            "outdoor", "outdoors", "walk", "walking"]),
            "food": Set(["food", "eating", "eat", "pizza", "burger", "ice cream", "icecream",
                          "chocolate", "cooking", "recipe", "restaurant", "cafe",
                          "breakfast", "lunch", "dinner", "snack", "dessert",
                          "delicious", "tasty", "yummy"]),
            "entertainment": Set(["movie", "movies", "film", "netflix", "show", "series",
                                   "watch", "watching", "game", "games", "gaming",
                                   "music", "song", "concert", "spotify", "youtube",
                                   "tiktok", "instagram", "social media"]),
            "learning": Set(["learn", "learning", "study", "studying", "course", "book",
                              "reading", "read", "class", "tutorial", "practice"]),
            "creative": Set(["cooking", "recipe", "painting", "drawing", "music",
                              "writing", "craft", "design", "photography", "art"]),
        ]
        
        let lowercased = text.lowercased()
        let words = Set(lowercased.split(whereSeparator: { !$0.isLetter }).map(String.init))
        
        for (category, keywords) in categories {
            if !words.intersection(keywords).isEmpty {
                tags.append(category)
            }
        }
        // Also check multi-word tags
        if lowercased.contains("ice cream") || lowercased.contains("ice-cream") {
            if !tags.contains("food") { tags.append("food") }
        }
        
        return Array(Set(tags)).sorted()
    }
}
