extensions[
  gis
  csv
]

globals[
  my-dataset
  SEAL_ISLAND
;  patch_size

  eaten_seals  ; used to count number of seals that died
  eaten_seals_in  ; used to count number of seals that died
  seals_foraging
  seals_home
  a
  a_2
  pred_dis
  group_num_list
  group_num_list_in
  group_num
  group_num_in
  group_num_distribution_list
  group_num_distribution_list_in
  light_level_seals
  starting_point



  si-patches
  ocean-patches
  land-patches
]

breed [sharks shark]
breed [seals seal]

seals-own[  group_center]
patches-own[categ zone ID id2 centroid art_light LIGHT_LEVEL light_level_sharks]

to setup
  clear-all
   set my-dataset gis:load-dataset "light_pol_poly.shp"
  set SEAL_ISLAND gis:load-dataset "CLIPPED_SEAL_ISLAND.shp"
  gis:set-world-envelope (gis:envelope-of my-dataset)
  gis:set-drawing-color white
  gis:draw my-dataset 1

  let i  1
 foreach gis:feature-list-of my-dataset [vector-feature ->
    ask patches gis:intersecting vector-feature[ set id2 i
      set centroid gis:location-of gis:centroid-of vector-feature
      ask patch item 0 centroid item 1 centroid
      [set ID i]
    ]
    set i i + 1
 ]

  ask patches with [ID > 0] [

    if ID = 22[gis:set-drawing-color white]
    if ID = 24[gis:set-drawing-color red]
    if ID = 25[gis:set-drawing-color orange]
    if ID = 26[gis:set-drawing-color yellow]
    if ID = 27[gis:set-drawing-color yellow]
    if ID = 28[gis:set-drawing-color orange]
    if ID = 29[gis:set-drawing-color yellow]
    if ID = 30[gis:set-drawing-color orange]
    if ID = 31[gis:set-drawing-color yellow]
    if ID = 32[gis:set-drawing-color yellow]
    if ID = 33[gis:set-drawing-color yellow]
    if ID = 34[gis:set-drawing-color green]
    if ID = 35[gis:set-drawing-color green]
    if ID = 36[gis:set-drawing-color green]
    if ID = 37[gis:set-drawing-color green]
    if ID = 38[gis:set-drawing-color blue]
    if ID = 39[gis:set-drawing-color blue]
    if ID = 40[gis:set-drawing-color white]
    if ID = 41[gis:set-drawing-color blue]
    if ID = 42[gis:set-drawing-color blue]


   gis:fill item (ID - 1) gis:feature-list-of my-dataset 2.0
  ]
 gis:set-drawing-color white
 gis:draw SEAL_ISLAND 1
 gis:fill SEAL_ISLAND 1
 resize-world -674 674 -518 518 ; Size of area is 67403.784m by 51763.885m Scale of 1/50 --> each patch 50x50m
 set-patch-size 1

  setup-patches      ;preforms "setup-patches" function below
  setup-sharks       ; preforms "setup-sharks" function below
  setup-seals       ; preforms "setup-sharks" function below
  set group_num_list []   ; creates a list to store group numbers in
  set group_num_distribution_list []
  set group_num_list_in []   ; creates a list to store group numbers in
  set group_num_distribution_list_in []
  reset-ticks        ; makes sure ticks start at zero
end

