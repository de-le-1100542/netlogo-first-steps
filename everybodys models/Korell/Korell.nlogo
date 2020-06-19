; Version   Korallenriff Modell Zwischenstand - 2.Prüfungsleistung              |
; Date      2020-06-18                                                          |
; Authors   Leonard Willen & Marvin Lauenburg                                   |
; Copyright Marvin Lauenburg, Leonard Willen                                    |
; Licence   CC-by-SA 4.0                                                        |
; ------------------------------------------------------------------------------

extensions [gis]

breed [rapid-corals rapid-coral]                                                ;reproduce fast, but are sensible to environment changes

breed [capacity-corals capacity-coral]                                          ;reproduce less, but are more resistant to temperature changes

breed [algae alga]                                                              ;in competition with corals, continues to show up, prefers warm,
                                                                                ; nutrient rich water

globals[
  start-energy
  coral-colors
  max-corals

  num-start-corals
  number-patches

  pH-value                                                                      ;pH-value of water - for calculating stress towards agents
  temperature                                                                   ;water temperature - for calculating stress towards agents
  stress

  structural-complexity                                                         ;A number that describes the complexity of the whole reef, calculated on basis of:
                                                                                ;  difference of coral-properties and depth of corals close to each other

  distance-between-corals                                                       ;Variables Important for grid- or clumped-arrangement
  grid-patches
  clumped-patches
  depth-dataset

]


patches-own [
  depth
  radiation
  patch-complexity
]


turtles-own [
  energy
  birth-energy
  living-energy
  stress-resilience
  lifetime
]


;-------------------------------------------------------------------------------
;------------------------------ SETUP PROCEDURES -------------------------------
;-------------------------------------------------------------------------------

to setup

  clear-all

; ------------------------ Initialization of variables -------------------------
  set max-corals 3                                                              ;maximal number of corals that can exist on one patch
  set start-energy 20                                                           ;Start energy every turtle starts with

  set number-patches world-width * world-height
  set num-start-corals (world-width * world-height * (density / 100))           ;number of corals that gets initially planted
  set distance-between-corals (floor sqrt (number-patches / num-start-corals))  ;distance between planted corals in grid- & clumped-arrangement


  set grid-patches patches with [                                               ;Calculate all the patches for grid-arrangement, where corals get planted
    pxcor mod distance-between-corals = 0
    and pycor mod distance-between-corals = 0
  ]

  set clumped-patches patches with [                                            ;Calculate all the patches for clumped-arrangement, where corals get planted
    (pxcor mod (distance-between-corals * 2)) = 0 and                           ;  initial calculated distance gets dubled
    (pycor mod (distance-between-corals * 2) = 0)
  ]

;--------------------------- Setup of world and agents -------------------------
  patches-setup

  if (planted-species = "r-strategist") [
    rapid-corals-setup
  ]

  if (planted-species = "k-strategist") [
    capacity-corals-setup
  ]

  if (planted-species = "both") [
    set num-start-corals num-start-corals / 2
    rapid-corals-setup
    capacity-corals-setup
  ]

  if algae-competition [algae-setup]

  display-labels

  reset-ticks
end


to patches-setup
                                                                                ;This model can run on three different seabeds, which differ in depth of patches
  if (depth-profile = "Profile 1") [                                            ;! The first profile ... describe first profile
    set depth-dataset gis:load-dataset "DS--1.asc"
  ]

   if (depth-profile = "Profile 2") [                                           ;! The second profile ...
     set depth-dataset gis:load-dataset "DS--2.asc"
  ]

   if (depth-profile = "Profile 3") [                                           ;! The third profile ...
     set depth-dataset gis:load-dataset "DS--3.asc"
  ]

  gis:set-world-envelope (gis:envelope-of depth-dataset)                        ;sets the coordinate system according to the gis-file via its envelope
  gis:apply-raster depth-dataset depth                                          ;gives patches its depth value based on the raster gis-file
  let min-depth gis:minimum-of depth-dataset
  let max-depth gis:maximum-of depth-dataset                                    ;sets minimum / maximum of elevation scala

  ask patches [
    if (depth <= 1) or (depth >= -25)
    [set pcolor scale-color blue depth min-depth max-depth]                     ;colors patches according to their depth
  ]
