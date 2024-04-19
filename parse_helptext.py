#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# Parse getopt-style help texts for options
# and generate zsh(1) completion function.
# http://github.com/RobSis/zsh-completion-generator

# Usage: program --help | ./help2comp.py program_name

import sys
import re
from string import Template
import io


URL = 'http://github.com/RobSis/zsh-completion-generator'
STRIP_CHARS = "\t\n\r,=" # dont strip spaces here

COMPLETE_FUNCTION_TEMPLATE = """
#compdef $program_name

# zsh completions for '$program_name'
# automatically generated with $url
local arguments

arguments=(
$argument_list
  '*:filename:_files'
)

_arguments -s $arguments
"""

ARGUMENT_TEMPLATE = """  {$opts}'[$description]$style'"""
SINGLE_ARGUMENT_TEMPLATE = """  '$opt[$description]$style'"""


def cut_option(line):
    """
    Cuts out the first option (short or long) and its argument.
    """
    line = line.strip() # strip spaces
    # TODO: dare to make it regex-free?
    newline = line.strip(STRIP_CHARS)
    opt = re.findall(r'^(-[a-zA-Z0-9\-]*[a-zA-Z0-9](?:(?: +|=)(?:<[^ ]+>|\[[^ ]+\])|\[=[^ ]+\])?)', line)
    #print("opt", repr(opt))
    if len(opt) > 0:
        newline = line.replace(opt[0], "", 1).strip(STRIP_CHARS)
        # return without parameter
        #print("opt newline", repr(newline))
        #print("opt 0 split", repr(re.split('[ [=]', opt[0], 1)))
        parts = re.split('(?:(\[)|=| +)', opt[0], 1) # capture [
        parts = [p for p in parts if p != None]
        if len(parts) > 1 and parts[1] == "[":
            parts = [parts[0], parts[1] + parts[2]]
        #print("parts", repr(parts))
        if len(parts) == 1:
            opt, var = parts[0], None
        elif len(parts) == 2:
            opt, var = parts
            if var[0] not in ("<", "["):
                # quickfix: ignore examples: --opt 123
                return newline, None, None
            if var[-1] not in (">", "]"):
                raise ValueError(f"failed to parse var from line: {repr(line)}. parts: {repr(parts)}")
        else:
            raise ValueError(f"failed to parse line: {repr(line)}. parts: {repr(parts)}")
        return newline, opt, var
    else:
        return newline, None, None


def parse_options(help_text):
    """
    Parses the options line by line.
    When description is missing and options are missing on
    consecutive line, link them together.
    """
    all_options = []
    previous_description_missing = False
    for line in help_text:
        line = line.strip(STRIP_CHARS)
        # " {0,5}": allow some indent before option, but not too much
        # to ignore examples in description
        if re.match(r'^ {0,5}--?[a-zA-Z0-9]+', line):  # starts with option
            previous_description_missing = False
            options = []
            var = None
            while True:
                line, opt, opt_var = cut_option(line)
                if opt is None:
                    break
                options.append(opt)
                if opt_var:
                    var = opt_var

            if (len(line) == 0):
                previous_description_missing = True

            options.append(var)
            options.append(line.strip()) # description
            all_options.append(options)
        elif previous_description_missing:
            #print(f"replacing missing previous description {repr(all_options[-1][-1])} with {repr(line.strip())}")
            all_options[-1][-1] = line.strip() # description
            previous_description_missing = False

    return all_options


def _escape(line):
    """
    Escape the syntax-breaking characters.
    """
    line = line.replace('[', r'\[').replace(']', r'\]')
    line = re.sub('\'', '', line)  # ' is unescapable afaik
    return line


def generate_argument_list(options):
    """
    Generate list of arguments from the template.
    """
    argument_list = []
    for opts in options:
        model = {}
        # remove unescapable chars.

        desc = list(_escape(opts[-1]))
        if len(desc) > 1 and desc[1].islower():
            desc[0] = desc[0].lower()
        model['description'] = "".join(desc)
        model['style'] = ""
        if (len(opts) > 2):
            model['opts'] = ",".join(opts[:-1])
            argument_list.append(Template(ARGUMENT_TEMPLATE).safe_substitute(model))
        elif (len(opts) == 2):
            model['opt'] = opts[0]
            argument_list.append(Template(SINGLE_ARGUMENT_TEMPLATE).safe_substitute(model))
        else:
            pass

    return "\n".join(argument_list)


def generate_completion_function(options, program_name):
    """
    Generate completion function from the template.
    """
    model = {}
    model['program_name'] = program_name
    model['argument_list'] = generate_argument_list(options)
    model['url'] = URL
    return Template(COMPLETE_FUNCTION_TEMPLATE).safe_substitute(model).strip()


