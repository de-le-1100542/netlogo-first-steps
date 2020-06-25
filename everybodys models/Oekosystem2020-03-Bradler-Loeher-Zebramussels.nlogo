; Population dynamics of the invasive zebra mussel (Dreissena polymorpha) under consideration of multiple predator-prey relationships

; Course: Interdisciplinary Sustainability Studies - Ecosystem Modelling
; Lecturers: Eckhard Bollow and Carsten Lemmen
; Summer Term 2020

; @authors Pia Bradler and Finja Loeher
; @license CC BY-NC-SA 4.0
; @copyright Pia Bradler and Finja Loeher
; NetLogo Version 6.1.1

; This model deals with the population dynamics of the zebra mussel (Dreissena polymorpha) in interaction with crayfish
; and yellowperch. Several external variables have an influence on the predatorprey-network and can have an effect on
; population sizes. Since the zebra mussel is highly invasive, a range of control mechanisms aiming to retain its spread
; in the artificial lake are incorporated into the model as well.


; ********************************************************

; TABLE OF CONTENTS
; 1. Globals, Breeds, Attributes
; 2. Setup, Go
; 3. Setup Patches
; 4. Setup Turtles
; 5. Turtle Procedures
; 6. Control Mechanisms
; 7. Calendar
; 8. Water Temperature

; ********************************************************



; ********************************************************
; 1. GLOBALS, BREEDS, ATTRIBUTES
; ********************************************************

globals
[ year
  month
  day
  day-of-year
  days-in-months
  water-temperature
]

breed [ zebramussels zebramussel ]
breed [ crayfish a-crayfish ]
breed [ yellowperch a-yellowperch ]

turtles-own                                                                              ; all turtles have the attributes speed, turn, energy and birth energy
[ speed                                                                                  ; speed at which turtles move
  turn                                                                                   ; angle at which turles turn when moving
  energy                                                                                 ; energy level
  birth-energy                                                                           ; energy required to give birth
  zequanox-level                                                                         ; in case zequanox is applied (control mechanism)
]

; ********************************************************
; 2. SETUP, GO
; ********************************************************

to set-up                                                                                ; set-up procedures
  clear-all
  reset-ticks
  setup-patches
  setup-turtles
  setup-calendar
  ask turtles [ set energy 100 + random-float 100 ]                                      ; all turtles have an initial energy in between 100 and <200
end

to go                                                                                    ; go procedures
  if year = 2030 [ stop ]                                                                ; simulation runs until 2030
  if not any? turtles [ stop ]                                                           ; simulation runs until all turtles have died
  update-temperature
  advance-calendar
  move-turtles
  feed
  reproduce
  death
  limit-pop-growth
  set-control-mechanisms
  tick
end

; ********************************************************
; 3. SETUP PATCHES
; ********************************************************

to setup-patches
  ask patches [ set pcolor 35 ]                                                          ; patches get a light brown color
  ask n-of ( cover-hard-substrate ) patches [ set pcolor 33 ]                            ; simulates hard substrate by darkening a number of patches as defined by cover-hard-substrate-slider
  ask patches with [ pcolor = 33 ]
  [ ask patches in-radius 6 [ set pcolor 33 ]
  ]
end

; ********************************************************
; 4. SETUP TURTLES
; ********************************************************

to setup-turtles
  setup-zebramussels
  setup-crayfish
  setup-yellowperch
end

to setup-zebramussels
  create-zebramussels nr-zebramussels
  ask zebramussels
  [ move-to one-of patches with [ pcolor = 33 ]                                          ; zebra mussels appear on hard substrate, this shows initial substrate preference, number as defined by slider
    set shape "zebramussel"                                                              ; set shape, shape was created using the Turtles Shape Editor
    set size 3
    set color 29 - random 2                                                              ; different colors to account for natural variability
    set speed 0                                                                          ; sets speed zero, adult zebra mussels do not move
    set turn 0                                                                           ; again, zebra mussels do not move
    set birth-energy 500
  ]
end

