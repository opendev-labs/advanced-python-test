
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
        s = state_map.get(asset, 0)
        score = 1 if s in (1, 2) else 0
        if score > best_score:
            best_score = score
            best_asset = asset

    return best_asset
