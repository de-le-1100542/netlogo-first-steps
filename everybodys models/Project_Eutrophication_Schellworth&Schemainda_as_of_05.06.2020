;Authors: Christin Schellworth and Anna Schemainda
;Date: 06.05.2020 -
;copyright instructions needed

; This is a simple model portraying the process and effects of euthrophication in the Baltic Sea. ... (short description or sufficient in info tab?)
;...


;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------

globals [
  surface-patches                    ;patch-subset for upper part
  bottom-patches                     ;patch-subset for lower part
  year                               ;calendar globals
  month
  day
  doy
  days-in-months
  ]

breed [producers producer]           ;producers can be addressed individually
breed [consumers consumer]           ;consumers can be addressed individually
breed [decomposers decomposer]       ;decomposers can be addressed individually

turtles-own [ energy ]               ;producers, consumers and decomposers have energy
patches-own [                        ;patches have a concentration (both nutrients and oxygen are described this way)
  concentration-nutrients
  concentration-oxygen
  ]

;-----------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------

to setup                             ;setup-procedures "setup-patches", "setup-turtles" and "setup-calendar" are described in next paragraphs
  clear-all
  setup-patches
  setup-turtles
  setup-calendar
  reset-ticks
end

;------------------------------------------------------------------------------------------------------------------------------------------------

to setup-patches                                                                            ;this paragraph is about the setup of patches
  ask patches [ set concentration-nutrients concentration-of-nutrients ]                    ;concentration can be adjusted via slider
  ask patches [ set concentration-oxygen concentration-of-oxygen ]                          ;concentration can be adjusted via slider
  set surface-patches patches with [pycor >= 0 ]                                            ;upper layer defined
  ask surface-patches [set pcolor 86                                                        ;upper layer light blue
    ;set concentration-oxygen ( concentration-of-oxygen * 0.8 )                             ;YES/NO?
  ]
  set bottom-patches patches with [pycor < 0]                                               ;lower layer defined
  ask bottom-patches [set pcolor 95
    ;set concentration-oxygen ( concentration-of-oxygen * 0.2 )                             ;YES/NO?
  ]                                                                                         ;lower layer dark blue
end

;-----------------------------------------------------------------------------------------------------------------------------------------------

to setup-turtles                                   ;this paragraph is about the setup of turtles

  create-producers 400                             ;SOMETHING LIKE: ONE PRODUCER REPRESENTS 1000 IN REAL LIFE?
  ask producers [                                  ;producers represent phytoplankton and similar algae
    set color green
    set shape "plant"
    set size 0.6
    set energy random 5
    move-to one-of surface-patches                 ;producers are set in upper layer only since there is the light they need to do photosynthesis
  ]

  create-consumers 15
  ask consumers [                                  ;consumers represent all consumers along food chain, f.e. zooplankton, fish
    set color white + 3
    set shape "fish"
    set size 1.5
    set energy random 7
    move-to one-of surface-patches                 ;consumers are set in upper layer only due to feasibility of model
  ]

  create-decomposers 300                           ;MAYBE ONE DECOMPOSER STANDS FOR 1000 IN REAL LIFE?
  ask decomposers [
    set color brown
    set shape "circle"
    set size 0.3
    move-to one-of bottom-patches                  ;decomposers are set in lower layer only since they live in the bottom of the ocean
  ]
end

;------------------------------------------------------------------------------------------------------------------------------------------------

to setup-calendar                                                   ;this paragraph is about the setup of the calendar
  set year 2020                                                     ;model starts january 1st of a random year, to make it easier the current year
  set month 1
  set day 1
  set doy 1
  set days-in-months (list 31 28 31 30 31 30 31 31 30 31 30 31)     ;let calendar know how may days each month has
end

;------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------

