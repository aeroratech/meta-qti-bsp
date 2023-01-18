#!/usr/bin/python3

# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# from tqdm.auto import tqdm
import os
import re
import sys
import subprocess
import argparse
from collections import defaultdict

class Resolver:
    def __init__(self, log_file, lib_map_file, dbg_rootfs_path, addr2line, mode = "local", report_file = "./report.txt"):
        self.mode = mode
        self.log_file = log_file
        self.map_file = lib_map_file
        self.map_dict = defaultdict(list)
        self.report_file = report_file
        self.dbg_rootfs_path = dbg_rootfs_path
        print('Required rootfs present at: {}'.format(self.dbg_rootfs_path))
        self.resolved_dict = dict()
        if addr2line and len(addr2line) > 0:
            self.addr2line = addr2line
        else:
            self.addr2line = 'addr2line'
            print("\n")
            if self.mode.startswith('target'):
                arch = self.mode.split('-')
                if arch[1] == 'aarch64':
                    self.addr2line = 'aarch64-oe-linux-addr2line'
                elif arch[1] == 'arm':
                    self.addr2line = 'arm-oe-linux-gnueabi-addr2line'
                else:
                    print("Target Arch {} is not supported".format(arch[1]))
                    sys.exit(0)
                if os.path.exists(self.addr2line) == False:
                    print("addr2line not found at {}".format(self.addr2line))
                    print("Expected location to invoke this tool is under \"/path/to/workspace/build*\" directory")
                    sys.exit(0)
                if not dbg_rootfs_path or len(dbg_rootfs_path) == 0:
                    print("rootfs-dbg path not provided")
                    sys.exit(0)
        print('Using addr2line at \"{}\"'.format(self.addr2line))

    def parse_map_file(self):
        print("Processing map file {} ...".format(self.map_file))
        result = subprocess.check_output(['wc', '-l', self.map_file])
        total_lines = int(result.split()[0])
        with open(self.map_file) as fp:
            for _ in range(total_lines):
                line = fp.readline()
                items = line.split()
                if len(items) > 5:
                    subitems = items[0].split('-')
                    if 'r-xp' in items[1]:
                        self.map_dict[items[5]].append(subitems[0])
                    elif 'rw-p' in items[1]:
                        self.map_dict[items[5]].append(subitems[1])
        print("\nCompleted processing map file {}.\n".format(self.map_file))

    def parse_log(self):
        report_fp = open(self.report_file, "w")
        print("Processing log report file {} ...".format(self.log_file))
        result = subprocess.check_output(['wc', '-l', self.log_file])
        total_lines = int(result.split()[0])
        with open(self.log_file) as fp:
            for _ in range(total_lines):
                line = fp.readline()
                output_line = self.resolved_dict.get(line)
                if output_line == None:
                    if line.startswith('   >') == True:
                        temp_line = line.strip()
                        line_parts = list(line.split())
                        if len(line_parts) > 1:
                            addr = line_parts[1].strip('[').strip(']')
                            if not re.match(r'0x[0-9a-fA-F]', addr):
                                print('Improper address. Some issue with the log: {}'.format({temp_line}))
                                exit(1)
                            offset = None
                            lib_name = None
                            for name, addr_range in self.map_dict.items():
                                if len(addr_range) == 2:
                                    if int(addr, 16) in range(int(addr_range[0], 16), int(addr_range[1], 16)):
                                        lib_name = name
                                        offset = hex(int(addr, 16) - min(int(addr_range[0], 16), int(addr_range[1], 16)))
                                        break
                            if offset:
                                if self.mode.startswith('target'):
                                    file_in_rootfs = self.dbg_rootfs_path + lib_name
                                    real_file = os.path.realpath(file_in_rootfs)
                                    #real_file = real_file.replace(self.rootfs_path, self.dbg_rootfs_path)
                                    split_path = real_file.rsplit('/', 1) # dir-name, filename split

                                    library = os.path.join(split_path[0], '.debug', split_path[1])
                                    if os.path.exists(library):
                                        command = [self.addr2line]
                                        command.extend(['-C', '-f'])
                                        command.extend(['-e', library, str(offset)])
                                        print(command)
                                        result = subprocess.check_output(command)
                                        result = result.decode('utf-8')
                                        result.replace('\n', ' ')
                                        result_list = result.split()
                                        result = ''
                                        for element in result_list:
                                            match = re.match(r'^\/.*build[-*a-zA-Z0-9]*\/tmp[-a-zA-Z]*\/work\/', element)
                                            if match:
                                                result += ' ' + element[match.end():]
                                            else:
                                                result += ' ' + element
                                        output_line = line.rstrip() + '  ' + result
                        else:
                            print('Some issue with the log: {}'.format({temp_line}))
                            exit(1)
                    if output_line == None:
                        output_line = line.rstrip()
                    self.resolved_dict[line] = output_line
                report_fp.write(output_line)
                report_fp.write('\n')
        report_fp.close()
        print("\nCompleted processing log file {}.".format(self.log_file))
        print("Output written to {}".format(self.report_file))

parser = argparse.ArgumentParser(description='Alloc Backtrace Post Processor')
parser.add_argument('--mode', dest='mode', required=False, default='local', type=str, help='Mode local files or from LE build')
parser.add_argument('--report', dest='report_file', required=False, default=None, type=str, help='Generated Report file')
parser.add_argument('--log-file', dest='log_file', required=True, type=str, help='report with log output and leak markers')
parser.add_argument('--proc-map', dest='map_file', required=True, type=str, help='libraries map file')
parser.add_argument('--dbgrootfs', dest='dbg_rootfs_path', required=False, default='', type=str, help='Debug copy of rootfs generated with build')
parser.add_argument('--addr2line', dest='addr2line', required=False, default='', type=str, help='addr-2-line utility')

args = parser.parse_args()

if args.report_file == None:
    args.report_file = args.log_file + '_backtrace_post_processed'

if __name__ == "__main__":
    r = Resolver(args.log_file, args.map_file, args.dbg_rootfs_path, args.addr2line, args.mode, args.report_file)
    r.parse_map_file()
    r.parse_log()
