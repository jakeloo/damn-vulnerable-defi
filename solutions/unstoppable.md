faulty code:
```
    // Ensured by the protocol via the `depositTokens` function
    assert(poolBalance == balanceBefore);
```

solution: transfer token into the `pool` contract without using `depositTokens`.

vulnerability: dos
