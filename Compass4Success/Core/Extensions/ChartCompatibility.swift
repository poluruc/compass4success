import SwiftUI
import Charts

/// A placeholder view shown when Charts are unavailable
struct ChartCompatPlaceholder: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Charts Not Available")
                .font(.headline)
            
            Text("Charts are only available on macOS 13.0+ and iOS 16.0+")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Chart Compatibility Extensions

extension View {
    /// Applies chartYScale modifier when available, otherwise returns the original view
    @ViewBuilder
    func adaptiveChartYScale(domain: ClosedRange<Double>) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 16.0, macOS 13.0, *) {
            self.chartYScale(domain: domain)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - iOS 16+ / macOS 13+ Chart Utilities

#if os(iOS) || os(macOS)
/// Factory methods for creating charts with proper availability checks
enum ChartFactory {
    /// Creates a bar chart with the given data and value keypath
    @available(iOS 16.0, macOS 13.0, *)
    static func barChart<T: Identifiable>(
        data: [T], 
        value: KeyPath<T, Double>,
        title: String? = nil
    ) -> some View {
        VStack {
            if let title = title {
                Text(title).font(.headline)
            }
            
            Chart(data) { item in
                BarMark(
                    x: .value("Item", "\(item.id)"),
                    y: .value("Value", item[keyPath: value])
                )
            }
        }
    }
    
    /// Creates a line chart with the given data and value keypath
    @available(iOS 16.0, macOS 13.0, *)
    static func lineChart<T: Identifiable>(
        data: [T], 
        x: KeyPath<T, String>,
        y: KeyPath<T, Double>,
        title: String? = nil
    ) -> some View {
        VStack {
            if let title = title {
                Text(title).font(.headline)
            }
            
            Chart(data) { item in
                LineMark(
                    x: .value("Category", item[keyPath: x]),
                    y: .value("Value", item[keyPath: y])
                )
            }
        }
    }
}

/// A wrapper function that creates an appropriate chart based on OS version
@ViewBuilder
func createAdaptiveChart<T: Identifiable>(
    data: [T],
    value: KeyPath<T, Double>,
    title: String? = nil
) -> some View {
    if #available(iOS 16.0, macOS 13.0, *) {
        ChartFactory.barChart(data: data, value: value, title: title)
    } else {
        ChartCompatPlaceholder()
    }
}
#endif 