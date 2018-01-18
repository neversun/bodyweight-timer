![](https://raw.githubusercontent.com/neversun/bodyweight-timer/master/harbour-bodyweight-timer.png) Bodyweight timer for Sailfish OS
=============================

Loving bodyweight training? Then give this utility a try and allow your ordinary clock a pause.

This app comes with different timers for different kinds of training methods (inspired by "Bodyweight  Training" by Marc Lauren).

Currently supported training methods:
* Circle interval
* Interval set
* Ladder
* Super set
* Tabata

## Planned features
* Enable/Disable Sounds
* Configuration of sound volume
* Configuration of bell types for different actions
* Naming of exercises
* Translations
* Additional training methods
* Saveable presets for each training method
* After playing a sound notification, resume with e.g. media player 


# Adding translations

For adding the language german (de) do the following:

1. copy the file `translations/harbour-bodyweight-timer.ts` to `translations/harbour-bodyweight-timer-de.ts`.
1. For every added translation remove `type="unfinished"` from that item.
1. Extend `TRANSLATIONS` section in `harbour-bodyweight-timer.pro`. See example

## Extend TRANSLATIONS example
```
TRANSLATIONS += translations/harbour-bodyweight-timer-en.ts \
                translations/harbour-bodyweight-timer-de.ts
```

### Troubleshooting

String are not displayed translated: Check with `lupdate harbour-bodyweight-timer.pro` for **any** (!) errors or warning and fix those.