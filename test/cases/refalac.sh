#!/usr/bin/env bash

# set default values
positional_args=()
__help=0 # Show help.
__fast=0 # Fast stereo encoding mode.
_d=() # Output directory. Default is current working dir.
__check=0 # Show library versions and exit.
__alac=0 # ALAC encoding mode
__decode=0 # Decode to a WAV file.
__caf=0 # Output to CAF file instead of M4A/WAV/AAC.
__play=0 # Decode to a WaveOut device (playback).
__rate=() # keep: output sampling rate will be same as input
__lowpass=() # Specify lowpass filter cut-off frequency in Hz.
__bits_per_sample=() # Bits per sample of output (for WAV/ALAC only)
__no_dither=0 # Turn off dither when quantizing to lower bit depth.
__peak=0 # Scan + print peak (don't generate output file).
__gain=() # Adjust gain by f dB.
__normalize=0 # Normalize (works in two pass. can generate HUGE
__drc=() # Dynamic range compression.
__limiter=0 # Apply smart limiter that softly clips portions
__start=() # Specify start point of the input.
__end=() # Specify end point of the input (exclusive).
__delay=() # Same as --start, with the sign reversed.
__no_delay=0 # Compensate encoder delay by prepending 960 samples
__num_priming=() # (Experimental). Set arbitrary number of priming
__gapless_mode=() # Encoder delay signaling for gapless playback.
__matrix_preset=() # Specify user defined preset for matrix mixer.
__matrix_file=() # Matrix file for remix.
__no_matrix_normalize=0 # Don't automatically normalize(scale) matrix
__chanmap=() # Rearrange input channels to the specified order.
__chanmask=() # Force input channel mask(bitmap).
__no_optimize=0 # Don't optimize MP4 container after encoding.
__tmpdir=() # Specify temporary directory. Default is %TMP%
__silent=0 # Suppress console messages.
__verbose=0 # More verbose console messages.
__ignorelength=0 # Assume WAV input and ignore the data chunk length.
__threading=0 # Enable multi-threading.
__nice=0 # Give lower process priority.
__sort_args=0 # Sort filenames given by command line arguments.
__text_codepage=() # Specify text code page of cuesheet/chapter/lyrics.
__stat=0 # Save bitrate statistics into file.
__log=() # Output message to file.
__fname_from_tag=0 # Generate filename based on metadata of input.
__fname_format=() # Format string for output filename.
_o=() # Specify output filename
__concat=0 # Encodes whole inputs into a single file.
__cue_tracks=() # Limit extraction to specified tracks.
__raw=0 # Raw PCM input.
__raw_channels=() # Number of channels, default 2.
__raw_rate=() # Sample rate, default 44100.
__raw_format=() # Sample format, default S16L.
__title=()
__artist=()
__band=() # This means "Album Artist".
__album=()
__grouping=()
__composer=()
__comment=()
__genre=()
__date=()
__track=()
__disk=()
__compilation=() # By default, iTunes compilation flag is not set.
__lyrics=()
__artwork=()
__artwork_size=() # Specify maximum width or height of artwork in pixels.
__copy_artwork=0 # Copy front cover art(APIC:type 3) from the source.
__chapter=() # Set chapter from file.
__tag=() # Set iTunes pre-defined tag with fourcc key
__tag_from_file=() # Same as above, but value is read from file.
__long_tag=() # Set long tag (iTunes custom metadata) with

