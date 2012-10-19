/************************************************************************
 ** This file is part of the network simulator Shawn.                  **
 ** Copyright (C) 2004-2007 by the SwarmNet (www.swarmnet.de) project  **
 ** Shawn is free software; you can redistribute it and/or modify it   **
 ** under the terms of the BSD License. Refer to the shawn-licence.txt **
 ** file in the root of the Shawn source tree for further details.     **
 ************************************************************************/
#include "_apps_enable_cmake.h"
#ifdef ENABLE_WISELIB

#include "apps/wiselib/ext_iface_processor.h"
#include "sys/simulation/simulation_controller.h"
#include "sys/node.h"
#include <cmath>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "sys/communication_model.h"

namespace wiselib
{
   ExtIfaceProcessor::
   ExtIfaceProcessor()
   {}
   // ----------------------------------------------------------------------
   ExtIfaceProcessor::
   ~ExtIfaceProcessor()
   {}
   // ----------------------------------------------------------------------
   void
   ExtIfaceProcessor::
   boot()
      throw()
   {
#ifdef ENABLE_TESTBEDSERVICE
      set_node( owner_w() );
      testbedservice_proc_boot();
#endif
   }
   // ----------------------------------------------------------------------
	bool   ExtIfaceProcessor::process_message( const shawn::ConstMessageHandle& mh ) throw()
	{
		const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
		const ExtIfaceWiselibMessage* message = dynamic_cast<const ExtIfaceWiselibMessage*> ( mh.get() );
		if ( message != NULL )
		{
			if ( message->source().id()!=owner().id() && (message->destination() == owner().id() || message->destination() == BROADCAST_ADDRESS) )
			{
				for ( ReceiverListIterator it = delegates_.begin();	it != delegates_.end(); ++it )
				{
					(*it)( message->source().id(), message->payload_size(), message->payload() );
				}
				if (!ext_delegates_.empty() )
				{
					node_id_t const from=message->source().id();
					double const ux=owner().real_position().x();
					double const uy=owner().real_position().y();
					double const uz=owner().real_position().z();
					double const vx=owner().world().find_node_by_id(from)->real_position().x();
					double const vy=owner().world().find_node_by_id(from)->real_position().y();
					double const vz=owner().world().find_node_by_id(from)->real_position().z();
					double const dist=std::sqrt((vx-ux)*(vx-ux)+(vy-uy)*(vy-uy)+(vz-uz)*(vz-uz));
					ExtendedData ex;
					double vrange = owner().world().find_node_by_id(from)->transmission_range();
					double urange = owner().transmission_range();
					double g_range = owner().world().communication_model().communication_upper_bound();
					double rssi_up = se.required_double_param( "rssi_up");
					double rssi_low = rssi_up - se.required_double_param( "rssi_low");
					double lqi_up = se.required_double_param( "lqi_limit_up_ratio");
					double lqi_low = se.required_double_param( "lqi_limit_low_ratio");
					double byte_var = se.required_double_param( "byte_var" );
					int len = message->payload_size();
					int max_len = 128;
					double max_dist = g_range*vrange;
					ex.set_link_metric( rssi(dist, max_dist, rssi_up, rssi_low, byte_var, len, max_len ) );
					ex.set_rssi( rssi(dist, max_dist, rssi_up, rssi_low, byte_var, len, max_len ) );
					ex.set_lqi( lqi(dist, max_dist, rssi_up, rssi_low, lqi_up, lqi_low, byte_var, len, max_len  ) );
					for ( ExtendedReceiverListIterator it = ext_delegates_.begin(); it != ext_delegates_.end(); ++it )
					{
						(*it)(from, message->payload_size(), message->payload(), ex);
					}
				}
			}
			return true;
		}
		return shawn::Processor::process_message( mh );
	}
   // ----------------------------------------------------------------------
#ifdef ENABLE_TESTBEDSERVICE
   void
   ExtIfaceProcessor::
   receive_vlink( testbedservice::VirtualLinkMessage *vlm )
      throw()
   {
      if ( vlm->destination == owner().id()
               || vlm->destination == BROADCAST_ADDRESS )
      {
//          std::cout << "--- pass to wiselib" << std::endl;
         for ( ReceiverListIterator
                     it = delegates_.begin();
                     it != delegates_.end();
                     ++it )
               (*it)( vlm->source, vlm->payload_size, vlm->payload );
      }
   }
   // ----------------------------------------------------------------------
   void
   ExtIfaceProcessor::
   process_message( testbedservice::TestbedserviceMessage& message )
      throw()
   {
      for ( UartReceiverListIterator
               it = uart_delegates_.begin();
               it != uart_delegates_.end();
               ++it )
         (*it)( message.size, message.buffer );
   }
#endif
   // ----------------------------------------------------------------------
   void
   ExtIfaceProcessor::
   timeout(shawn::EventScheduler& es,
           shawn::EventScheduler::EventHandle eh,
           double time,
           shawn::EventScheduler::EventTagHandle& tag_handle) throw()
   {
      ExtIfaceWiselibEventTag *tag = dynamic_cast<ExtIfaceWiselibEventTag*>( tag_handle.get() );
      if ( state() == Active && tag && tag->delegate() )
         tag->delegate()( tag->userdata() );
   }
   // ----------------------------------------------------------------------
   int
   ExtIfaceProcessor::
   rssi(double dist, double max_dist, double rssi_up, double rssi_low, double byte_var, int len, int max_len )
   {
		int rssi = 0;
		if ( dist / max_dist == 0 )
		{
			return rssi_up;
		}
		else if ( dist / max_dist <= 100  )
		{
			return ( rssi_up - rssi_low * ( log10( ( ( dist / max_dist ) * 1000 ) ) / log10( 1000 )  ) ) * ( ( 100 - ( byte_var - byte_var * ( (double) len / max_len ) ) ) / 100 ) ;
		}
		else
		{
			return rssi_low;
		}
		return  rssi;
   };
   // ----------------------------------------------------------------------
   int
   ExtIfaceProcessor::
   lqi( double dist, double max_dist, double rssi_up, double rssi_low, double lqi_up, double lqi_low, double byte_var, int len, int max_len )
   {
		double dist_offset_low = max_dist * ( lqi_up / 100 );
		double dist_offset_up = max_dist - max_dist * ( lqi_low / 100 );
		int lqi = rssi( dist, max_dist, rssi_up, rssi_low, byte_var, len, max_len );
		if ( ( dist_offset_low != 0 ) && ( ( dist < dist_offset_low ) || ( dist == 0 ) ) )
		{
			return rssi( dist_offset_low, max_dist, rssi_up, rssi_low, byte_var, len, max_len );
		}
		else if ( ( dist_offset_up != 0 ) && ( ( dist > dist_offset_up ) || ( dist > max_dist ) ) )
		{
			return rssi( dist_offset_up, max_dist, rssi_up, rssi_low, byte_var, len, max_len );
		}
		return lqi;
   };
   // ----------------------------------------------------------------------


}
#endif
