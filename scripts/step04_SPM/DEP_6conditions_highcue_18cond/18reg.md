# Regressors

Per run, 22 epochs were modeled: 2 cue epochs, 18 stimulus epochs, 2 rating epochs

## 2 cue epoch

- high cue
- low cue

## 18 Stimulus epoch

3 onsets (ramp up, plateau, ramp down)
x 6 conditions (2 cue x 3 intensity)

- cue H stim H rampup
- cue H stim H plateau
- cue H stim H rampdown
- cue H stim M rampup
- cue H stim M plateau
- cue H stim M rampdown

- cue H stim L rampup
- cue H stim L plateau
- cue H stim L rampdown

- cue L stim H rampup
- cue L stim H plateau
- cue L stim H rampdown

- cue L stim M rampup
- cue L stim M plateau
- cue L stim M rampdown

- cue L stim L rampup
- cue L stim L plateau
- cue L stim L rampdown

NOTE: Duration of each event:

- rampup: as calculated by TTL signals (TTL2 - TTL1)
- plateau: 5 sec for pain, vicarious, cognitive runs
- rampdown: as calculated by TTL signals (TTL4 - TTL 3)

## 2 rating epoch

- expectation rating
- outcome rating
- NOTE: reaction time of the rating response was entered as duration for HRF estimation.

# Contrasts

- cue_P: cue epoch, pain runs > vicarious & cognitive runs
- cue_V: cue epoch, vicarious runs > pain & cognitive runs
- cue_C: cue epoch, cognitive runs > pain & vicarious runs
- cue_G: cue epoch, pain & vicarious & cognitive runs
- stim_P: stimulus epoch, pain runs > vicarious & cognitive runs
- stim_V: stimulus epoch, vicarious runs > pain & cognitive runs
- stim_C: stimulus epoch, cognitive runs > pain & vicarious runs
- stim_G: stimulus epoch, pain & vicarious & cognitive runs
- motor: expectation and outcome rating epoch
- simple_cue_P: cue epoch, pain runs > baseline
- simple_cue_V: cue epoch, vicarious runs > baseline
- simple_cue_C: cue epoch, cognitive runs > baseline
- simple_stim_P: stimulus epoch, pain runs > baseline
- simple_stim_V: stimulus epoch, vicarious runs > baseline
- simple_stim_C: stimulus epoch, cognitive runs > baseline
