Prerequisites
=============

Custom version of NS-3 and specified version of ndnSIM needs to be installed.

The code should also work with the latest version of ndnSIM, but it is not guaranteed.

    git clone git@github.com:cawka/ns-3-dev-ndnSIM.git -b ns-3.16-ndnSIM ns-3
    git clone git@github.com:NDN-Routing/ndnSIM.git -b v0.2.2 ns-3/src/ndnSIM

    cd ns-3
    ./waf configure
    ./waf install

For more information how to install NS-3 and ndnSIM, please refer to http://ndnsim.net website.

Compiling
=========

``./waf configure``

or (configure in debug mode with logging enabled)

``./waf configure --debug``

If you have installed NS-3 in a non-standard location, you may need to set up ``PKG_CONFIG_PATH`` variable.
For example, if NS-3 is installed in /usr/local/, then the following command should be used to
configure scenario

``PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./waf configure``

or

``PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./waf configure --debug``

Running
=======

Normally, you can run scenarios either directly

``./build/<scenario_name>``

or using waf

``./waf --run <scenario_name>``

If NS-3 is installed in a non-standard location, on some platforms (e.g., Linux) you need to specify ``LD_LIBRARY_PATH`` variable:

``LD_LIBRARY_PATH=/usr/local/lib ./build/<scenario_name>``

or

``LD_LIBRARY_PATH=/usr/local/lib ./waf --run <scenario_name>``


When running using ./waf, it is possible to run scenario with visualizer:

``./waf --run <scenario_name> --vis``


Available simulations
=====================

One-flow congestion scenario in a simple topology (Figure 9)
------------------------------------------------------------

Figure 9 from "A Case for Stateful Forwarding Plane" paper:

To generate NDN exepriment trace (results/congestion-zoom-ndn-rate-trace.log):

    NS_LOG=BaseExperiment:Experiment ./waf --run congestion-zoom-ndn

To generate TCP experiment trace

    NS_LOG=BaseExperiment:Experiment ./waf --run results/congestion-zoom-tcp-rate-trace.log

If you have R with ggplot2 package installed, the generated files can be processed with the following R script,
which produces a raw graph for the figure (graphs/pdfs/congestion-zoom.pdf):

    ./graphs/congestion-zoom.R

20-flow congestion scenario in Sprint POP topology (Figure 10)
--------------------------------------------------------------

To produce traces (``congestion-pop-run-1-tcp-consumers-seqs.log`` and congestion-pop-run-1-ndn-consumers-seqs.log)
for a single run, use the following commands:

    NS_LOG=BaseExperiment:Experiment ./waf --run congestion-pop-ndn

    NS_LOG=BaseExperiment:Experiment ./waf --run congestion-pop-tcp

To build a graph for a single run, run the command:

    ./graphs/congestion-pop.R

There is also an automated python script, which allows running 100 simulation runs in parallel:

    ./run.py

To build a graph, combining all 100 runs:

    ./graphs/congestion-pop.R 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100

