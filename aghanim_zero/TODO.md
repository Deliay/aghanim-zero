# Aghanim's Zero — 待办 (TODO)

## 2026-11-20 排查/修复记录

- [x] Shadowraze 无法施法/无法造成伤害：`GetCastRange` `shadowraze_range=0`、`doAction distance=0`、`doShadowraze radius=0 enemies=0`
  - [x] 根因：改版后引擎只认 `AbilityValues`（新格式），旧 `AbilitySpecial` 数字 key 失效 → 已写转换脚本 `research/converter/index-aghzero.js` 并执行完成（16 个 kv 文件已转）
- [x] `GameRules:BeginTemporaryNight` 报错 → 新签名 `(duration: float, arg2: int)` → 已改为 `GameRules:BeginTemporaryNight(duration, 0)`（item_moon_butterfly.lua）
- [x] Commit & push：`b38bc9e` on main

## 待办

- [ ] boss_dark_willow.lua:210 — `self.hShadowRealm` nil：`CBossDarkWillow:OnBossDarkWillowThink` phase==SHADOW_REALM 时访问未挂载能力
  - 待定：是能力查找失败 / AI 挂载时机问题
- [ ] boss_primal_beast.lua:645 — `self.hRapidVaultAbility` nil：`CBossPrimalBeast:LeapToMiddle`（胜利序列 `OnThinkVictorySequence:542`）
  - 待定：`encounter_primal_beast.lua:543` 还引用 `self.hBeast.AI.hRapidVaultAbility`（GetSpellCastTime），需一并处理
- [ ] 重启游戏/重载资源后验证：shadowraze 新 KV 转换生效、BeginTemporaryNight 修复生效、boss AI nil 问题
