
import pandas as pd
from engine import classify_state, decide_asset
from simulator import simulate

files = {
    "ASSET_A": "asset_a.csv",
    "ASSET_B": "asset_b.csv",
    "ASSET_C": "asset_c.csv",
}

data = {}
for name, path in files.items():
    df = pd.read_csv(path)
    df = classify_state(df)
    data[name] = df

decisions = []
prices = []

length = min(len(df) for df in data.values())

for i in range(length):
    state_map = {a: data[a].iloc[i]["state"] for a in data}
    decision = decide_asset(state_map, list(data.keys()))
    decisions.append(decision)

    if decision != "CASH":
        prices.append(data[decision].iloc[i]["close"])
    else:
        prices.append(prices[-1] if prices else 1)

result = simulate(prices, decisions)
print("\nRESULT:", result)