to setup-crayfish
  create-crayfish nr-crayfish                                                            ; creates crayfish depending on number as defined by the slider
  ask crayfish
  [ set shape "crayfish"                                                                 ; set shape, shape was created using the Turtles Shape Editor
    set size 5
    set color 15
    set speed random-float 4                                                             ; crayfish move at different speed
    set turn random 360                                                                  ; crayfish randomly turn when moving
    setxy random-xcor random-ycor                                                        ; crayfish appear at random spots in the lake
    set birth-energy 500
  ]
end

to setup-yellowperch
  create-yellowperch nr-yellowperch                                                      ; creates yellow perch depending on number as defined by the slider
  ask yellowperch
  [ set shape "fish"                                                                     ; set shape, existing shape modified to represent top view
    set size 7
    set color 45
    set speed 5 + ( random-float 2 )                                                     ; yellow perch move at different speeds, they are the fastest turtles in this model
    set turn random 360                                                                  ; yellow perch randomly turn when moving
    setxy random-xcor random-ycor                                                        ; yellow perch appear at random spots in the lake
    set birth-energy 500
  ]
end

; ********************************************************
; 5. TURTLE PROCEDURES
; ********************************************************

to move-turtles                                                                          ; turtles are moved according to their defined speed and turn attributes
  ask turtles
  [ forward speed
    ifelse random 4 = 1 [ left turn ] [ left 0 ]
    set energy energy - 1                                                                ; turtles lose one energy with each tick
  ]
end

to feed                                                                                  ; turtle-specific feeding procedures
  ask zebramussels
  [ filter-water
    faeces-deposition
  ]
  ask crayfish
  [ eat-zebramussels
  ]
  ask yellowperch
  [ eat-crayfish
  ]
end

to filter-water                                                                          ; zebra mussel procedure
  set energy energy + ( filtration-rate / 2 ) + ( cover-hard-substrate / 2 )             ; zebra mussels gain energy according to their filtration rate and hard substrate cover (as defined by sliders)
end

to faeces-deposition                                                                     ; zebra mussel procedure
  if random 4 = 1
  [ set pcolor black                                                                     ; faeces are deposited once zebra mussels digest - patches turn black (same as in death procedure)
    set energy energy - 50                                                               ; zebra mussels lose energy when depositing faeces
  ]
end

to eat-zebramussels                                                                      ; crayfish procedure
  if random-float 50 < water-temperature                                                 ; higher probability of preying on zebra mussels as the temperature rises
  [ let prey one-of zebramussels-here                                                    ; crayfish prey on zebra mussels
    if prey != nobody
    [ ask prey [ die ]
      set energy energy + 350 + water-temperature + filtration-rate                      ; crayfish gain energy as they feed, higher energy gain with higher water temperature and higher water purity
    ]
  ]
  if pcolor = black [ set energy energy - 10 ]                                           ; crayfish are negatively affected by zebra mussel faeces and shells
end

to eat-crayfish                                                                          ; yellow perch procedure
  if random-float 100 > 50                                                               ; yellow perch prey on crayfish in 50% of opportunities
  [ let prey one-of crayfish-here
    if prey != nobody
    [ ask prey [ die ]
      set energy energy + 500 + filtration-rate                                          ; yellow perch gain energy as they feed on crayfish and water purity increases
    ]
  ]
end

to reproduce
  ask turtles
  [ if energy > birth-energy                                                             ; turtles reproduce when their energy level exceeds the birth energy
    [ set energy energy - ( birth-energy - 100 )                                         ; turtles lose energy when they reproduce
      hatch 1                                                                            ; one offspring per reproduction
      [ set energy 100 + random-float 100                                                ; offsprings have energy in between 100 and <200 and move away from their parent
        fd random 5 rt random-float 360
        set zequanox-level 0                                                             ; only important for zebra mussels in case of zequanox-application
      ]
    ]
  ]
end

to death
  ask turtles
  [ if energy <= 0 [ die ]                                                               ; turtles die when they have no energy left
  ]
  ask zebramussels
  [ if energy <= 0 [ set pcolor black ]                                                  ; zebra mussels deposit shells as they die, altering substrate composition
  ]
end

