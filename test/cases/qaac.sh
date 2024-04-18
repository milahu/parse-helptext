#!/usr/bin/env bash

# set default values
positional_args=()
__help=false # Show help.
__formats=false # Show available AAC formats and exit
__abr=() # AAC ABR mode / bitrate
__tvbr=() # AAC True VBR mode / quality [0-127]
__cvbr=() # AAC Constrained VBR mode / bitrate
__cbr=() # AAC CBR mode / bitrate
__he=false # HE AAC mode (TVBR is not available)
__quality=() # AAC encoding Quality [0-2]
__adts=false # ADTS output (AAC only)
__no_smart_padding=false # Don't apply smart padding for gapless playback.
_d=() # Output directory. Default is current working dir.
__check=false # Show library versions and exit.
__alac=false # ALAC encoding mode
__decode=false # Decode to a WAV file.
__caf=false # Output to CAF file instead of M4A/WAV/AAC.
__play=false # Decode to a WaveOut device (playback).
__rate=() # keep: output sampling rate will be same as input
__lowpass=() # Specify lowpass filter cut-off frequency in Hz.
__bits_per_sample=() # Bits per sample of output (for WAV/ALAC only)
__no_dither=false # Turn off dither when quantizing to lower bit depth.
__peak=false # Scan + print peak (don't generate output file).
__gain=() # Adjust gain by f dB.
__normalize=false # Normalize (works in two pass. can generate HUGE
__drc=() # Dynamic range compression.
__limiter=false # Apply smart limiter that softly clips portions
__start=() # Specify start point of the input.
__end=() # Specify end point of the input (exclusive).
__delay=() # Same as --start, with the sign reversed.
__no_delay=false # Compensate encoder delay by prepending 960 samples
__num_priming=() # (Experimental). Set arbitrary number of priming
__gapless_mode=() # Encoder delay signaling for gapless playback.
__matrix_preset=() # Specify user defined preset for matrix mixer.
__matrix_file=() # Matrix file for remix.
__no_matrix_normalize=false # Don't automatically normalize(scale) matrix
__chanmap=() # Rearrange input channels to the specified order.
__chanmask=() # Force input channel mask(bitmap).
__no_optimize=false # Don't optimize MP4 container after encoding.
__tmpdir=() # Specify temporary directory. Default is %TMP%
__silent=false # Suppress console messages.
__verbose=false # More verbose console messages.
__ignorelength=false # Assume WAV input and ignore the data chunk length.
__threading=false # Enable multi-threading.
__nice=false # Give lower process priority.
__sort_args=false # Sort filenames given by command line arguments.
__text_codepage=() # Specify text code page of cuesheet/chapter/lyrics.
__stat=false # Save bitrate statistics into file.
__log=() # Output message to file.
__fname_from_tag=false # Generate filename based on metadata of input.
__fname_format=() # Format string for output filename.
_o=() # Specify output filename
__concat=false # Encodes whole inputs into a single file.
__cue_tracks=() # Limit extraction to specified tracks.
__raw=false # Raw PCM input.
__raw_channels=() # Number of channels, default 2.
__raw_rate=() # Sample rate, default 44100.
__raw_format=() # Sample format, default S16L.
__native_resampler=() # Arguments followed by '=' are optional.
__title=() # 
__artist=() # 
__band=() # This means "Album Artist".
__album=() # 
__grouping=() # 
__composer=() # 
__comment=() # 
__genre=() # 
__date=() # 
__track=() # 
__disk=() # 
__compilation=() # By default, iTunes compilation flag is not set.
__lyrics=() # 
__artwork=() # 
__artwork_size=() # Specify maximum width or height of artwork in pixels.
__copy_artwork=false # Copy front cover art(APIC:type 3) from the source.
__chapter=() # Set chapter from file.
__tag=() # Set iTunes pre-defined tag with fourcc key
__tag_from_file=() # Same as above, but value is read from file.
__long_tag=() # Set long tag (iTunes custom metadata) with

