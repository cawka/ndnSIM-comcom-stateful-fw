/* -*- Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil -*- */
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

#include "base-experiment.h"

#include "extra-routing.h"

#include <ns3/log.h>
#include <ns3/simulator.h>
#include <ns3/names.h>
#include <ns3/ptr.h>

#include <ns3/ndn-stack-helper.h>
#include <ns3/ndn-face-container.h>
#include <ns3/ndn-global-routing-helper.h>

#include <ns3/internet-stack-helper.h>
#include <ns3/ipv4-global-routing-helper.h>

using namespace std;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("BaseExperiment");

#define _LOG_INFO(x) NS_LOG_INFO(x)

namespace ns3
{

void PrintTime (const Time &nextTime, const Time &endTime)
{
  _LOG_INFO ("Progress: " << static_cast<int>(100*(Simulator::Now ()).ToDouble (Time::S) / endTime.ToDouble (Time::S)) << "%");
  Simulator::Schedule (nextTime, PrintTime, nextTime, endTime);
}


BaseExperiment::BaseExperiment (uint32_t numNodes)
  : m_rand (0, numNodes)
  , reader (0)
  , m_numNodes (numNodes)
{ }

BaseExperiment::~BaseExperiment ()
{
  if (reader != 0) delete reader;
}

// void
// BaseExperiment::ConfigureTopology ()
// {
//   Names::Clear ();
//   _LOG_INFO ("Configure Topology");
//   if (reader != 0) delete reader;
//   reader = new RocketfuelWeightsReader ();

//   string weights   ("topologies/sprint-pops.weights");
//   string positions ("topologies/sprint-pops.positions");
//   string latencies ("topologies/sprint-pops.latencies");

//   reader->SetFileName (positions);
//   reader->SetFileType (RocketfuelWeightsReader::POSITIONS);
//   reader->Read ();

//   reader->SetFileName (weights);
//   reader->SetFileType (RocketfuelWeightsReader::WEIGHTS);
//   reader->Read ();

//   reader->SetFileName (latencies);
//   reader->SetFileType (RocketfuelWeightsReader::LATENCIES);
//   reader->Read ();

//   reader->Commit ();
// }

void
BaseExperiment::InstallNdnStack (bool installFIBs/* = true*/)
{
  _LOG_INFO ("Installing NDN stack");

  // Install NDN stack
  ndn::StackHelper ndnHelper;
  ndnHelper.SetForwardingStrategy ("ns3::ndn::fw::BestRoute::PerOutFaceLimits",
                                   "Limit", "ns3::ndn::Limits::Rate",
                                   "EnableNACKs", "true");
  ndnHelper.EnableLimits (true, Seconds(0.1));
  ndnHelper.SetDefaultRoutes (false);
  ndnHelper.InstallAll ();

  ndn::GlobalRoutingHelper routingHelper;
  routingHelper.InstallAll ();

  reader->ApplyOspfMetric ();

  if (installFIBs)
    {
      routingHelper.AddOriginsForAll ();

      NdnGlobalRouter_CalculateAllPossibleRoutes (); // check extra-routing.cc
    }
}

void
BaseExperiment::InstallIpStack ()
{
  InternetStackHelper stack;
  stack.Install (reader->GetNodes ());
  reader->AssignIpv4Addresses (Ipv4Address ("10.0.0.0"));
  reader->ApplyOspfMetric ();

  Ipv4GlobalRoutingHelper::PopulateRoutingTables ();
}

void
BaseExperiment::GenerateRandomPairs (uint16_t numStreams)
{
  m_pairs.clear ();
  // map<uint32_t, set<uint32_t> > streams;
  m_usedNodes.clear ();

  uint16_t createdStreams = 0;
  uint16_t guard = 0;
  while (createdStreams < numStreams && guard < (numeric_limits<uint16_t>::max ()-1))
    {
      guard ++;

      uint32_t node1_num = m_rand.GetValue ();
      uint32_t node2_num = m_rand.GetValue ();

      if (node1_num == node2_num)
        continue;

      if (m_usedNodes.count (node1_num) > 0 ||
          m_usedNodes.count (node2_num) > 0 )
        {
          continue; // don't reuse nodes
        }

      m_usedNodes.insert (node1_num);
      m_usedNodes.insert (node2_num);

      m_pairs.push_back (make_tuple (node1_num, node2_num));
      createdStreams ++;
    }
}

void
BaseExperiment::SetPair (uint32_t pairId)
{
  m_pairs.clear ();
  m_usedNodes.clear ();

  uint32_t i = 0;
  for (uint32_t node1_num = 0; node1_num < 52; node1_num++)
    for (uint32_t node2_num = 0; node2_num < 52; node2_num++)
      {
        if (node1_num == node2_num) continue;

        // std::cout << "i = " << i << ", pairId = " << pairId << "\n";
        if (i++ != pairId) continue;

        m_usedNodes.insert (node1_num);
        m_usedNodes.insert (node2_num);

        m_pairs.push_back (make_tuple (node1_num, node2_num));
        return;
      }
}

void
BaseExperiment::DumpPairs (const std::string &filename)
{
  ofstream of_nodes (filename.c_str ());
  for (list<tuple<uint32_t,uint32_t> >::iterator i = m_pairs.begin (); i != m_pairs.end (); i++)
    {
      of_nodes << "From " << i->get<0> ()
               << " to "  << i->get<1> ();
      of_nodes << "\n";
    }
  of_nodes.close ();
}

void
BaseExperiment::Run (const Time &finishTime)
{
  _LOG_INFO ("Run Simulation");

  Simulator::Stop (finishTime);
  Simulator::Schedule (Seconds (5.0), PrintTime, Seconds (5), finishTime);
  Simulator::Run ();
  Simulator::Destroy ();

  _LOG_INFO ("Done");
}

} // namespace ns3
