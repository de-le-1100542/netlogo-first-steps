; @authors: Mareike Thomas <mareike.thomas@stud.leuphana.de> and Jannika Baars <jannika.m.baars@stud.leuphana.de>
; @date: 2020-06-25
; @license: CC-by-SA 4.0
; @copyright: Mareike Thomas and Jannika Baars
; this model explores dynamics of heathlands


globals
[ year                                                                                                           ; count the number of years...
  month                                                                                                          ; ... and months passing by in the course of our simulation
]
                                                                                                                 ; there are three breeds of turtles:
breed [ beetles beetle ]                                                                                         ; the heather beetle (Lochmaea suturalis)
breed [ Molinia a-Molinia ]                                                                                      ; the purple moor-grass (Molinia cearulea)
breed [ Calluna a-Calluna ]                                                                                      ; the common heather (Calluna vulgaris)

turtles-own                                                                                                      ; all three breeds have energy and possess a certain age
[ energy
  age
]

; -------------------------------------------------------------------------------

to startup                                                                                                       ; when the project is opened, the setup procedures are implemented
  setup
end

to setup
  clear-all                                                                                                      ; all the parameters are reset to the standards settings
  setup-calendar                                                                                                 ; the calendar is set up
  ask patches [ set pcolor 36 ]                                                                                   ; the background patches are brown
  setup-turtles                                                                                                  ; the turtles are set up
  setup-treatment                                                                                                ; the nutrient treatment is set up
  reset-ticks                                                                                                    ; all the ticks are reset to 0
end

to setup-calendar
  set year 1                                                                                                     ; the simulation starts at year 1 and month 1
  set month 1
end

to setup-turtles                                                                                                 ; by pressing the setup-button, the different breeds are created
  create-beetles beetles-initial-number                                                                          ; the beetles are created and are described with specific characteristics
  [ set size 0.5
    set shape "bug"
    set color 32
    set age 0
    set energy 70
    setxy random-xcor random-ycor                                                                                ; the beetles are dispersed randomly in the ecosystem
  ]

  create-Molinia Molinia-initial-number                                                                          ; Molinia is created and is described with specific characteristics
  [ set size 3.5
    set shape "flower budding"
    set color 46
    set age 0
    set energy 70
    setxy random-xcor random-ycor                                                                                ; Molinia is dispersed randomly in the ecosystem
  ]

  create-Calluna Calluna-initial-number                                                                          ; Calluna is created and is described with specific characteristics
  [ set size 2
    set shape "plant"
    set color 126
    set age 0
    setup-life-phase                                                                                             ; the life phases of Calluna are set up
    setxy random-xcor random-ycor                                                                                ; Calluna is dispersed randomly in the ecosystem
  ]
end

to setup-treatment                                                                                               ; setup the specific productivity factors of the two plant species and of the beetles, ...
 if nutrient-treatment = "no-treatment"        [ ask Calluna [ set energy energy * 1   ]                         ; ... depending on the type of treatment
                                                 ask Molinia [ set energy energy * 1   ]
                                                 ask beetles [ set energy energy * 1   ]
                                               ]
  if nutrient-treatment = "N-fertilisation"    [ ask Calluna [ set energy energy * 2   ]
                                                 ask Molinia [ set energy energy * 4.7 ]
                                                 ask beetles [ set energy energy * 2   ]
                                               ]
  if nutrient-treatment = "P-fertilisation"    [ ask Calluna [ set energy energy * 1.1 ]
                                                 ask Molinia [ set energy energy * 0.8 ]
                                                 ask beetles [ set energy energy * 1   ]
                                               ]
  if nutrient-treatment = "N+P-fertilisation"  [ ask Calluna [ set energy energy * 2   ]
                                                 ask Molinia [ set energy energy * 4   ]
                                                 ask beetles [ set energy energy * 2   ]
                                               ]
end

to setup-life-phase                                                                                              ; setup the specific energy for each life phase of Calluna
  if Calluna-life-phase = "pioneer-phase"       [ set energy 14.9 ]
  if Calluna-life-phase = "development-phase"   [ set energy 78.4 ]
  if Calluna-life-phase = "mature-phase"        [ set energy 100  ]
  if Calluna-life-phase = "degeneration-phase"  [ set energy 54.2 ]
