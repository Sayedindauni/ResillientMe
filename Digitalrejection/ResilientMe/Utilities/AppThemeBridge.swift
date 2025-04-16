import SwiftUI

// MARK: - App Theme Bridge
// This file serves as a bridge between the UI components and the theme types
// It provides documentation about component relationships without creating
// redundant definitions that could cause conflicts.

// Note: The theme components are directly defined in their respective modules
// and should be imported directly from there when needed.

// Forward declarations - removed to avoid duplicate definitions
// These types are now properly imported from their respective modules

// Type aliases for theme components - COMMENTED OUT TO AVOID REDECLARATION ERRORS
// These are now directly defined in DashboardView.swift
// public typealias AppColors = ThemeColors
// public typealias AppTextStyles = ThemeTextStyles
// public typealias AppLayout = ThemeLayout

// Remove the following type aliases that are causing conflicts
// They are now directly defined in DashboardView.swift
// public typealias AppCopingStrategyDetail = ExportCopingStrategyDetail
// public typealias AppCopingStrategyCategory = ExportCopingStrategyCategory
// public typealias AppCopingStrategiesLibrary = ExportCopingStrategiesLibrary

// Import this file to get access to all the theme components and exported modules
// without having to import multiple files or deal with naming conflicts