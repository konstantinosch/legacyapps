#include "PLTT_processor.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_environment.h"
#include "sys/node.h"
#include "sys/taggings/basic_tags.h"
#include "sys/taggings/node_reference_tag.h"

namespace wiselib
{
	PLTT_Processor::PLTT_Processor()	:
			wiselib_radio_ ( os_ ),
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
		network_size_x = se.required_int_param( "network_size_x" );
		network_size_y = se.required_int_param( "network_size_y" );
		network_size_z = se.required_int_param( "network_size_z" );
		intensity_detection_threshold = se.required_int_param( "intensity_detection_threshold" );
		nb_convergence_time = se.required_int_param( "nb_convergence_time" );
		backoff_connectivity_weight = se.required_int_param( "backoff_connectivity_weight" );
		backoff_lqi_weight = se.required_int_param( "backoff_lqi_weight" );
		backoff_random_weight = se.required_int_param( "backoff_random_weight" );
		backoff_candidate_list_weight = se.required_int_param( "backoff_candidate_list_weight" );
		transmission_power_db = se.required_int_param( "transmission_power_db" );
		random_enable_timer_range = se.required_int_param( "random_enable_timer_range" );
#ifdef PLTT_SECURE
		decryption_request_timer = se.required_int_param( "decryption_request_timer" );
		decryption_request_offset = se.required_int_param( "decryption_request_offset" );
		decryption_max_retries = se.required_int_param( "decryption_max_retries" );
#endif
		shawn::BoolTag *target_tag = new shawn::BoolTag( "target_tag",false);
		owner_w().add_tag(target_tag);
		shawn::BoolTag *passive_tag = new shawn::BoolTag( "passive_tag",false);
		owner_w().add_tag(passive_tag);
#ifdef PLTT_SECURE
		shawn::BoolTag *central_authority_tag = new shawn::BoolTag( "central_authority_tag", false );
		owner_w().add_tag( central_authority_tag );
		shawn::BoolTag *helper_tag = new shawn::BoolTag( "helper_tag", false );
		owner_w().add_tag( helper_tag );
#endif
		for (int i=0; i< owner().world().active_nodes_count(); i++ )
		{
			ostringstream oss;
			oss << "central_authority_id_" << i;
			if ( se.optional_int_param( oss.str(), -1 ) == owner().id() )
			{
				os_.proc = this;
				owner_w().set_real_position( shawn::Vec( 0, 0, 0 ) );
				central_authority = new Privacy();
				central_authority->set_encryption();
				central_authority->init( wiselib_radio_, wiselib_debug_, wiselib_timer_ );
				central_authority->enable();
				return;
			}
		}
		for (int i=0; i < owner().world().active_nodes_count(); i++)
		{
			ostringstream oss;
			oss << "target_id_" << i;
			if ( se.optional_int_param( oss.str(), -1 ) == owner().id() )
			{
				owner_w().set_real_position( shawn::Vec( 0, 0, 0 ) );
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
				srand( (unsigned int)( time(0)*owner().id() ) );
				destination = shawn::Vec( rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0 );
				owner_w().add_tag(new shawn::DoubleTag( "vis_node_color", (double) target_color ) );
				oss.str("");
				oss << "target." << owner().id();
				this->owner_w().set_label(oss.str());
				os_.proc = this;
#ifndef PLTT_SECURE
				target = new PLTT_Target( PLTT_Trace( trace_diminish_seconds, trace_diminish_amount, trace_spread_penalty, trace_start_intensity, 0) , target_spread_milis, target_transmission_power );
#else
				INFO( logger(), "bla1" );
				target = new PLTT_Target( PLTT_SecureTrace( trace_diminish_seconds, trace_diminish_amount, trace_spread_penalty, trace_start_intensity, 0 ), target_spread_milis, target_transmission_power );
				INFO( logger(), "bla2" );
				privacy_target = new Privacy();
				privacy_target->set_randomization();
				target->set_request_id( i );
				privacy_target->init( wiselib_radio_, wiselib_debug_, wiselib_timer_ );
				target->reg_privacy_radio_callback<Privacy, &Privacy::radio_receive>( &(*privacy_target) );
				privacy_target->reg_privacy_callback<PLTT_Target, &PLTT_Target::randomize_callback>( 999, &(*target) );
				privacy_target->enable();
#endif
				target->init(wiselib_radio_, wiselib_timer_, wiselib_clock_, wiselib_debug_);
				target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				target->enable();
				return;
			}
			else
			{

			}
		}
		TagHandle tag_h = owner_w().find_tag_w("passive_tag");
		shawn::BoolTag *pass_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
		pass_tag->set_value( true );
		//WRITE CODE HERE PASSIVE
		owner_w().add_tag(new shawn::DoubleTag( "vis_node_color", 222 ) );
		ostringstream oss;
		oss << "passive." << owner().id();
		this->owner_w().set_label(oss.str());
		//passive = new PLTT_Passive();
		//neighbor_discovery = new NeighborDiscovery();

