; @author Alexandra Dropmann & Nadja Horacek
; @license
; @date 28.05.2020
; @last-update 07.06.2020
; @copyright
; Seminar: Ökosystemmodellierung @Leuphana University
; Reproduction of Bufo viridis in a post-mining open-cast lignite
; landscape in Lower Saxony in the North of Germany

;; This model shows the influence of precipitation, temperature
;; & natural succession (vegetation growth)
;; on the reproduction of *Bufo viridis* (European green toad).
;; All factors determine the survival of reproduction stages.
;; Successful reproduction is represented by newly appearing adult toads.
;; Extensive grazing by cattle is used as an example of widely used
;; management practice to support the reproduction process.



globals
[
  water-top      ; y-coordinate
  soil-top       ; y-coordinate

  sky-blue       ; sky is colored blue
  water-cyan     ; water is colored cyan
  soil-brown     ; soil is colored brown
  level-change   ; amount water increases or decreases
  water-patches  ; all patches with color water-cyan
  soil-patches   ; all patches with color soil-brown


  year
  month
  day
  dor            ; day-of-reproduction-period, starts 1st of April each year
  days-in-months ; every month has a specific number of days
]


; The breeding procedure integrates male toads as toads, female toads
; as ftoads and vegetation as plants.
breed [toads toad]
breed [ftoads ftoad]
breed [plants plant]


; Male and female toads get their own speed and energy.
; Plants also have their own amount of energy.
turtles-own
[
  speed
  energy
]


;;------------------------
; setup-procedure
;;------------------------

to setup
  clear-all
  setup-calendar
  setup-environment ; Establishes water, soil, sky with clouds.
 ;setup-climate     ; Integrates temperature and precipitation.
  setup-toads       ; Defines everything about European green toad.
  reset-ticks
end


;;-----------------------
; setup-calendar
;;-----------------------

; The calendar shows the reproduction period of Bufo viridis (april -  september).
; The calendar is initially set up to 1st april 2015.
to setup-calendar
  set year 2015
  set day 1
  set month 4
  set dor 1

  set days-in-months (list 31 28 31 30 31 30 31 31 30 31 30 31)
end


;;------------------------
; setup-environment
;;------------------------

; Establishes the water-layer and the soil-layer.
; Establishes the sky and coulds that are placed in the sky.
to setup-environment
    set water-top 15
    set soil-top -15                                        ;;;TO DO: festlegen, dass soil-top nicht niedriger liegen kann als - 15
                                                            ;;;da der Tümpel nicht tiefer werden kann (abgegrenzt nach oben).
  setup-color
  setup-clouds
end


; Defines the colors for globals sky-blue, water-cyan, soil-brown.
; Gives every specific area one of these colors.
to setup-color
  set sky-blue 103
  set water-cyan 85
  set soil-brown 22

  ask patches
  [
     if pycor >  water-top                                  ; sky
      [set pcolor scale-color sky-blue pycor -30 30]
     if pycor <=  water-top                                 ; water
      [set pcolor water-cyan]
     if pycor <=  soil-top                                  ; soil
      [set pcolor soil-brown]
  ]
end

; The clouds are established in the sky. They are merely a design element.
; Thus, the clouds do not interact with the other turtles or patches, respectively.
; The shape "cloud" needed to be created in Turtle shape editor.
to setup-clouds
  create-turtles 5
  [
    set shape "cloud"
    set size 4
    set color 9.9                                           ; clouds are colored in white
    let x random-xcor                                       ; clouds are spread randomly in the sky
    let y max-pycor - 2                                     ; cloud-height is set
    setxy x y                                               ; clouds are located in the upper part of the world
  ]
end


;;-----------------------
; setup-climate
;;-----------------------

; Creates temperature and precipitation.                   ;;; ggf. wird das noch eingebracht
; The temperature range is between 8°C and 21°C.
; Precipitation ranges between 8mm and 122mm.
; Use the calender to simulate weather from
; April to October each year.
;to setup-climate
;  setup-temperature
;  setup-precipitation
;end

;to setup-temperature
;end

;to setup-precipitation
;end


;;------------------------
; setup-toads
;;------------------------

