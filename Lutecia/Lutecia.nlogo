
;;;;;;;;;;;;;;;;;;;;;
;;
;; LUTECIA Model
;;
;; (MetropolSim v3.0)
;; Major changes since v2
;;   - matrix dynamic shortest path (euclidian and nw) computation
;;   - simplified population structure (one csp)
;;   - game-theoretical governance management
;;
;; Possible extensions (v4) :
;;    * add different transportation modes ?
;;    * add csp ? not prioritary.
;;
;;;;;;;;;;;;;;;;;;;;;

extensions[matrix table context nw shell gradient numanal gis morphology]

__includes [
  
  ; main
  "main.nls"
  
  ; setup
  "setup.nls"
  
  ;;;;;;;;;
  ;; main modules
  ;;;;;;;;;
  
  ;; transportation
  "transportation.nls"
  
  ;; luti
  "luti.nls"
  
  ;; governance
  "governance.nls"
  
  ;;;;;;;;
  ; agents
  ;;;;;;;;
  
  ; mayors
  "mayor.nls"
  
  ; patches
  "patches.nls"
  
  ;;;;;;;;
  ; transportation network
  ;;;;;;;;
  
  ; network
  "network.nls"
  
  ;;;;;;;;;
  ; functions
  ;;;;;;;;;
  
  ; functions to update distance matrices
  "distances.nls"
  
  ; accessibilities
  "accessibilities.nls"
  
  ;;;;;;;;;;
  ; display
  ;;;;;;;;;;
  
  "display.nls"
  
  
  ;;;;;;;;;;
  ; indicators
  ;;;;;;;;;;
  
  "indicators.nls"
  
  ;;;;;;;;;;
  ;; visual exploration
  ;;;;;;;;;;
  
  "exploration.nls"
  
  ;;;;;;;;
  ;; experiments
  ;;;;;;;;
  "experiments.nls"
  
  
  
  ;;;;;;;;;;
  ;; utils
  ;;;;;;;;;;
  
  ; Q : package utils subpackages or all utils to have a simpler use ?
  
  "utils/math/SpatialKernels.nls"
  "utils/math/Statistics.nls"
  "utils/math/EuclidianDistanceUtilities.nls"
  "utils/misc/List.nls"
  "utils/misc/Types.nls"
  "utils/misc/Matrix.nls"
  "utils/gui/Display.nls"
  "utils/agent/Link.nls"
  "utils/agent/AgentSet.nls"
  "utils/agent/Agent.nls"
  "utils/network/Network.nls"
  "utils/io/Timer.nls"
  "utils/io/Logger.nls"
  "utils/io/FileUtilities.nls"
  "utils/misc/String.nls"
  
  ;;;;;;;;;;;
  ;; Tests
  ;;;;;;;;;;;
  
  "test/test-distances.nls"
  "test/test-transportation.nls"
  "test/test-experiments.nls"
  
  
]




