#!/usr/bin/env bash

# set default values
__=() # positional args
__help=0 # Show help.
__formats=0 # Show available AAC formats and exit
__abr=() # AAC ABR mode / bitrate
__tvbr=() # AAC True VBR mode / quality [0-127]
__cvbr=() # AAC Constrained VBR mode / bitrate
__cbr=() # AAC CBR mode / bitrate
__he=0 # HE AAC mode (TVBR is not available)
__quality=() # AAC encoding Quality [0-2]
__adts=0 # ADTS output (AAC only)
__no_smart_padding=0 # Don't apply smart padding for gapless playback.
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
__native_resampler=() # Arguments followed by '=' are optional.
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
A=()
while [ ${#s[@]} != 0 ]; do a="${s[0]}"; s=("${s[@]:1}"); case "$a" in
  -h|--help) : $((__help++)); A+=("$a"); continue;;
  --formats) : $((__formats++)); A+=("$a"); continue;;
  -a|--abr) v; __abr+=("$v"); A+=("$a" "$v"); continue;;
  -V|--tvbr) v; __tvbr+=("$v"); A+=("$a" "$v"); continue;;
  -v|--cvbr) v; __cvbr+=("$v"); A+=("$a" "$v"); continue;;
  -c|--cbr) v; __cbr+=("$v"); A+=("$a" "$v"); continue;;
  --he) : $((__he++)); A+=("$a"); continue;;
  -q|--quality) v; __quality+=("$v"); A+=("$a" "$v"); continue;;
  --adts) : $((__adts++)); A+=("$a"); continue;;
  --no-smart-padding) : $((__no_smart_padding++)); A+=("$a"); continue;;
  -d) v; _d+=("$v"); A+=("$a" "$v"); continue;;
  --check) : $((__check++)); A+=("$a"); continue;;
  -A|--alac) : $((__alac++)); A+=("$a"); continue;;
  -D|--decode) : $((__decode++)); A+=("$a"); continue;;
  --caf) : $((__caf++)); A+=("$a"); continue;;
  --play) : $((__play++)); A+=("$a"); continue;;
  -r|--rate) v; __rate+=("$v"); A+=("$a" "$v"); continue;;
  --lowpass) v; __lowpass+=("$v"); A+=("$a" "$v"); continue;;
  -b|--bits-per-sample) v; __bits_per_sample+=("$v"); A+=("$a" "$v"); continue;;
  --no-dither) : $((__no_dither++)); A+=("$a"); continue;;
  --peak) : $((__peak++)); A+=("$a"); continue;;
  --gain) v; __gain+=("$v"); A+=("$a" "$v"); continue;;
  -N|--normalize) : $((__normalize++)); A+=("$a"); continue;;
  --drc) v; __drc+=("$v"); A+=("$a" "$v"); continue;;
  --limiter) : $((__limiter++)); A+=("$a"); continue;;
  --start) v; __start+=("$v"); A+=("$a" "$v"); continue;;
  --end) v; __end+=("$v"); A+=("$a" "$v"); continue;;
  --delay) v; __delay+=("$v"); A+=("$a" "$v"); continue;;
  --no-delay) : $((__no_delay++)); A+=("$a"); continue;;
  --num-priming) v; __num_priming+=("$v"); A+=("$a" "$v"); continue;;
  --gapless-mode) v; __gapless_mode+=("$v"); A+=("$a" "$v"); continue;;
  --matrix-preset) v; __matrix_preset+=("$v"); A+=("$a" "$v"); continue;;
  --matrix-file) v; __matrix_file+=("$v"); A+=("$a" "$v"); continue;;
  --no-matrix-normalize) : $((__no_matrix_normalize++)); A+=("$a"); continue;;
  --chanmap) v; __chanmap+=("$v"); A+=("$a" "$v"); continue;;
  --chanmask) v; __chanmask+=("$v"); A+=("$a" "$v"); continue;;
  --no-optimize) : $((__no_optimize++)); A+=("$a"); continue;;
  --tmpdir) v; __tmpdir+=("$v"); A+=("$a" "$v"); continue;;
  -s|--silent) : $((__silent++)); A+=("$a"); continue;;
  --verbose) : $((__verbose++)); A+=("$a"); continue;;
  -i|--ignorelength) : $((__ignorelength++)); A+=("$a"); continue;;
  --threading) : $((__threading++)); A+=("$a"); continue;;
  -n|--nice) : $((__nice++)); A+=("$a"); continue;;
  --sort-args) : $((__sort_args++)); A+=("$a"); continue;;
  --text-codepage) v; __text_codepage+=("$v"); A+=("$a" "$v"); continue;;
  -S|--stat) : $((__stat++)); A+=("$a"); continue;;
  --log) v; __log+=("$v"); A+=("$a" "$v"); continue;;
  --fname-from-tag) : $((__fname_from_tag++)); A+=("$a"); continue;;
  --fname-format) v; __fname_format+=("$v"); A+=("$a" "$v"); continue;;
  -o) v; _o+=("$v"); A+=("$a" "$v"); continue;;
  --concat) : $((__concat++)); A+=("$a"); continue;;
  --cue-tracks) v; __cue_tracks+=("$v"); A+=("$a" "$v"); continue;;
  -R|--raw) : $((__raw++)); A+=("$a"); continue;;
  --raw-channels) v; __raw_channels+=("$v"); A+=("$a" "$v"); continue;;
  --raw-rate) v; __raw_rate+=("$v"); A+=("$a" "$v"); continue;;
  --raw-format) v; __raw_format+=("$v"); A+=("$a" "$v"); continue;;
  --native-resampler) v; __native_resampler+=("$v"); A+=("$a" "$v"); continue;;
  --title) v; __title+=("$v"); A+=("$a" "$v"); continue;;
  --artist) v; __artist+=("$v"); A+=("$a" "$v"); continue;;
  --band) v; __band+=("$v"); A+=("$a" "$v"); continue;;
  --album) v; __album+=("$v"); A+=("$a" "$v"); continue;;
  --grouping) v; __grouping+=("$v"); A+=("$a" "$v"); continue;;
  --composer) v; __composer+=("$v"); A+=("$a" "$v"); continue;;
  --comment) v; __comment+=("$v"); A+=("$a" "$v"); continue;;
  --genre) v; __genre+=("$v"); A+=("$a" "$v"); continue;;
  --date) v; __date+=("$v"); A+=("$a" "$v"); continue;;
  --track) v; __track+=("$v"); A+=("$a" "$v"); continue;;
  --disk) v; __disk+=("$v"); A+=("$a" "$v"); continue;;
  --compilation) v; __compilation+=("$v"); A+=("$a" "$v"); continue;;
  --lyrics) v; __lyrics+=("$v"); A+=("$a" "$v"); continue;;
  --artwork) v; __artwork+=("$v"); A+=("$a" "$v"); continue;;
  --artwork-size) v; __artwork_size+=("$v"); A+=("$a" "$v"); continue;;
  --copy-artwork) : $((__copy_artwork++)); A+=("$a"); continue;;
  --chapter) v; __chapter+=("$v"); A+=("$a" "$v"); continue;;
  --tag) v; __tag+=("$v"); A+=("$a" "$v"); continue;;
  --tag-from-file) v; __tag_from_file+=("$v"); A+=("$a" "$v"); continue;;
  --long-tag) v; __long_tag+=("$v"); A+=("$a" "$v"); continue;;
  -[^-]*)
    p=()
    for ((i=1;i<${#a};i++)); do case "${a:$i:1}" in
      [ADNsinSR]) p+=("-${a:$i:1}"); continue;;
      [aVvcqdrbo]) p+=("-${a:$i:1}" "${a:$((i+1))}"); break;;
      *) echo "error: failed to parse argument ${a@Q}" >&2; exit 1;;
    esac; done;
    s=("${p[@]}" "${s[@]}"); p=; continue;;
  --) __+=("${s[@]}"); A+=("${s[@]}"); s=; break;;
  *) __+=("$a"); A+=("$a");;
esac; done

# print parsed values
if true; then
  echo "#A: ${#A[@]}"
  echo -n 'A:'; for a in "${A[@]}"; do echo -n " ${a@Q}"; done; echo
  for i in "${!__[@]}"; do v="${__[$i]}"; echo "__ $i: ${v@Q}"; done
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