end

; -------------------------------------------------------------------------------

to go
  if not any? Calluna [ user-message "There are no Calluna individuals left." stop ]                             ; stop the model if there are no Calluna individuals left and inform the user
  if count turtles > 15000 [ user-message "The maximum number of individuals has been reached." stop ]           ; stop the model if there are more than 15000 turtles and inform the user

  advance-calendar                                                                                               ; when the simulation runs, the calendar shall be advanced, so that months and years pass by

  ask beetles
  [ move
    set energy energy - 1                                                                                        ; the beetles lose energy while moving
    if month = 1 [ set age age + 1 ]                                                                             ; with the beginning of a new year, the beetles become one year older
    eat-Calluna                                                                                                  ; the beetles eat the Calluna plants
    reproduce-beetles                                                                                            ; they reproduce
    beetles-death                                                                                                ; they die
  ]

  ask Molinia
  [ if month = 1 [ set age age + 1 ]                                                                             ; with the beginning of a new year, the Molinia plants become one year older
    produce-Molinia                                                                                              ; they gain energy monthly
    reproduce-Molinia                                                                                            ; they reproduce
    Molinia-death                                                                                                ; they die
  ]

  ask Calluna
  [ if month = 1 [ set age age + 1 ]                                                                             ; with the beginning of a new year, the Calluna plants become one year older
    produce-Calluna                                                                                              ; they gain energy monthly
    reproduce-Calluna                                                                                            ; they reproduce
    Calluna-death                                                                                                ; they die
  ]

  tick

end

; -------------------------------------------------------------------------------

to advance-calendar
  set month month + 1                                                                                            ; with every tick, one month passes by
  if month > 12                                                                                                  ; when twelve months are over, a new year starts with month 1
    [ set year year + 1
      set month 1
    ]
   wait 0.7                                                                                                      ; wait a bit so that the model does not run too quickly
end

; -------------------------------------------------------------------------------

to move
  if not any? Calluna [ stop ]
  move-to one-of Calluna                                                                                         ; the beetles head for the Calluna individuals
  right random 360
  fd random 10
end

to eat-Calluna
  let prey one-of Calluna-here                                                                                   ; the beetles eat the Calluna plants...
  if prey != nobody
  [
    ask prey
    [ if age > 10 [ die ]                                                                                        ; ... so older Calluna plants die
      if age < 11 [ set energy energy - 10 ]                                                                     ; ... and younger Calluna plants lose energy
    ]
    set energy energy + 10                                                                                       ; ... and the beetles gain new energy
  ]
end

to reproduce-beetles
  if (random-float 100 < 50) and (energy > 10)                                                                   ; define the random probability and an energy threshold for the beetle reproduction
  [ set energy energy - 20                                                                                       ; they lose energy when they reproduce
    if (month = 6) [ hatch 20 [ set age 0 rt random-float 360 ] ]                                                ; they reproduce in june, so new beetles are hatched
  ]
end

to beetles-death                                                                                                 ; the beetles die...
  if energy < 0 [ die ]                                                                                          ; ... if they run out of energy...
  if age > 1 [ die ]                                                                                             ; ... or if they are more than one year old
end

; -------------------------------------------------------------------------------

to produce-Molinia                                                                                               ; every month, Molinia gains a certain amount of energy
  set energy energy + 7.6
end

to reproduce-Molinia
  if (random-float 100 < 50) and (energy > 10)                                                                   ; define the random probability and an energy threshold for the Molinia reproduction
  [ set energy energy - 20                                                                                       ; the Molinia plants lose energy when they reproduce
    if (month > 3) and (month < 7)                                                                               ; they reproduce only from april to june ...
        [ hatch 1 [ set age 0 rt random-float 360 fd 0.5 ] ]                                                     ; ... and new Molinia plants are hatched in a radius of 0.5
  ]
end

to Molinia-death                                                                                                 ; the Molinia plants die...
  if energy < 0 [ die ]                                                                                          ; ... if they run out of energy...
  if age > 5 [ die ]                                                                                             ; ... or if they are more than five years old
end

; -------------------------------------------------------------------------------