end


to rapid-corals-setup

  create-rapid-corals num-start-corals [
    if arrangement = "random" [
      set xcor random-xcor set ycor random-ycor
    ]

    if arrangement = "grid" [
      move-to one-of grid-patches with [count turtles-here = 0]                 ;moves every coral to a free patch on the grid patches
    ]

    if arrangement = "clumped" [                                                ;arranges corals around specific patches, that are
      move-to one-of clumped-patches
      left 360
      forward random 3
    ]

    set shape "square"
    set color one-of (list red orange yellow magenta)                           ;colors in which r-strategist shimmer, each color = one sub-species
    set energy start-energy
    set label-color black
    set birth-energy 50
    set living-energy 2
    set stress-resilience 1

  ]
end


to capacity-corals-setup

  create-capacity-corals num-start-corals [
    if arrangement = "random" [
      set xcor random-xcor set ycor random-ycor
    ]

    if arrangement = "grid" [
      move-to one-of grid-patches with [count turtles-here = 0]                 ;see rapid-corals-setup
    ]

    if arrangement = "clumped" [
      move-to one-of clumped-patches
      left 360
      forward random 3
    ]

    set shape "circle"
    set color one-of (list brown turquoise violet pink)                         ;colors in which k-strategist shimmer, each color = one sub-species
    set energy start-energy
    set label-color black
    set birth-energy 100
    set living-energy 1
    set stress-resilience 1.5
  ]

end


to algae-setup

  create-algae 20 [
    set xcor random-xcor set ycor random-ycor
    set color green
    set shape "plant"
    set energy start-energy
    set label-color black
    set lifetime 0
  ]
end


;-------------------------------------------------------------------------------
;-------------------------------- GO PROCEDURES --------------------------------
;-------------------------------------------------------------------------------


to go

  update-patches

  set pH-value  random-float 0.05 + (average-pH - 0.02)
  set temperature random-float 8 + (average-temperature - 4)
  set stress abs (pH-value - 8.1) * 40 + (temperature - 24.3)                   ;!scientific explanation needed

  if algae-competition [ algae-live ]                                           ;updates energy, distribution / hatches of algae

  corals-live

  display-labels

  if coral-cover = 100 [                                                        ;end simulation when everything is covered in corals
    user-message (word "A new reef was created after " ticks " ticks") stop
  ]

  tick
end


to update-patches

  let helper-complexity 0

  ask patches [
    set radiation radiation-energy
    set radiation precision ((-0.125 * abs depth) + radiation) 2                ;!updates radiation depending on depth - new formular
                                                                                ; if radiation energy is on max value (9)
    if radiation < 0 [                                                          ;    max energy gain is 9 (at depths close to 0m) min-value 4.5 (depth close to -20m)
      set radiation 0                                                           ;  when radiation on min (0)
    ]                                                                           ;    all turtles get 0 energy, but can't loose energy

    let surrounding-corals                                                      ;creates an agentset with all corals surrounding the patch
      (turtle-set (rapid-corals in-radius 1) (capacity-corals in-radius 1))     ;  algae don't count towards complexity
    if count surrounding-corals  > 0 [
      set patch-complexity complexity-of-patch? surrounding-corals depth        ;updates the patch complexity
      set helper-complexity helper-complexity + patch-complexity                ;adds the patch-complexity to reef complexity
    ]                                                                           ;complexity is dependend on number of different breeds, different sub-species in breeds (colors)
  ]                                                                             ;  and the change of depth

  set structural-complexity precision (helper-complexity / number-patches) 2    ;relativize complexity to the number of added complexity
end