to limit-pop-growth                                                                      ; density-related dying of individual turtles to balance population sizes
  ask zebramussels [ set energy energy - ( count zebramussels / 100 ) ]
  ask yellowperch [ set energy energy - ( count yellowperch / 50 ) ]
  ask crayfish [ set energy energy - ( count crayfish / 50 ) ]
end

; ********************************************************
; 6. CONTROL MECHANISMS                                                                  ; chooser in interface
; ********************************************************

to set-control-mechanisms
  if control-mechanism = "fishing"                                                       ; fishing of yellow perch
  [ ask turtles
    [ let prey one-of yellowperch-here
      if prey != nobody
      [ if random-float 100 > 95                                                         ; fishing activities take place with a 5% chance of success
        [ ask prey [ die ]                                                               ; yellow perch die when being fished
        ]
      ]
    ]
  ]
  if control-mechanism = "additional-crayfish-introduction"
  [ if day-of-year = 100                                                                 ; in late spring, 200 crayfish are released
    [ ask n-of 200 patches [ sprout-crayfish 1 ]                                         ; randomly distributed independently from population size
      ask crayfish                                                                       ; the crayfish have the same characteristics as the other crayfish
      [ set shape "crayfish"
        set size 5
        set color 15
        set speed random-float 4
        set turn random 360
        set birth-energy 500
        set energy 100 + random-float 100
      ]
    ]
  ]
  if control-mechanism = "zequanox-application"
  [ ask zebramussels [ set zequanox-level zequanox-level + random-float 70 ]             ; zebra mussels ingest up to <70 units of zequanox each day
    ask zebramussels with [ zequanox-level >= 1000 ]                                     ; with 1000 units of bio-accumulated zequanox ...
    [ if random 10 = 1
      [ if one-of crayfish-here != nobody
        [ ask one-of crayfish-here [ die ]                                               ; ... the poison accumulates slowly along the food chain ...
        ]
      ]
      if random 20 = 1
      [ if one-of yellowperch-here != nobody
        [ ask one-of yellowperch-here [ die ]
        ]
      ]
      die                                                                                ; ... and the zebra mussel dies
    ]
  ]
  if control-mechanism = "mechanic-removal"                                              ; mechanical removal of zebramussels attached to any surface
  [ if day-of-year = 100
   [ ask n-of ( count zebramussels * 0.9 ) zebramussels [ die ]                          ; 90% of zebramussels are detected and are removed from the system by dying
   ]
  ]
end

; ********************************************************
; 7. CALENDAR
; ********************************************************

to setup-calendar                                                                        ; the calendar starts in Jan 1st 2020
  set year 2020
  set month 1
  set day 1
  set day-of-year 1
  set days-in-months ( list 31 28 31 30 31 30 31 31 30 31 30 31 )
end


to-report leap-year                                                                      ; leap years are included in the calendar
  if ( year mod 4 != 0 ) [ report 0 ]
  if ( year mod 400 = 0 ) [ report 1 ]
  if ( year mod 100 = 0 ) [ report 0 ]
  report 1
end

to advance-calendar                                                                      ; one day passes with each tick
  set day day + 1
  set day-of-year day-of-year + 1
  let my-doy sum sublist days-in-months 0 month
  if my-doy > 31
  [ set my-doy my-doy + leap-year
  ]
  if day-of-year > my-doy
  [ set month month + 1
    set day 1
  ]
  if day-of-year > 365 + leap-year
  [ set month 1
    set day 1
    set year year + 1
    set day-of-year 1
  ]
end

; ********************************************************
; 8. WATER TEMPERATURE
; ********************************************************

to update-temperature                                                                    ; mean water temperature including seasonal variation
  let daily-temperature-sigma 1.0
  let seasonal-temperature-range 10.0
  let base-temperature mean-water-temperature + sin ( ( day-of-year - 129 + 19 )         ; the base mean annual water temperature can be adjusted with a slider
    * 360.0 / ( 365 + leap-year ) ) * seasonal-temperature-range / 2.0
  set water-temperature random-normal base-temperature daily-temperature-sigma
end



; ********************************************************
; THE END
; ********************************************************
@#$#@#$#@
GRAPHICS-WINDOW
267
30
675
439
-1
-1
4.0
1
10
1
1
1
0
0
0
1
0
99
0
99
0
0
1
ticks
30.0