to produce-Calluna                                                                                               ; every month, Calluna gains a certain amount of energy ...
  if Calluna-life-phase = "pioneer-phase"       [ set energy energy + 7.8 ]                                      ; ... depending on the specific life phase
  if Calluna-life-phase = "development-phase"   [ set energy energy + 6.7 ]
  if Calluna-life-phase = "mature-phase"        [ set energy energy + 6.1 ]
  if Calluna-life-phase = "degeneration-phase"  [ set energy energy + 5.9 ]
end

to reproduce-Calluna
  if (random-float 100 < 50) and (energy > 30)                                                                   ; define the random probability and an energy threshold for the Calluna reproduction
  [ set energy energy - 30                                                                                       ; the Calluna plants lose energy when they reproduce
    if (month > 0) and (month < 5)                                                                               ; they reproduce only from january to april ...
        [ hatch 1 [ set age 0 rt random-float 360 fd random 10 ] ]                                               ; ... and new Calluna plants are hatched in a radius of 10
  ]
end

to Calluna-death                                                                                                 ; the Calluna plants die...
  if energy < 0 [ die ]                                                                                          ; ... if they run out of energy...
  if age > 25 [ die ]                                                                                            ; ... or if they are more than 25 years old
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
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
1
1
-16
16
-16
16
0
0
1
months
30.0

BUTTON
12
412
85
445
go forever
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

BUTTON
95
413
152
446
go once
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

BUTTON
12
369
67
402
setup
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

SLIDER
15
186
187
219
beetles-initial-number
beetles-initial-number
0
500
50.0
5
1
NIL
HORIZONTAL

SLIDER
14
234
186
267
Molinia-initial-number
Molinia-initial-number
0
500
50.0
5
1
NIL
HORIZONTAL

SLIDER
14
281
186
314
Calluna-initial-number
Calluna-initial-number
0
500
100.0
5
1
NIL
HORIZONTAL

MONITOR
670
163
758
208
NIL
count beetles
17
1
11

MONITOR
768
163
858
208
count Molinia
count molinia
17
1
11

MONITOR
868
163
956
208
NIL
count Calluna
17
1
11

PLOT
671
231
1034
449
plot populations
months
population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Molinia caerulea" 1.0 0 -987046 true "" "plot count Molinia"
"Lochmaea suturalis" 1.0 0 -6459832 true "" "plot count beetles"
"Calluna vulgaris" 1.0 0 -5825686 true "" "plot count Calluna"

CHOOSER
16
40
188
85
Calluna-life-phase
Calluna-life-phase
"pioneer-phase" "development-phase" "mature-phase" "degeneration-phase"
0

MONITOR
673
66
730
111
NIL
year
17
1
11

MONITOR
738
66
795
111
NIL
month
17
1
11

CHOOSER
16
95
188
140
nutrient-treatment
nutrient-treatment
"no-treatment" "N-fertilisation" "P-fertilisation" "N+P-fertilisation"
0

TEXTBOX
17
161
187
195
2. adjust slider parameters:
14
0.0
1

TEXTBOX
18
10
202
44
1. choose model conditions:
14
0.0
1

TEXTBOX
15
337
186
371
3. setup and start model:
14
0.0
1

TEXTBOX
673
34
873
68
4. observe the calendar:
14
0.0
1

TEXTBOX
673
131
893
165
5. observe the population sizes:
14
0.0
1

@#$#@#$#@
# Dynamics of Heathlands: Interspecific Competition Between *Calluna vulgaris* and *Molinia caerulea* Considering Combination Effects of Fertilisation With Nitrogen and Phosphorus and Pest Infestation by *Lochmaea suturalis*

## WHAT IS IT?

This model explores the impacts of different treatments with nutrient inputs in heathlands on the population dynamics of common heather (*Calluna vulgaris*), purple moor-grass (*Molinia caerulea*), and the heather beetle (*Lochmaea suturalis*). 
Heathlands are nowadays strongly threatened ecosystems, which is mainly due to rising nutrient inputs coming from agriculture, public transportation and some other pillars of human civilisation. Closely related to this is the replacement of *Calluna* by *Molinia*, resulting from strong competitive advantages of the latter in the course of a higher nutrient deposition. 

