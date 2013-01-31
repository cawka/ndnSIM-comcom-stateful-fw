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

#include <boost/lexical_cast.hpp>
#include <boost/foreach.hpp>

#include <ns3/ipv4-global-routing-helper.h>
#include <ns3/internet-module.h>
#include <ns3/applications-module.h>
#include <ns3/network-module.h>
#include <ns3/core-module.h>

#include <ns3/ndnSIM-module.h>
#include <ns3/ndnSIM/plugins/topology/rocketfuel-weights-reader.h>

using namespace std;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("CongestionPopExperiment");

#define _LOG_INFO(x) NS_LOG_INFO(x)


CongestionPopExperiment::CongestionPopExperiment ()
  : BaseExperiment (52)
{
}

CongestionPopExperiment::~CongestionPopExperiment ()
{
}

void
CongestionPopExperiment::ConfigureTopology (const std::string &topology)
{
  Names::Clear ();
  _LOG_INFO ("Configure Topology");
  RocketfuelWeightsReader *rf_reader = new RocketfuelWeightsReader ();

  string weights   (topology+".weights");
  // string positions (topology+".positions");
  string latencies (topology+".latencies");
  // string latencies ("topologies/sprint-pops.latencies");

  // rf_reader->SetFileName (positions);
  // rf_reader->SetFileType (RocketfuelWeightsReader::POSITIONS);
  // rf_reader->Read ();

  rf_reader->SetFileName (weights);
  rf_reader->SetFileType (RocketfuelWeightsReader::WEIGHTS);
  rf_reader->Read ();

  rf_reader->SetFileName (latencies);
  rf_reader->SetFileType (RocketfuelWeightsReader::LATENCIES);
  rf_reader->Read ();

  rf_reader->Commit ();

  if (reader != 0) delete reader;
  reader = rf_reader;
}


ApplicationContainer
CongestionPopExperiment::AddNdnApplications ()
{
  ApplicationContainer apps;

  for (list<tuple<uint32_t,uint32_t> >::iterator i = m_pairs.begin (); i != m_pairs.end (); i++)
    {
      uint32_t node1_num = i->get<0> ();
      uint32_t node2_num = i->get<1> ();

      Ptr<Node> node1 = Names::Find<Node> (lexical_cast<string> (node1_num));
      Ptr<Node> node2 = Names::Find<Node> (lexical_cast<string> (node2_num));

      ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerWindow");
      consumerHelper.SetPrefix ("/" + Names::FindName (node2));
      // consumerHelper.SetAttribute ("MeanRate", StringValue ("2Mbps"));
      consumerHelper.SetAttribute ("Size", StringValue ("1.983642578125")); //to make sure max seq # is 2000

      ndn::AppHelper producerHelper ("ns3::ndn::Producer");
      producerHelper.SetPrefix ("/" + Names::FindName (node2));

      apps.Add
        (consumerHelper.Install (node1));

      apps.Add
        (producerHelper.Install (node2));
    }

  return apps;
}

ApplicationContainer
CongestionPopExperiment::AddTcpApplications ()
{
  ApplicationContainer apps;

  uint32_t streamId = 0;
  const static uint32_t base_port = 10;
  for (list<tuple<uint32_t,uint32_t> >::iterator i = m_pairs.begin (); i != m_pairs.end (); i++)
    {
      uint32_t node1_num = i->get<0> ();
      uint32_t node2_num = i->get<1> ();

      Ptr<Node> node1 = Names::Find<Node> (lexical_cast<string> (node2_num));
      Ptr<Node> node2 = Names::Find<Node> (lexical_cast<string> (node1_num));

      Ptr<Ipv4> ipv4 = node1->GetObject<Ipv4> ();
      // ipv4->GetAddress (0, 0);

      // to make sure we don't reuse the same port numbers for different flows, just make all port numbers unique
      PacketSinkHelper consumerHelper ("ns3::TcpSocketFactory",
                                       InetSocketAddress (Ipv4Address::GetAny (), base_port + streamId));

      BulkSendHelper producerHelper ("ns3::TcpSocketFactory",
                                     InetSocketAddress (ipv4->GetAddress (1, 0).GetLocal (), base_port + streamId));
      // cout << "SendTo: " <<  ipv4->GetAddress (1, 0).GetLocal () << endl;
      producerHelper.SetAttribute ("MaxBytes", UintegerValue (2081040)); // equal to 2001 ccnx packets

      apps.Add
        (consumerHelper.Install (node1));

      apps.Add
        (producerHelper.Install (node2));

      streamId++;
    }

  return apps;
}