BUTTON
47
33
126
66
NIL
set-up
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
47
77
129
110
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
51
473
225
506
filtration-rate
filtration-rate
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
47
184
219
217
nr-zebramussels
nr-zebramussels
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
48
237
220
270
nr-crayfish
nr-crayfish
0
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
52
428
225
461
cover-hard-substrate
cover-hard-substrate
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
48
287
220
320
nr-yellowperch
nr-yellowperch
0
50
25.0
1
1
NIL
HORIZONTAL

MONITOR
268
527
360
572
zebramussels
count zebramussels
17
1
11

MONITOR
267
589
359
634
crayfish
count crayfish
17
1
11

MONITOR
268
655
362
700
yellowperch
count yellowperch
17
1
11

PLOT
391
483
963
702
Population Sizes
time
population size
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Zebramussels" 1.0 0 -16777216 true "" "plot count zebramussels"
"Crayfish" 1.0 0 -7500403 true "" "plot count crayfish"
"Yellowperch" 1.0 0 -2674135 true "" "plot count yellowperch"

MONITOR
801
338
873
383
NIL
year
17
1
11

MONITOR
888
337
961
382
NIL
month
17
1
11

MONITOR
800
396
874
441
NIL
day
17
1
11

MONITOR
888
397
963
442
NIL
day-of-year
17
1
11

MONITOR
830
42
966
87
NIL
water-temperature
2
1
11

PLOT
724
116
967
311
Water Temperature
day of year
temperature (°C)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy day-of-year water-temperature"

TEXTBOX
49
135
225
167
Initial population sizes of the different species:
13
0.0
1

TEXTBOX
51
585
201
635
Possible attempts to control the zebra mussel population:
13
0.0
1

TEXTBOX
52
365
227
413
Abiotic parameters in the lake and filtration rate of the zebra mussels:
13
0.0
1

BUTTON
136
77
218
110
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
51
514
227
547
mean-water-temperature
mean-water-temperature
10
30
20.0
1
1
NIL
HORIZONTAL

CHOOSER
47
652
234
697
control-mechanism
control-mechanism
"no-control" "fishing" "mechanic-removal" "zequanox-application" "additional-crayfish-introduction"
0

TEXTBOX
270
488
420
506
Population sizes:
13
0.0
1

TEXTBOX
729
52
828
90
Water Temperature:
13
0.0
1

TEXTBOX
731
359
794
377
Calendar:
13
0.0
1

@#$#@#$#@
# Population dynamics of the invasive zebra mussel (_Dreissena polymorpha_) under consideration of multiple predator-prey relationships

## WHAT IS IT?

The zebra mussel (_Dreissena polymorpha_) is native to lakes and rivers in the Caspian and Black Sea regions, but has invaded aquatic freshwater ecosystem around the world, causing environmental and economic harm in some places. Prominent examples are the establishment in the Great Lakes in the USA and in the Shannon river in Ireland (Minchin et al. 2002).

In this model, we set the focus on the predator-prey relationships between zebra mussels, yellow perch (_Perca flavescens_) and crayfish (e.g. _Orconectes propinquus_) and aim at detecting patterns within these relationships under different initial settings. Moreover, several control mechanisms are investigated, to limit the spread of the zebra mussel in the fictional lake.




## HOW IT WORKS


The set-up procedure spreads zebra mussels randomly across the hard substrate of the lake. Yellow perch and crayfish are distributed ranomly within the lake.

The main processes described in the model are:

1. Reproduction procedures
2. Predator-prey relationships between the zebra mussel, the crayfish and the yellow perch. 
2.1 Yellow perch feed on zebra mussels
2.2 Crayfish feed on yellow perch   
2.3 Yellow perches feed on crayfish
  3. Growth of hard substrate via the deposition of old shells and zebra mussels attaching to different substrate types while spreading.

Further processes included and running in the background but not visually displayed in the 'world view' incluse water filtration by the mussels. Seasonal changes in mean water temperature can be followed in a water temperature monitor and plot.

## HOW TO USE IT

