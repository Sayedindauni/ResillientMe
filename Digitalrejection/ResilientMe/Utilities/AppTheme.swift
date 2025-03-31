import SwiftUI

// MARK: - App Theme Exports
// This file centralizes all theme-related types in one place for easy importing

// Import the actual theme types directly
#if canImport(ResilientMe)
// In app target, these are available via ResilientMe module
import ResilientMe
#else
// When this file is compiled directly in the module itself,
// we need to make sure the types are accessible from Theme.swift
@_exported import Foundation
#endif

// We don't define the typealiases here anymore - they're in ThemeTypeAliases.swift

// This function is a no-op that forces the compiler to load the Theme.swift file
// which contains the original definitions of ThemeColors, ThemeTextStyles, and ThemeLayout
@inline(never) 
public func _ensureThemeIsLoaded() {
    // This function does nothing but ensures the compiler includes Theme.swift
    // Use fully qualified names to avoid ambiguity
    let _ = ResilientMe.ThemeColors.primary
    let _ = ResilientMe.ThemeTextStyles.h1
    let _ = ResilientMe.ThemeLayout.cornerRadius
} 