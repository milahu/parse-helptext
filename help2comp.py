#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# Parse getopt-style help texts for options
# and generate zsh(1) completion function.
# http://github.com/RobSis/zsh-completion-generator

# Usage: program --help | ./help2comp.py program_name

import sys
import re
from string import Template


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


if __name__ == "__main__":
    if len(sys.argv) > 1:
        options = parse_options(sys.stdin.readlines())
        if (len(options) == 0):
            sys.exit(2)

        # TODO use the new options format
        import json
        print(json.dumps(options, indent=2))
        sys.exit()

        print(generate_completion_function(options, sys.argv[1]))
    else:
        print("Please specify program name.")
