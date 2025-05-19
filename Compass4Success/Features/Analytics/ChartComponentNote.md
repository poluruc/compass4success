# Chart Components for Analytics

This document provides an overview of the chart components used in the analytics features of Compass4Success.

## Available Chart Components

### 1. Grade Distribution Chart
- **Purpose**: Display distribution of grades across different grade ranges (A, B, C, D, F)
- **File**: `GradeDistributionChart.swift`
- **Usage**: Class performance analysis, school-wide grade distribution

### 2. Subject Performance Chart
- **Purpose**: Compare average grades across different subjects
- **File**: `SubjectPerformanceChart.swift`
- **Usage**: Identifying strengths/weaknesses in specific subject areas

### 3. Time Series Chart
- **Purpose**: Visualize grade trends over time
- **File**: `TimeSeriesChart.swift`
- **Usage**: Tracking student or class progress throughout a term

### 4. Engagement Radar Chart
- **Purpose**: Multi-dimensional visualization of student engagement metrics
- **File**: `EngagementRadarChart.swift`
- **Usage**: Holistic view of student participation, attendance, assignment completion

### 5. Specialty Charts
- **Purpose**: Collection of specialized chart types for specific analytics needs
- **File**: `SpecialtyCharts.swift`
- **Includes**:
  - CircularProgressGauge
  - ComparisonBarChart
  - AttendanceHeatMap
  - AchievementProgressMeter

## Implementation Guidelines

### Data Models
Each chart component expects specific data structures:
- `ChartDataPoint`: Basic label-value pair for bar charts
- `TimeSeriesDataPoint`: Date-based data points for line charts
- `ScatterPlotDataPoint`: X-Y coordinates with optional label
- Custom structures for specialized charts

### Customization Options
All charts support customization of:
- Colors and styling
- Height and dimensions
- Legends and labels
- Animations (where applicable)

### Accessibility
Charts include accessibility features:
- Color schemes considerate of color blindness
- VoiceOver descriptions of data trends
- Alternative text representations

## Usage Examples

```swift
// Example 1: Basic Grade Distribution Chart
GradeDistributionChart(
    data: [
        ChartDataPoint(label: "A (90-100%)", value: 12),
        ChartDataPoint(label: "B (80-89%)", value: 18),
        ChartDataPoint(label: "C (70-79%)", value: 15),
        ChartDataPoint(label: "D (60-69%)", value: 7),
        ChartDataPoint(label: "F (0-59%)", value: 3)
    ],
    showLegend: true
)

// Example 2: Time Series Chart with multiple data series
TimeSeriesChart(
    data: analyticsService.getGradeOverTimeData(),
    title: "Grade Trends",
    yAxisLabel: "Average Grade",
    minY: 0,
    maxY: 100
)
```

## Best Practices

1. **Performance**: Large datasets should be optimized before rendering
2. **Consistency**: Use similar color schemes across the app
3. **Clarity**: Include legends and clear labels for all charts
4. **Responsiveness**: Charts should adapt to different device sizes
5. **Printing**: Consider how charts will appear in exported reports

## Future Enhancements

- Add interactive tooltips for data points
- Implement drill-down capabilities for hierarchical data
- Add export options for individual charts
- Develop comparison views for year-over-year data