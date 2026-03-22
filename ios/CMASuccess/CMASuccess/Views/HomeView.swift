//
//  HomeView.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var apiService = APIService()
    @State private var showTopics = false
    @State private var showProgress = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "1a237e"), Color(hex: "283593")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Logo and title
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)

                        Text("CMA Success")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        Text("Your CMA Exam Companion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    // Stats card
                    VStack(spacing: 8) {
                        Text("Exam in 2 months")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("1 hour daily = CMA certified 🏆")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Buttons
                    VStack(spacing: 16) {
                        NavigationLink(destination: TopicListView(apiService: apiService)) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Start Studying")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(hex: "1a237e"))
                            .cornerRadius(12)
                        }

                        NavigationLink(destination: MyProgressView(apiService: apiService)) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("My Progress")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView()
}