to algae-live

  if random 100 <= 33 [                                                         ;simulates algae getting continously into reef system from the outside
    create-algae 1 [
      set xcor random-xcor set ycor random-ycor
      set color green
      set shape "plant"
      set energy start-energy
      set label-color black
      set lifetime 0
    ]
  ]

  ask algae [

  set lifetime lifetime + 1
  if random 100 <= lifetime [die]

  set energy (energy                                                            ;determine the energy gain/loss this tick for each algae
    + [radiation] of patch-here * 0.1 * nutrients
    - abs(average-temperature - 26.3)                                           ;!research for optimal water-temp and pH-value
    - abs (average-pH - 8.1) * 40)                                              ;
    - 2                                                                         ;A constant energy is needed for living

  if energy <= 0 [die]

  ask patch-here [set radiation (radiation - 5)]                                ;reduce radiation of patch algae is on, due to shadow of plant

  if energy >= 50 [                                                             ;if alga has enough energy, a new alga is breeded to an adjacent patch
    set energy start-energy
    hatch 1 [
      set lifetime 0
      set energy start-energy
      left random 360
      ifelse (                                                                  ; if patch is full, no alga is breeded
          [count capacity-corals-here  + count algae-here]                      ;   A patch is full when there are three agents of any type or
          of patch-ahead 1 < max-corals + 1                                     ;
        )
        [forward 1]
        [die]
    ]
  ]
]
end


to corals-live

  ask turtles with [(breed = rapid-corals or breed = capacity-corals)] [        ; and count turtles with [(breed = rapid-corals or breed = capacity-corals)] in-radius 2 <= max-corals * 8 + 2

    set energy random 4 + (energy                                               ;A coral gains energy...
      + [radiation] of patch-here                                               ; - from photosynthesis, best:  + 9 energy
                                                                                ;                        worst: + 0 energy
      + (0.05 * zooplankton-abundance - 2)                                      ; - from eating plankton, best: + 3 energy, worst: + 0.5 energy
                                                                                ;A coral looses energy...
      - stress / stress-resilience                                              ; - from the stress it is exposed to, depending on pH and temperature
      - living-energy                                                           ; - its actions needed for living: breathing, movement, digesting, etc.
      - 2)                                                                      ; - this loss is to relativize the gain of random 4 energy in line 251

    if energy <= 0 [die]
                                                                                ;To reproduce, a coral...
    if energy >= birth-energy  [                              ; - needs species specific amount of energy to reproduce ;BAUSTELLE
      set energy start-energy                                                   ; - looses all of its energy, except the energy it started with
      hatch 1 [                                                                 ; - breeds one coral to a random location around itself
        set energy start-energy
        left random 360
        ifelse (                                                                ;   if the space is full, no coral is breeded
            [count rapid-corals-here                                            ;   A space is full when there are three agents of any type or
            + (2 * count capacity-corals-here)]                                 ;     one agent of the k-coral type plus one agent of any type
            of patch-ahead 1 < max-corals
          )
          [forward 1]
          [die]
      ]
    ]
  ]
end


to display-labels
  ifelse display_lables?
    [ask turtles [ set label round energy ]]
    [ask turtles [ set label ""]]
end


;-------------------------------------------------------------------------------
;--------------------------------- REPORTER ------------------------------------
;-------------------------------------------------------------------------------


to-report coral-cover
  report count patches with [any? turtles-here with                             ;determine percentage of patches with corals on them
   [breed = rapid-corals or breed = capacity-corals]] / number-patches * 100
end


to-report complexity-of-patch? [turtle-agentset patch-depth]                    ;Returns number of unique breeds in an agentset
                                                                                ;  parameter:
  let known-breeds []                                                           ;    coral-agentset - Agentset of turtles
  let known-colors []
  let depth-change 0


  ask turtle-agentset [                                                         ;Look at the breed and color of every turtle in turtle-agentset
    if not (member? breed known-breeds) [                                       ;  if breed has not been seen before
      set known-breeds lput breed known-breeds                                  ;  remember its breed
    ]
    if not (member? color known-colors) [                                       ;  if color has not been seen before
      set known-colors lput color known-colors                                  ;  remember the color
    ]

    set depth-change depth-change + (abs patch-depth - [depth] of patch-here)
   ; show (abs patch-depth - [depth] of patch-here)
  ]

  report (length known-breeds
    + (length known-colors) / 2 + depth-change / (count turtle-agentset * 4))   ;Return the number of breeds noted and half of
                                                                                ; number of colors, because breed is more weighty
