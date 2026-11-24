# Smell → Transformation Reference

Use during Step 4 of [`refactoring`](SKILL.md) to pick one micro-step for the smell in front of you.

| Smell | Transformation |
| :--- | :--- |
| Long method or god class | Extract Function, Extract Class, Replace Temp with Query |
| Same logic scattered across files (shotgun surgery) | Move Function, Move Field — give it one owner |
| Method reaches into other objects more than its own (feature envy) | Move Function or Extract Function next to the data |
| Deep `if`/`switch` chain | Decompose Conditional or Replace Conditional with Polymorphism |
| `a.getB().getC().run()` (message chain) | Hide Delegate |
| Repeated parameter group (data clumps) | Introduce Parameter Object |
| Three copies of the same logic | Extract shared helper, delete duplicates |
| Type admitting an invalid state combination | Model as a sum type; make illegal states unrepresentable |
| Layers that hide no decision | Inline the pass-through layers |
| Single-implementation, single-caller abstraction | Inline it |
| Unreferenced code | Delete it |
