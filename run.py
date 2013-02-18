#!/usr/bin/env python
# -*- Mode: python; py-indent-offset: 4; indent-tabs-mode: nil; coding: utf-8; -*-

from subprocess import call
from sys import argv
import os
import subprocess
import workerpool
import multiprocessing
import argparse

######################################################################
######################################################################
######################################################################

parser = argparse.ArgumentParser(description='Simulation runner')
parser.add_argument('scenarios', metavar='scenario', type=str, nargs='*',
                    help='Scenario to run')

parser.add_argument('-l', '--list', dest="list", action='store_true', default=False,
                    help='Get list of available scenarios')

parser.add_argument('-s', '--simulate', dest="simulate", action='store_true', default=False,
                    help='Run simulation and postprocessing (false by default)')

parser.add_argument('-g', '--no-graph', dest="graph", action='store_false', default=True,
                    help='Do not build a graph for the scenario (builds a graph by default)')

args = parser.parse_args()

if not args.list and len(args.scenarios)==0:
    print "ERROR: at least one scenario need to be specified"
    parser.print_help()
    exit (1)

if args.list:
    print "Available scenarios: "
else:
    if args.simulate:
        print "Simulating the following scenarios: " + ",".join (args.scenarios)

    if args.graph:
        print "Building graphs for the following scenarios: " + ",".join (args.scenarios)

######################################################################
######################################################################
######################################################################

class SimulationJob (workerpool.Job):
    "Job to simulate things"
    def __init__ (self, cmdline):
        self.cmdline = cmdline
    def run (self):
        print (" ".join (self.cmdline))
        subprocess.call (self.cmdline)

pool = workerpool.WorkerPool(size = multiprocessing.cpu_count())

class Processor:
    def run (self):
        if args.list:
            print "    " + self.name
            return

        if "all" not in args.scenarios and self.name not in args.scenarios:
            return

        if args.list:
            pass
        else:
            if args.simulate:
                self.simulate ()
                pool.join ()
                self.postprocess ()
            if args.graph:
                self.graph ()

class CongestionZoom (Processor):
    def __init__ (self, name):
        self.name = name

    def simulate (self):
        cmdline = ["./build/congestion-zoom-ndn"]
        job = SimulationJob (cmdline)
        pool.put (job)

        cmdline = ["./build/congestion-zoom-tcp"]
        job = SimulationJob (cmdline)
        pool.put (job)

    def postprocess (self):
        os.rename ("results/congestion-zoom-ndn-rate-trace.log", "results/%s-ndn.txt" % self.name)
        os.rename ("results/congestion-zoom-tcp-rate-trace.log", "results/%s-tcp.txt" % self.name)

        subprocess.call ("bzip2 -f \"results/%s-ndn.txt\"" % (self.name), shell=True)
        subprocess.call ("bzip2 -f \"results/%s-tcp.txt\"" % (self.name), shell=True)

    def graph (self):
        subprocess.call ("./graphs/%s.R" % self.name, shell=True)

class CongestionPop (Processor):
    def __init__ (self, name, runs = range(1,101)):
        self.name = name
        self.runs = runs

    def simulate (self):
        for run in self.runs:
            cmdline = ["./build/congestion-pop-ndn",
                       "--run=%d" % run
                       ]
            job = SimulationJob (cmdline)
            pool.put (job)

            cmdline = ["./build/congestion-pop-tcp",
                       "--run=%d" % run
                       ]
            job = SimulationJob (cmdline)
            pool.put (job)

    def postprocess (self):
        for subtype in ["tcp", "ndn"]:
            f_out = open ("results/%s-%s.txt" % (self.name, subtype), "w")
            needHeader = True

            for run in self.runs:
                f_in = open ("results/congestion-pop-run-%d-%s-consumers-seqs.log" % (run, subtype), "r")

                firstline = f_in.readline ()

                if needHeader:
                    f_out.write ("Run\t%s" % firstline)
                    needHeader = False

                for line in f_in:
                    f_out.write ("%d\t%s" % (run, line))

                f_in.close ()
                os.remove ("results/congestion-pop-run-%d-%s-consumers-seqs.log" % (run, subtype))
                os.remove ("results/congestion-pop-run-%d-%s-apps.log" % (run, subtype))

            f_out.close ()
            subprocess.call ("bzip2 -f \"results/%s-%s.txt\"" % (self.name, subtype), shell=True)

        subprocess.call ("./graphs/%s-preprocess.R" % self.name, shell=True)

    def graph (self):
        subprocess.call ("./graphs/%s.R" % self.name, shell=True)

try:
    # Simulation, processing, and graph building for Figure 9
    fig9 = CongestionZoom (name="figure-9-one-flow-congestion")
    fig9.run ()

    # Simulation, processing, and graph building for Figure 4
    fig10 = CongestionPop (name="figure-10-twenty-flow-congestion", runs = range(1,101))
    fig10.run ()

finally:
    pool.join ()
    pool.shutdown ()
