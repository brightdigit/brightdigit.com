import Foundation

/// Utility for working with YAML content.
public enum YAML {
  /// The date formatter used for YAML content.
  ///
  /// This date formatter is created once and cached,
  /// so it is safe to call this property multiple times.
  public static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.timeZone = .current
    return dateFormatter
  }()
}
