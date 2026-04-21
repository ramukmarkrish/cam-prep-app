//
//  APIService.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import Foundation
import Combine

class APIService: ObservableObject {
    
    @Published var isLoading = false
    
    let baseURL = "https://cma-api-923923178690.us-central1.run.app"
    let userID = "vaishnu_001"
    
    // Fetch all topics
    func getTopics(completion: @escaping ([Topic]) -> Void) {
        guard let url = URL(string: "\(baseURL)/topics") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let topics = try? JSONDecoder().decode([Topic].self, from: data) {
                DispatchQueue.main.async {
                    completion(topics)
                }
            }
        }.resume()
    }
    
    // Fetch questions for a topic
    func getQuestions(topicId: Int, difficulty: String = "medium",
                      completion: @escaping ([Question]) -> Void) {
        guard let url = URL(string: "\(baseURL)/topics/\(topicId)/questions?difficulty=\(difficulty)&user_id=\(userID)") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                DispatchQueue.main.async { completion([]) }
                return
            }
            guard let data = data else {
                print("❌ No data")
                DispatchQueue.main.async { completion([]) }
                return
            }
            print("📦 Response: \(String(data: data, encoding: .utf8) ?? "nil")")
            if let questions = try? JSONDecoder().decode([Question].self, from: data) {
                DispatchQueue.main.async { completion(questions) }
            } else {
                print("❌ Decode failed")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
    // Submit answer
    func submitAnswer(questionId: Int, topicId: Int,
                      answerId: Int, timeTaken: Int,
                      completion: @escaping (SubmitResponse) -> Void) {
        guard let url = URL(string: "\(baseURL)/submit") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userID,
            "question_id": questionId,
            "topic_id": topicId,
            "selected_answer_id": answerId,
            "time_taken": timeTaken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            if let response = try? JSONDecoder().decode(SubmitResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(response)
                }
            }
        }.resume()
    }
    
    // Get progress
    func getProgress(completion: @escaping ([ProgressItem]) -> Void) {
        guard let url = URL(string: "\(baseURL)/progress/\(userID)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let progress = try? JSONDecoder().decode([ProgressItem].self, from: data) {
                DispatchQueue.main.async {
                    completion(progress)
                }
            }
        }.resume()
    }
    func getTheoryCards(topicId: Int, completion: @escaping (TheoryResponse?) -> Void) {
        guard let url = URL(string: "\(baseURL)/topics/\(topicId)/theory") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Theory error: \(error)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            print("📦 Theory response: \(String(data: data, encoding: .utf8) ?? "nil")")
            if let response = try? JSONDecoder().decode(TheoryResponse.self, from: data) {
                DispatchQueue.main.async { completion(response) }
            } else {
                print("❌ Theory decode failed")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
