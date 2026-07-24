# Rain's Firearm Range Balance Proposal

**Status:** Implemented in Rain's role-based balance overlay.

## Goal

Give every firearm family a clear range role now that CJS Firearm Aiming
Overhaul makes shots beyond `MaxSightRange` viable with additional
stabilization time.

The intended progression is:

```text
sawn-off shotgun
  < full-size shotgun
  < handgun
  < submachine gun
  < carbine
  < semi-automatic / assault rifle
  < battle rifle
  < bolt-action rifle
```

This is a gameplay hierarchy, not a real-world effective-range conversion.
Project Zomboid tiles, camera limits, target density, weapon damage, and the
aiming overhaul's stabilization curve all make literal real-world ranges a
poor balance target.

## Recommendation

Use the existing handgun values as the anchor, shorten the shotgun outliers,
extend SMGs slightly beyond handguns, and open clear steps between carbines,
full-length automatic rifles, battle rifles, and bolt-action rifles.

Also rebalance `MaxSightRange`. Almost every current long gun has a sight
range of exactly 10, which makes very different weapons enter the aiming
overhaul's extended stabilization band at the same distance. A stocked,
full-length rifle should have a larger comfortable sight band than a handgun
or compact automatic weapon even before an optic is fitted.

The proposed long-gun sight ladder is now explicit:

```text
carbine (12–14)
  < assault rifle (15–17)
  < battle rifle (17–18)
  < semi-automatic sporting rifle (19–21)
  < bolt-action rifle (24–28)
```

### Proposed class envelopes

| Role | Current sight | Proposed sight | Current max | Proposed max |
|---|---:|---:|---:|---:|
| Sawn-off shotgun | 3–8 | 3–5 | 12–15 | 10–12 |
| Full-size shotgun | 8–9 | 8–9 | 15–20 | 14–17 |
| Handgun | 5–6.5 | unchanged | 16–22 | unchanged |
| Submachine gun | 6–10 | 6–11 | 18–24 | 20–26 |
| Carbine | 10 | 12–14 | 25–30 | 29–33 |
| Semi-automatic / sporting rifle | 10 | 19–21 | 32–35 | 34–38 |
| Assault rifle | 10 | 15–17 | 34–35 | 37–39 |
| Battle rifle | 10 | 17–18 | 38–40 | 40–42 |
| Machine gun | 10 | 10–17 | 28–34 | 32–40 |
| Bolt-action rifle | 10 | 24–28 | 40–50 | 44–52 |

The bands deliberately overlap at their edges. A compact carbine should not
automatically outrange a full-size sporting rifle, and a MAC-10 should remain
closer to a handgun than an MP5.

## Exact Proposed Values

`Current` and `Proposed` are shown as `MaxSightRange / MaxRange`. Drum and
alternate-magazine variants should continue to inherit their parent
weapon's values.

### Shotguns

| Firearm | Current | Proposed | Proposed gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| Remington M870 | 8 / 17 | **8 / 16** | 8 | 3.15x |
| Remington M11-87 | 8 / 17 | **8 / 16** | 8 | 3.15x |
| Sawn-off M11-87 | 8 / 14 | **5 / 12** | 7 | 2.76x |
| Sawn-off M11-87, stockless | 8 / 12 | **3 / 10** | 7 | 2.76x |
| Remington Coach Gun | 9 / 20 | **9 / 17** | 8 | 3.15x |
| Sawn-off Coach Gun | 3 / 15 | **5 / 12** | 7 | 2.76x |
| Sawn-off Coach Gun, stockless | 3 / 12 | **3 / 10** | 7 | 2.76x |
| Sawn-off M870 | 3 / 15 | **5 / 12** | 7 | 2.76x |
| Sawn-off M870, stockless | 3 / 12 | **3 / 10** | 7 | 2.76x |
| AA-12 | 8 / 16 | **8 / 14** | 6 | 2.39x |
| Mossberg M590 Tactical | 8 / 18 | **8 / 17** | 9 | 3.56x |
| Winchester M1887 | 8 / 15 | **8 / 15** | 7 | 2.76x |
| SPAS-12 | 8 / 17 | **8 / 16** | 8 | 3.15x |

