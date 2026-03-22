//
//  ResultView.swift
//  CMASuccess
//
//  Created by Ramkumar Krishnan on 2026-03-22.
//

import SwiftUI

struct ResultView: View {
    let submitResponse: SubmitResponse
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: submitResponse.is_correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(submitResponse.is_correct ? .green : .red)

            Text(submitResponse.is_correct ? "Correct! 🎉" : "Incorrect")
                .font(.title)
                .fontWeight(.bold)

            Text(submitResponse.explanation)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            HStack {
                Label("\(Int(submitResponse.accuracy_rate))% accuracy",
                      systemImage: "chart.bar")
                Spacer()
                Label(submitResponse.current_difficulty.capitalized,
                      systemImage: "speedometer")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)

            Button(action: onNext) {
                Text("Next Question →")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1a237e"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