; Creates toads with shape "toad" and converts some of them
; to female toads with shape "ftoad".
to setup-toads
  create-toads 10
  [
    let y  soil-top + random (abs(water-top - soil-top))  ; places toads in cyan
    print y                                               ; determines the y-coordinate of toads
    setxy random-xcor y
    set shape "toad"
    set size 2
    set speed 1.5
    set energy 1830                                       ; 1830 energy equal a life-span of 10 years
  ]

    ask n-of (0.36 * 10) toads                            ; 36 % of toads are changed to female toads
    [
      set shape "ftoad"
      set size 4
      set speed 2
      set color grey
      create-link-to one-of toads
    ]
end


;;----------------------
; go-procedure
;;----------------------

; Defines under which circumstances the simulation stops.
; Lets plants grow and die. Lets toads move, hatch and die.
; Includes additional sudden events in the environment that
; lead to a loss of toad specimens.
; Updates the water-level.
; Includes extensive grazing as a measure of habitat managment.
to go
  if (not any? toads) [stop]                             ; simulation stops
  if count toads = 200 [stop]                            ; simulation stops as soon as 200 toads exist   ;;;TO DO: unten user messages einfügen

  advance-calendar                                       ; calendar advances as time goes by

  ask toads
  [
    move-toads                                           ; toads move in the water
    set energy energy - 1
    reproduce                                            ; toads hatch toads
  ]
  ask plants
  [
    set energy energy - 1
  ]
  grow-plants                                            ; new plants grow as the time goes by
  death                                                  ; toads, female-toads and plants die
  update-water-body                                      ; connects the water-level with prec/temp
  wait 0.1
  tick

  extensive-grazing
end


;;-----------------------
; calendar-procedure
;;-----------------------

; At day 183 each reproduction period comes to an end.
; Thus, a new reroduction period is started.
; The year is advanced by one. Every year starts on 1st April.
; The water-top and soil-top are set to the initial settings
; as precipitation during winter is expected to refill the
; water bodies.
to advance-calendar
  set dor dor + 1
  set day day + 1

  let my-dor sum sublist days-in-months 3 month
  if dor > my-dor
  [
    set month month + 1
    set day 1
  ]

  if dor > 183
  [
    set month 4
    set day 1
    set dor 1
    set year year + 1
    set water-top 15
    set soil-top -15
  ]
end


;;-----------------------
; movement-of-toads
;;-----------------------

; Toads move within the water that is colored cyan and turn around when they reach an end of the water body.
to move-toads
  let all-toads turtles with [breed = ftoads or breed = toads]
    ask all-toads
    [
      if [pcolor] of patch-ahead 1 != water-cyan [set heading heading - 100]
      forward random speed
      lt random 10
    ]
end


;;-----------------------
; lifecycle-of-toads
;;-----------------------

; The female toad "hears" the call of the male toad which creates a link between one female
; and one male toad (ftoads & toads). Female toads move toward male toad.
; For 3-5 ticks male and female toads have same coordinates and stop moving.
;to female-movement
  ; let female-toads turtles with [breed = ftoads]
  ; ask female-toads
   ;[
    ; if any? toads  with [breed = toads]
    ; in-cone 5 160
    ; [
    ;  let target one-of link-neighbors
    ;  face target
     ; forward speed * 2
     ; ]
    ; ]

 ; reproduce
; end

; After courtship of toads new toads are produced.
; It is assumed that if the water-top is higher than the soil-top and the plant
; count is less than 10 in mid July (RANGE: dor 106 to 168), new toads are created.
; If the water-layer (abs (water-top - soil-top)) > 5: 3-5 new toads hatch.
; If the water-layer (abs (water-top - soil-top)) < 5: 1-3 new toads hatch.
; 50 % male toads and 50 % female toads should be created.
to reproduce                                ;;; Hier wird nichts gehatched. Warum?
  let female-toads turtles with [breed = ftoads]
  ask female-toads ;with [any? link-neighbors]
 ; [
     ; set heading (towards min-one-of link-neighbors [distance self])
 ; ]
  [
   if (dor = 10  and (abs(water-top - (soil-top))) >= 5 and count plants < 100)
   [
     hatch 2
     [ set shape one-of ["ftoad" "toad"]
      ;set size [one-of [2 4]
       fd 1
     ]
    ]
  ]
      ; ifelse (shape = "ftoad")  ;;; and specific date out of list with (5 days)  in July )
  ;[
   ; if (abs(water-top - (soil-top))) >= 20
    ;[
     ; hatch-toads 2
      ;[
       ; set shape one-of ["ftoad" "toad"]
        ;fd 1
      ;]
    ;]
  ;]
  ;[
   ; if (abs(water-top - (soil-top))) < 20
    ;[
     ; hatch-toads 1
      ;[
       ; set shape one-of ["ftoad" "toad"]
        ;fd 1
      ;]
    ;]
  ;]
