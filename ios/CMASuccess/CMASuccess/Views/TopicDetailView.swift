//
//  TopicDetailView.swift
//  CMASuccess
//
//  Created by Vaishnavi Srinivasan on 2026-04-21.
//


import SwiftUI

struct TopicDetailView: View {
    let topic: Topic
    @ObservedObject var apiService: APIService

    var body: some View {
        ZStack {
            Color(hex: "f5f5f5").ignoresSafeArea()

            VStack(spacing: 20) {
                // Topic header
                VStack(spacing: 8) {
                    Text(topic.icon ?? "📚")
                        .font(.system(size: 60))
                    Text(topic.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    if let weightage = topic.weightage {
                        Text("Exam weight: \(weightage)%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)

                // Study modes
                VStack(spacing: 12) {
                    Text("Choose Study Mode")
                        .font(.headline)
                        .foregroundColor(.black)

                    // Theory Cards
                    NavigationLink(destination: TheoryCardView(
                        topic: topic,
                        apiService: apiService
                    )) {
                        StudyModeCard(
                            icon: "rectangle.stack.fill",
                            title: "Theory Cards",
                            subtitle: "Swipe through key concepts",
                            color: Color(hex: "1a237e")
                        )
                    }

                    // Practice Quiz
                    NavigationLink(destination: QuizView(
                        topic: topic,
                        apiService: apiService
                    )) {
                        StudyModeCard(
                            icon: "checkmark.circle.fill",
                            title: "Practice Quiz",
                            subtitle: "Test your knowledge",
                            color: Color(hex: "2e7d32")
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StudyModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(color)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}