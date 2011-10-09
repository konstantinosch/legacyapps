#include "PLTT_processor.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_environment.h"
#include "sys/node.h"
#include "sys/taggings/basic_tags.h"
#include "sys/taggings/node_reference_tag.h"

namespace wiselib
{
	PLTT_Processor::PLTT_Processor()
	:wiselib_radio_ ( os_ ),
	wiselib_timer_( os_ ),
	wiselib_debug_( os_ ),
	wiselib_rand_ (os_ ),
	wiselib_clock_ (os_ )
	{}
	//-------------------------------------------------------------------------------------------------
	PLTT_Processor::~PLTT_Processor()
	{}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::boot( void ) throw()
	{	
		const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
		number_of_targets = se.required_int_param( "number_of_targets" );
		number_of_trackers = se.required_int_param( "number_of_trackers" );
		number_of_targets = se.required_int_param( "number_of_targets" );
		network_size_x = se.required_int_param( "network_size_x" );
		network_size_y = se.required_int_param( "network_size_y" );
		network_size_z = se.required_int_param( "network_size_z" );
		intensity_detection_threshold = se.required_int_param( "intensity_detection_threshold" );
		reliable_tracking_expiration_time = se.required_int_param( "reliable_tracking_expiration_time");
		reliable_tracking_recurring_time = se.required_int_param( "reliable_tracking_recurring_time");
		reliable_tracking_daemon_time = se.required_int_param( "reliable_tracking_daemon_time");
		tracker_tracking_metrics_timer = se.required_int_param( "tracker_tracking_metrics_timer" );
		metrics_timeout = se.required_int_param( "metrics_timeout" );
		shawn::BoolTag *target_tag = new shawn::BoolTag( "target_tag",false);
		owner_w().add_tag(target_tag);
		shawn::BoolTag *tracker_tag = new shawn::BoolTag( "tracker_tag" ,false);
		owner_w().add_tag(tracker_tag);
		shawn::BoolTag *passive_tag = new shawn::BoolTag( "passive_tag",false);
		owner_w().add_tag(passive_tag);

		for (int i=0; i < number_of_targets; i++)
		{
			ostringstream oss;
			oss << "target_id_" << i;
			if ( se.required_int_param( oss.str() )  == owner().id() )
			{
				TagHandle tag_h = owner_w().find_tag_w("target_tag");
				shawn::BoolTag *pass_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
				pass_tag->set_value( true );
				oss.str("");
				oss << "target_movement_round_intervals_" << i;
				target_movement_round_intervals = se.required_int_param( oss.str() );
				oss.str("");
				oss << "target_movement_distance_intervals_" << i;
				target_movement_distance_intervals = se.required_double_param( oss.str() );
				oss.str("");
				oss << "target_spread_milis_" << i;
				target_spread_milis = se.required_int_param( oss.str() );
				oss.str("");
				oss << "target_transmission_power_" << i;
				target_transmission_power = se.required_int_param( oss.str() );
				oss.str("");
				oss << "trace_diminish_seconds_" << i;
				trace_diminish_seconds = se.required_int_param( oss.str() );
				oss.str("");
				oss << "trace_diminish_amount_" << i;
				trace_diminish_amount = se.required_int_param( oss.str() );
				oss.str("");
				oss << "trace_start_intensity_" << i;
				trace_start_intensity = se.required_int_param( oss.str() );
				oss.str("");
				oss << "target_color_" << i;
				target_color = se.required_int_param( oss.str() );
				shawn::IntegerTag *start_intensity_tag = new shawn::IntegerTag( "start_intensity", trace_start_intensity);
				owner_w().add_tag(start_intensity_tag);
				oss.str("");
				oss << "trace_spread_penalty_" << i;
				trace_spread_penalty = se.required_int_param( oss.str() );
				oss.str("");
				srand((unsigned int)(time(0)*owner().id()));
				destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0/*rand()%(long int)network_size_z*/);
				owner_w().add_tag(new shawn::DoubleTag("vis_node_color", (double) target_color) );
				oss.str("");
				oss << "target." << owner().id();
				this->owner_w().set_label(oss.str());
				os_.proc = this;
				target = new PLTT_Target( PLTT_Trace(trace_diminish_seconds, trace_diminish_amount, trace_spread_penalty, trace_start_intensity, 0), target_spread_milis, target_transmission_power );
				target->init(wiselib_radio_, wiselib_timer_, wiselib_clock_, wiselib_debug_);
				target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				target->enable();
				return;
			}
		}
		for (int i=0; i < number_of_trackers; i++)
		{
			ostringstream oss;
			oss << "tracker_id_" << i;
			if ( se.required_int_param( oss.str() )  == owner().id() )
			{
				TagHandle tag_h = owner_w().find_tag_w("tracker_tag");
				shawn::BoolTag *tra_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
				tra_tag->set_value( true );
				oss.str("");
				oss << "tracker_id_to_track_" << i;
				tracker_id_to_track = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_send_milis_" << i;
				tracker_send_milis = se.required_double_param( oss.str() );
				oss.str("");
				oss << "tracker_transmission_power_" << i;
				tracker_transmission_power = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_color_" << i;
				target_color = tracker_color = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_target_to_track_max_intensity_" << i;
				tracker_target_to_track_max_intensity = se.required_int_param( oss.str() );	
				oss.str("");
				oss << "tracker_movement_round_intervals_" << i;
				tracker_movement_round_intervals = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_movement_distance_intervals_" << i;
				tracker_movement_distance_intervals = se.required_double_param( oss.str() );
				oss.str("");
				oss << "tracker_spread_milis_" << i;
				tracker_spread_milis = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_transmission_power_as_target_" << i;
				tracker_transmission_power_as_target = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_trace_diminish_seconds_" << i;
				tracker_trace_diminish_seconds = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_trace_diminish_amount_" << i;
				tracker_trace_diminish_amount = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_trace_start_intensity_" << i;
				tracker_trace_start_intensity = se.required_int_param( oss.str() );
				oss.str("");
				oss << "tracker_trace_spread_penalty_" << i;
				tracker_trace_spread_penalty = se.required_int_param( oss.str() );
				srand((unsigned int)(time(0)*owner().id()));
				destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0/*rand()%(long int)network_size_z*/);
				owner_w().add_tag(new shawn::DoubleTag("vis_node_color", (double) tracker_color) );
				oss.str("");
				oss << "tracker." << owner().id();
				this->owner_w().set_label(oss.str());
				tracker = new PLTT_Tracker( tracker_id_to_track, tracker_target_to_track_max_intensity, tracker_send_milis, tracker_transmission_power );
				os_.proc = this;
				tracker->init( wiselib_radio_, wiselib_timer_, wiselib_rand_, wiselib_clock_, wiselib_debug_);
				tracker->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				tracker->set_metrics_timer( tracker_tracking_metrics_timer );
				tracker->enable();
				target = new PLTT_Target( PLTT_Trace(tracker_trace_diminish_seconds, tracker_trace_diminish_amount, tracker_trace_spread_penalty, tracker_trace_start_intensity, 0), tracker_spread_milis, tracker_transmission_power_as_target );
				target->init(wiselib_radio_, wiselib_timer_, wiselib_clock_, wiselib_debug_);
				target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				target->enable();
				wiselib_radio_.reg_recv_callback<PLTT_Processor, &PLTT_Processor::receive>(this);
				return;
			}
		}
		TagHandle tag_h = owner_w().find_tag_w("passive_tag");
		shawn::BoolTag *pass_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
		pass_tag->set_value( true );
		//WRITE CODE HERE PASSIVE
		owner_w().add_tag(new shawn::DoubleTag("vis_node_color", 222));
		ostringstream oss;
		oss << "passive." << owner().id();
		this->owner_w().set_label(oss.str());
		passive = new PLTT_Passive();
		neighbor_discovery = new NeighborDiscovery();
		os_.proc = this;
		passive->init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_rand_, wiselib_clock_, *neighbor_discovery );
		passive->set_self( PLTT_Node( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) ) );
		passive->enable();
		passive->set_intensity_detection_threshold( intensity_detection_threshold );
	#ifdef OPT_RELIABLE_TRACKING
		passive->set_reliable_agent_exp_time( reliable_tracking_expiration_time );
		passive->set_reliable_agent_rec_time( reliable_tracking_recurring_time );
		passive->set_reliable_millis_counter( reliable_tracking_daemon_time );
	#endif
	#ifdef PLTT_METRICS
		passive->set_metrics_timeout( metrics_timeout );
	#endif
		wiselib_radio_.reg_recv_callback<PLTT_Processor, &PLTT_Processor::receive>(this);
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::work( void ) throw()
	{

		shawn::ConstTagHandle passive_tag;
		passive_tag = owner().find_tag( "passive_tag" );
		const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
		if ( pass_tag->value() == true)
		{
			//WRITE CODE HERE PASSIVE
			tags_from_traces();
			if ( this->owner().world().simulation_round() == 1999 )
			{
						printf(" SMRN\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n ",
						owner().id(),
						passive->spread_messages_send,
						passive->inhibition_messages_send,
						passive->spread_messages_received,
						passive->inhibition_messages_received,
						passive->spread_messages_inhibited,
						passive->inhibition_messages_inhibited );
//						printf(" SMRP\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n ",
//						owner().id(),
//						passive->spread_messages_send_periodic,
//						passive->inhibition_messages_send_periodic,
//						passive->spread_messages_received_periodic,
//						passive->inhibition_messages_received_periodic,
//						passive->spread_messages_inhibited_periodic,
//						passive->inhibition_messages_inhibited_periodic );
			}
//						passive->spread_messages_send_periodic = 0;
//						passive->spread_messages_received_periodic = 0;
//						passive->spread_messages_inhibited_periodic = 0;
//						passive->inhibition_messages_send_periodic = 0;
//						passive->inhibition_messages_received_periodic = 0;
//						passive->inhibition_messages_inhibited_periodic = 0;
			return;
		}
		shawn::ConstTagHandle target_tag;
		target_tag = owner().find_tag( "target_tag" );
		const shawn::BoolTag* tar_tag = dynamic_cast<const shawn::BoolTag*>( target_tag.get() );
		if ( tar_tag->value() == true )
		{
			//WRITE CODE HERE TARGET
			if ( ( (int) ( ((int) owner().current_time() ) % target_movement_round_intervals == 0 ) ) && (owner().current_time() != 0) )
			{
				target_waypoint( destination );
				if ( euclidean_distance( owner().real_position(), destination ) <= target_movement_distance_intervals )
				{
					destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0/*rand()%(long int)network_size_z*/);
				}
			}
			return;
		}
		shawn::ConstTagHandle tracker_tag;
		tracker_tag = owner().find_tag( "tracker_tag" );
		const shawn::BoolTag* tra_tag = dynamic_cast<const shawn::BoolTag*>( tracker_tag.get() );
		if ( tra_tag->value() == true )
		{
			//WRITE CODE TRACKER
			if ( ( (int) ( ((int) owner().current_time() ) % tracker_movement_round_intervals == 0 ) ) && (owner().current_time() != 0) )
			{
				tracker_waypoint( destination );
				if ( euclidean_distance( owner().real_position(), destination ) <= tracker_movement_distance_intervals )
				{
					destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0/*rand()%(long int)network_size_z*/);
				}
			}
			return;
		}
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::target_waypoint(shawn::Vec destination)
	{
		double theta = atan2( ( destination.y() - owner().real_position().y()  ) , ( destination.x() - owner().real_position().x() ) );
		double x_int = cos( theta ) * target_movement_distance_intervals;
		double y_int = sin( theta ) * target_movement_distance_intervals;
		owner_w().set_real_position( shawn::Vec( owner().real_position().x() + x_int, owner().real_position().y() + y_int ) );
		target->get_self()->set_position( Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) );
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::tracker_waypoint(shawn::Vec destination)
	{
		double theta = atan2( ( destination.y() - owner().real_position().y()  ) , ( destination.x() - owner().real_position().x() ) );
		double x_int = cos( theta ) * tracker_movement_distance_intervals;
		double y_int = sin( theta ) * tracker_movement_distance_intervals;
		owner_w().set_real_position( shawn::Vec( owner().real_position().x() + x_int, owner().real_position().y() + y_int ) );
		tracker->get_self()->set_position( Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) );
		target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw()
	{
		shawn::ConstTagHandle passive_tag;
		passive_tag = owner().find_tag( "passive_tag" );
		const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
		if ( pass_tag->value() == true)
		{
			//WRITE CODE HERE PASSIVE
			return;
		}
		shawn::ConstTagHandle tracker_tag;
		tracker_tag = owner().find_tag( "tracker_tag" );
		const shawn::BoolTag* tra_tag = dynamic_cast<const shawn::BoolTag*>( tracker_tag.get() );
		if ( tra_tag->value() == true )
		{
			//WRITE CODE HERE TRACKER
			return;
		}
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::tags_from_traces( void ) throw()
	{
		shawn::TagContainer::tag_iterator ti = owner().begin_tags();
		while( ti != owner().end_tags() )
		{
			if ( ( ti->first != "passive_tag" ) && ( ti->first != "target_tag" ) && ( ti->first != "tracker_tag" ) && ( ti->first != "vis_node_color" ) && (ti->first != "start_intensity") )
			{
				TagHandle trace_tag = owner_w().find_tag_w(ti->first);
				shawn::IntegerTag* it = dynamic_cast<shawn::IntegerTag*>( trace_tag.get() );
				owner_w().remove_tag_by_name(ti->first);
			}
			++ti;
		}
		for (PLTT_TraceList::iterator tr_i = (passive->get_traces())->begin(); tr_i != (passive->get_traces())->end(); ++tr_i)
		{
			ostringstream oss, oss2, oss3;
			if ((tr_i->get_parent().get_id() > 0) && (tr_i->get_intensity()!=0))
			{
				const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
				oss2.str("");
				oss2 << "target_color_" << tr_i->get_target_id();
				int target_color = se.required_int_param( oss2.str() );

				oss3.str("");
				oss3 << "trace_start_intensity_" <<  tr_i->get_target_id();
				int start_intensity = se.required_int_param(oss3.str());

				oss << tr_i->get_parent().get_id() << "." << tr_i->get_target_id() << "." << target_color << "." << start_intensity;
				TagHandle tag_h = owner_w().find_tag_w(oss.str());
				if ( tag_h.is_not_null() )
				{
					shawn::IntegerTag* trace_tag = dynamic_cast<shawn::IntegerTag*>(tag_h.get() );
					trace_tag->set_value( tr_i->get_intensity() );
				}
				else
				{
					shawn::IntegerTag* trace_tag = new shawn::IntegerTag( oss.str(), tr_i->get_intensity() );
					owner_w().add_tag( trace_tag );
				}
			}
		}
	}


}
#endif