globals[
  
  ;;;;;;;;;;;;;
  ;; Setup params
  ;;;;;;;;;;;;;
  
  ; initial number of territories
  ;#-initial-territories
  
  ; spatial distribution params
  ;actives-spatial-dispersion
  ;employments-spatial-distribution
  
  ;; global employments and actives list
  patches-employments
  patches-actives
  
  ;; convergence variables
  diff-actives
  diff-employments
  
  
  initial-max-acc
  
  ; utility : cobb-douglas parameter
  ;gamma-cobb-douglas
  
  ; relocation : discrete choice parameter
  ;beta-discrete-choices
  
  ; governor of the region : particular mayor
  regional-authority
  
  
  ;; list of patches for the external facility
  external-facility
  
  ;; coordinates of mayors, taken from setup file
  mayors-coordinates
  mayors-populations
  mayors-employments
  mayors-names
  
  ;; position of ext patch
  ext-position
  
  ;; path to the setup files
  positions-file
  ext-file
  
  ;; GIS setup
  gis-network-file
  gis-extent-file
  gis-centers-file
  gis-population-raster-file
  gis-sea-file
  gis-economic-areas-file
  gis-governed-patches-file
  
  ;conf-file
  
  ;;;;;;;;;;;;;
  ;; Transportation
  ;;;;;;;;;;;;;
  
  ;; transportation flows \phi_ij between patches
  flow-matrix
  
  ;; congestion in patches
  ; list ordered by patch number
  patches-congestion
  
  ;; maximal pace (inverse of speed) in the transportation network
  ;network-max-pace
  
  
  
  ;;;;;;;;;;;;;
  ;; governance
  ;;;;;;;;;;;;;
  
  collaborations-wanted
  collaborations-realized
  collaborations-expected
  
  ;evolve-network?
  
  
  ;;;;;;;;;;;;;
  ;; Cached distances matrices
  ;;
  ;;  updated through dynamic programming rules
  ;;;;;;;;;;;;;
  
  ;; Matrix of euclidian distances between patches
  ; remains unchanged
  euclidian-distance-matrix
  
  ;; network distance (without congestion)
  network-distance-matrix
  
  ;; effective distance
  ;  - with congestion in network -
  effective-distance-matrix
  
  ;;
  ; Cached access patches to network, i.e. closest patch belonging to nw
  ;  @type table
  ;   number -> number of access
  nw-access-table
  
  ;; cached shortest paths -> updated same time as distance
  ; stored as table (num_patch_1,num_patch_2) -> [path-as-list]
  ;
  ; in network
  network-shortest-paths
  
  ;; list of nw patches
  ;  @type list
  ;  List of network patches number
  nw-patches
  
  ;; number of patches
  #-patches
  
  ;; for patches in nw, table caching closest nw inters (i.e. [end1,end2] of my-link )
  closest-nw-inters
  
  ;; network intersections
  ;  @type list
  ;  List of intersection patches numbers
  nw-inters
  
  ;; network clusters
  network-clusters
  
  ;; connexion between clusters
  network-clusters-connectors
  
  ; overall
  ; stored as table (num_patch_1,num_patch_2) -> [[i,i1],[i1,i2],...,[in,j]] where couples are either (void-nw) or (nw-nw)
  ; then effective path is [ik->i_k+1] or [ik->_nw i_k+1]
  effective-shortest-paths
  
  ;;
  ; maximal distance in the world
  dmax
  
  
  target-network-file
  
  ;;;
  ; network measures
  shortest-paths
  nw-relative-speeds
  nw-distances
  
  
  
  ;;;;;;;;;;;;;
  ;; Utils
  ;;;;;;;;;;;;;
  
  ; log level : defined in chooser
  ;log-level
  
  
  ;;;;;;;;;;;;;
  ;; Tests
  ;;;;;;;;;;;;;
  
  gridor
  
  ;; infra constructed by hand
  to-construct
  
  ;; HEADLESS
  headless?
  
  failed
  
  
  link-distance-function
  
  tracked-indicators
  history-indicators
  
]



patches-own [
  
  ; number of actives on the patch
  actives
  
  ; number of jobs on the patch
  employments
  
  
  
  ; number of the patch (used as index in distance matrices)
  number
  
  ; pointer to governing mayor
  governing-mayor
  
  ; actives and employment
  ; do not need mobile agents as deterministic evolution, considering at this time scale that random effect is averaged
  ;  on the contrary to transportation infrastructure evolution, that evolves at a greater scale.
  ;  -> patch variables and not agents
  
  
  
  
  ;;;;;
  ;; utilities and accessibilities
  ;;;;;
  
  ; accessibility of jobs to actives
  a-to-e-accessibility
  
  ; accessibility of actives to employments
  e-to-a-accessibility
   
  ; previous and current cumulated accessibilities
  prev-accessibility
  current-accessibility
   
  ; travel distances
  a-to-e-distance
  e-to-a-distance
   
  ; utilities
  ; for actives
  a-utility
  ; for employments
  e-utility
  
  ; form factor
  form-factor
  
  
  sea?
  
  
]


;;
; abstract entity representing territorial governance
breed[mayors mayor]

mayors-own[
  
  ; set of governed patches -> not needed ?
  ;governed-patches
  
  ; wealth of the area
  wealth
  
]


;;;;;;;;;
;; Transportation Network
;;;;;;;;;

;; transportation link
undirected-link-breed[transportation-links transportation-link]

transportation-links-own [
  
  transportation-link-length
  bw-centrality
  
  ; capacity of the link ; expressed as max trip per length unit 
  capacity
  
  ; congestion : travels in the link
  congestion
  
  ; speed in the link, deduced from capacity and congestion
  speed
  
  ; tick on which the infra has been constructed
  age
  
  status
  
]

