# parse-helptext

parse getopt-style help texts from `someprogram --help`

return one of

- json
- argument parser for bash.
  useful to write program wrappers in bash:
  modify arguments,
  run the program in a sandbox (bubblewrap),
  run code before and after the program,
  trap exit to handle program crashes,
  ...



## usage

see [test/update.sh](test/update.sh)



## examples

see [test/cases/](test/cases/)



## similar projects



### helptext parsers

- [RobSis/zsh-completion-generator](https://github.com/RobSis/zsh-completion-generator) - parse help texts and generate zsh shell completions



### argparse in bash

- [matejak/argbash](https://github.com/matejak/argbash) - generate argument parsers for bash
- [ko1nksm/getoptions](https://github.com/ko1nksm/getoptions) - An elegant option/argument parser for shell scripts (full support for bash and all POSIX shells)
- [Anvil/bash-argsparse](https://github.com/Anvil/bash-argsparse) - An high level argument parsing library for bash
- [agriffis/pure-getopt](https://github.com/agriffis/pure-getopt) - getopt in pure Bash
- [moebrowne/bash-argument-parser](https://github.com/moebrowne/bash-argument-parser) - BASH Argument Parser allows for easy access to command line arguments
- [reconquest/opts.bash](https://github.com/reconquest/opts.bash) - Missing very simple option parser for bash



## todo

- write an actual parser for helptext: pyparsing, tree-sitter, ...



## licence

[GNU GPLv2](LICENSE)
