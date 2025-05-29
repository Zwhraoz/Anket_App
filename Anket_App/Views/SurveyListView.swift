//  SurveyListView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//
import SwiftUI

struct SurveyListView: View {
    @StateObject var viewModel = SurveyListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Arama çubuğu
                TextField("Anket ara...", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)

                List(viewModel.filteredSurveys) { survey in
                    NavigationLink(destination: SurveyDetailView(viewModel: SurveyDetailViewModel(survey: survey))) {
                        VStack(alignment: .leading) {
                            Text(survey.title)
                                .font(.headline)
                            Text(survey.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Anketler")
            .onAppear {
                viewModel.loadSurveys()
            }
        }
    }
}
