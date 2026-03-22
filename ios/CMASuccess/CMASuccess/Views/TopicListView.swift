//
//  TopicListView.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import SwiftUI

struct TopicListView: View {
    @ObservedObject var apiService: APIService
    @State private var topics: [Topic] = []
    @State private var isLoading = true
    @State private var selectedPart = 1

    var filteredTopics: [Topic] {
        topics.filter { $0.cma_part == selectedPart }
    }

    var body: some View {
        ZStack {
            Color(hex: "f5f5f5").ignoresSafeArea()

            VStack(spacing: 0) {
                // Part selector
                Picker("CMA Part", selection: $selectedPart) {
                    Text("Part 1").tag(1)
                    Text("Part 2").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.white)

                if isLoading {
                    Spacer()
                    ProgressView("Loading topics...")
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTopics) { topic in
                                NavigationLink(destination: QuizView(
                                    topic: topic,
                                    apiService: apiService
                                )) {
                                    TopicCard(topic: topic)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("CMA Topics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            apiService.getTopics { topics in
                self.topics = topics
                self.isLoading = false
            }
        }
    }
}

struct TopicCard: View {
    let topic: Topic

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Text(topic.icon ?? "📚")
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(Color(hex: "e8eaf6"))
                .cornerRadius(12)

            // Topic info
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                if let weightage = topic.weightage {
                    Text("Exam weight: \(weightage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        TopicListView(apiService: APIService())
    }
}
