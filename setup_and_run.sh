#!/bin/bash
set -e

echo "[+] Starting professional automation pipeline"

PROJECT_DIR="project"

echo "[+] Creating project directory"
mkdir -p $PROJECT_DIR

echo "[+] Writing engine.py"
cat << 'EOF' > $PROJECT_DIR/engine.py
import pandas as pd
import numpy as np

def classify_state(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["return"] = df["close"].pct_change()
    df["vol"] = df["return"].rolling(20, min_periods=20).std()
    df["trend"] = df["close"].rolling(20, min_periods=20).mean()

    vol_q = df["vol"].rank(pct=True)
    trend_q = (df["close"] - df["trend"]).rank(pct=True)

    def state(row):
        if pd.isna(row["vol"]) or pd.isna(row["trend"]):
            return 0
        if trend_q[row.name] > 0.5 and vol_q[row.name] < 0.5:
            return 1
        if trend_q[row.name] > 0.5 and vol_q[row.name] >= 0.5:
            return 2
        if trend_q[row.name] <= 0.5 and vol_q[row.name] < 0.5:
            return 3
        return 0

    df["state"] = df.apply(state, axis=1)
    return df

def decide_asset(state_map: dict, assets: list):
    best_asset = "CASH"
    best_score = -1
    for asset in assets:
        score = 1 if state_map.get(asset, 0) in (1, 2) else 0
        if score > best_score:
            best_score = score
            best_asset = asset
    return best_asset
EOF

echo "[+] Writing simulator.py"
cat << 'EOF' > $PROJECT_DIR/simulator.py
def simulate(prices, decisions, fee=0.001):
    capital = 1.0
    position = None
    trades = 0

    for i in range(1, len(decisions)):
        if decisions[i] != position:
            capital *= (1 - fee)
            trades += 1
            position = decisions[i]

        if position != "CASH":
            capital *= prices[i] / prices[i-1]

    return {
        "total_return": capital - 1,
        "trades": trades
    }
EOF

echo "[+] Writing main.py"
cat << 'EOF' > $PROJECT_DIR/main.py
import os
import pandas as pd
from engine import classify_state, decide_asset
from simulator import simulate

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

files = {
    "ASSET_A": os.path.join(BASE_DIR, "asset_a.csv"),
    "ASSET_B": os.path.join(BASE_DIR, "asset_b.csv"),
    "ASSET_C": os.path.join(BASE_DIR, "asset_c.csv"),
}

data = {}
for k, v in files.items():
    df = pd.read_csv(v)
    df = classify_state(df)
    data[k] = df

decisions = []
prices = []

length = min(len(df) for df in data.values())

for i in range(length):
    states = {k: data[k].iloc[i]["state"] for k in data}
    choice = decide_asset(states, list(data.keys()))
    decisions.append(choice)
    if choice != "CASH":
        prices.append(data[choice].iloc[i]["close"])
    else:
        prices.append(prices[-1] if prices else 1)

result = simulate(prices, decisions)
print("RESULT:", result)
EOF

echo "[+] Writing README.md"
cat << 'EOF' > $PROJECT_DIR/README.md
Deterministic multi-asset Python system.

- Past-only state classification
- Four explainable states
- Single asset or cash decision
- Deterministic execution simulation

Designed for robustness, clarity, and explainability.
EOF

echo "[+] Creating sample CSV data"
cat << 'EOF' > $PROJECT_DIR/asset_a.csv
close
100
101
102
101
103
104
EOF

cat << 'EOF' > $PROJECT_DIR/asset_b.csv
close
50
51
49
52
53
54
EOF

cat << 'EOF' > $PROJECT_DIR/asset_c.csv
close
200
198
199
201
202
203
EOF

echo "[+] Running system"
cd $PROJECT_DIR
python3 main.py

echo "[✓] Automation complete"
