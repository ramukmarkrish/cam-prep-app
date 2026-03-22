//
//  MyProgressView.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import SwiftUI

struct MyProgressView: View {
    @ObservedObject var apiService: APIService
    @State private var progressItems: [ProgressItem] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color(hex: "f5f5f5").ignoresSafeArea()

            if isLoading {
                ProgressView("Loading progress...")
            } else if progressItems.isEmpty {
                VStack(spacing: 16) {
                    Text("📚")
                        .font(.system(size: 60))
                    Text("No progress yet!")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Start studying to see your progress here")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Part 1
                        SectionHeader(title: "CMA Part 1")
                        ForEach(progressItems.filter { $0.cma_part == 1 }, id: \.topic) { item in
                            ProgressCard(item: item)
                        }

                        // Part 2
                        SectionHeader(title: "CMA Part 2")
                        ForEach(progressItems.filter { $0.cma_part == 2 }, id: \.topic) { item in
                            ProgressCard(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("My Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            apiService.getProgress { items in
                self.progressItems = items
                self.isLoading = false
            }
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

struct ProgressCard: View {
    let item: ProgressItem

    var accuracyColor: Color {
        switch item.accuracy {
        case 75...100: return .green
        case 50...74: return .orange
        default: return .red
        }
    }

    var difficultyColor: Color {
        switch item.difficulty {
        case "hard": return .red
        case "medium": return .orange
        default: return .green
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(item.icon ?? "📚")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.topic)
                        .font(.headline)
                    Text("\(item.questions_seen) questions answered")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(item.accuracy))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(accuracyColor)
                    Text(item.difficulty.capitalized)
                        .font(.caption)
                        .foregroundColor(difficultyColor)
                }
            }

            // Accuracy bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(accuracyColor)
                        .frame(width: geo.size.width * item.accuracy / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        MyProgressView(apiService: APIService())
    }
}