end


;;-----------------------
;growth-of-vegetation
;;-----------------------

; Creates plants and algae (here on after refered to as plants) that only grow in the pond.
; In this project, at the beginning there are 0 plants as the pond is newly created.
; After 10 ticks a new plant is created
to grow-plants
  if (ticks mod 10 = 0)
  [
    create-plants 3
    [
      setxy random-xcor min-pycor + random (abs(soil-top + 3 - min-pycor))
      set shape "plant"
      set color green
      set size 3
      set energy 915                                    ; 915 energy equals a life-span of 5 years
    ]
  ]
end


;;-----------------------
; death-procedure
;;-----------------------

; Toads and plants die at the end of their life-span.
; 20% of toads might die due to predators or other hazards each year.
; These are random environmental events.
to death
  let all-turtles turtles with [breed = toads or breed = ftoads or breed = plants]
  ask all-turtles
  [
    if energy < 0 [die]
  ]

  if dor = random 183
  [
   ask n-of (0.2 * count toads) toads [ die ]
  ]
end


;;-----------------------
; level-change-of-water-body
;;-----------------------

; Connecting the temperature/ precipitation sliders to the water-level.
; It is assumed that Evapotransipartion is proportional to the temperature.
; Therefore it is valid that the difference of P-ET=P-g*T.
; The values of the precipitation/ temperature sliders are in %.
; This gives the direction of the water-level wether it is increasing or
; decreasing.
to update-water-body                                                              ;;;noch unsicher, wie wir diesen Teil des Codes final gestalten
  set level-change 0.1
  set water-patches patches with [shade-of? pcolor water-cyan]
  set soil-patches patches with [shade-of? pcolor soil-brown]

  ifelse (precipitation  > temperature)
  [
    if soil-top < water-top - level-change [set soil-top soil-top - level-change]
  ]
  [
    if soil-top > min-pycor + level-change [set soil-top soil-top + level-change]
  ]

  set water-patches patches with [pycor > soil-top and pycor <= water-top]
  set soil-patches patches with [pycor <= soil-top]
  ask water-patches [set pcolor water-cyan]
  ask soil-patches [set pcolor soil-brown]
end


;;-----------------------
; extensive grazing as a method of habitat management
;;-----------------------

; Gives the opportunity to include extensive grazing as a measure of habitat management.
; Cited Literature recommends a value of 0,5 GVE/ ha. (GVE = life stock units, 1 GVE = 500 kg).
; Assuming that the pond-area is 7 ha, an total of 3,5 GVE would count as extensive grazing.
; One adult cattle weights 1000kg. Thus, a callte is represented by the value of 2 GVE.
; Two cattle are represented by 4 GVE in this model.
to extensive-grazing
    if extensive-grazing?
    [
      if (ticks mod 5 = 0)
      [
       let prey one-of plants
       ask prey [die]
      ]
    ]
end

;;; Alternative: possibility 2 = SLIDER (0, 2, 4 GVE)
@#$#@#$#@
GRAPHICS-WINDOW
489
10
1290
682
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
-30
30
-25
25
0
0
1
ticks
30.0

BUTTON
15
15
83
48
NIL
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

BUTTON
92
16
155
49
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
169
16
254
49
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
22
88
194
121
temperature
temperature
0
100
70.0
10
1
NIL
HORIZONTAL

SLIDER
22
132
194
165
precipitation
precipitation
0
100
38.0
1
1
NIL
HORIZONTAL

MONITOR
12
227
133
272
green-toads
count toads
17
1
11

MONITOR
419
14
476
59
NIL
year
17
1
11

MONITOR
352
13
409
58
NIL
month
17
1
11

MONITOR
284
13
341
58
NIL
day
17
1
11

MONITOR
354
67
411
112
NIL
dor
17
1
11

PLOT
6
312
364
491
species-count
time
number-of-individuals
0.0
100.0
0.0
50.0
true
true
"" ""
PENS
"toads" 1.0 0 -10899396 true "" "plot count toads"
"plants" 1.0 0 -4699768 true "" "plot count plants"

MONITOR
162
227
219
272
plants
count plants
17
1
11

