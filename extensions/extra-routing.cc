/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil -*- */
/*
 * Copyright (c) 2012 University of California, Los Angeles
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
 * Author:  Alexander Afanasyev <alexander.afanasyev@ucla.edu>
 */


#include "ns3/ndnSIM/model/ndn-net-device-face.h"
#include "ns3/ndnSIM/model/ndn-global-router.h"
#include "ns3/ndn-name-components.h"
#include "ns3/ndn-fib.h"

#include "ns3/ndn-l3-protocol.h"
#include "ns3/ndn-face.h"

#include "ns3/node.h"
#include "ns3/node-container.h"
#include "ns3/net-device.h"
#include "ns3/channel.h"
#include "ns3/log.h"
#include "ns3/assert.h"
#include "ns3/names.h"
#include "ns3/node-list.h"
#include "ns3/channel-list.h"
#include "ns3/object-factory.h"

#include <boost/lexical_cast.hpp>
#include <boost/foreach.hpp>
#include <boost/concept/assert.hpp>
// #include <boost/graph/graph_concepts.hpp>
// #include <boost/graph/adjacency_list.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>

#include "ns3/ndnSIM/helper/boost-graph-ndn-global-routing-helper.h"

#include <math.h>

using namespace std;
using namespace boost;
using namespace ns3;
using namespace ns3::ndn;

NS_LOG_COMPONENT_DEFINE ("ExtraRouting");


void
NdnGlobalRouter_CalculateAllPossibleRoutes ()
{
  /**
   * Implementation of route calculation is heavily based on Boost Graph Library
   * See http://www.boost.org/doc/libs/1_49_0/libs/graph/doc/table_of_contents.html for more details
   */

  int counter = 0;

  BOOST_CONCEPT_ASSERT(( VertexListGraphConcept< NdnGlobalRouterGraph > ));
  BOOST_CONCEPT_ASSERT(( IncidenceGraphConcept< NdnGlobalRouterGraph > ));

  NdnGlobalRouterGraph graph;
  typedef graph_traits < NdnGlobalRouterGraph >::vertex_descriptor vertex_descriptor;

  // For now we doing Dijkstra for every node.  Can be replaced with Bellman-Ford or Floyd-Warshall.
  // Other algorithms should be faster, but they need additional EdgeListGraph concept provided by the graph, which
  // is not obviously how implement in an efficient manner
  for (NodeList::Iterator node = NodeList::Begin (); node != NodeList::End (); node++)
    {
      Ptr<GlobalRouter> source = (*node)->GetObject<GlobalRouter> ();
      if (source == 0)
	{
	  NS_LOG_DEBUG ("Node " << (*node)->GetId () << " does not export GlobalRouter interface");
	  continue;
	}

      Ptr<Fib>  fib  = source->GetObject<Fib> ();
      fib->InvalidateAll ();
      NS_ASSERT (fib != 0);

      NS_LOG_DEBUG ("===========");
      NS_LOG_DEBUG ("Reachability from Node: " << source->GetObject<Node> ()->GetId () << " (" << Names::FindName (source->GetObject<Node> ()) << ")");

      Ptr<L3Protocol> l3 = source->GetObject<L3Protocol> ();
      NS_ASSERT (l3 != 0);

      // remember interface statuses
      std::vector<uint16_t> originalMetric (l3->GetNFaces ());
      for (uint32_t faceId = 0; faceId < l3->GetNFaces (); faceId++)
        {
          originalMetric[faceId] = l3->GetFace (faceId)->GetMetric ();
          l3->GetFace (faceId)->SetMetric (std::numeric_limits<int16_t>::max ()-1); // value std::numeric_limits<int16_t>::max () MUST NOT be used (reserved)
        }

      for (uint32_t enabledFaceId = 0; enabledFaceId < l3->GetNFaces (); enabledFaceId++)
        {
          if (DynamicCast<ndn::NetDeviceFace> (l3->GetFace (enabledFaceId)) == 0)
            continue;

          // enabling only faceId
          l3->GetFace (enabledFaceId)->SetMetric (originalMetric[enabledFaceId]);

          DistancesMap    distances;

          NS_LOG_DEBUG ("-----------");

          dijkstra_shortest_paths (graph, source,
                                   // predecessor_map (boost::ref(predecessors))
                                   // .
                                   distance_map (boost::ref(distances))
                                   .
                                   distance_inf (WeightInf)
                                   .
                                   distance_zero (WeightZero)
                                   .
                                   distance_compare (boost::WeightCompare ())
                                   .
                                   distance_combine (boost::WeightCombine ())
                                   );

          // NS_LOG_DEBUG (predecessors.size () << ", " << distances.size ());

          for (DistancesMap::iterator i = distances.begin ();
               i != distances.end ();
               i++)
            {
              if (i->first == source)
                continue;
              else
                {
                  // cout << "  Node " << i->first->GetObject<Node> ()->GetId ();
                  if (i->second.get<0> () == 0)
                    {
                      // cout << " is unreachable" << endl;
                    }
                  else
                    {
                      BOOST_FOREACH (const Ptr<const NameComponents> &prefix, i->first->GetLocalPrefixes ())
                        {
                          NS_LOG_DEBUG (" prefix " << *prefix << " reachable via face " << *i->second.get<0> ()
                                        << " with distance " << i->second.get<1> ()
                                        << " with delay " << i->second.get<2> ());

                          if (i->second.get<0> ()->GetMetric () == std::numeric_limits<uint16_t>::max ()-1)
                            continue;

                          Ptr<fib::Entry> entry = fib->Add (prefix, i->second.get<0> (), i->second.get<1> ());
                          entry->SetRealDelayToProducer (i->second.get<0> (), Seconds (i->second.get<2> ()));

                          Ptr<Limits> faceLimits = i->second.get<0> ()->GetObject<Limits> ();

                          Ptr<Limits> fibLimits = entry->GetObject<Limits> ();
                          if (fibLimits != 0)
                            {
                              // if it was created by the forwarding strategy via DidAddFibEntry event
                              fibLimits->SetLimits (faceLimits->GetMaxRate (), 2 * i->second.get<2> () /*exact RTT*/);
                              NS_LOG_DEBUG ("Set limit for prefix " << *prefix << " " << faceLimits->GetMaxRate () << " / " <<
                                            2*i->second.get<2> () << "s (" << faceLimits->GetMaxRate () * 2 * i->second.get<2> () << ")");
                            }
                        }
                    }
                }
            }

          // disabling the face again
          l3->GetFace (enabledFaceId)->SetMetric (std::numeric_limits<uint16_t>::max ()-1);
        }

      // recover original interface statuses
      for (uint32_t faceId = 0; faceId < l3->GetNFaces (); faceId++)
        {
          l3->GetFace (faceId)->SetMetric (originalMetric[faceId]);
        }
    }
}
