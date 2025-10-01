//
//  CompactFilterView.swift
//  NewsHub
//
//  Created by Karthick Ramasamy on 30/09/25.
//

import SwiftUI

// Compact Filter View - Combines all filters in a better layout
struct CompactFilterView: View {
    @Binding var selectedCategory: NewsCategory
    @Binding var selectedDateFilter: DateFilter
    @Binding var selectedSource: NewsSource
    let availableSources: [NewsSource]
    let isLoadingSources: Bool
    let onCategoryChange: (NewsCategory) -> Void
    let onDateFilterChange: (DateFilter) -> Void
    let onSourceFilterChange: (NewsSource) -> Void
    let onLoadSources: () -> Void
    
    @State private var showFilterSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter header with active filter count
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                    Text("Filters")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Active filter count badge
                    if activeFilterCount > 0 {
                        Text("\(activeFilterCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(Color.blue))
                    }
                }
                
                Spacer()
                
                // Clear all filters button
                if hasActiveFilters {
                    Button("Clear All") {
                        selectedCategory = .all
                        selectedDateFilter = .all
                        selectedSource = .all
                        onCategoryChange(.all)
                        onDateFilterChange(.all)
                        onSourceFilterChange(.all)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                // More filters button
                Button {
                    print("🔍 More button tapped - showing filter sheet")
                    showFilterSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("More")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            
            // Quick filter chips - horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    // Category chips - showing all main categories as specified in the story
                    ForEach([NewsCategory.business, .sports, .technology, .health, .science, .entertainment, .all], id: \.self) { category in
                        FilterChipView(
                            title: category.displayName,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            color: .blue,
                            onTap: {
                                print("🏷️ Category chip tapped: \(category.displayName)")
                                selectedCategory = category
                                onCategoryChange(category)
                            }
                        )
                    }
                    
                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 4)
                    
                    // Date filter chips
                    ForEach([DateFilter.all, .today, .lastWeek], id: \.id) { dateFilter in
                        FilterChipView(
                            title: dateFilter.displayName,
                            icon: dateFilter.icon,
                            isSelected: selectedDateFilter.isEqual(to: dateFilter),
                            color: .green,
                            onTap: {
                                print("📅 Date filter chip tapped: \(dateFilter.displayName)")
                                selectedDateFilter = dateFilter
                                onDateFilterChange(dateFilter)
                            }
                        )
                    }
                    
                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 4)
                    
                    // Source filter chips (show selected + all)
                    if isLoadingSources {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Loading...")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                    } else {
                        FilterChipView(
                            title: selectedSource.name,
                            icon: selectedSource.id == "all" ? "building.2" : "newspaper",
                            isSelected: selectedSource != .all,
                            color: .purple,
                            onTap: {
                                print("📰 Source filter chip tapped - showing filter sheet")
                                showFilterSheet = true
                            }
                        )
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            if availableSources.count <= 1 {
                onLoadSources()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            CompactFilterSheet(
                selectedCategory: $selectedCategory,
                selectedDateFilter: $selectedDateFilter,
                selectedSource: $selectedSource,
                availableSources: availableSources,
                onCategoryChange: onCategoryChange,
                onDateFilterChange: onDateFilterChange,
                onSourceFilterChange: onSourceFilterChange
            )
        }
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if selectedCategory != .all { count += 1 }
        if !selectedDateFilter.isEqual(to: .all) { count += 1 }
        if selectedSource != .all { count += 1 }
        return count
    }
    
    private var hasActiveFilters: Bool {
        activeFilterCount > 0
    }
}

// Reusable filter chip component
struct FilterChipView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .contentShape(Rectangle())
    }
}

// Comprehensive filter sheet
struct CompactFilterSheet: View {
    @Binding var selectedCategory: NewsCategory
    @Binding var selectedDateFilter: DateFilter
    @Binding var selectedSource: NewsSource
    let availableSources: [NewsSource]
    let onCategoryChange: (NewsCategory) -> Void
    let onDateFilterChange: (DateFilter) -> Void
    let onSourceFilterChange: (NewsSource) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var customFromDate = Date()
    @State private var customToDate = Date()
    @State private var showCustomDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // Categories Section
                Section("Categories") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(NewsCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                onCategoryChange(category)
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text(category.displayName)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedCategory == category {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCategory == category ? Color.blue.opacity(0.1) : Color.clear)
                                )
                            }
                        }
                    }
                }
                
                // Date Filter Section
                Section("Date Range") {
                    ForEach(DateFilter.allCases, id: \.id) { dateFilter in
                        Button(action: {
                            selectedDateFilter = dateFilter
                            onDateFilterChange(dateFilter)
                        }) {
                            HStack {
                                Image(systemName: dateFilter.icon)
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                
                                Text(dateFilter.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedDateFilter.isEqual(to: dateFilter) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    // Custom date range option
                    Button("Custom Range") {
                        showCustomDatePicker = true
                    }
                    .foregroundColor(.green)
                }
                
                // Sources Section
                Section("News Sources") {
                    ForEach(availableSources.prefix(20)) { source in
                        Button(action: {
                            selectedSource = source
                            onSourceFilterChange(source)
                        }) {
                            HStack {
                                Image(systemName: source.id == "all" ? "building.2" : "newspaper")
                                    .foregroundColor(.purple)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(source.name)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    if let description = source.description, !description.isEmpty, source.id != "all" {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedSource == source {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter News")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        selectedCategory = .all
                        selectedDateFilter = .all
                        selectedSource = .all
                        onCategoryChange(.all)
                        onDateFilterChange(.all)
                        onSourceFilterChange(.all)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showCustomDatePicker) {
            CustomDateRangeSheet(
                fromDate: $customFromDate,
                toDate: $customToDate,
                onApply: { from, to in
                    let customFilter = DateFilter.custom(from: from, to: to)
                    selectedDateFilter = customFilter
                    onDateFilterChange(customFilter)
                }
            )
        }
        .onAppear {
            // Set reasonable defaults for custom date picker
            let calendar = Calendar.current
            customToDate = Date()
            customFromDate = calendar.date(byAdding: .day, value: -7, to: customToDate) ?? customToDate
        }
    }
}

struct CustomDateRangeSheet: View {
    @Binding var fromDate: Date
    @Binding var toDate: Date
    let onApply: (Date, Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Date Range") {
                    DatePicker("From", selection: $fromDate, displayedComponents: .date)
                    DatePicker("To", selection: $toDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Custom Date Range")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(fromDate, toDate)
                        dismiss()
                    }
                    .disabled(fromDate > toDate)
                }
            }
        }
        .onAppear {
            // Set reasonable defaults
            let calendar = Calendar.current
            toDate = Date()
            fromDate = calendar.date(byAdding: .day, value: -7, to: toDate) ?? toDate
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: NewsCategory = .all
    @Previewable @State var selectedDateFilter: DateFilter = .all
    @Previewable @State var selectedSource: NewsSource = .all
    @Previewable @State var availableSources: [NewsSource] = [.all]
    
    CompactFilterView(
        selectedCategory: $selectedCategory,
        selectedDateFilter: $selectedDateFilter,
        selectedSource: $selectedSource,
        availableSources: availableSources,
        isLoadingSources: false,
        onCategoryChange: { _ in },
        onDateFilterChange: { _ in },
        onSourceFilterChange: { _ in },
        onLoadSources: { }
    )
}