to setup-patches
  ask patches [set categ "land"]
  ask patches [
    if id2 = 25[set categ "ocean"]
    if id2 = 29[set categ "ocean"]
    if id2 = 30[set categ "ocean"]
    if id2 = 33[set categ "ocean"]
    if id2 = 34[set categ "ocean"]
    if id2 = 36[set categ "ocean"]
    if id2 = 41[set categ "ocean"]
  ]

  ask patches gis:intersecting SEAL_ISLAND[
      set categ "island"]

   set ocean-patches patches with [categ = "ocean"]
   set land-patches patches with [categ = "land"]
   set si-patches patches with [categ = "island"]

  ask patches[ set zone 5 ; 800m + away from Seal Island
    if distance one-of si-patches < 16 [set zone 4] ;600-800m away from Seal Island
    if distance one-of si-patches < 12 [set zone 3] ;400-600m away from Seal Island
    if distance one-of si-patches < 8 [set zone 2] ;200-400m away from Seal Island
    if distance one-of si-patches < 4 [set zone 1] ;0-200m away from Seal Island
  ]

  ifelse Light_Pollution = true [
    ask patches with [pcolor = blue] [set art_light (0.33 * natural_light_level) set LIGHT_LEVEL (art_light + natural_light_level)]
    ask patches with [pcolor = green] [set art_light natural_light_level set LIGHT_LEVEL (art_light + natural_light_level)]
    ask patches with [pcolor = yellow] [set art_light (3 * natural_light_level) set LIGHT_LEVEL (art_light + natural_light_level)]
    ask patches with [pcolor = orange] [set art_light (9 * natural_light_level) set LIGHT_LEVEL (art_light + natural_light_level)]
    ask patches with [pcolor = red] [set art_light (27 * natural_light_level) set LIGHT_LEVEL (art_light + natural_light_level)]
  ]
  [ask patches[set LIGHT_LEVEL natural_light_level]
  ]

  ask patches [
  if LIGHT_LEVEL <= 200 [set light_level_sharks 0.4039]
  if LIGHT_LEVEL > 200 and LIGHT_LEVEL <= 300 [set light_level_sharks 0.069]
  if LIGHT_LEVEL > 300 and LIGHT_LEVEL <= 400 [set light_level_sharks 0.0197]
  if LIGHT_LEVEL > 400 and LIGHT_LEVEL <= 600 [set light_level_sharks 0.0197]
  if LIGHT_LEVEL > 600 and LIGHT_LEVEL <= 800 [set light_level_sharks 0.0049]
  if LIGHT_LEVEL > 800 and LIGHT_LEVEL <= 1000 [set light_level_sharks 0.0099]
  if LIGHT_LEVEL > 1000 and LIGHT_LEVEL <= 1500 [set light_level_sharks 0.0099]
  ]

end

to setup-sharks
  create-sharks 128
  ask sharks[ move-to one-of ocean-patches] ;creates initial sharks values and have them start at random coordinates
  ask sharks [ set shape "dot" set color magenta - 2 set size 10]
end


to setup-seals
   create-seals 0
    ask seals [
    set eaten_seals 0
    set eaten_seals_in 0
    set seals_foraging 0
    set seals_home 0
  ]
    set group_num_in 1000
    set group_num 0
end

to go
  ask sharks[
    move_sharks   ;run move_sharks function
    eat-seals   ;run eat-seals function
  ]

ifelse natural_light_level <= 300 / 4 [set light_level_seals 0.4] [set light_level_seals 0.6]

;  foreach gis:feature-list-of SEAL_ISLAND [ this-vector-feature ->
;    gis:create-turtles-inside-polygon this-vector-feature seals 10 ]

  ask one-of si-patches [ ;sprouts a number of seals from seal island every time step with some probability of occuring based on what time of day it is
                          ; .24 is to help match data
    if ticks <= 60[set a .296 * light_level_seals * .24
        sprout_seals_out]
      if (ticks > 60 and ticks <= 120)[set a .189 * light_level_seals * .24
        sprout_seals_out]
      if (ticks > 120 and ticks <= 180)[set a .202 * light_level_seals * .24
        sprout_seals_out]
      if (ticks > 180 and ticks <= 240)[set a .102 * light_level_seals * .24
        sprout_seals_out]
      if (ticks > 240 and ticks <= 300)[set a .1213 * light_level_seals * .24
        sprout_seals_out]
      if (ticks > 300 and ticks <= 360)[set a .059 * light_level_seals * .24
        sprout_seals_out]
  ]

   ask patch (-300 + (random 600)) min-pycor [;sprouts a number of seals from south every time step with some probability of occuring based on what time of day it is
                                              ; .18 is to help match data
          if ticks <= 60[set a_2 .3708 * light_level_seals * .18
            sprout_seals_in]
          if (ticks > 60 and ticks <= 120)[set a_2 .23596 * light_level_seals * .18
            sprout_seals_in]
          if (ticks > 120 and ticks <= 180)[set a_2 .14232 * light_level_seals * .18
            sprout_seals_in]
          if (ticks > 180 and ticks <= 240)[set a_2 .11236 * light_level_seals * .18
            sprout_seals_in]
          if (ticks > 240 and ticks <= 300)[set a_2 .0824 * light_level_seals * .18
            sprout_seals_in]
          if (ticks > 300 and ticks <= 360)[set a_2 .0637 * light_level_seals
            sprout_seals_in]
        ]

  ask seals[
    move_seals    ;run move_seals function
  ]

  tick

  if ticks > 360 ;resets everything every 360 ticks to simulate restarting every day since data starts aroung 730 and ends 1330
    [stop];[setup]