def loop_options(options):
    for parts in options:
        #print("parts", repr(parts))
        desc = parts[-1]
        var = parts[-2]
        opts = [o for o in parts if o and o[0] == "-"]
        opt_name = opts[-1].replace("-", "_")
        yield opts, var, desc, opt_name


def generate_argparse_bash(options):

    # add missing help option
    has_help = False
    for opts, var, desc, opt_name in loop_options(options):
        if "--help" in opts:
            has_help = True
            break
    if not has_help:
        options = [["-h", "--help", None, "Show help."]] + options
    out = io.StringIO()
    def w(line=""):
        out.write(line + "\n")
    w("#!/usr/bin/env bash")
    w()
    # TODO handle joined short arguments: someprogram -vvv == someprogram -v -v -v
    w("# set default values")
    w("positional_args=()")
    for opts, var, desc, opt_name in loop_options(options):
        comment = f" # {desc}" if desc else ""
        if var == None:
            # boolean argument
            w(opt_name + "=0" + comment) # set default value: 0. count number of args
        else:
            # string argument
            w(opt_name + '=()' + comment) # set default value: empty array

    w()
    w("# parse args")

    # get value from stack
    out.write('v(){ ')
    out.write('if [ -n "$s" ]; then ')
    out.write('v="${s[0]}"; s=("${s[@]:1}"); ') # shift value from stack
    #out.write('echo "${s[0]}"; s=("${s[@]:1}"); ') # shift value from stack # no. echo is lossy
    out.write('return; ')
    out.write('fi; ')
    out.write('echo "error: missing value for argument $a" >&2; exit 1; ')
    out.write('}')
    w()

    w('s=("$@")') # stack
    out.write('while [ ${#s[@]} != 0 ]; do ')
    out.write('a="${s[0]}"; s=("${s[@]:1}"); ') # shift arg from stack
    out.write('case "$a" in')
    w()
    for opts, var, desc, opt_name in loop_options(options):
        out.write("  " + "|".join(opts) + ") ")
        if var == None:
            # boolean argument
            #out.write(opt_name + "=true; ") # set value
            out.write(": $((" + opt_name + "++)); ") # set value: increase by 1
        else:
            # string argument
            out.write('v; ')
            out.write(opt_name + '+=("$v"); ') # set value
            #out.write(opt_name + '+=("$(v)"); ') # set value # no. echo is lossy
        out.write("continue;;")
        w()

    # unshift args: expand concatenated short options
    # example: -vvv -> -v -v -v
    out.write('  ')
    out.write('-[^-]*) ')
    out.write('p=(); ') # pre_stack
    out.write('for ((i=1;i<${#a};i++)); do ')
    # arg2="${a:$i:1}"; echo "unshifting ${arg2@Q}"
    out.write('p+=("-${a:$i:1}"); ')
    out.write('done; ')
    out.write('s=("${p[@]}" "${s[@]}"); ') # unshift args to stack
    out.write('p=; ')
    out.write('continue;;')
    w()

    # all following args are positional args
    out.write('  --) ')
    out.write('positional_args+=("${s[@]}"); ') # copy stack to positional_args
    out.write('s=; ') # clear stack
    out.write('break;;')
    w()

    # default case
    w('  *) positional_args+=("$a");;')
    w("esac; done")

    w()
    w("# print parsed values")
    w("if true; then")
    opt_name = "positional_args"
    out.write('  for i in "${!' + opt_name + '[@]}"; do ')
    out.write('v="${' + opt_name + '[$i]}"; ')
    out.write('echo "' + opt_name + ' $i: ${v@Q}"; ')
    out.write('done')
    w()
    for opts, var, desc, opt_name in loop_options(options):
        if var == None:
            # boolean argument
            w('  echo "' + opt_name + ': $' + opt_name + '"')
        else:
            # string argument
            out.write('  for i in "${!' + opt_name + '[@]}"; do ')
            out.write('v="${' + opt_name + '[$i]}"; ')
            out.write('echo "' + opt_name + ' $i: ${v@Q}"; ')
            out.write('done')
            w()
    w("fi")
    return out.getvalue()


def main(argv):
    #if len(argv) > 1:
    if True:
        options = parse_options(sys.stdin.readlines())
        if (len(options) == 0):
            print("error: failed to parse the help text from stdin")
            sys.exit(2)

    if "--gen-argparse-sh" in argv:
        # generate argument parser in bash
        # see also https://github.com/matejak/argbash
        print(generate_argparse_bash(options))
        return

    if True or "--json" in argv:
        import json
        print(json.dumps(options, indent=2))
        sys.exit()

    if True:
        program_name = "some-program"
        if len(argv) > 1:
            program_name = argv[1]
        # FIXME make generate_completion_function work with the new options format
        print(generate_completion_function(options, program_name))


if __name__ == "__main__":
    sys.exit(main(sys.argv))
