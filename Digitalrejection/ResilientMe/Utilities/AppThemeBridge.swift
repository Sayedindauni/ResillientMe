import SwiftUI

// MARK: - App Theme Bridge
// This file serves as a bridge between the UI components and the theme types

// Forward declarations - removed to avoid duplicate definitions
// These types are now properly imported from their respective modules

// Type aliases for theme components
public typealias AppColors = ThemeColors
public typealias AppTextStyles = ThemeTextStyles
public typealias AppLayout = ThemeLayout

// Type aliases for coping strategies library - using the Export* types 
// to avoid conflicts with the other definitions
public typealias AppCopingStrategyDetail = ExportCopingStrategyDetail
public typealias AppCopingStrategyCategory = ExportCopingStrategyCategory
public typealias AppCopingStrategiesLibrary = ExportCopingStrategiesLibrary

// Import this file to get access to all the theme components and exported modules
// without having to import multiple files or deal with naming conflicts