		os_.proc = this;
		//passive->init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_rand_, wiselib_clock_, *neighbor_discovery );
		//neighbor_discovery->init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_ );
		//passive->set_self( PLTT_Node( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) ) );
		//passive->set_intensity_detection_threshold( intensity_detection_threshold );
		//passive->set_nb_convergence_time( nb_convergence_time );
		//passive->set_backoff_connectivity_weight( backoff_connectivity_weight );
		//passive->set_backoff_lqi_weight( backoff_lqi_weight );
		//passive->set_backoff_random_weight( backoff_random_weight );
		//passive->set_backoff_candidate_list_weight( backoff_candidate_list_weight );
		//passive->set_transmission_power_dB( transmission_power_db );
		//passive->set_random_enable_timer_range( random_enable_timer_range );
#ifdef PLTT_SECURE
		//passive->set_decryption_request_timer( decryption_request_timer );
		//passive->set_decryption_request_offset( decryption_request_offset );
		//passive->set_decryption_max_retries( decryption_max_retries );
#endif
		//passive->enable();
		//wiselib_radio_.reg_recv_callback<PLTT_Processor, &PLTT_Processor::receive>(this);
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::work( void ) throw()
	{
		INFO( logger(), "bla1" );
//		shawn::ConstTagHandle passive_tag;
//		passive_tag = owner().find_tag( "passive_tag" );
//		const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
//		if ( pass_tag->value() == true)
//		{
//			//WRITE CODE HERE PASSIVE
//			tags_from_traces();
//			return;
//		}

//		shawn::ConstTagHandle target_tag;
//		target_tag = owner().find_tag( "target_tag" );
//		const shawn::BoolTag* tar_tag = dynamic_cast<const shawn::BoolTag*>( target_tag.get() );
//		if ( tar_tag->value() == true )
//		{
//			//WRITE CODE HERE TARGET
//			if ( ( (int) ( ((int) owner().current_time() ) % target_movement_round_intervals == 0 ) ) && (owner().current_time() != 0) )
//			{
//				target_waypoint( destination );
//				if ( euclidean_distance( owner().real_position(), destination ) <= target_movement_distance_intervals )
//				{
//					destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0);
//				}
//			}
//			return;
//		}

//		if ( owner().current_time() == 500 )
//		{
//			NeighborDiscovery::Protocol* p;
//			wiselib_debug_.debug("----tr-----\n", owner().id() );
//			wiselib_debug_.debug(" node id %x\n", owner().id() );
//			p = neighbor_discovery->get_protocol_ref( NeighborDiscovery::TRACKING_PROTOCOL_ID );
//			p->print( wiselib_debug_, wiselib_radio_ );
//			wiselib_debug_.debug("-----------\n", owner().id() );
//			wiselib_debug_.debug("----vs-----\n", owner().id() );
//			wiselib_debug_.debug("----nb-----\n", owner().id() );
//			wiselib_debug_.debug(" node id %x\n", owner().id() );
//			p = neighbor_discovery->get_protocol_ref( NeighborDiscovery::NB_PROTOCOL_ID );
//			p->print( wiselib_debug_, wiselib_radio_ );
//			wiselib_debug_.debug("-----------\n", owner().id() );
//		}
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::target_waypoint(shawn::Vec destination)
	{
//		double theta = atan2( ( destination.y() - owner().real_position().y()  ) , ( destination.x() - owner().real_position().x() ) );
//		double x_int = cos( theta ) * target_movement_distance_intervals;
//		double y_int = sin( theta ) * target_movement_distance_intervals;
//		owner_w().set_real_position( shawn::Vec( owner().real_position().x() + x_int, owner().real_position().y() + y_int ) );
//		target->get_self()->set_position( Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) );
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw()
	{
//		if ( from != owner().id() )
//		{
//			shawn::ConstTagHandle passive_tag;
//			passive_tag = owner().find_tag( "passive_tag" );
//			const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
//			if ( pass_tag->value() == true)
//			{
//				//WRITE CODE HERE PASSIVE
//				return;
//			}
//		}
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::tags_from_traces( void ) throw()
	{
//		shawn::TagContainer::tag_iterator ti = owner().begin_tags();
//		while( ti != owner().end_tags() )
//		{
//			if ( ( ti->first != "passive_tag" ) && ( ti->first != "target_tag" ) /*&& ( ti->first != "tracker_tag" ) */&& ( ti->first != "vis_node_color" ) && (ti->first != "start_intensity") )
//			{
//				TagHandle trace_tag = owner_w().find_tag_w(ti->first);
//				shawn::IntegerTag* it = dynamic_cast<shawn::IntegerTag*>( trace_tag.get() );
//				owner_w().remove_tag_by_name(ti->first);
//			}
//			++ti;
//		}
//		for (PLTT_TraceList::iterator tr_i = (passive->get_traces())->begin(); tr_i != (passive->get_traces())->end(); ++tr_i)
//		{
//			ostringstream oss, oss2, oss3;
//			if ((tr_i->get_parent().get_id() > 0) && (tr_i->get_intensity()!=0))
//			{
//				const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
//				oss2.str("");
//				oss2 << "target_color_" << tr_i->get_target_id();
//				int target_color = se.required_int_param( oss2.str() );
//
//				oss3.str("");
//				oss3 << "trace_start_intensity_" <<  tr_i->get_target_id();
//				int start_intensity = se.required_int_param(oss3.str());
//
//				oss << tr_i->get_parent().get_id() << "." << tr_i->get_target_id() << "." << target_color << "." << start_intensity;
//				TagHandle tag_h = owner_w().find_tag_w(oss.str());
//				if ( tag_h.is_not_null() )
//				{
//					shawn::IntegerTag* trace_tag = dynamic_cast<shawn::IntegerTag*>(tag_h.get() );
//					trace_tag->set_value( tr_i->get_intensity() );
//				}
//				else
//				{
//					shawn::IntegerTag* trace_tag = new shawn::IntegerTag( oss.str(), tr_i->get_intensity() );
//					owner_w().add_tag( trace_tag );
//				}
//			}
//		}
	}
}
#endif
