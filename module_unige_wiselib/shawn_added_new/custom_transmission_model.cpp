/************************************************************************
 ** This file is part of the network simulator Shawn.                  **
 ** Copyright (C) 2004-2007 by the SwarmNet (www.swarmnet.de) project  **
 ** Shawn is free software; you can redistribute it and/or modify it   **
 ** under the terms of the BSD License. Refer to the shawn-licence.txt **
 ** file in the root of the Shawn source tree for further details.     **
 ************************************************************************/

#include "sys/transm_models/custom_transmission_model.h"
#include "sys/edge_model.h"
#include "sys/world.h"
#include "sys/node.h"
#include <algorithm>
#include "stdio.h"
#include "sys/communication_model.h"

using namespace shawn;

#define EPSILON_TIME 0.00001

namespace shawn
{

    // ----------------------------------------------------------------------
    CustomTransmissionModel::
        CustomTransmissionModel(bool immediate_delivery_ /* = false */)
        : immediate_delivery_(immediate_delivery_),
        next_timeout_(NULL)
    {}

    // ----------------------------------------------------------------------
    CustomTransmissionModel::
        ~CustomTransmissionModel()
    {}

    // ----------------------------------------------------------------------
    bool
        CustomTransmissionModel::
        supports_mobility( void )
        const throw(std::logic_error)
    {
        return world().edge_model().supports_mobility();
    }

    // ----------------------------------------------------------------------
    void
        CustomTransmissionModel::
        init( void )
        throw()
    {
        TransmissionModel::init();
    }

    // ----------------------------------------------------------------------
    void
        CustomTransmissionModel::
        reset( void )
        throw()
    {
        TransmissionModel::reset();

        while( !aired_messages_.empty() )
        {
            MessageInfo* mi = aired_messages_.front();
            aired_messages_.pop();
            delete mi;
        }
    }

    // ----------------------------------------------------------------------
    void
        CustomTransmissionModel::
        send_message( TransmissionModel::MessageInfo& mi )
        throw()
    {
        queued_messages_.push( &mi );
        if( immediate_delivery_ && next_timeout_ == NULL)
            next_timeout_ = world_w().scheduler_w().new_event(*this, 
            world_w().scheduler_w().current_time() + EPSILON_TIME, NULL);
    }

    // ----------------------------------------------------------------------
    void
        CustomTransmissionModel::
        deliver_messages()
        throw()
    {
        // copy the queued messages to the aired_messages and clear the queue.
        while( !queued_messages_.empty() )
        {
            aired_messages_.push( queued_messages_.front() );
            queued_messages_.pop();
        }

        // Deliver messages. It is possible, that a processor receives a
        // message and resend it immediately. Therefore there are the two
        // queues queued- and aired_messages. The following loop processes
        // the aired_messages_, whereby messages which are sent during the
        // loop, are packed into queued_messages_.
        while( ! aired_messages_.empty() )
        {
            MessageInfo* mi = aired_messages_.front();
            aired_messages_.pop();
            deliver_one_message( *mi );
        }
    }

    // ----------------------------------------------------------------------
	void
		CustomTransmissionModel::
		timeout (EventScheduler &, EventScheduler::EventHandle, double, EventScheduler::EventTagHandle &)
		throw ()
   	{
       	next_timeout_ = NULL;
		   deliver_messages();
   	}

    // ----------------------------------------------------------------------
    void
        CustomTransmissionModel::
        deliver_one_message( TransmissionModel::MessageInfo& mi )
        throw()
    {

        if( mi.msg_->is_unicast() )
        {
            ABORT_INCONSISTENT_CONFIGURATION("Unicast is not supported by the custom transmission model. Implement it -> NOW.");
        }
        //std::cout << "deliver one, now " << world_w().scheduler_w().current_time() << std::endl;
        

        for( EdgeModel::adjacency_iterator it = world_w().begin_adjacent_nodes_w( *mi.src_ ),
             endit = world_w().end_adjacent_nodes_w( *mi.src_ ); it != endit; ++it )
        {
           Node *cur_dst = &(*it);
           if(transmission_in_range(mi.src_, cur_dst, &mi))
           {
			   if ( world().communication_model().can_communicate_uni( *mi.src_, *cur_dst ) )
			   {
				   double euc_distance = euclidean_distance( mi.src_->real_position(), cur_dst->real_position() );
				   double g_range = world().communication_model().communication_upper_bound();
				   double source_range = mi.src_->transmission_range();
				   //printf("euc_dist = %f, g_range = %f, source_range = %f\n", euc_distance, g_range, source_range );
				   it->receive( ConstMessageHandle(mi.msg_) );
			   }
           }
        }

        const Message* m = mi.msg_.get();
		if (m->has_sender_proc())
        	(m->sender_proc_w()).process_sent_indication( ConstMessageHandle(mi.msg_), shawn::Processor::SHAWN_TX_STATE_SUCCESS, 1 );
        
        
		delete &mi;
    }


}

/*-----------------------------------------------------------------------
* Source  $Source: /cvs/shawn/shawn/sys/transm_models/custom_transmission_model.cpp,v $
* Version $Revision: 370 $
* Date    $Date: 2009-11-12 14:12:56 +0100 (Thu, 12 Nov 2009) $
*-----------------------------------------------------------------------
* $Log: custom_transmission_model.cpp,v $
 *-----------------------------------------------------------------------*/
