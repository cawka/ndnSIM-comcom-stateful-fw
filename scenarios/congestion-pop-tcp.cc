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

#include "congestion-pop-experiment.h"
#include <ns3/core-module.h>

#include <boost/lexical_cast.hpp>
#include <boost/foreach.hpp>

#include <ns3/ndnSIM-module.h>
#include <ns3/ndnSIM/utils/tracers/ipv4-seqs-app-tracer.h>

using namespace std;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("Experiment");

#define _LOG_INFO(x) NS_LOG_INFO(x)

int
main (int argc, char *argv[])
{
  _LOG_INFO ("Begin congestion-pop scenario (TCP)");

  Config::SetDefault ("ns3::PointToPointNetDevice::DataRate", StringValue ("1Mbps"));
  Config::SetDefault ("ns3::DropTailQueue::MaxPackets", StringValue ("60"));
  Config::SetDefault ("ns3::TcpSocket::SegmentSize", StringValue ("1040"));

  Config::SetDefault ("ns3::BulkSendApplication::SendSize", StringValue ("1040"));

  uint32_t run = 1;
  CommandLine cmd;
  cmd.AddValue ("run", "Simulation run", run);
  cmd.Parse (argc, argv);

  Config::SetGlobal ("RngRun", IntegerValue (run));
  NS_LOG_INFO ("seed = " << SeedManager::GetSeed () << ", run = " << SeedManager::GetRun ());

  CongestionPopExperiment experiment;
  NS_LOG_INFO ("Run " << run);
  string prefix = "results/congestion-pop-run-" + lexical_cast<string> (run) + "-tcp-";

  experiment.GenerateRandomPairs (20);
  experiment.DumpPairs (prefix + "apps.log");

  experiment.ConfigureTopology ("topologies/sprint-pops");
  experiment.InstallIpStack ();
  ApplicationContainer apps = experiment.AddTcpApplications ();

  for (uint32_t i = 0; i < apps.GetN () / 2; i++)
    {
      apps.Get (i*2)->SetStartTime (Seconds (1+i));
      apps.Get (i*2 + 1)->SetStartTime (Seconds (1+i));
    }

  boost::tuple< boost::shared_ptr<std::ostream>, std::list<Ptr<Ipv4SeqsAppTracer> > > tracers =
    Ipv4SeqsAppTracer::InstallAll (prefix + "consumers-seqs.log");

  experiment.Run (Seconds (200.0));

  _LOG_INFO ("Finish congestion-pop scenario");
  return 0;
}
