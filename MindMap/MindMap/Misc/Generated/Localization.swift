// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {

  internal enum Buttons {
    /// Cancel
    internal static let cancel = Localization.tr("Localizable", "buttons.cancel")
    /// Delete
    internal static let delete = Localization.tr("Localizable", "buttons.delete")
    /// Edit
    internal static let edit = Localization.tr("Localizable", "buttons.edit")
    /// Save
    internal static let save = Localization.tr("Localizable", "buttons.save")
  }

  internal enum Dialog {
    /// Your idea
    internal static let placeholder = Localization.tr("Localizable", "dialog.placeholder")
    /// the file will have the same name
    internal static let subtitle = Localization.tr("Localizable", "dialog.subtitle")
    /// Enter your idea
    internal static let title = Localization.tr("Localizable", "dialog.title")
    internal enum Delete {
      /// All sub-ideas of this idea will be deleted too
      internal static let childrenSubtitle = Localization.tr("Localizable", "dialog.delete.children_subtitle")
      /// You are deleting root idea. The file will be deleted too
      internal static let fileSubtitle = Localization.tr("Localizable", "dialog.delete.file_subtitle")
      /// Confirm Deletion
      internal static let title = Localization.tr("Localizable", "dialog.delete.title")
    }
  }

  internal enum MainScreen {
    /// MIND MAP
    internal static let title = Localization.tr("Localizable", "mainScreen.title")
  }

  internal enum Navigation {
    internal enum Map {
      /// MIND MAP
      internal static let name = Localization.tr("Localizable", "navigation.map.name")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