The overall aim of the model is thus to examine the competitive relationship between *Calluna* and *Molinia* under different environmental conditions, e.g. depending on the population size of heather beetles, on the type of nutrient deposition into the heath ecosystem, and on the respective life stage in which a specific area with heather plants may be. 
The model tries to identify possible thresholds in the different environmental preconditions in order to predict the evolution of the populaton sizes of all three species and to discover under which conditions a heathland gets overgrown with and thus replaced by grasses. 

## HOW IT WORKS

In order to imitate the complex dynamics in a real-world heathland ecosystem, this model determines different relationships between the three types of turtles along with the underlying environmental conditions, based on empirical data. Even though the model is only able to represent the ecosystem in a very simplistic and limited way, it is still useful for showing some interesting mechanisms of actions and moreover identifying new interdependencies between the different parts of the system. The most important rules, which the model tries to depict and on which the overall behaviour of the model is based, are the following relations:

- The three breeds of turtles have specific rates of **energy** and **productivity**, which are defined in the code. In consideration of the two plant species, *Calluna* and *Molinia*, the energy rate represents their above-ground biomass whereas the productivity stands for the net primary production. All three species, including the beetles, need a certain energy level in order to reproduce, which in turn consumes energy, too. The heather beetles, in addition, constantly lose energy when moving, which they can compensate by consuming the *Calluna* plants as food and therefore gaining new energy. 


- The three types of turtles also underlie specific rules to determine their **time of death**. Each of the breeds possesses a specific natural life span, so when this time is elapsed, it implies a **natural death** for the respective individual which then disappears from the interface. This event occurs for *Calluna* after 25 years, for *Molinia* after 5 years and for the heather beetles after 1 year, roughly orientating towards practical biological data concerning these species. The applied NetLogo command in this case is `if age > X [die]`. 
Besides, *Calluna* individuals may also die when they are **attacked by heather beetles**, which are specialised in *Calluna* as a food source in their larval as well as adult life stages (implemented in the model with the command `let prey one-of Calluna-here`). The heather beetles also do not move around complety random, but on the contrary they purposefully head for the heather plants, in order to eat them. This is carried out by using the command `move-to one-of Calluna`. 
A third possibility to death consists for all three breeds in **energy levels dropping below zero**, represented with the command `if energy < 0 [die]`. 


- The productivity (i.e. the net primary production) of *Calluna* and *Molinia* is strongly influenced by the **type of nutrient treatment** the ecosystem receives, and therefore indirectly their energy levels (i. e. the above-ground biomass) as well. Consequently, also the constellation in their competitive relationship changes, depending on the type of fertilization. 
When **N** is deposited into the ecosystem, *Molinia* gains strong competitive advantages, multiplying its productivity by nearly five, whereas *Calluna* is only able to double its productivity. 
The deposition of **P** alone does not lead to such drastic changes, showing slightly negative effects for *Molinia* and consistent productivity values for *Calluna*. 
A fertilization with both **N and P**, is again to the advantage of *Molinia*, given an increase in productivity which is approximately twice as high as that of *Calluna*. 
The nutrient inputs have indirect effects on the beetles, as well, leading to higher populations when N is brought into the ecosystem. The concrete factors by which the productivity rates of *Calluna*, *Molinia* and the beetles are multiplied in the different treatment conditions, are listed in the code under the procedure `to setup-treatment`. 


- Another important element in the modeled ecosystem is the development of *Calluna*, which takes place in **four consecutive life stages**: the pioneer phase, the development phase, the mature phase, and the degeneration phase. Depending on the specific life phase, the plants show different values in energy and productivity. For instance, in the pioneer phase the productivity is highest, whereas the biomass maximum of *Calluna* can be found in the mature phase. The respective values are specified in the code under the procedure `to setup-life-phase`. 


## HOW TO USE IT

**1.** Choose one life-phase and one kind of treatment.
**2.** Adjust the slider parameters (see below), or use the default settings.
**3.** Click the SETUP button to setup the individuals of *Calluna*, *Molinia*, and the beetles. 
**4.** Click on the GO button to start the simulation. Use the GO ONCE button for forwarding the simulation just by one month or for a continuious time sequence use the GO FOREVER button.
**5.** Look at the monitors to see the current population sizes.
**6.** Look at the plot POPULATIONS to watch changes in populations sizes and fluctuations over time.

