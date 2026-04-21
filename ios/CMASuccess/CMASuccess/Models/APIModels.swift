//
//  APIModels.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import Foundation

struct Topic: Codable, Identifiable {
    let id: Int
    let name: String
    let cma_part: Int
    let description: String?
    let icon: String?
    let weightage: Int?
}

struct Question: Codable, Identifiable {
    let id: Int
    let text: String
    let type: String
    let difficulty: String
    let answers: [Answer]
}

struct Answer: Codable, Identifiable {
    let id: Int
    let text: String
}

@MainActor
struct SubmitResponse: Codable, Sendable {
    let is_correct: Bool
    let explanation: String
    let accuracy_rate: Double
    let current_difficulty: String
}

struct ProgressItem: Codable {
    let topic: String
    let cma_part: Int
    let icon: String?
    let difficulty: String
    let accuracy: Double
    let questions_seen: Int
}

struct TheoryCard: Codable, Identifiable {
    var id = UUID()
    let concept: String
    let explanation: String
    let example: String
    let memory_trick: String
    let formula: String?
    let category: String

    enum CodingKeys: String, CodingKey {
        case concept, explanation, example
        case memory_trick, formula, category
    }
}

struct TheoryResponse: Codable {
    let topic: String
    let cma_part: Int
    let icon: String?
    let cards: [TheoryCard]
}