# parse args
for ((i=1;i<=$#;i++)); do a="${!i}"; case "$a" in
  -h|--help) __help=true; continue;;
  --formats) __formats=true; continue;;
  -a|--abr) : $((i++)); __abr+=("${!i}"); continue;;
  -V|--tvbr) : $((i++)); __tvbr+=("${!i}"); continue;;
  -v|--cvbr) : $((i++)); __cvbr+=("${!i}"); continue;;
  -c|--cbr) : $((i++)); __cbr+=("${!i}"); continue;;
  --he) __he=true; continue;;
  -q|--quality) : $((i++)); __quality+=("${!i}"); continue;;
  --adts) __adts=true; continue;;
  --no-smart-padding) __no_smart_padding=true; continue;;
  -d) : $((i++)); _d+=("${!i}"); continue;;
  --check) __check=true; continue;;
  -A|--alac) __alac=true; continue;;
  -D|--decode) __decode=true; continue;;
  --caf) __caf=true; continue;;
  --play) __play=true; continue;;
  -r|--rate) : $((i++)); __rate+=("${!i}"); continue;;
  --lowpass) : $((i++)); __lowpass+=("${!i}"); continue;;
  -b|--bits-per-sample) : $((i++)); __bits_per_sample+=("${!i}"); continue;;
  --no-dither) __no_dither=true; continue;;
  --peak) __peak=true; continue;;
  --gain) : $((i++)); __gain+=("${!i}"); continue;;
  -N|--normalize) __normalize=true; continue;;
  --drc) : $((i++)); __drc+=("${!i}"); continue;;
  --limiter) __limiter=true; continue;;
  --start) : $((i++)); __start+=("${!i}"); continue;;
  --end) : $((i++)); __end+=("${!i}"); continue;;
  --delay) : $((i++)); __delay+=("${!i}"); continue;;
  --no-delay) __no_delay=true; continue;;
  --num-priming) : $((i++)); __num_priming+=("${!i}"); continue;;
  --gapless-mode) : $((i++)); __gapless_mode+=("${!i}"); continue;;
  --matrix-preset) : $((i++)); __matrix_preset+=("${!i}"); continue;;
  --matrix-file) : $((i++)); __matrix_file+=("${!i}"); continue;;
  --no-matrix-normalize) __no_matrix_normalize=true; continue;;
  --chanmap) : $((i++)); __chanmap+=("${!i}"); continue;;
  --chanmask) : $((i++)); __chanmask+=("${!i}"); continue;;
  --no-optimize) __no_optimize=true; continue;;
  --tmpdir) : $((i++)); __tmpdir+=("${!i}"); continue;;
  -s|--silent) __silent=true; continue;;
  --verbose) __verbose=true; continue;;
  -i|--ignorelength) __ignorelength=true; continue;;
  --threading) __threading=true; continue;;
  -n|--nice) __nice=true; continue;;
  --sort-args) __sort_args=true; continue;;
  --text-codepage) : $((i++)); __text_codepage+=("${!i}"); continue;;
  -S|--stat) __stat=true; continue;;
  --log) : $((i++)); __log+=("${!i}"); continue;;
  --fname-from-tag) __fname_from_tag=true; continue;;
  --fname-format) : $((i++)); __fname_format+=("${!i}"); continue;;
  -o) : $((i++)); _o+=("${!i}"); continue;;
  --concat) __concat=true; continue;;
  --cue-tracks) : $((i++)); __cue_tracks+=("${!i}"); continue;;
  -R|--raw) __raw=true; continue;;
  --raw-channels) : $((i++)); __raw_channels+=("${!i}"); continue;;
  --raw-rate) : $((i++)); __raw_rate+=("${!i}"); continue;;
  --raw-format) : $((i++)); __raw_format+=("${!i}"); continue;;
  --native-resampler) : $((i++)); __native_resampler+=("${!i}"); continue;;
  --title) : $((i++)); __title+=("${!i}"); continue;;
  --artist) : $((i++)); __artist+=("${!i}"); continue;;
  --band) : $((i++)); __band+=("${!i}"); continue;;
  --album) : $((i++)); __album+=("${!i}"); continue;;
  --grouping) : $((i++)); __grouping+=("${!i}"); continue;;
  --composer) : $((i++)); __composer+=("${!i}"); continue;;
  --comment) : $((i++)); __comment+=("${!i}"); continue;;
  --genre) : $((i++)); __genre+=("${!i}"); continue;;
  --date) : $((i++)); __date+=("${!i}"); continue;;
  --track) : $((i++)); __track+=("${!i}"); continue;;
  --disk) : $((i++)); __disk+=("${!i}"); continue;;
  --compilation) : $((i++)); __compilation+=("${!i}"); continue;;
  --lyrics) : $((i++)); __lyrics+=("${!i}"); continue;;
  --artwork) : $((i++)); __artwork+=("${!i}"); continue;;
  --artwork-size) : $((i++)); __artwork_size+=("${!i}"); continue;;
  --copy-artwork) __copy_artwork=true; continue;;
  --chapter) : $((i++)); __chapter+=("${!i}"); continue;;
  --tag) : $((i++)); __tag+=("${!i}"); continue;;
  --tag-from-file) : $((i++)); __tag_from_file+=("${!i}"); continue;;
  --long-tag) : $((i++)); __long_tag+=("${!i}"); continue;;
  *) positional_args+=("$a");;
esac; done

# print parsed values
if true; then
  for i in "${!positional_args[@]}"; do v="${positional_args[$i]}"; echo "positional_args $i: ${v@Q}"; done
  echo "__help: $__help"
  echo "__formats: $__formats"
  for i in "${!__abr[@]}"; do v="${__abr[$i]}"; echo "__abr $i: ${v@Q}"; done
  for i in "${!__tvbr[@]}"; do v="${__tvbr[$i]}"; echo "__tvbr $i: ${v@Q}"; done
  for i in "${!__cvbr[@]}"; do v="${__cvbr[$i]}"; echo "__cvbr $i: ${v@Q}"; done
  for i in "${!__cbr[@]}"; do v="${__cbr[$i]}"; echo "__cbr $i: ${v@Q}"; done
  echo "__he: $__he"
  for i in "${!__quality[@]}"; do v="${__quality[$i]}"; echo "__quality $i: ${v@Q}"; done
  echo "__adts: $__adts"
  echo "__no_smart_padding: $__no_smart_padding"
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
  for i in "${!__native_resampler[@]}"; do v="${__native_resampler[$i]}"; echo "__native_resampler $i: ${v@Q}"; done
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

