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

#ifndef BASE_EXPERIMENT_H
#define BASE_EXPERIMENT_H

#include <ns3/random-variable.h>
#include <ns3/nstime.h>
#include <ns3/ndnSIM/plugins/topology/rocketfuel-weights-reader.h>

#include <list>
#include <set>
#include <boost/tuple/tuple.hpp>

namespace ns3
{

/**
 * @brief Base functionality for COMCOM Stateful Forwarding paper
 */
class BaseExperiment
{
public:
  BaseExperiment (uint32_t numNodes);
  virtual ~BaseExperiment ();

  virtual void
  ConfigureTopology (const std::string &topology) = 0;

  void InstallNdnStack (bool installFIBs = true);

  void InstallIpStack ();

  void
  GenerateRandomPairs (uint16_t numStreams);

  void
  SetPair (uint32_t pairId);

  void
  Run (const Time &finishTime);

protected:
  UniformVariable m_rand;
  AnnotatedTopologyReader *reader;

  std::list<boost::tuple<uint32_t,uint32_t> > m_pairs;
  std::set<uint32_t> m_usedNodes;
  const int m_numNodes;
};

} // namespace ns3

#endif
