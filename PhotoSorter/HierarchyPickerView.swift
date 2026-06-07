//
//  HierarchyPickerView.swift
//  PhotoSorter
//

import SwiftUI
import SwiftData

struct HierarchyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [SortPreferences]

    var body: some View {
        NavigationStack {
            Group {
                if let prefs = preferences.first {
                    PreferencesForm(prefs: prefs)
                } else {
                    Color.clear
                        .task {
                            modelContext.insert(SortPreferences())
                        }
                }
            }
            .navigationTitle("Sort Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct PreferencesForm: View {
    @Bindable var prefs: SortPreferences

    var body: some View {
        Form {
            Section {
                ForEach(prefs.hierarchy) { dimension in
                    HierarchyRow(dimension: dimension, prefs: prefs)
                }
                .onMove { source, destination in
                    var newOrder = prefs.hierarchy
                    newOrder.move(fromOffsets: source, toOffset: destination)
                    prefs.hierarchy = newOrder
                }
            } header: {
                Text("Sort Hierarchy")
            } footer: {
                Text("Drag to reorder. Photos are grouped from top to bottom.")
            }

            Section("Display") {
                Picker("Bucket Order", selection: $prefs.bucketSortOrder) {
                    ForEach(BucketSortOrder.allCases) { order in
                        Text(order.displayName).tag(order)
                    }
                }

                Toggle("Favorites Only", isOn: $prefs.favoritesOnly)
            }
        }
        .environment(\.editMode, .constant(.active))
    }
}

private struct HierarchyRow: View {
    let dimension: Dimension
    @Bindable var prefs: SortPreferences

    var body: some View {
        HStack {
            Label(dimension.displayName, systemImage: dimension.systemImageName)
            Spacer()
            granularityControl
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var granularityControl: some View {
        switch dimension {
        case .time:
            Menu {
                Picker("Granularity", selection: $prefs.timeGranularity) {
                    ForEach(TimeGranularity.allCases) { g in
                        Text(g.displayName).tag(g)
                    }
                }
            } label: {
                Text(prefs.timeGranularity.displayName)
            }
        case .location:
            Menu {
                Picker("Granularity", selection: $prefs.locationGranularity) {
                    ForEach(LocationGranularity.allCases) { g in
                        Text(g.displayName).tag(g)
                    }
                }
            } label: {
                Text(prefs.locationGranularity.displayName)
            }
        case .content:
            EmptyView()
        }
    }
}

#Preview {
    HierarchyPickerView()
        .modelContainer(for: SortPreferences.self, inMemory: true)
}
