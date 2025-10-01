# Accessibility Identifiers for NewsHub

This document lists all accessibility identifiers added to the NewsHub app for UI automation testing.

## NewsHomeView

### Article Cards
- `newsArticleCard_<index>` - Individual news article cards in the main feed (index-based for unique identification)

### Loading States
- `loadingMoreIndicator` - Loading indicator shown when fetching more articles

### Empty/Error States
- `errorView` - Error view displayed when article loading fails
- `emptyStateView` - Empty state view shown when no articles are available
- `errorRetryButton` - Retry button in error view

## NewsListItemView (Article Card Components)

### Article Elements
- `articleImage` - Article preview image
- `articleTitle` - Article title text
- `articleDescription` - Article description/summary text
- `articleSource` - News source name
- `articleTime` - Time ago string (e.g., "2 hours ago")

### Action Buttons
- `readMoreButton` - "Read More" button to open full article
- `favoriteButton` - Heart icon button to add/remove from favorites
  - Accessibility label: "Add to favorites" / "Remove from favorites"

## ArticleModalView (Full Article View)

### Article Content
- `modalArticleImage` - Full-size article image in modal
- `modalArticleTitle` - Article title in modal
- `modalArticleSource` - News source in modal
- `modalArticleTime` - Publication time in modal
- `modalArticleAuthor` - Article author (if available)
- `modalArticleDescription` - Article description in modal
- `modalArticleContent` - Full article content in modal

### Action Buttons
- `readFullArticleButton` - Button to open article in Safari
- `shareArticleButton` - Button to share article
- `closeModalButton` - Close button to dismiss modal

## CompactFilterView (Filter Components)

### Filter Controls
- `clearAllFiltersButton` - Button to clear all active filters
- `moreFiltersButton` - Button to open full filter sheet

### Filter Chips (Horizontal Scroll)
- `categoryFilter_<index>` - Category filter chips (Business, Sports, Technology, etc.)
  - Index 0: Business
  - Index 1: Sports
  - Index 2: Technology
  - Index 3: Health
  - Index 4: Science
  - Index 5: Entertainment
  - Index 6: All
  
- `dateFilter_<index>` - Date range filter chips
  - Index 0: All
  - Index 1: Today
  - Index 2: Last Week

- `sourceFilterChip` - News source filter chip
- `sourceFilterLoading` - Loading indicator for news sources

## CompactFilterSheet (Full Filter Screen)

### Category Filters
- `filterSheetCategory_<index>` - Category options in filter sheet (matches all NewsCategory cases)

### Date Range Filters
- `filterSheetDate_<index>` - Date filter options in filter sheet
- `customDateRangeButton` - Button to open custom date range picker

### Source Filters
- `filterSheetSource_<index>` - News source options (up to 20 sources, index-based)

### Sheet Actions
- `filterSheetResetButton` - Reset button to clear all filters
- `filterSheetDoneButton` - Done button to apply filters and close sheet

## CustomDateRangeSheet

### Date Pickers
- `customDateFromPicker` - "From" date picker
- `customDateToPicker` - "To" date picker

### Actions
- `customDateCancelButton` - Cancel button
- `customDateApplyButton` - Apply button to confirm date range

## EnhancedNewsCardView (Alternative Card Layout)

### Action Buttons
- `enhancedReadMoreButton` - "Read More" button
- `enhancedFavoriteButton` - Favorite heart button
  - Accessibility label: "Add to favorites" / "Remove from favorites"

---

## Usage Guidelines for Automation

1. **List Items**: All items in lists (articles, filters) use index-based identifiers (e.g., `newsArticleCard_0`, `newsArticleCard_1`, etc.) for unique identification.

2. **Dynamic Content**: 
   - Favorite button accessibility labels change based on state ("Add to favorites" / "Remove from favorites")
   - Filter active counts are displayed but not directly accessible via identifiers

3. **Modal Navigation**:
   - Use `readMoreButton` to open article modal
   - Use `closeModalButton` to dismiss modal

4. **Filter Workflow**:
   - Use `moreFiltersButton` to open full filter sheet
   - Use specific filter identifiers to select options
   - Use `filterSheetDoneButton` to apply and close
   - Use `clearAllFiltersButton` for quick reset

5. **Error Handling**:
   - Check for `errorView` presence to detect error states
   - Use `errorRetryButton` to trigger retry action

## Example Test Scenarios

### Opening an Article
```
1. Tap newsArticleCard_0
2. Verify modalArticleTitle is visible
3. Tap readFullArticleButton (opens Safari)
4. Or tap closeModalButton to return to feed
```

### Filtering Articles
```
1. Tap categoryFilter_1 (Sports)
2. Or tap moreFiltersButton
3. Tap filterSheetCategory_2 (Technology)
4. Tap filterSheetDoneButton
5. Verify filtered content loads
```

### Adding to Favorites
```
1. Tap favoriteButton on article card
2. Verify accessibility label changes to "Remove from favorites"
3. Tap again to remove
4. Verify label changes back to "Add to favorites"
```

---

**Note**: All identifiers follow a consistent naming convention:
- Component type + specific element + optional index
- camelCase formatting
- Descriptive and unique names