### Slider Parameters

#### Calluna-life-phase

- **pioneer-phase:**
The Calluna's energy is set at 14.9 %.  
- **development-phase:** 
The Callunas's energy is set at 78.4 %.
- **mature-phase:** 
The Calluna's energy is set at 100 %.
- **degeneration-phase:** 
The Calluna's energy is set at 54.2 %.


#### nutrient-treatment

- **no-treatment:**
The model runs without any influence of nutrient input.
- **N-fertilisation:**
The model runs under the influence of fertilisation with nitrogen (N).
- **P-fertilisation:**
The model runs under the influence of fertilisation with phosphorus (P).
- **N+P-fertilisation:**
The model runs under the influence of fertilisation with both nitrogen and phosphorus (N+P).


**initial-number-beetles:** The initial size of beetle population. The default setting is 50.
**initial-number-molinia:** The initial size of *Molinia* population. The default setting is 50.
**initial-number-calluna:** The initial size of *Calluna* population. The default setting is 100.


## THINGS TO NOTICE

Observe the plot and the monitors to see how the populations change over time. Notice that there are periodic times for reproduction. You will only see increases during these reproductive periods, which differ from each species. 

## THINGS TO TRY

Try adjusting the slider parameters under various settings. What influence does the initial number of each species have on the population development? How sensitive is the course of the model to these parameters? Can you detect changes when choosing different life phases of *Calluna* and/or adjusting the type of nutrient treatment?

## EXTENDING THE MODEL

Try changing the rules and parameters for reproduction and production. What would happen, if the reproduction time spans are shifted, shortened or extended? You could even try to implement a slider in the interface displaying a variable reproduction threshold so that the agents would need to meet a certain energy level set by the users themselves in order to reproduce (in contrast to the current regulation in the code with set values).

It is also possible to change the radius of movement if you change the numbers of the move-procedure in the code. What changes if the beetles move further or less far? Another option would be to change or remove the `move-to one-of Calluna`-command to see what would happen if the beetles moved arbitrarily.   

Another interesting advancement of the model would be the inclusion of a cyclic succession of the four life phases of *Calluna*, representing an even more realistic life cycle of the heathland. With this further adaptation, one life stage would run consecutively after the other in the simulation, which would allow for monitoring the development of the ecosystem and of the population sizes over a longer time span. 

Very interesting would also be the invention of a "beetle outbreak" every five to ten years, due to temperature conditions, as it is indicated in the literature, which would make the model even more dynamic and realistic. This could be implemented into the simulation by giving the beetles the command to reproduce for example twice as high as normal in these specific years. 

## RELATED MODELS

This model shares some feature similarities with the Model named *Wolf Sheep Predation* in that both use energy as a unit to model population and ecosystem dynamics. In both models the agents are able to reproduce under certain conditions, one agent acts as the predator of another and all agents are mortal. 

Look up *Rabbits Grass Weeds* for another energy-based model of interacting populations with different rules.

## REFERENCES

Aerts, R. (1989): Aboveground Biomass and Nutrient Dynamics of Calluna vulgaris and Molinia caerulea in a Dry Heathland. In Oikos 56 (1), p. 31. 

Berdowski, J. J. M. (1987): Transition from Heathland to Grassland Initiated by the Heather Beetle. In Vegetatio 72, pp. 167–173.

Braunschweigische Wissenschaftliche Gesellschaft (Ed.) (2015): Reader Faszination Feuer. Vortragsreihe der Akademie-Vorlesungen 2015 der Braunschweigischen Wissenschaftlichen Gesellschaft. Braunschweig.

Brunsting, A. M. H.; Heil, G. W. (1985): The Role of Nutrients in the Interactions between a Herbivorous Beetle and Some Competing Plant Species in Heathlands. In Oikos 44 (1), pp. 23–26. 

Ellenberg, Heinz (1996): Vegetation Mitteleuropas mit den Alpen in ökologischer, dynamischer und historischer Sicht. 5. edition. Stuttgart: Ulmer (UTB für Wissenschaft: Große Reihe, 8104).