Design intent:

- Stockless sawn-offs end at 10 tiles; stocked sawn-offs end at 12.
- The AA-12 has the shortest full-size shotgun reach because automatic fire
  and nine projectiles already give it exceptional output.
- The M590 and Coach Gun reach 17 as the long-range shotgun specialists, but
  no shotgun reaches the common service-pistol maximum of 20.
- Sawn-off sight values are normalized by handling: 5 with a usable stock,
  3 when stockless. Their shorter barrels no longer inherit an implausibly
  generous sight band of 8.

### Pistols

| Firearm | Current | Proposed | Gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| Beretta M92F | 6 / 20 | **6 / 20** | 14 | 4.00x |
| Glock 17 | 6 / 20 | **6 / 20** | 14 | 4.00x |
| P226 | 6 / 19 | **6 / 19** | 13 | 4.00x |
| Walther P5 | 6 / 17 | **6 / 17** | 11 | 4.00x |
| Beretta 93R variants | 6 / 16 | **6 / 16** | 10 | 4.00x |
| Colt M1911 | 6 / 20 | **6 / 20** | 14 | 4.00x |
| HK USP / HKM23 | 6 / 20 | **6 / 20** | 14 | 4.00x |
| Desert Eagle | 6 / 22 | **6 / 22** | 16 | 4.00x |
| Sawn-off Long Ranger | 6 / 20 | **6 / 20** | 14 | 4.00x |

No first-pass pistol changes are recommended. Their 16–22 max-range band is
a good anchor, and their short base aiming times keep an occasional
fully-stabilized long shot practical without giving them a large comfortable
sight band.

### Revolvers

| Firearm | Current | Proposed | Gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| S&W M36 | 5 / 18 | **5 / 18** | 13 | 4.00x |
| S&W M625 | 6 / 20 | **6 / 20** | 14 | 4.00x |
| Colt Anaconda | 6.5 / 22 | **6.5 / 22** | 15.5 | 4.00x |
| S&W M29 | 6.5 / 22 | **6.5 / 22** | 15.5 | 4.00x |

Revolvers also remain unchanged. Their higher damage is already offset by
slower base aiming and limited capacity.

### Submachine Guns

| Firearm | Current | Proposed | Proposed gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| MP5 variants | 10 / 24 | **11 / 26** | 15 | 4.00x |
| MP5SD variants | 10 / 21 | **10 / 24** | 14 | 4.00x |
| Uzi | 6 / 20 | **8 / 23** | 15 | 4.00x |
| MAC-10 | 6 / 18 | **6 / 20** | 14 | 4.00x |
| Thompson variants | 10 / 24 | **11 / 26** | 15 | 4.00x |
| Kriss Vector variants | 10 / 21 | **10 / 24** | 14 | 4.00x |

Design intent:

- The MP5 and Thompson define the stocked SMG ceiling at 26.
- The suppressed MP5 and Vector occupy the 24-tile middle band.
- The Uzi receives a modest 23-tile reach and better sight band, while the
  very compact MAC-10 only reaches the normal service-pistol ceiling.
- SMGs gain range and sight comfort, not rifle-level damage or reach.

### Manual and Semi-Automatic Rifles

| Firearm | Current | Proposed | Proposed gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| Long Ranger Rifle | 10 / 40 | **24 / 44** | 20 | 4.00x |
| Remington M788 | 10 / 45 | **26 / 48** | 22 | 4.00x |
| Remington M24 | 10 / 50 | **28 / 52** | 24 | 4.00x |
| AR-15 | 10 / 35 | **21 / 38** | 17 | 4.00x |
| SKS-56 | 10 / 35 | **20 / 37** | 17 | 4.00x |
| Marlin M1894 | 10 / 32 | **19 / 34** | 15 | 4.00x |