end

;;;;;sprout_seals_out has seals group together in groups of 2,3,4,5,or 6 seals with varying probabilities and sprout from
;;;;; seal island and leave seal island. Note several groups can leave Seal Island at the same time

to sprout_seals_out
  let dummy_var random-float 1
  if dummy_var < 0.003 * a
  [let shift random 90
    set group_num group_num + 1
   set group_num_distribution_list lput 2 group_num_distribution_list
   sprout-seals 2
  [ set heading (135 + shift)
    set shape "dot"
    set color grey
    set size 10
    set label group_num]
    set group_num_list lput group_num group_num_list
  ]

  if dummy_var > 0.003 * a and dummy_var < .0172 * a
  [ let shift random 90
    set group_num group_num + 1
    set group_num_distribution_list lput 6 group_num_distribution_list
    sprout-seals 6
  [ set heading (135 + shift)
    set shape "dot"
    set color grey
    set size 10
    set label group_num]
    set group_num_list lput group_num group_num_list
  ]

    if dummy_var > 0.0172 * a and dummy_var < .1872 * a
  [ let shift random 90
    set group_num group_num + 1
    set group_num_distribution_list lput 5 group_num_distribution_list
    sprout-seals 5
  [ set heading (135 + shift)
    set shape "dot"
    set color grey
    set size 10
    set label group_num]
    set group_num_list lput group_num group_num_list
  ]

  if dummy_var > 0.1872 * a and dummy_var < .6844 * a
 [ let shift random 90
    set group_num group_num + 1
    set group_num_distribution_list lput 3 group_num_distribution_list
    sprout-seals 3
  [ set heading (135 + shift)
    set shape "dot"
    set color grey
    set size 10
    set label group_num]
    set group_num_list lput group_num group_num_list
  ]

if dummy_var > 0.6844 * a and dummy_var <  a
 [ let shift random 90
   set group_num group_num + 1
    set group_num_distribution_list lput 4 group_num_distribution_list
    sprout-seals 4
  [ set heading 180
    set shape "dot"
    set color grey
    set size 10
    set label group_num]
    set group_num_list lput group_num group_num_list
  ]
end


