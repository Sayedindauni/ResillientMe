# Module Structure and Import Summary

## Recommendations for ResilientMe

1. Consistently use `import ResilientMe` to access shared types
2. Use fully-qualified names for ambiguous types like `ResilientMe.EngineModels.StrategyCategory`
3. Create typealiases in a single location (CopingTypes.swift) for shared types
4. Avoid circular dependencies by ensuring proper module structure
5. When using CoreData entities, always import ResilientMe
6. Use factory methods like App...Protocol for protocol disambiguation
