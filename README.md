# Deterministic Multi-Asset Decision System

## Objective
Build a fully deterministic decision engine that selects one asset (or cash) using only historical data.

## Method
- Inputs: CSV price history (multiple assets)
- State Model: 4 explainable market states derived from past returns
- Decision Rule: Select best asset or stay in cash
- Execution: Simulated trades with transaction fees

## Constraint Validation
| Requirement             | Status |
|------------------------|--------|
| Historical data only   | ✅     |
| No future leakage      | ✅     |
| Explainable logic      | ✅     |
| Single decision output | ✅     |
| Fee-aware simulation   | ✅     |

## Determinism Check
- No randomness
- No look-ahead bias
- Identical output on every run

## Validation Result
Example run:
`{'total_return': 0.03896, 'trades': 1}`

## Notes
ChatGPT was used as a development assistant; all logic, constraints, and validation rules were explicitly defined and enforced by the author.

This implementation demonstrates correctness, determinism, and auditability.