to sprout_seals_in
  let dummy_var random-float 1
  if dummy_var < 0.01592 * a_2
  [set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 2 group_num_distribution_list_in
   sprout-seals 2
  [ facexy (31 + random 8 ) (50 + random 4 )
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]

  if dummy_var > 0.01592 * a_2 and dummy_var < 0.03822 * a_2
  [ set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 1 group_num_distribution_list_in
   sprout-seals 1
  [ facexy (31 + random 8 ) (50 + random 4 )
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]

  if dummy_var > 0.03822 * a_2 and dummy_var < 0.06052 * a_2
  [ set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 6 group_num_distribution_list_in
   sprout-seals 6
  [ facexy (31 + random 8 ) (50 + random 4 )
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]

  if dummy_var > 0.06052 * a_2 and dummy_var < 0.11782 * a_2
  [ set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 5 group_num_distribution_list_in
   sprout-seals 5
  [ facexy (31 + random 8 ) (50 + random 4 )
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]

  if dummy_var > 0.11782 * a_2 and dummy_var < 0.43632 * a_2
  [ set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 3 group_num_distribution_list_in
   sprout-seals 3
  [ facexy (31 + random 8 ) (50 + random 4 )
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]


  if dummy_var > 0.43632 * a_2 and dummy_var < a_2
  [ set group_num_in group_num_in + 1
   set group_num_distribution_list_in lput 4 group_num_distribution_list_in
   sprout-seals 4
  [ facexy (random 10 * .5) (random 10 * .5)
    set shape "dot"
    set color grey
    set size 10
    set label group_num_in]
    set group_num_list_in lput group_num_in group_num_list_in
  ]
end


to move_sharks
  let next-patch ocean-patches in-radius 1  ;average shark travels 0.5 m/s -> 4 patches per tick (Not shown in model:They produce burst of speed up to 11.9m/s (42.84 km/hour) to catch prey)
  move-to one-of next-patch
end


;;;;move_seals have seal groups move towards a given direction (N,S,E,or W) and if the seperate too much
;;;; they move back towards the center of the group
to move_seals
  foreach group_num_list
      [x -> ask seals with [x = label]
          [
           let center_x mean [ xcor ] of seals with [x = label] ;x_cor of group center
           let center_y mean [ ycor ] of seals with [x = label] ;y_cor of group center
           ifelse distancexy center_x center_y > 0.2 ;seals stay in groups with range of 10m
            [facexy center_x center_y forward 3.3] ; average seal travels 9.840 km/hour during winter -> 164m/min -> 3.28 patches per tick
          [facexy (-674 + (random 1348)) -518 forward 3.3]
          if patch-here != ocean-patches [move-to one-of ocean-patches in-radius 10]
          ask seals with [x = label] [if abs(xcor) > 670 or abs(ycor) > 514 [set seals_foraging seals_foraging + 1 die]]
           ]
       ]

  foreach group_num_list_in
      [x -> ask seals with [x = label]
          [
          let center_x mean [ xcor ] of seals with [x = label] ;x_cor of group center
           let center_y mean [ ycor ] of seals with [x = label] ;y_cor of group center
           ifelse distancexy center_x center_y > 0.2
           [facexy center_x center_y forward 3.3] ;  average seal travels 9.840 km/hour during winter -> 164m/min -> 3.28 patches per tick
          [face one-of si-patches forward 3.3]
           ifelse distance one-of si-patches > 20
            [forward 3.3]
            [move-to one-of si-patches set seals_home seals_home + 1 die]
           if patch-here != ocean-patches [move-to one-of ocean-patches in-radius 3]
;           ask seals with [x = label] [if distance one-of si-patches < 20  [set seals_home seals_home + 1 die]]
           ]
           ]
;forward 3.3
end

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
to eat-seals
   ask seals[ if any? sharks in-radius .25[
      if zone = 1[
      set pred_dis  0.195 * light_level_sharks
;      if random-float 1 < 0.195 ;each seal 0m-200m from seal island has a 0.195 chance of being eaten every tick. That is a a 0.39 chance of predation happening and 0.5 chance being successful
      seal_predation_groupsize
      seal_predation_groupsize_in]

      if zone = 2[
      set pred_dis  0.1408 * light_level_sharks
;      if random-float 1 < 0.1408 ;each seal 200m-400m from seal island has a 0.1408 chance of being eaten every tick. That is a a 0.32 chance of predation happening and 0.44 chance being successful
      seal_predation_groupsize
      seal_predation_groupsize_in]

      if zone = 3[
      set pred_dis  0.0492 * light_level_sharks
;      if random-float 1 < 0.0492 ;each seal 400m-600m from seal island has a 0.0492 chance of being eaten every tick. That is a a 0.12 chance of predation happening and 0.41 chance being successful
      seal_predation_groupsize
      seal_predation_groupsize_in]

      if zone = 4[
      set pred_dis  0.0408 * light_level_sharks
;      if random-float 1 < 0.0408 ;each seal 600m-800m from seal island has a 0.0408 chance of being eaten every tick. That is a a 0.08 chance of predation happening and 0.51 chance being successful
      seal_predation_groupsize
      seal_predation_groupsize_in]

      if zone = 5[
      set pred_dis  0.0549 * light_level_sharks
;      if random-float 1 < 0.0549 ;each seal 800m+ from seal island has a 0.0549 chance of being eaten every tick. That is a a 0.9 chance of predation happening and 0.61 chance being successful
      seal_predation_groupsize
      seal_predation_groupsize_in]
  ]]

end

to seal_predation_groupsize
  foreach group_num_list
      [x -> let seal_num (count seals with [x = label])
        let num .008
;        ask one-of (seals with [x = label])[ask patch-here [print(zone)]]
        if seal_num = 6 [
        if random-float 1 < 0.00353 * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 5 [
        if random-float 1 < 0.01412 * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing  seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 4 [
        if random-float 1 < 0.0471  * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 3 [
        if random-float 1 < 0.1255 * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 2 [
        if random-float 1 < 0.251  * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 1 [
        if random-float 1 < 0.3347 * pred_dis * num[
            set eaten_seals eaten_seals + 1 ;adds to total outgoing seals that died
             die stop]
        ]
  ]
end

to seal_predation_groupsize_in
  foreach group_num_list_in
      [x -> let seal_num (count seals with [x = label])
        let num .008
;        ask one-of (seals with [x = label])[ask patch-here [print(zone)]]
        if seal_num = 6 [
        if random-float 1 < 0.00353 * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 5 [
        if random-float 1 < 0.01412 * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 4 [
        if random-float 1 < 0.0471 * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            ask one-of (seals with [x = label])[die stop]]
        ]
        if seal_num = 3 [
        if random-float 1 <  0.1255 * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            ask one-of (seals with [x = label])[ die stop]]
        ]
        if seal_num = 2 [
        if random-float 1 < 0.251  * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            ask one-of (seals with [x = label])[die stop]]
        ]
        if seal_num = 1 [
        if random-float 1 < 0.3347 * pred_dis * num[
            set eaten_seals_in eaten_seals_in + 1 ;adds to total incoming seals that died
            die stop]
        ]
       ; show eaten_seals_in
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
7
10
1364
1056
-1
-1
1.0
1
5
1
1
1
0
0
0
1
-674
674
-518
518
1
1
1
ticks
30.0

BUTTON
1382
12
1482
45
setup-map
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
1398
66
1461
99
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

MONITOR
1385
195
1471
240
Count Seals
count seals
17
1
11

MONITOR
1389
265
1607
310
Number of Outgoing Seal Groups
group_num
17
1
11

MONITOR
1391
334
1608
379
Number of Incoming Seal Groups
(group_num_in - 1000)
17
1
11

MONITOR
1395
408
1476
453
Eaten Seals
eaten_seals + eaten_seals_in
17
1
11

MONITOR
1397
476
1649
521
Seals that Arrived at Foraging Grounds
seals_foraging
17
1
11

MONITOR
1400
543
1604
588
Seals that Arrived at Seal Island
seals_home
17
1
11

SLIDER
1401
139
1716
172
natural_light_level
natural_light_level
0
375
370.0
10
1
10^-6 E (lux per m^2)
HORIZONTAL

SWITCH
1521
38
1670
71
Light_Pollution
Light_Pollution
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

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
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="test_experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <metric>ticks</metric>
    <metric>count seals</metric>
    <metric>group_num</metric>
    <metric>(group_num_in - 1000)</metric>
    <metric>eaten_seals</metric>
    <metric>eaten_seals_in</metric>
    <metric>seals_foraging</metric>
    <metric>seals_home</metric>
    <enumeratedValueSet variable="natural_light_level">
      <value value="370"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Light_Pollution">
      <value value="true"/>
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
