
def simulate(prices, decisions, fee=0.001):
    capital = 1.0
    position = None
    trades = 0

    for t in range(1, len(decisions)):
        decision = decisions[t]
        prev_price = prices[t - 1]
        curr_price = prices[t]

        if decision != position:
            trades += 1
            capital *= (1 - fee)
            position = decision

        if position != "CASH":
            capital *= curr_price / prev_price

    return {
        "total_return": capital - 1,
        "trades": trades
    }