;; nodes of the transportation network
breed[transportation-nodes transportation-node]

transportation-nodes-own[
  transportation-node-closeness-centrality
]


undirected-link-breed[ghost-transportation-links ghost-transportation-link]

breed[ghost-transportation-nodes ghost-transportation-node]
@#$#@#$#@
GRAPHICS-WINDOW
373
11
813
472
7
7
28.666666666666668
1
10
1
1
1
0
0
0
1
-7
7
-7
7
0
0
1
ticks
30.0

SLIDER
4
77
135
110
#-initial-territories
#-initial-territories
0
5
1
1
1
NIL
HORIZONTAL

BUTTON
406
532
472
565
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

CHOOSER
9
671
128
716
patches-display
patches-display
"governance" "actives" "employments" "a-utility" "e-utility" "accessibility" "a-to-e-accessibility" "e-to-a-accessibility" "congestion" "mean-effective-distance" "lbc-effective-distance" "center-effective-distance" "lbc-network-distance"
1

TEXTBOX
11
15
161
33
Setup parameters
11
0.0
1

TEXTBOX
9
193
159
211
Runtime parameters
11
0.0
1

SLIDER
7
116
182
149
actives-spatial-dispersion
actives-spatial-dispersion
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
6
150
182
183
employments-spatial-dispersion
employments-spatial-dispersion
0
10
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
183
116
292
149
actives-max
actives-max
0
1000
500
1
1
NIL
HORIZONTAL

SLIDER
182
150
292
183
employments-max
employments-max
0
1000
500
1
1
NIL
HORIZONTAL

SLIDER
0
235
178
268
gamma-cobb-douglas-a
gamma-cobb-douglas-a
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
3
305
172
338
beta-discrete-choices
beta-discrete-choices
0
5
1.8
0.05
1
NIL
HORIZONTAL

