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

#include <boost/lexical_cast.hpp>
#include <boost/foreach.hpp>

#include <ns3/ipv4-global-routing-helper.h>
#include <ns3/internet-module.h>
#include <ns3/applications-module.h>
#include <ns3/network-module.h>
#include <ns3/core-module.h>

#include <ns3/ndnSIM-module.h>

using namespace std;
using namespace boost;

NS_LOG_COMPONENT_DEFINE ("CongestionZoomExperiment");

#define _LOG_INFO(x) NS_LOG_INFO(x)

CongestionZoomExperiment::CongestionZoomExperiment ()
  : BaseExperiment (6)
{
}

CongestionZoomExperiment::~CongestionZoomExperiment ()
{
}

void
CongestionZoomExperiment::ConfigureTopology (const std::string &topology)
{
  Names::Clear ();
  _LOG_INFO ("Configure Topology");
  if (reader != 0) delete reader;
  reader = new AnnotatedTopologyReader ();

  string input (topology);

  reader->SetFileName (input);
  reader->Read ();
}

ApplicationContainer
CongestionZoomExperiment::AddNdnApplications ()
{
  ApplicationContainer apps;

  Ptr<Node> client = Names::Find<Node> (lexical_cast<string> ("client"));
  Ptr<Node> server = Names::Find<Node> (lexical_cast<string> ("server"));

  ndn::AppHelper consumerHelper ("ns3::ndn::ConsumerWindow");
  consumerHelper.SetPrefix ("/" + Names::FindName (server));
  consumerHelper.SetAttribute ("Size", StringValue ("2.0"));

  ndn::AppHelper producerHelper ("ns3::ndn::Producer");
  producerHelper.SetPrefix ("/" + Names::FindName (server));

  apps.Add
    (consumerHelper.Install (client));

  apps.Add
    (producerHelper.Install (server));

  return apps;
}

ApplicationContainer
CongestionZoomExperiment::AddTcpApplications ()
{
  ApplicationContainer apps;

  Ptr<Node> client = Names::Find<Node> (lexical_cast<string> ("client"));
  Ptr<Node> server = Names::Find<Node> (lexical_cast<string> ("server"));

  Ptr<Ipv4> ipv4 = client->GetObject<Ipv4> ();

  // to make sure we don't reuse the same port numbers for different flows, just make all port numbers unique
  PacketSinkHelper consumerHelper ("ns3::TcpSocketFactory",
                                   InetSocketAddress (Ipv4Address::GetAny (), 1024));

  BulkSendHelper producerHelper ("ns3::TcpSocketFactory",
                                 InetSocketAddress (ipv4->GetAddress (1, 0).GetLocal (), 1024));
  // cout << "SendTo: " <<  ipv4->GetAddress (1, 0).GetLocal () << endl;
  producerHelper.SetAttribute ("MaxBytes", UintegerValue (2081040)); // equal to 2001 ccnx packets

  apps.Add
    (consumerHelper.Install (client));

  apps.Add
    (producerHelper.Install (server));

  return apps;
}
