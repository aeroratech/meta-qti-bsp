#!/usr/bin/python3

# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

import argparse
import subprocess
import os.path

alloc_dict = dict()
free_list = list()
map_dict = dict()
resolved_dict = dict()

def collect_backtrace(fp):
    line = fp.readline()
    bt = ""
    while line.startswith('   > '):
        bt += line
        line = fp.readline()

    return bt

def parse_allocdebug_log(allocdbg_file, report_file):
    report_fp = open(report_file, "w")
    msg_idx = 0
    print("Processing allocdebug report file {} ...".format(allocdbg_file))
    result = subprocess.check_output(['wc', '-l', allocdbg_file])
    total_lines = int(result.split()[0])

    with open(allocdbg_file) as fp:
        line = fp.readline()
        while line:
            if line.startswith(("malloc", "calloc", "realloc", "new")) == True or line.startswith(("free", "delete")):
                words = line.split('=')
                if words[0].startswith(("malloc", "calloc", "realloc", "new")):
                    words[1] = words[1].strip().rstrip()
                    type_n_backtrace = list()
                    type_n_backtrace.append(words[0].strip())
                    type_n_backtrace.append(collect_backtrace(fp))
                    alloc_dict[words[1]] = type_n_backtrace
                if words[0].startswith(("free", "delete")):
                    words[1] = words[1].strip().rstrip()
                    ret = alloc_dict.pop(words[1], None)
                    if ret is None:
                        type_n_backtrace = list()
                        type_n_backtrace.append(words[0].strip())
                        type_n_backtrace.append(collect_backtrace(fp))
                        alloc_dict[words[1]] = type_n_backtrace

            line = fp.readline()

        msg = ['++++++++++++++++++++', '********************']
        if msg_idx == 0:
            msg_idx = 1
        else:
            msg_idx = 0
        print(msg[msg_idx], end = '')

    print(alloc_dict)
    print("\nGenerating final report ....")
    report_fp.write("=== Mismatched memory ====\n")
    for addr,name_bt in alloc_dict.items():
        type(name_bt)
        type(addr)
        block = name_bt[0] + "  =  " + addr + "\n" + name_bt[1]
        report_fp.write(block)

    print(free_list)
    report_fp.close()

parser = argparse.ArgumentParser(description='Valgrind Post Processor')
parser.add_argument('--log-file', dest='log_file', required=True, type=str, help='Allocdebug output')
parser.add_argument('--report', dest='report_file', required=False, default=None, type=str, help='Generated Report file')
args = parser.parse_args()

if args.report_file == None:
    args.report_file = args.log_file + '_filtered'

# parse_map_file(args.map_file)
parse_allocdebug_log(args.log_file, args.report_file)
