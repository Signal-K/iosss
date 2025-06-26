//
//  Inventory.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 26/6/2025.
//

import SwiftUI
import Foundation
import Supabase

struct ItemDefinition: Decodable {
    let id: Int
    let name: String
    let description: String
    let cost: Int?
    let icon_url: String
    let ItemCategory: String
    let parentItem: Int?
    let itemLevel: Int?
    let locationType: String?
    let recipe: [String: Int]?
    let gif: String?
}

struct RawInventory: Decodable, Identifiable {
    let id: Int64
    let item: Int64?
    let owner: UUID?
}

@MainActor
class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []

    private var itemDefinitions: [Int: ItemDefinition] = [:]

    func fetchInventory() async {
        do {
            async let definitions = fetchItemDefinitions()
            async let rawItems: [RawInventory] = supabase
                .from("inventory")
                .select("id, item, owner")
                .limit(100)
                .execute()
                .value

            let (defs, inv) = try await (definitions, rawItems)
            self.itemDefinitions = Dictionary(uniqueKeysWithValues: defs.map { ($0.id, $0) })

            self.items = inv.map { raw in
                if let id = raw.item, let def = itemDefinitions[Int(id)] {
                    return InventoryItem(
                        id: raw.id,
                        name: def.name,
                        iconURL: def.icon_url
                    )
                } else {
                    return InventoryItem(
                        id: raw.id,
                        name: "Unknown Item \(raw.item ?? -1)",
                        iconURL: ""
                    )
                }
            }

        } catch {
            print("Failed to fetch inventory: \(error)")
        }
    }

    private func fetchItemDefinitions() async throws -> [ItemDefinition] {
        guard let url = URL(string: "https://starsailors.space/api/gameplay/inventory") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ItemDefinition].self, from: data)
    }
}

struct InventoryItem: Identifiable {
    let id: Int64
    let name: String
    let iconURL: String
}

struct Inventory: View {
    @StateObject private var viewModel = InventoryViewModel()

    private var groupedItems: [String: [InventoryItem]] {
        Dictionary(grouping: viewModel.items) {
            String($0.name.prefix(1)).uppercased()
        }.mapValues {
            $0.sorted { $0.name < $1.name }
        }
    }

    private var sectionTitles: [String] {
        groupedItems.keys.sorted()
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List {
                    ForEach(sectionTitles, id: \.self) { section in
                        Section(header: Text(section).id(section)) {
                            ForEach(groupedItems[section] ?? []) { item in
                                HStack {
                                    if let url = URL(string: item.iconURL), !item.iconURL.isEmpty {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 24, height: 24)
                                        }
                                    } else {
                                        Image(systemName: "questionmark.square.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                    }

                                    Text(item.name)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Inventory")
                .task {
                    await viewModel.fetchInventory()
                }
                .overlay(
                    VStack(spacing: 4) {
                        ForEach(sectionTitles, id: \.self) { letter in
                            Button(action: {
                                withAnimation {
                                    proxy.scrollTo(letter, anchor: .top)
                                }
                            }) {
                                Text(letter)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .trailing),
                    alignment: .trailing
                )
            }
        }
    }
}

#Preview {
    Inventory()
}