to go                                                                               ;all procedures will be defined individually in the next paragraphs in their order of appearance here
  ask producers [go-producers]                                                      ;describes all actions related to producers
  ask consumers [go-consumers]                                                      ;describes all actions related to consumers
  ask decomposers [go-decomposers]                                                  ;describes all actions related to decomposers
  ;ask patches with  [ concentration-nutrients > 5 ] [ set pcolor white]            ;DELETE ALTER ON, JUST TO OBSERVE
  ;ask patches with [ concentration-nutrients <= 5 ] [ set pcolor black]            ;DELETE LATER ON, JUST TO OBSERVE
  ask patches with [concentration-oxygen <= 0 ] [set pcolor black]                  ;show patches without oxygen as there is no more life possible for consumers/producers
  nutrient-inflow                                                                   ;there is an ongoing inflow of nutrients from rivers
  balance-concentrations                                                            ;diffusion of nutrients and oxygen into patches with lower concentration
  advance-calendar                                                                  ;advances calendar each tick
  if ticks = 1000 [ stop ]                                                          ;NEEDED? stop the model if there are no producers -> DELETE LATER if the system works
  ;if not any? consumers [ user-message "Humans have destroyed the ocean" stop ]    ;if no consumers left, the model stops and a user message appears
  tick
end

;-------------------------------------------------------------------------------------------------------------------------------------------------

