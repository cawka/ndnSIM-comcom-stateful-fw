/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2013 University of California, Los Angeles
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Author: Alexander Afanasyev <alexander.afanasyev@ucla.edu>
 */

#include "congestion-zoom-experiment.h"
#include <ns3/core-module.h>

#include <ns3/ndnSIM-module.h>
#include <ns3/ndnSIM/utils/tracers/ndn-l3-rate-tracer.h>

using namespace std;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("Experiment");

#define _LOG_INFO(x) NS_LOG_INFO(x)

int
main (int argc, char *argv[])
{
  _LOG_INFO ("Begin congestion-pop scenario (NDN)");

  Config::SetDefault ("ns3::PointToPointNetDevice::DataRate", StringValue ("1Mbps"));
  // Config::SetDefault ("ns3::DropTailQueue::MaxPackets", StringValue ("60"));

  Config::SetDefault ("ns3::ndn::RttEstimator::MaxRTO", StringValue ("1s"));
  
  Config::SetDefault ("ns3::ndn::ConsumerWindow::Window", StringValue ("1"));
  // Config::SetDefault ("ns3::ndn::ConsumerWindow::InitialWindowOnTimeout", StringValue ("false")); // irrelevant

  CommandLine cmd;
  cmd.Parse (argc, argv);

  CongestionZoomExperiment experiment;
  string prefix = "results/congestion-zoom-ndn-";

  _LOG_INFO ("NDN experiment");
  experiment.ConfigureTopology ("topologies/congestion-zoom.txt");
  experiment.InstallNdnStack ();
  experiment.AddNdnApplications ();

  boost::tuple< boost::shared_ptr<std::ostream>, std::list<Ptr<ndn::L3RateTracer> > >
    rateTracers = ndn::L3RateTracer::InstallAll (prefix + "rate-trace.log", Seconds (0.5));

  experiment.Run (Seconds (50.0));

  return 0;
}