1. Chose initial stage by adjusting parameters in the interface
2. press the set-up button to start the model
3. Press the go button to follow changes tick-by-tick or press the go forever button.

Parameters that can be modified:
- nr-zebramussels
- nr-crayfish
- nr-yellow-perch
- cover-hard-substrate
- filtration-rate
- mean-water-temperature

Moreover, a choser can be used to select different control mechanisms:
- no-control
- fishing
- mechanic-removal
- zequanox-application
- additional-crayfish-introduction

Follow changes of population growth, temperatures and the advance of the calendar in the monitors and have a look at the graphs in the plot as time progresses as shown in the calendar.


## THINGS TO NOTICE

The zebra mussel is a very successful invader due to its unique reproductive biology and its rapid spread. The veliger stage, for example, is able to move around, thereby facilitating spread via currents to distant places in real ecosystems (Ackermann et al. 1994). This veliger stage is not displayed in the model, although represented through rapid reproduction and increase in adult numbers. Thus the number of turtles can get very high in this model.

## THINGS TO TRY

Use the chooser to try different control mechanisms that have differing impacts on the zebra mussel population or try different combinations of slider settings.

## EXTENDING THE MODEL

The model could be adapted to a real-world example of a lake using maps and importing shapefiles. Furthermore, changes in nutrient concentrations and resulting consequences for water quality and presence of perch and crayfish could be simulated.
Further, less drastic changes could include changing slider ranges or parameters such as number of additionally introduced crayfish in the control mechanisms. 


## RELATED MODELS

An example for other models displaying predator-prey relationships are the wolf-sheep predation models. 

## REFERENCES

Minchin, D., Lucy, F., & Sullivan, M. (2002). Zebra mussel: impacts and spread. In Invasive aquatic species of Europe. Distribution, impacts and management (pp. 135-146). Springer, Dordrecht.

Ackerman, J. D., Sim, B., Nichols, S. J., & Claudi, R. (1994). A review of the early life history of zebra mussels (Dreissena polymorpha): comparisons with marine bivalves. Canadian Journal of Zoology, 72(7), 1169-1179.

## COPYRIGHT AND LICENSE
This work is licensed under a Creative Commons Attribution 4.0 International License.
License: CC BY-NC-SA 4.0

Copyright: Finja Löher and Pia Bradler 2020
This models has been developed in the course "Ökosystemmodellierung" at Leuphana University.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crayfish
true
0
Rectangle -2674135 true false 180 120 240 120
Circle -16777216 true false 120 135 0
Rectangle -2674135 true false 75 120 225 225
Polygon -2674135 true false 105 120 75 75 105 90 135 75
Polygon -2674135 true false 195 120 225 75 195 90 165 75
Circle -16777216 true false 120 150 0
Circle -16777216 true false 105 135 30
Circle -16777216 true false 165 135 30
Circle -2674135 true false 129 204 42
Circle -2674135 true false 135 225 30
Circle -2674135 true false 135 240 30

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
true
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 165 210 149 250 125 233 106 225 76 219 90 180
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30
Circle -16777216 true false 210 150 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

zebramussel
true
0
Circle -7500403 true true 86 86 127
Rectangle -16777216 true false 90 120 210 135
Rectangle -16777216 true false 90 150 210 165
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Standardeinstellungen" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fishing" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;fishing&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mechanic-removal" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;mechanic-removal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="zequanox" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;zequanox-application&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="crayfish" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;additional-crayfish-introduction&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="substrate-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="substrate-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="filtration-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="filtration-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="watertemp-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="watertemp-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="zebramussels-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="zebramussels-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="75"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="crayfish-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="crayfish-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="yellowperch-low" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="yellowperch-high" repetitions="10" runMetricsEveryStep="true">
    <setup>set-up</setup>
    <go>go</go>
    <metric>count zebramussels</metric>
    <metric>count crayfish</metric>
    <metric>count yellowperch</metric>
    <enumeratedValueSet variable="filtration-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-crayfish">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="control-mechanism">
      <value value="&quot;no-control&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-water-temperature">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-yellowperch">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cover-hard-substrate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nr-zebramussels">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