to go-producers                                          ;this paragraph is about producer procedures
  ;let alive-producers producers with [ color = green ]
  ;right random 360
  ;forward 0.5
  ;ask alive-producers [
  uphill concentration-nutrients                         ;producers move towards the highest nutrient concentration in their direct surrounding (8 patches)
  if ycor <= 0 [ move-to one-of surface-patches ]        ;producers stay in the upper layer as there is the light they need for photosynthesis
  set energy energy - 0.1                                ;producers lose energy as they move
  eat-nutrients                                          ;producers eat nutrients on their patch
  decay                                                  ;producers die if they run out of nutrients or energy
  reproduce-producers                                    ;producers reproduce at a certain amount of energy
end


to eat-nutrients
  if concentration-nutrients > 0 [                                                  ;if nutrients are availabe, producers can eat them
    set energy energy + 0.8                                                         ;by eating nutrients, producers gain energy
    set concentration-nutrients concentration-nutrients - 2                         ;concentration of nutrients in the water (the patch the producer is on) declines as producers take up nutrients
    set concentration-oxygen concentration-oxygen + 2                               ;as producers do photosynthesis, they release oxygen into the water (on the patch they are on)
    ]
end


to decay                                                                            ;producers die if...
  if (energy <= 0) or (concentration-oxygen <= 0) [                                 ;...no energy left or no oxygen left
    move-to one-of bottom-patches                                                   ;dying here means they turn black and fall to the lower part where they will fully disappear after decomposition by decomposers
    set color black                                                                 ;PROBLEM: THEY SHOULDNT DO EVERATHING THE ALIVE/ GREEN ONES DO:
    ;let dead-producers producers with [ color = black ]                            ;NO UPHILL NUTRIENTS, STAY IN BOTTOM LAYER, DONT REPRODUCE, DONT MOVE
    ;ask dead-producers [
      if ycor >= -1  [ move-to one-of bottom-patches]
      ;]
    ]
end


to reproduce-producers
  if energy > 5 [                                            ;producer reproduces at an energy level of higher than 5
    set energy (energy / 2)                                  ;divide energy between parent and offspring
    hatch 4 [rt random-float 360 fd 0.5 ]                    ;hatch an offspring and let it floar in the water
    ]
end

;-----------------------------------------------------------------------------------------------------------------------------------------------------

to go-consumers                                         ;this paragraph is about consumer procedures
  right random 360
  forward 2
  if ycor <= 0 [ move-to one-of surface-patches ]       ;as in setup, consumers need to stay in the upper layer due to feasibility of model
  set energy energy - 0.2                               ;producers lose energy as they move
  set concentration-oxygen (concentration-oxygen - 0.5) ;while breathing, consumers need oxygen so the concentration in the water (on the patch they are on) declines
  eat-producers                                         ;consumers eat a producer on their patch
  death                                                 ;consumers die if they run out of energy or oxygen
  reproduce-consumers                                   ;consumers reproduce at a certain amount of energy
end


to eat-producers
  let prey one-of producers-here                ;define producers as prey for consumers
  if prey != nobody [                           ;if consumers get a producer on its patch...
    ask prey [ die ]                            ;they kill it ...
    set energy energy + 1                       ;and get energy from eating
    ]
end


to death                                                 ;consumers die if ...
  if (energy <= 0) or (concentration-oxygen <= 2) [      ;...no energy left or no oxygen left
    move-to one-of bottom-patches                        ;here dying means they turn black and fall down to the lower part where they will disappear after decomposition by decomposers
    set color black
    if ycor >= 0 [move-to one-of bottom-patches ]
    ]
                                                         ;SAME PROBLEM AS ABOVE WHEN PRODUCERS DIE: DEAD CONSUMERS SHOULD BEHAVE DIFFERENTLY THAN ALIVE ONES
end


to reproduce-consumers
  if energy > 5 [                                       ;consumer reproduces at an energy level of higher than 5
    set energy (energy / 2)                             ;divide energy between parent and offspring
    hatch 2 [ rt random-float 360 fd 2 ]                ;hatch an offspring and move it forward
    ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------------------

to go-decomposers                                 ;this paragraph is about decomposers procedures
  right random 360
  forward 0.1
  if ycor >= -1 [right 180 fd 0.4]               ;decomposers stay in lower layer as they live on the ground of the ocean
  decompose-producers                            ;in this process, the producers are decomposed
  decompose-consumers                            ;in this process, the consumers are decomposed
end


to decompose-producers
  let prey one-of producers-here                                   ;define "dead"/ black producers as prey for decomposers
  if prey != nobody [                                              ;if decomposers get a "dead"/ black producer ...
    ask prey [ die ]                                               ;"dead"/ black producers get decomposed and disappear
    set concentration-oxygen ( concentration-oxygen - 2)           ;decomposers need oxygen, so the concentration of oxygen (on the patch the decomposers are on) declines
    set concentration-nutrients (concentration-nutrients + 0.3 )   ;decomposers convert dead organic matter and anorganic nutrients are released into the water (on the patch the decomposers are on)
    ]
end

to decompose-consumers
  let prey one-of consumers-here                                   ;define "dead"/ black consumers as prey for decomposers
  if prey != nobody [                                              ;if decomposers get a "dead"/ black consumer ...
    ask prey [ die ]                                               ;"dead"/ black producers get decomposed and disappear
    set concentration-oxygen (concentration-oxygen - 3.5)          ;decomposers need oxygen, so the concentration of oxygen (on the patch the decomposers are on) declines
    set concentration-nutrients (concentration-nutrients + 2.4)    ;decomposers convert dead organic matter and anorganic nutrients are released into the water (on the patch the decomposers are on)
    ]
end

;------------------------------------------------------------------------------------------------------------------------------------------------------------

to nutrient-inflow
    ask surface-patches [
      set concentration-nutrients concentration-nutrients  + ( concentration-of-nutrients  * 0.1 )      ;every tick there's an inflow of 10% of nutrients of the set amount, this represents the constant inflow from rivers
      ]
end

;--------------------------------------------------------------------------------------------------------------------------------------------------------------

to balance-concentrations
  diffuse concentration-nutrients 0.8              ;half the concentration of nutrients on one patch diffuses to the surrounding 8 patches
  diffuse concentration-oxygen 0.8                 ;halt the concentration of oxygen on one patch diffuses to the surrounding 8 patches
end

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------

to  advance-calendar
  set day day + 1                                              ;each tick, advance calendar by 1 day
  set doy doy + 1                                              ;each tick, adavance doy by 1

  let my-doy sum sublist days-in-months 0 month

  if doy > my-doy [                                            ;implement month change
    set month month + 1
    set day 1
    ]

  if doy > 365 [                                               ;implement year change
    set year year + 1
    set day 1
    set doy 1
    set month 1
    ]
end



;things to implement soon:
;connect nutrient cycle with seasons/calendar
;implement salt water intrusion as a random event where oxygen floats into the Baltic Sea (model-version yes or no)






@#$#@#$#@
GRAPHICS-WINDOW
612
20
1049
458
-1
-1
13.0
1
10
1
1
1
0
1
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
18
23
81
56
NIL
setup\n
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
91
24
154
57
NIL
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

PLOT
1082
72
1328
222
populations
Ticks
Anzahl
0.0
30.0
0.0
30.0
true
true
"" ""
PENS
"consumers" 1.0 0 -16777216 true "" "plot count consumers"
"producers" 1.0 0 -7500403 true "" "plot count producers"

MONITOR
441
169
515
214
Consumers
count consumers
17
1
11

MONITOR
522
169
591
214
Producers
count producers
17
1
11

MONITOR
298
25
446
70
c. nutrients high surface
count surface-patches with [ concentration-nutrients > 5 ]
17
1
11

SLIDER
18
159
207
192
concentration-of-nutrients
concentration-of-nutrients
0
10
8.0
1
1
NIL
HORIZONTAL

MONITOR
299
79
442
124
c. nutrients low surface
count surface-patches with [ concentration-nutrients <= 5]
17
1
11

PLOT
1082
227
1327
377
nutrients und oxygen surface patches
Ticks
concentration
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"nutrients_high" 1.0 0 -16777216 true "" "plot count surface-patches with [ concentration-nutrients > 5 ]"
"oxygen_high" 1.0 0 -11221820 true "" "plot count surface-patches with [ concentration-oxygen > 5 ]"

SLIDER
17
202
205
235
concentration-of-oxygen
concentration-of-oxygen
0
10
6.0
1
1
NIL
HORIZONTAL

MONITOR
455
25
595
70
c. oxygen high surface
count surface-patches with [concentration-oxygen > 5]
17
1
11

MONITOR
455
79
590
124
c. oxygen low surface
count surface-patches with [ concentration-oxygen <= 5]
17
1
11

BUTTON
162
26
277
59
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

MONITOR
502
257
598
302
ox. high botom
count bottom-patches with [concentration-oxygen > 5]
17
1
11

MONITOR
503
316
599
361
ox. bottom low
count bottom-patches with [ concentration-oxygen <= 0]
17
1
11

MONITOR
1205
22
1262
67
NIL
year
17
1
11

MONITOR
1143
22
1200
67
NIL
month
17
1
11

MONITOR
1081
22
1138
67
NIL
day
17
1
11

MONITOR
1267
22
1324
67
NIL
doy
17
1
11

MONITOR
365
256
485
301
nutrients high bottom
count bottom-patches with [ concentration-nutrients > 5 ]
17
1
11

MONITOR
363
313
490
358
nutrients low bottom
count bottom-patches with [ concentration-nutrients <= 5 ]
17
1
11

CHOOSER
19
104
206
149
model-version
model-version
"salt-water-intrusion" "no-salt-water-intrusion"
0

PLOT
1082
378
1327
528
nutrients and oxygen bottom patches
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
"nutrients_high" 1.0 0 -16777216 true "" "plot count bottom-patches with [ concentration-nutrients > 5 ]"
"oxygen_high" 1.0 0 -7500403 true "" "plot count bottom-patches with [ concentration-oxygen > 5 ]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

This model explores the impacts of eutrophication on the Baltic Sea. Due to a man-made increased input of nutrients via rivers natural balances of the ecosystem are not necessarily in place anymore. Decreased nutrient inputs or increased oxygen inputs as a successful management strategy leads to a stable system with an equilibrium between organisms and the concentration of nutrients and oxygen. A failured one leads to an instable system in which entire populations die.


## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

1. Adjust the slider parameters (see below), or use default settings (I THINK WE NEED DEFAULT SETTINGS FOR A STABLE ECOSYSTEM).
2. Set the model-version chooser to "Salzkeilintrosion" to include this random event in the model, or to "no Salzkeilintrosion" to run the model without it. (I KNOW WE DONT HAVE IT YET)
3. Press the SETUP button
4. Press the GO or GO-ONCE button to begin the simulation.
5. Look ath the monitors to see the current population sizes and concentrations.
6. Look ath the POPULATIONS and CONCENTRATIONS plots to watch its fluctuation over time.


PARAMETERS:

**Model-version:** Whether the model includes the phenomenon of Salzkeilintrusion(english) or not
**Concentration-of-nutrients:** The amount of nutrients brought into the Baltic Sea externally via rivers, both initially when setting up the model and a fraction of this amount constantly throughout running the model. 
**Concentration-of-oxygen:** The amount of oxygen available in the Baltic Sea at the beginning of running the model. 



## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

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