end
@#$#@#$#@
GRAPHICS-WINDOW
614
14
1041
442
-1
-1
6.45
1
10
1
1
1
0
1
1
1
-32
32
-32
32
1
1
1
ticks
30.0

CHOOSER
154
19
363
64
planted-species
planted-species
"select planted coral species" "r-strategist" "k-strategist" "both"
3

SWITCH
1068
104
1234
137
algae-competition
algae-competition
0
1
-1000

BUTTON
35
114
111
151
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
372
19
586
64
arrangement
arrangement
"select arrangemet of corals" "clumped" "grid" "random"
1

SLIDER
411
267
589
300
nutrients
nutrients
0
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
195
188
387
221
average-temperature
average-temperature
22
28
24.3
0.1
1
°C
HORIZONTAL

BUTTON
31
286
107
319
Go
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
373
75
588
108
density
density
1
7
2.0
0.1
1
%
HORIZONTAL

PLOT
28
386
285
568
Number of Individuals
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"r-corals" 1.0 0 -8630108 true "" "plot count rapid-corals"
"k-corals" 1.0 0 -955883 true "" "plot count capacity-corals"
"algae" 1.0 0 -13210332 true "" "plot count algae"

SLIDER
410
189
588
222
zooplankton-abundance
zooplankton-abundance
50
100
64.0
1
1
NIL
HORIZONTAL

BUTTON
31
245
108
278
go-once
go\n
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
410
229
588
262
radiation-energy
radiation-energy
0
9
4.0
1
1
NIL
HORIZONTAL

SWITCH
1069
17
1207
50
display_lables?
display_lables?
1
1
-1000

MONITOR
305
387
417
432
coral-cover %
coral-cover
2
1
11

MONITOR
305
442
418
487
structural-complexity
structural-complexity
17
1
11

SLIDER
193
228
387
261
average-pH
average-pH
7.8
8.2
8.1
0.05
1
pH
HORIZONTAL

CHOOSER
195
83
301
128
depth-profile
depth-profile
"Profile 1" "Profile 2" "Profile 3"
1

TEXTBOX
14
18
152
49
1. Choose Plantment & density
13
0.0
1

TEXTBOX
14
85
164
103
2. Choose ground profile
13
0.0
1

TEXTBOX
14
187
200
238
3. While running, try changing different parameters
13
0.0
1

@#$#@#$#@
## WHAT IS IT?

Korell models the reproduction and survival of corals after being replanted in their natural habitat while different environmental parameters can change drastically. It demonstrates how a reef that has been destroyed can be recovered, planting regrown corals.

Coral reefs experience bleaching events that endangers survival of reef drastically. To ensure persistance of a reef the preservatory decides to plant new corals.
But: in which shape new corals should be planted, and which type of corals should be selected?


## HOW IT WORKS

The corals are gaining energy, depending on the circumstances they are living in. The more plankton and the stronger radiation of the sun is, the more energy the coral gains. But at the same time a coral constantly loses energy. On the one hand it takes energy to keep living and on the other hand the coral loses energy under stress. Stress is created if the pH-value or temperature of the water changes.
If a coral (is grown)/has enough energy, it reproduces and sends a seed of a new coral to a random patch next to it. If the patch has already three corals on it, the new coral dies.


## HOW TO USE IT

Setup:
Choose a depth profile to have a representative riff surface with elevation values.
Decide wether only r-strategic corals, k-strategic-corals or both are planted (planted-species) and if this is done in grids, in clumps or randomly (arrangement).
Also define the density of planted corals (slider).

--- algae-competition ---

GO:
While running the model, change the stress-level of the corals by changing pH-value and temperature of the water as well as the zooplankton-abundance and the radiation energy.

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

Gis-Extension

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

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
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
