# PoolClass

A compact Luau object pool for pivotable Roblox instances. It keeps pooled
objects off-map and can clone a saved template when the pool is empty.

## Install (Wally)

Add this to `wally.toml`:

```toml
[dependencies]
PoolClass = "nickszone/instancepoolclass@1.0.0"
```

Then run:

```sh
wally install
```

## Use

```lua
local PoolClass = require(Packages.PoolClass)
local pool = PoolClass.new()

-- Pool objects under a tag, then grab them when needed.
pool:pool({ workspace.Enemy }, "Enemy")
local enemy = pool:grab("Enemy")

-- Destroy all cached objects and templates when finished.
pool:clean()
```

Use `_setPoolPosition(CFrame)` to choose where pooled objects are moved, and
`_setDebugMode(true)` to enable warnings for missing pool tags.
