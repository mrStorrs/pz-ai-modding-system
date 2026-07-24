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
| Long Ranger Rifle | 24 | 44 | 20 |
| Remington M788 | 26 | 48 | 22 |
| Remington M24 | 28 | 52 | 24 |
| AR-15 | 21 | 38 | 17 |
| SKS-56 | 20 | 37 | 17 |
| Marlin M1894 | 19 | 34 | 15 |

## Battle Rifles, Assault Rifles, and Carbines

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| M14 variants | 18 | 42 | 24 |
| H&K G3 variants | 17 | 40 | 23 |
| M16A2 variants | 16 | 38 | 22 |
| M16A1 variants | 15 | 37 | 22 |
| Galil | 16 | 38 | 22 |
| Colt Commando variants | 14 | 33 | 19 |
| Honey Badger variants | 12 | 29 | 17 |
| Charlie's Angel variants | 16 | 38 | 22 |
| HK G36 variants | 17 | 39 | 22 |
| HK G36C variants | 14 | 32 | 18 |
| AK-47 variants | 15 | 37 | 22 |
| RK-62 variants | 16 | 38 | 22 |
| RK-95 variants | 17 | 39 | 22 |
| AK-105 variants | 14 | 32 | 18 |
| AK-105 Folded | 12 | 29 | 17 |

## Submachine Guns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| MP5 variants | 11 | 26 | 15 |
| MP5SD variants | 10 | 24 | 14 |
| Uzi | 8 | 23 | 15 |
| MAC-10 | 6 | 20 | 14 |
| Thompson variants | 11 | 26 | 15 |
| Kriss Vector variants | 10 | 24 | 14 |

## Machine Guns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| M249 | 15 | 37 | 22 |
| M60 | 17 | 40 | 23 |
| Old Painless Minigun | 10 | 32 | 22 |

## Shotguns

| Firearm | Sight | Max | Gap |
|---|---:|---:|---:|
| Remington M870 | 8 | 16 | 8 |
| Remington M11-87 | 8 | 16 | 8 |
| Sawn-off M11-87 | 5 | 12 | 7 |
| Sawn-off M11-87, stockless | 3 | 10 | 7 |
| Remington Coach Gun | 9 | 17 | 8 |
| Sawn-off Coach Gun | 5 | 12 | 7 |
| Sawn-off Coach Gun, stockless | 3 | 10 | 7 |
| Sawn-off M870 | 5 | 12 | 7 |
| Sawn-off M870, stockless | 3 | 10 | 7 |
| AA-12 | 8 | 14 | 6 |
| Mossberg M590 Tactical | 8 | 17 | 9 |
| Winchester M1887 | 8 | 15 | 7 |
| SPAS-12 | 8 | 16 | 8 |

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
