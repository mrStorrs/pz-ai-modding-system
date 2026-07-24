# Rain's Firearms Sight and Maximum Ranges

These are the current base values from Rain's Firearms & Gun Parts Expanded
with the local role-based balance overlay applied. Values assume Aiming 0, no
range-changing traits, and no optics or other attachments.

Drum and alternate-magazine versions are grouped because they share the same
range statistics.

## Pistols

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| Beretta M92F | 6 | 20 | 14 |
| Glock 17 | 6 | 20 | 14 |
| P226 | 6 | 19 | 13 |
| Walther P5 | 6 | 17 | 11 |
| Beretta 93R variants | 6 | 16 | 10 |
| Colt M1911 | 6 | 20 | 14 |
| HK USP / HKM23 | 6 | 20 | 14 |
| Desert Eagle | 6 | 22 | 16 |
| Sawn-off Long Ranger | 6 | 20 | 14 |

## Revolvers

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| S&W M36 | 5 | 18 | 13 |
| S&W M625 | 6 | 20 | 14 |
| Colt Anaconda | 6.5 | 22 | 15.5 |
| S&W M29 | 6.5 | 22 | 15.5 |

## Manual and Semi-Automatic Rifles

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| Long Ranger Rifle | 10 | 40 | 30 |
| Remington M788 | 10 | 45 | 35 |
| Remington M24 | 10 | 50 | 40 |
| AR-15 | 10 | 35 | 25 |
| SKS-56 | 10 | 35 | 25 |
| Marlin M1894 | 10 | 32 | 22 |

## Battle Rifles, Assault Rifles, and Carbines

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| M14 variants | 10 | 40 | 30 |
| H&K G3 variants | 10 | 38 | 28 |
| M16A2 variants | 10 | 35 | 25 |
| M16A1 variants | 10 | 34 | 24 |
| Galil | 10 | 35 | 25 |
| Colt Commando variants | 10 | 30 | 20 |
| Honey Badger variants | 10 | 25 | 15 |
| Charlie's Angel variants | 10 | 34 | 24 |
| HK G36 variants | 10 | 35 | 25 |
| HK G36C variants | 10 | 28 | 18 |
| AK-47 variants | 10 | 34 | 24 |
| RK-62 variants | 10 | 35 | 25 |
| RK-95 variants | 10 | 34 | 24 |
| AK-105 variants | 10 | 29 | 19 |
| AK-105 Folded | 10 | 27 | 17 |

## Submachine Guns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| MP5 variants | 10 | 24 | 14 |
| MP5SD variants | 10 | 21 | 11 |
| Uzi | 6 | 20 | 14 |
| MAC-10 | 6 | 18 | 12 |
| Thompson variants | 10 | 24 | 14 |
| Kriss Vector variants | 10 | 21 | 11 |

## Machine Guns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| M249 | 10 | 32 | 22 |
| M60 | 10 | 34 | 24 |
| Old Painless Minigun | 10 | 28 | 18 |

## Shotguns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| Remington M870 | 8 | 17 | 9 |
| Remington M11-87 | 8 | 17 | 9 |
| Sawn-off M11-87 | 8 | 14 | 6 |
| Sawn-off M11-87, stockless | 8 | 12 | 4 |
| Remington Coach Gun | 9 | 20 | 11 |
| Sawn-off Coach Gun | 3 | 15 | 12 |
| Sawn-off Coach Gun, stockless | 3 | 12 | 9 |
| Sawn-off M870 | 3 | 15 | 12 |
| Sawn-off M870, stockless | 3 | 12 | 9 |
| AA-12 | 8 | 16 | 8 |
| Mossberg M590 Tactical | 8 | 18 | 10 |
| Winchester M1887 | 8 | 15 | 7 |
| SPAS-12 | 8 | 17 | 9 |

## How Aiming Skill Changes These Values

The table lists the base script values. At runtime, Project Zomboid adjusts
them before the aiming overhaul reads them:

```text
effective sight = sight * (1 + Aiming / 30)
effective max = max + AimingPerkRangeModifier * (Aiming / 2)
```

Eagle Eyed, Short Sighted, corrective glasses, and active optics can further
change effective sight. The aiming overhaul always uses the resulting live
values.

With the overhaul's default curve, maximum-range slowdown at Aiming 0 depends
on the listed gap:

| Gap | Aim-time multiplier at maximum range |
|---:|---:|
| 4 | 1.76x |
| 6 | 2.39x |
| 7 | 2.76x |
| 8 | 3.15x |
| 9 | 3.56x |
| 10 or more | 4.00x |