Falk, K.; Friedrich, U.; Oheimb, G. v.; Mischke, K.; Merkle, K.; Meyer, H.; Härdtle, W. (2010): Molinia caerulea responses to N and P fertilisation in a dry heathland ecosystem (NW-Germany). In Plant Ecol 209 (1), pp. 47–56. 

Friedrich, U.; Oheimb, G. v.; Dziedek, C.; Kriebitzsch, W.-U.; Selbmann, K.; Härdtle, W. (2011): Mechanisms of purple moor-grass (Molinia caerulea) encroachment in dry heathland ecosystems with chronic nitrogen inputs. In Environmental pollution (Barking, Essex : 1987) 159 (12), pp. 3553–3559. 

Friedrich, U.; Oheimb, G. v.; Kriebitzsch, W.-U.; Schleßelmann, K.; Weber, M. S.; Härdtle, W. (2012): Nitrogen deposition increases susceptibility to drought - experimental evidence with the perennial grass Molinia caerulea (L.) Moench. In Plant Soil 353 (1-2), pp. 59–71. 

Härdtle, W.; Assmann, T.; Diggelen, R. v.; Oheimb, G. v. (2009): Renaturierung und Management von Heiden. In Stefan Zerbe, Gerhard Wiegleb (Eds.): Renaturierung von Ökosystemen in Mitteleuropa. With assistance of René Fronczek. Heidelberg: Spektrum Akademischer Verlag, pp. 317–347.

Härdtle, W.; Niemeyer, T. (2015): Zur Wirkung von Feuer und anderen Pflegemaßnahmen auf den Nährstoffhaushalt von Heidelandschaften. In Braunschweigische Wissenschaftliche Gesellschaft (Ed.): Reader Faszination Feuer. Vortragsreihe der Akademie-Vorlesungen 2015 der Braunschweigischen Wissenschaftlichen Gesellschaft. Braunschweig, pp. 1–11.

Heil, G. W.; Bruggink, M. (1987): Competition for nutrients between Calluna vulgaris (L.) Hull and Molinia caerulea (L.) Moench. In Oecologia 73 (1), pp. 105–107. 

Keienburg, T.; Prüter, J. (2006): Naturschutzgebiet Lüneburger Heide. Erhaltung und Entwicklung einer alten Kulturlandschaft. In Mitteilungen aus der NNA 17 (Sonderheft 1), pp. 1–65.

Ladekarl, U. L.; Nørnberg, P.; Rasmussen, K. R.; Nielsen, K. E.; Hansen, B. (2001): Effects of a heather beetle attack on soil moisture and water balance at a Danish heathland. In Plant Soil 229 (1), pp. 147–158.

Marrs, R. H. (1986): The Role of Catastrophic Death of Calluna in Heathland Dynamics. In Vegetatio 66 (2), pp. 109–115. 

Oheimb, G. v.; Power, S. A.; Falk, K.; Friedrich, U.; Mohamed, A.; Krug, A. et al. (2010): N:P Ratio and the Nature of Nutrient Limitation in Calluna-Dominated Heathlands. In Ecosystems 13 (2), pp. 317–327. 

Scandrett, E.; Gimingham, C. H. (1991): The Effect of Heather Beetle Lochmaea suturalis on Vegetation in a Wet Heath in NE Scotland. In Holarctic Ecology 14 (1), pp. 24–30.

Terry, A. C.; Ashmore, M. R.; Power, S. A.; Allchin, E. A.; Heil, G. W. (2004): Modelling the impacts of atmospheric nitrogen deposition on Calluna-dominated ecosystems in the UK. In Journal of Applied Ecology 41 (5), pp. 897–909. 

## COPYRIGHT AND LICENSE

Copyright 2020 
Jannika Baars, Mareike Thomas

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).

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

flower budding
false
0
Polygon -7500403 true true 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Polygon -7500403 true true 189 233 219 188 249 173 279 188 234 218
Polygon -7500403 true true 180 255 150 210 105 210 75 240 135 240
Polygon -7500403 true true 180 150 180 120 165 97 135 84 128 121 147 148 165 165
Polygon -7500403 true true 170 155 131 163 175 167 196 136

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