Design intent:

- Bolt-action rifles receive both the longest sight bands and longest
  physical reach.
- The three bolt actions retain a clear progression instead of merely
  sharing the generic long-gun sight value of 10.
- Semi-automatic sporting rifles have 19–21 tiles of comfortable sight
  range, beginning above the M14's 18-tile battle-rifle ceiling.
- Bolt actions begin at 24 sight, leaving a further three-tile break above
  the AR-15. Their manually cycled fire is rewarded with substantially
  better deliberate-shot reach.
- The sporting rifles' physical maximums still bridge carbines and assault
  rifles. Their distinction is precision and sight comfort rather than an
  automatic claim to greater absolute range than every self-loading rifle.

### Battle Rifles, Assault Rifles, and Carbines

| Firearm | Current | Proposed | Proposed gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| M14 variants | 10 / 40 | **18 / 42** | 24 | 4.00x |
| H&K G3 variants | 10 / 38 | **17 / 40** | 23 | 4.00x |
| M16A2 variants | 10 / 35 | **16 / 38** | 22 | 4.00x |
| M16A1 variants | 10 / 34 | **15 / 37** | 22 | 4.00x |
| Galil | 10 / 35 | **16 / 38** | 22 | 4.00x |
| Colt Commando variants | 10 / 30 | **14 / 33** | 19 | 4.00x |
| Honey Badger variants | 10 / 25 | **12 / 29** | 17 | 4.00x |
| Charlie's Angel variants | 10 / 34 | **16 / 38** | 22 | 4.00x |
| HK G36 variants | 10 / 35 | **17 / 39** | 22 | 4.00x |
| HK G36C variants | 10 / 28 | **14 / 32** | 18 | 4.00x |
| AK-47 variants | 10 / 34 | **15 / 37** | 22 | 4.00x |
| RK-62 variants | 10 / 35 | **16 / 38** | 22 | 4.00x |
| RK-95 variants | 10 / 34 | **17 / 39** | 22 | 4.00x |
| AK-105 variants | 10 / 29 | **14 / 32** | 18 | 4.00x |
| AK-105 Folded | 10 / 27 | **12 / 29** | 17 | 4.00x |

Design intent:

- Compact and folded carbines occupy 29–33, safely above SMGs but below
  full-length rifles.
- Full-length assault rifles occupy 37–39.
- Battle rifles occupy 40–42, below the shortest bolt action at 44.
- The existing weapon-to-weapon identities remain: compactness costs reach,
  while the modern full-length G36 and RK-95 sit at the top of their class.

### Machine Guns

| Firearm | Current | Proposed | Proposed gap | Max-range multiplier |
|---|---:|---:|---:|---:|
| M249 | 10 / 32 | **15 / 37** | 22 | 4.00x |
| M60 | 10 / 34 | **17 / 40** | 23 | 4.00x |
| Old Painless Minigun | 10 / 28 | **10 / 32** | 22 | 4.00x |

The M249 follows the assault-rifle band and the M60 follows the battle-rifle
band. Old Painless gains some physical reach but keeps a short sight band:
its extreme volume of fire should not also make it an easy precision weapon.

## Interaction With Firearm Aiming Overhaul

At the current default curve:

```text
multiplier = 1 + 3 * min(1, gap / 10) ^ 1.5
```

where `gap` is the target's distance beyond the live effective sight range.
The useful checkpoints are:

| Tiles beyond sight | Aim-time multiplier |
|---:|---:|
| 4 | 1.76x |
| 5 | 2.06x |
| 6 | 2.39x |
| 7 | 2.76x |
| 8 | 3.15x |
| 9 | 3.56x |
| 10 or more | 4.00x |

Most handguns and all proposed rifles still reach the 4x cap at maximum
range. That is intentional. Raising rifle sight ranges until every
sight-to-max gap is less than 10 would make their penalty-free sight bands
far too generous. For long guns, the important balance differences are:

1. how far the vanilla-speed sight band extends;
2. how much physical reach remains after that band;
3. the weapon's existing base `AimingTime`; and
4. its accuracy, damage, capacity, and fire mode.

The curve cap also means that a 22-tile gap is not slower at maximum range
than a 30-tile gap. If maximum-range multipliers must remain distinct across
those large gaps, the correct control is Firearm Aiming Overhaul's
`FullPenaltyDistanceTiles` sandbox setting, not inflated `MaxSightRange`
values in Rain's. That should be evaluated separately after this range pass.

### Representative maximum-range stabilization work

These values exclude recoverable movement, pain, moodle, weather, light, and
headgear penalties. They multiply the existing base `AimingTime` by the
proposed maximum-range multiplier.

| Weapon | Base aim time | Proposed max multiplier | Base work at max |
|---|---:|---:|---:|
| Beretta M92F | 15 | 4.00x | 60 |
| Desert Eagle | 35 | 4.00x | 140 |
| Sawn-off M870 | 25 | 2.76x | 69 |
| Remington M870 | 45 | 3.15x | 142 |
| AA-12 | 35 | 2.39x | 84 |
| MP5 | 20 | 4.00x | 80 |
| Thompson | 25 | 4.00x | 100 |
| Honey Badger | 27 | 4.00x | 108 |
| M16A2 | 35 | 4.00x | 140 |
| M14 | 45 | 4.00x | 180 |
| Long Ranger Rifle | 35 | 4.00x | 140 |
| Remington M24 | 50 | 4.00x | 200 |

This preserves useful handling identities. SMGs reach farther than pistols
without taking rifle time to stabilize, while precision and battle rifles
pay heavily for full accuracy at their extreme reach.

## Scope Of The First Balance Pass

Change only:

- `MaxSightRange`;
- `MaxRange`; and
- the documentation generated from those values.

Keep the following unchanged until the range pass has been tested:

- base `AimingTime`;
- hit chance and Aiming growth;
- critical chance and critical growth;
- damage;
- recoil and fire modes;
- projectile count;
- attachment modifiers; and
- `AimingPerkRangeModifier`.

Changing several of those systems with range at the same time would make it
difficult to identify whether a weapon is strong because of reach,
stabilization speed, damage, or skill scaling.

## Implementation

The implemented balance pass:

1. Adds `maxSightRange` to every balance profile in
   `zz_RFNGP_WeaponBalance.lua`.
2. Applies both `MaxSightRange` and `MaxRange` through the overlay.
3. Keeps magazine, drum, and alternate-fire-mode variants synchronized with
   their parent profile.
4. Lazily migrates existing Rain firearm instances when they enter player or
   visible-container scope. B42.19 serializes both range values on
   `HandWeapon`, so changing only the script definition is insufficient.
5. Preserves the summed `MaxRange` bonuses from installed weapon parts and
   records a namespaced per-item migration version so later attachment or
   mod changes are not overwritten.

## Validation Plan

Test without optics or range-changing traits at Aiming 0, 5, and 10.

Use one representative from every role:

- stockless sawn-off M870;
- full-size M870;
- Beretta M92F;
- Desert Eagle;
- MAC-10;
- MP5;
- Honey Badger;
- M16A2;
- M14;
- Long Ranger Rifle; and
- Remington M24.

For each representative:

1. Confirm the live sight and maximum ranges match the expected skill-scaled
   values.
2. Confirm stabilization remains vanilla-speed inside effective sight.
3. Confirm one-, five-, and ten-tile beyond-sight shots progressively slow.
4. Confirm a target at physical maximum range can eventually reach the same
   weapon-and-skill accuracy ceiling as an equivalent sight-band target.
5. Confirm targets immediately beyond physical maximum range cannot be hit.
6. Repeat after firing once to verify post-shot recovery uses the same
   distance scaling.

The pass is successful if the practical range order is clearly visible in
game, no lower class broadly outranges the class above it, and the class-edge
exceptions described in this proposal remain useful without erasing weapon
identity.