# parse args
v(){ if [ -n "$s" ]; then v="${s[0]}"; s=("${s[@]:1}"); return; fi; echo "error: missing value for argument $a" >&2; exit 1; }
s=("$@")
while [ ${#s[@]} != 0 ]; do a="${s[0]}"; s=("${s[@]:1}"); case "$a" in
  -h|--help) : $((__help++)); continue;;
  --fast) : $((__fast++)); continue;;
  -d) v; _d+=("$v"); continue;;
  --check) : $((__check++)); continue;;
  -A|--alac) : $((__alac++)); continue;;
  -D|--decode) : $((__decode++)); continue;;
  --caf) : $((__caf++)); continue;;
  --play) : $((__play++)); continue;;
  -r|--rate) v; __rate+=("$v"); continue;;
  --lowpass) v; __lowpass+=("$v"); continue;;
  -b|--bits-per-sample) v; __bits_per_sample+=("$v"); continue;;
  --no-dither) : $((__no_dither++)); continue;;
  --peak) : $((__peak++)); continue;;
  --gain) v; __gain+=("$v"); continue;;
  -N|--normalize) : $((__normalize++)); continue;;
  --drc) v; __drc+=("$v"); continue;;
  --limiter) : $((__limiter++)); continue;;
  --start) v; __start+=("$v"); continue;;
  --end) v; __end+=("$v"); continue;;
  --delay) v; __delay+=("$v"); continue;;
  --no-delay) : $((__no_delay++)); continue;;
  --num-priming) v; __num_priming+=("$v"); continue;;
  --gapless-mode) v; __gapless_mode+=("$v"); continue;;
  --matrix-preset) v; __matrix_preset+=("$v"); continue;;
  --matrix-file) v; __matrix_file+=("$v"); continue;;
  --no-matrix-normalize) : $((__no_matrix_normalize++)); continue;;
  --chanmap) v; __chanmap+=("$v"); continue;;
  --chanmask) v; __chanmask+=("$v"); continue;;
  --no-optimize) : $((__no_optimize++)); continue;;
  --tmpdir) v; __tmpdir+=("$v"); continue;;
  -s|--silent) : $((__silent++)); continue;;
  --verbose) : $((__verbose++)); continue;;
  -i|--ignorelength) : $((__ignorelength++)); continue;;
  --threading) : $((__threading++)); continue;;
  -n|--nice) : $((__nice++)); continue;;
  --sort-args) : $((__sort_args++)); continue;;
  --text-codepage) v; __text_codepage+=("$v"); continue;;
  -S|--stat) : $((__stat++)); continue;;
  --log) v; __log+=("$v"); continue;;
  --fname-from-tag) : $((__fname_from_tag++)); continue;;
  --fname-format) v; __fname_format+=("$v"); continue;;
  -o) v; _o+=("$v"); continue;;
  --concat) : $((__concat++)); continue;;
  --cue-tracks) v; __cue_tracks+=("$v"); continue;;
  -R|--raw) : $((__raw++)); continue;;
  --raw-channels) v; __raw_channels+=("$v"); continue;;
  --raw-rate) v; __raw_rate+=("$v"); continue;;
  --raw-format) v; __raw_format+=("$v"); continue;;
  --title) v; __title+=("$v"); continue;;
  --artist) v; __artist+=("$v"); continue;;
  --band) v; __band+=("$v"); continue;;
  --album) v; __album+=("$v"); continue;;
  --grouping) v; __grouping+=("$v"); continue;;
  --composer) v; __composer+=("$v"); continue;;
  --comment) v; __comment+=("$v"); continue;;
  --genre) v; __genre+=("$v"); continue;;
  --date) v; __date+=("$v"); continue;;
  --track) v; __track+=("$v"); continue;;
  --disk) v; __disk+=("$v"); continue;;
  --compilation) v; __compilation+=("$v"); continue;;
  --lyrics) v; __lyrics+=("$v"); continue;;
  --artwork) v; __artwork+=("$v"); continue;;
  --artwork-size) v; __artwork_size+=("$v"); continue;;
  --copy-artwork) : $((__copy_artwork++)); continue;;
  --chapter) v; __chapter+=("$v"); continue;;
  --tag) v; __tag+=("$v"); continue;;
  --tag-from-file) v; __tag_from_file+=("$v"); continue;;
  --long-tag) v; __long_tag+=("$v"); continue;;
  -[^-]*) p=(); for ((i=1;i<${#a};i++)); do p+=("-${a:$i:1}"); done; s=("${p[@]}" "${s[@]}"); p=; continue;;
  --) positional_args+=("${s[@]}"); s=; break;;
  *) positional_args+=("$a");;
esac; done

# print parsed values
if true; then
  for i in "${!positional_args[@]}"; do v="${positional_args[$i]}"; echo "positional_args $i: ${v@Q}"; done
  echo "__help: $__help"
  echo "__fast: $__fast"
  for i in "${!_d[@]}"; do v="${_d[$i]}"; echo "_d $i: ${v@Q}"; done
  echo "__check: $__check"
  echo "__alac: $__alac"
  echo "__decode: $__decode"
  echo "__caf: $__caf"
  echo "__play: $__play"
  for i in "${!__rate[@]}"; do v="${__rate[$i]}"; echo "__rate $i: ${v@Q}"; done
  for i in "${!__lowpass[@]}"; do v="${__lowpass[$i]}"; echo "__lowpass $i: ${v@Q}"; done
  for i in "${!__bits_per_sample[@]}"; do v="${__bits_per_sample[$i]}"; echo "__bits_per_sample $i: ${v@Q}"; done
  echo "__no_dither: $__no_dither"
  echo "__peak: $__peak"
  for i in "${!__gain[@]}"; do v="${__gain[$i]}"; echo "__gain $i: ${v@Q}"; done
  echo "__normalize: $__normalize"
  for i in "${!__drc[@]}"; do v="${__drc[$i]}"; echo "__drc $i: ${v@Q}"; done
  echo "__limiter: $__limiter"
  for i in "${!__start[@]}"; do v="${__start[$i]}"; echo "__start $i: ${v@Q}"; done
  for i in "${!__end[@]}"; do v="${__end[$i]}"; echo "__end $i: ${v@Q}"; done
  for i in "${!__delay[@]}"; do v="${__delay[$i]}"; echo "__delay $i: ${v@Q}"; done
  echo "__no_delay: $__no_delay"
  for i in "${!__num_priming[@]}"; do v="${__num_priming[$i]}"; echo "__num_priming $i: ${v@Q}"; done
  for i in "${!__gapless_mode[@]}"; do v="${__gapless_mode[$i]}"; echo "__gapless_mode $i: ${v@Q}"; done
  for i in "${!__matrix_preset[@]}"; do v="${__matrix_preset[$i]}"; echo "__matrix_preset $i: ${v@Q}"; done
  for i in "${!__matrix_file[@]}"; do v="${__matrix_file[$i]}"; echo "__matrix_file $i: ${v@Q}"; done
  echo "__no_matrix_normalize: $__no_matrix_normalize"
  for i in "${!__chanmap[@]}"; do v="${__chanmap[$i]}"; echo "__chanmap $i: ${v@Q}"; done
  for i in "${!__chanmask[@]}"; do v="${__chanmask[$i]}"; echo "__chanmask $i: ${v@Q}"; done
  echo "__no_optimize: $__no_optimize"
  for i in "${!__tmpdir[@]}"; do v="${__tmpdir[$i]}"; echo "__tmpdir $i: ${v@Q}"; done
  echo "__silent: $__silent"
  echo "__verbose: $__verbose"
  echo "__ignorelength: $__ignorelength"
  echo "__threading: $__threading"
  echo "__nice: $__nice"
  echo "__sort_args: $__sort_args"
  for i in "${!__text_codepage[@]}"; do v="${__text_codepage[$i]}"; echo "__text_codepage $i: ${v@Q}"; done
  echo "__stat: $__stat"
  for i in "${!__log[@]}"; do v="${__log[$i]}"; echo "__log $i: ${v@Q}"; done
  echo "__fname_from_tag: $__fname_from_tag"
  for i in "${!__fname_format[@]}"; do v="${__fname_format[$i]}"; echo "__fname_format $i: ${v@Q}"; done
  for i in "${!_o[@]}"; do v="${_o[$i]}"; echo "_o $i: ${v@Q}"; done
  echo "__concat: $__concat"
  for i in "${!__cue_tracks[@]}"; do v="${__cue_tracks[$i]}"; echo "__cue_tracks $i: ${v@Q}"; done
  echo "__raw: $__raw"
  for i in "${!__raw_channels[@]}"; do v="${__raw_channels[$i]}"; echo "__raw_channels $i: ${v@Q}"; done
  for i in "${!__raw_rate[@]}"; do v="${__raw_rate[$i]}"; echo "__raw_rate $i: ${v@Q}"; done
  for i in "${!__raw_format[@]}"; do v="${__raw_format[$i]}"; echo "__raw_format $i: ${v@Q}"; done
  for i in "${!__title[@]}"; do v="${__title[$i]}"; echo "__title $i: ${v@Q}"; done
  for i in "${!__artist[@]}"; do v="${__artist[$i]}"; echo "__artist $i: ${v@Q}"; done
  for i in "${!__band[@]}"; do v="${__band[$i]}"; echo "__band $i: ${v@Q}"; done
  for i in "${!__album[@]}"; do v="${__album[$i]}"; echo "__album $i: ${v@Q}"; done
  for i in "${!__grouping[@]}"; do v="${__grouping[$i]}"; echo "__grouping $i: ${v@Q}"; done
  for i in "${!__composer[@]}"; do v="${__composer[$i]}"; echo "__composer $i: ${v@Q}"; done
  for i in "${!__comment[@]}"; do v="${__comment[$i]}"; echo "__comment $i: ${v@Q}"; done
  for i in "${!__genre[@]}"; do v="${__genre[$i]}"; echo "__genre $i: ${v@Q}"; done
  for i in "${!__date[@]}"; do v="${__date[$i]}"; echo "__date $i: ${v@Q}"; done
  for i in "${!__track[@]}"; do v="${__track[$i]}"; echo "__track $i: ${v@Q}"; done
  for i in "${!__disk[@]}"; do v="${__disk[$i]}"; echo "__disk $i: ${v@Q}"; done
  for i in "${!__compilation[@]}"; do v="${__compilation[$i]}"; echo "__compilation $i: ${v@Q}"; done
  for i in "${!__lyrics[@]}"; do v="${__lyrics[$i]}"; echo "__lyrics $i: ${v@Q}"; done
  for i in "${!__artwork[@]}"; do v="${__artwork[$i]}"; echo "__artwork $i: ${v@Q}"; done
  for i in "${!__artwork_size[@]}"; do v="${__artwork_size[$i]}"; echo "__artwork_size $i: ${v@Q}"; done
  echo "__copy_artwork: $__copy_artwork"
  for i in "${!__chapter[@]}"; do v="${__chapter[$i]}"; echo "__chapter $i: ${v@Q}"; done
  for i in "${!__tag[@]}"; do v="${__tag[$i]}"; echo "__tag $i: ${v@Q}"; done
  for i in "${!__tag_from_file[@]}"; do v="${__tag_from_file[$i]}"; echo "__tag_from_file $i: ${v@Q}"; done
  for i in "${!__long_tag[@]}"; do v="${__long_tag[$i]}"; echo "__long_tag $i: ${v@Q}"; done
fi