BUTTON
533
532
588
565
go
ifelse ticks < total-time-steps [\n  go\n][stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
817
10
988
154
convergence
NIL
NIL
0.0
2.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" "plot diff-employments"
"pen-1" 1.0 0 -12087248 true "" "plot diff-actives"

OUTPUT
838
410
1295
704
10

TEXTBOX
6
218
156
236
LUTI
11
0.0
1

TEXTBOX
188
216
338
234
Governance
11
0.0
1

SLIDER
184
235
333
268
regional-decision-proba
regional-decision-proba
0
1
1
0.05
1
NIL
HORIZONTAL

TEXTBOX
174
234
189
265
|
25
0.0
1

TEXTBOX
174
255
189
286
|
25
0.0
1

TEXTBOX
174
277
189
308
|
25
0.0
1

SLIDER
5
404
170
437
network-min-pace
network-min-pace
0
10
1
1
1
NIL
HORIZONTAL

TEXTBOX
4
363
207
390
_________________
20
0.0
1

TEXTBOX
5
389
155
407
Transportation
11
0.0
1

TEXTBOX
174
299
189
330
|
25
0.0
1

BUTTON
1374
400
1487
433
setup test nw
setup-test-nw-mat
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
1374
436
1429
469
grid
test-nw-mat-grid-nw
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
1375
474
1485
507
test shortest
test-shortest-path
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
1305
398
1373
443
nw patches
length nw-patches
17
1
11

MONITOR
1314
446
1368
491
eff paths
length table:keys network-shortest-paths
17
1
11

MONITOR
1315
494
1366
539
inters
length nw-inters
17
1
11

BUTTON
1375
510
1469
543
test inters
test-closest-inter
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
1396
546
1459
579
rnd
test-nw-mat-random-nw
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
678
523
816
568
log-level
log-level
"DEBUG" "VERBOSE" "DEFAULT"
2

SLIDER
5
440
169
473
euclidian-min-pace
euclidian-min-pace
1
50
5
1
1
NIL
HORIZONTAL

SLIDER
5
474
169
507
congestion-price
congestion-price
0
10
50
0.1
1
NIL
HORIZONTAL

SLIDER
184
273
333
306
road-length
road-length
0
20
2
1
1
NIL
HORIZONTAL

SLIDER
186
345
334
378
#-explorations
#-explorations
0
1000
25
1
1
NIL
HORIZONTAL

SLIDER
4
339
171
372
lambda-accessibility
lambda-accessibility
0
0.1
0.0010
0.001
1
NIL
HORIZONTAL

BUTTON
836
372
930
405
indicators
compute-indicators
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
481
571
605
604
total-time-steps
total-time-steps
0
20
15
1
1
NIL
HORIZONTAL

TEXTBOX
184
558
336
593
__________________
20
0.0
1

CHOOSER
186
380
338
425
game-type
game-type
"random" "simple-nash" "discrete-choices"
0

TEXTBOX
174
321
189
353
|
25
0.0
1

TEXTBOX
174
344
192
374
|
25
0.0
1

PLOT
987
10
1152
154
accessibility
NIL
NIL
0.0
2.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -12186836 true "" "plot mean-accessibility patches"

SLIDER
5
509
168
542
lambda-flows
lambda-flows
0
1
1
0.005
1
NIL
HORIZONTAL

TEXTBOX
405
497
592
541
__________________
20
0.0
1

BUTTON
1312
547
1393
580
test dist
setup\ntest-network-effect (patches with [pxcor = 0])\n;check-effective-distance 1180 684
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
134
675
209
708
update
compute-patches-variables\ncolor-patches
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
1067
374
1149
407
test connex
test-connex-components
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
1312
582
1385
615
nw effect
test-network-effect patches
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
185
427
333
460
collaboration-cost
collaboration-cost
0
0.001
5.0E-4
1e-6
1
NIL
HORIZONTAL

CHOOSER
139
69
231
114
setup-type
setup-type
"random" "from-file" "gis-synthetic" "gis"
2

SLIDER
7
582
152
615
ext-growth-factor
ext-growth-factor
0
20
1
0.1
1
NIL
HORIZONTAL

BUTTON
475
532
530
565
go
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

SWITCH
5
546
151
579
with-externalities?
with-externalities?
1
1
-1000

BUTTON
934
371
1026
404
construct
if mouse-down? [\n  if length to-construct < 2[\n    set to-construct lput (list mouse-xcor mouse-ycor) to-construct\n  ]\n  if length to-construct = 2[\n    construct-infrastructure (list to-construct) save-nw-config\n    compute-patches-variables\n    update-display\n    set to-construct []\n    verbose (word \"mean-travel-distance : \" mean-travel-distance)\n    stop\n  ]\n  wait 0.2\n  \n]
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
6
614
119
647
ext-employments-proportion-of-max
ext-employments-proportion-of-max
0
5
3
0.1
1
NIL
HORIZONTAL

SLIDER
0
270
177
303
gamma-cobb-douglas-e
gamma-cobb-douglas-e
0
1
0.8
0.05
1
NIL
HORIZONTAL

TEXTBOX
11
651
161
669
Display
11
0.0
1

BUTTON
406
568
469
601
NIL
luti
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
994
241
1154
361
externalities
NIL
NIL
0.0
2.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot externality-employments"

SLIDER
185
309
335
342
infra-snapping-tolerance
infra-snapping-tolerance
0
10
2
1
1
NIL
HORIZONTAL

SLIDER
185
462
335
495
construction-cost
construction-cost
0
1e-2
0.0010
1e-4
1
NIL
HORIZONTAL

SLIDER
185
498
334
531
beta-dc-game
beta-dc-game
0
5000
400
10
1
NIL
HORIZONTAL

PLOT
832
241
992
361
externality mean acc
NIL
NIL
0.0
2.0
0.0
0.1
true
false
"clear-plot" ""
PENS
"default" 1.0 0 -16777216 true "" "if external-facility != 0 [plot (mean [current-accessibility] of patches with [member? number external-facility]) / initial-max-acc]"

SLIDER
6
33
98
66
seed
seed
-100000
100000
0
1
1
NIL
HORIZONTAL

SLIDER
100
34
203
67
world-size
world-size
0
50
15
1
1
NIL
HORIZONTAL

SWITCH
235
75
339
108
initial-nw?
initial-nw?
0
1
-1000

SWITCH
160
184
338
217
setup-from-world-file?
setup-from-world-file?
1
1
-1000

INPUTBOX
209
10
366
70
conf-file
setup/conf/synth_nonw.conf
1
0
String

PLOT
1154
10
1322
154
morphology
NIL
NIL
0.0
0.1
0.0
0.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy moran-actives slope-actives"

SWITCH
186
532
328
565
evolve-network?
evolve-network?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

MetropolSim 3.0

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

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

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
NetLogo 5.1.0
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