SWITCH
23
188
198
221
extensive-grazing?
extensive-grazing?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model shows an aquatic ecosystem for the green toad (*Bufo viridis*). The model deals with the reproduction of the species. Therefore the reproduction period (April-September) is used as the model's time frame. The reproductive success of the European green toad is strongly dependent on the **water conditions** of its spawning waters. These should have shallow banks if possible. A water depth of approx. 85 cm  favours a drying out of these in late summer. This keeps the fine pressure from **predatory insect larvae** and **fish** low. In addition, the water bodies and their banks must not be silt up by excessive **vegetation growth**. To call and spawn, the European green toad is dependent on shore areas with little or no vegetation. **Extensive grazing** by large mammals or regular manual removal of riparian vegetation can contribute to the reproductive success of the species. 

![*Bufo viridis* ] ()
In Lower Saxony this amphibian species is threatened with extinction. Here, only small and unstable populations exist in raw material mining areas or their recultivation areas. In this federal state, they are thus protected from the emergence of new spawning waters 

This model generalises the influence of **precipitation** and **temperature** on the water flow of potential spawning waters (average precipitation, average temperature).  


## HOW IT WORKS



## HOW TO USE IT

Using the setup button, the model creates a number of individuals that is within the values of a small population (< 50 individuals). The go button starts or stops the process. The influences on the reproductive success of the *Bufo viridis* integrated in the model can be regulated by the users through the sliders. Furthermore, it is possible to switch extensive grazing on or off as a habitat management measure. 

## THINGS TO NOTICE

The females of *Bufo viridis* are larger and have a different color than the males of the adults. 

## THINGS TO TRY

Try out the extensive grazing switch.

## EXTENDING THE MODEL

The model could be extended by adding a vegetation slider which lets the user regulate the growth of plants. It would also be possible to develop different growth rates for different plant species.

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)
--> frog model? 

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)

--> ; Inspiration for regrowth of plants Steinling & Schwalbe 
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

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

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

ftoad
true
0
Polygon -7500403 true true 146 18 135 30 119 42 105 90 90 150 105 195 135 225 165 225 195 195 210 150 195 90 180 41 165 30 155 18
Polygon -7500403 true true 91 176 67 148 70 121 66 119 61 133 59 111 53 111 52 131 47 115 42 120 46 146 55 187 80 237 106 269 116 268 114 214 131 222
Polygon -7500403 true true 185 62 234 84 223 51 226 48 234 61 235 38 240 38 243 60 252 46 255 49 244 95 188 92
Polygon -7500403 true true 115 62 66 84 77 51 74 48 66 61 65 38 60 38 57 60 48 46 45 49 56 95 112 92
Polygon -7500403 true true 200 186 233 148 230 121 234 119 239 133 241 111 247 111 248 131 253 115 258 120 254 146 245 187 220 237 194 269 184 268 186 214 169 222
Circle -16777216 true false 157 38 18
Circle -16777216 true false 125 38 18
Circle -13840069 true false 105 90 30
Circle -13840069 true false 150 135 30
Circle -13840069 true false 165 75 28
Circle -13840069 true false 195 195 28
Circle -13840069 true false 103 163 32
Circle -13840069 true false 58 163 32

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

toad
true
0
Polygon -6459832 true false 146 18 135 30 119 42 105 90 90 150 105 195 135 225 165 225 195 195 210 150 195 90 180 41 165 30 155 18
Polygon -6459832 true false 91 176 67 148 70 121 66 119 61 133 59 111 53 111 52 131 47 115 42 120 46 146 55 187 80 237 106 269 116 268 114 214 131 222
Polygon -6459832 true false 185 62 234 84 223 51 226 48 234 61 235 38 240 38 243 60 252 46 255 49 244 95 188 92
Polygon -6459832 true false 115 62 66 84 77 51 74 48 66 61 65 38 60 38 57 60 48 46 45 49 56 95 112 92
Polygon -6459832 true false 200 186 233 148 230 121 234 119 239 133 241 111 247 111 248 131 253 115 258 120 254 146 245 187 220 237 194 269 184 268 186 214 169 222
Circle -16777216 true false 157 38 18
Circle -16777216 true false 125 38 18
Circle -10899396 true false 105 90 30
Circle -10899396 true false 150 135 30
Circle -10899396 true false 165 75 28
Circle -10899396 true false 195 195 28
Circle -10899396 true false 103 163 32
Circle -10899396 true false 58 163 32

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
