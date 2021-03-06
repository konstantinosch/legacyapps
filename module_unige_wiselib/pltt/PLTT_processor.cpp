#ifndef __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_PLTT_PROCESSOR_H
#else
#include "PLTT_processor.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_environment.h"
#include "sys/node.h"
#include "sys/taggings/basic_tags.h"
#include "sys/taggings/node_reference_tag.h"
#include "sys/communication_model.h"
#include "math.h"

namespace wiselib
{
	PLTT_Processor::PLTT_Processor()	:
		wiselib_radio_	( os_ ),
		wiselib_timer_	( os_ ),
		wiselib_debug_	( os_ ),
		wiselib_rand_	( os_ ),
		wiselib_clock_	( os_ )
	{
		wiselib_reliable_radio_.init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
	}
	//-------------------------------------------------------------------------------------------------
	PLTT_Processor::~PLTT_Processor()
	{}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::boot( void ) throw()
	{
		first_time_pos = 0;

		const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();

		//***topology attributes
		network_size_x = se.required_int_param( "network_size_x" );
		network_size_y = se.required_int_param( "network_size_y" );
		network_size_z = se.required_int_param( "network_size_z" );
		if (owner().id() == 0 ) { printf("TOPO:%f:%f:%f\n",network_size_x, network_size_y, network_size_z ); }
		//***

		//***passive node attributes
		intensity_detection_threshold = se.required_int_param( "intensity_detection_threshold" );
		intensity_ticks = se.required_int_param( "intensity_ticks" );
		nb_convergence_time = se.required_int_param( "nb_convergence_time" );
		nb_convergence_time_max_counter = se.required_int_param( "nb_convergence_time_max_counter" );
		nb_connections_high = se.required_int_param( "nb_connections_high" );
		nb_connections_low = se.required_int_param( "nb_connections_low" );
		backoff_connectivity_weight = se.required_int_param( "backoff_connectivity_weight" );
		backoff_lqi_weight = se.required_int_param( "backoff_lqi_weight" );
		backoff_random_weight = se.required_int_param( "backoff_random_weight" );
		backoff_candidate_list_weight = se.required_int_param( "backoff_candidate_list_weight" );
		transmission_power_db = se.required_int_param( "transmission_power_db" );
		random_enable_timer_range = se.required_int_param( "random_enable_timer_range" );
		inhibition_spread_offset_millis_ratio = se.required_int_param( "inhibition_spread_offset_millis_ratio" );
		agent_hop_count_limit = se.required_int_param( "agent_hop_count_limit" );
		stats_daemon_period = se.required_int_param( "stats_daemon_period" );
		//***

#ifdef CONFIG_PLTT_PRIVACY
		//***privacy_node attributes
		decryption_request_timer = se.required_int_param( "decryption_request_timer" );
		decryption_request_offset = se.required_int_param( "decryption_request_offset" );
		decryption_max_retries = se.required_int_param( "decryption_max_retries" );
		helper_color = se.required_int_param( "helper_color" );
		privacy_power_db = se.required_int_param( "privacy_power_db");
		//***
#endif

		//**tracking tags setup
		shawn::BoolTag *target_tag = new shawn::BoolTag( "target_tag",false );
		owner_w().add_tag( target_tag );
		shawn::BoolTag *passive_tag = new shawn::BoolTag( "passive_tag",false );
		owner_w().add_tag( passive_tag );
		shawn::BoolTag *tracker_tag = new shawn::BoolTag( "tracker_tag",false );
		owner_w().add_tag( tracker_tag );
		//**

#ifdef CONFIG_PLTT_PRIVACY
		//***privacy tags setup
		shawn::BoolTag *central_authority_tag = new shawn::BoolTag( "central_authority_tag", false );
		owner_w().add_tag( central_authority_tag );
		shawn::BoolTag *helper_tag = new shawn::BoolTag( "helper_tag", false );
		owner_w().add_tag( helper_tag );
		//***

		//***helper nodes
		double r_ratio_copy = se.required_double_param( "r_ratio_copy" );
		double beta_copy = se.required_double_param( "beta_copy" );
		double Px = se.required_double_param( "Px" );

		communication_range = std::pow( 10.0, privacy_power_db / 30.0 ) * owner().world().communication_model().communication_upper_bound();
		double R_range =  communication_range * ( r_ratio_copy / 100 );
		CoordinatesNumber helper_d = R_range * pow( ( 2 * ( 1 - Px/100 ) ), 1 / ( 2 * beta_copy ) ); //only compatible with shadow log fade at the moment.
		CoordinatesNumber helper_step_x = floor( network_size_x / ( helper_d / sqrt( 2 ) ) );
		CoordinatesNumber helper_step_y = floor( network_size_y / ( helper_d / sqrt( 2 ) ) );
		CoordinatesNumber helper_step_z = floor( network_size_z / ( helper_d / sqrt( 2 ) ) );

		//cout << "r_ratio_copy=" << r_ratio_copy << ", beta_copy=" << beta_copy << ", Px=" << Px <<endl;
		//cout << "communication_range=transm_power * sim_range_upper_bound [" << std::pow(10.0, privacy_power_db / 30.0 ) << " * " << owner().world().communication_model().communication_upper_bound() << "=" << communication_range << "]" << endl;
		//cout << "(distance for Px=" << Px / 100 << ") helper_d=" << helper_d << endl;

		int helper_i = owner().id();
		if ( helper_i < helper_step_x * helper_step_y ) //picks the first nodes based on their sequential id's that are enough to cover the topology based on the above computations
		{
			//cout << "helper grid range : " << helper_d;
			TagHandle tag_h = owner_w().find_tag_w("helper_tag");
			shawn::BoolTag *hlpr_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
			hlpr_tag->set_value( true );
			owner_w().add_tag(new shawn::DoubleTag( "vis_node_color", helper_color ) );
			CoordinatesNumber index_j = ( (int) helper_i ) % ( (int) helper_step_x ) ;
			CoordinatesNumber index_i = ( (int) helper_i ) / ( (int) helper_step_x );
			CoordinatesNumber helper_coord_y = ( network_size_x / helper_step_x ) / 2 + index_i * ( network_size_x / helper_step_x );
			CoordinatesNumber helper_coord_x = ( network_size_y / helper_step_y ) / 2 + index_j * ( network_size_y / helper_step_y );
			CoordinatesNumber helper_coord_z = 0;
			//printf("helper %d - helper_d %f : stepx %f : stepy %f : stepz %f\n", helper_i, helper_d, helper_step_x, helper_step_y, helper_step_z );
			//printf(" coordx : %f, coordy : %f, coordz %f : index_i : %f, index_j : %f\n", helper_coord_x, helper_coord_y, helper_coord_z, index_i, index_j ); //places the helper nodes on a full coverage grid
			owner_w().set_real_position( shawn::Vec( helper_coord_x, helper_coord_y, helper_coord_z ) );
			os_.proc = this;
			helper = new Privacy();
			helper->set_decryption();
			helper->init( wiselib_radio_, wiselib_debug_, wiselib_timer_ );
			helper->set_privacy_power_db( privacy_power_db );
			helper->enable();
			return;
		}
		//***

		//***central_authority
		if ( owner().id() == helper_step_x * helper_step_y )
		{
			TagHandle tag_h = owner_w().find_tag_w( "central_authority_tag" );
			shawn::BoolTag *ca_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
			ca_tag->set_value( true );
			os_.proc = this;
			owner_w().set_real_position( shawn::Vec( 0, 0, 0 ) );
			central_authority = new Privacy();
			central_authority->set_encryption();
			central_authority->init( wiselib_radio_, wiselib_debug_, wiselib_timer_ );
			central_authority->set_privacy_power_db( privacy_power_db );
			central_authority->enable();
			return;
		}
		//***

#endif
		//***target nodes
		for ( int i=0; i < owner().world().active_nodes_count(); i++ )
		{
			ostringstream oss;
			oss << "target_id_" << i;
			if ( se.optional_int_param( oss.str(), -1 ) == owner().id() )
			{
				owner_w().set_real_position( shawn::Vec( 0, 0, 0 ) );
				TagHandle tag_h = owner_w().find_tag_w( "target_tag" );
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
				oss << "target_init_spread_milis_" << i;
				target_init_spread_milis = se.required_int_param( oss.str() );
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
				os_.proc = this;
#ifndef CONFIG_PLTT_PRIVACY
				target = new PLTT_Target( PLTT_Trace( trace_diminish_seconds, trace_diminish_amount, trace_spread_penalty, trace_start_intensity, 0) , target_spread_milis, target_init_spread_milis, target_transmission_power );
#else
				target = new PLTT_Target( PLTT_PrivacyTrace( trace_diminish_seconds, trace_diminish_amount, trace_spread_penalty, trace_start_intensity, 0 ), target_spread_milis, target_init_spread_milis, target_transmission_power );
				privacy_target = new Privacy();
				privacy_target->set_randomization();
				target->set_request_id( i );
				privacy_target->init( wiselib_radio_, wiselib_debug_, wiselib_timer_ );
				target->reg_privacy_radio_callback<Privacy, &Privacy::radio_receive>( &(*privacy_target) );
				privacy_target->reg_privacy_callback<PLTT_Target, &PLTT_Target::randomize_callback>( 999, &(*target) );
				privacy_target->set_privacy_power_db( privacy_power_db );
				privacy_target->enable();
#endif
				target->init(wiselib_radio_, wiselib_timer_, wiselib_clock_, wiselib_debug_);
				target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				target->enable();

				oss.str("");
				oss << "tracker_id_" << i;
				if ( se.optional_int_param( oss.str(), -1 ) == owner().id() )
				{
					owner_w().set_real_position( shawn::Vec( 0, 0, 0 ) );
					TagHandle tag_h = owner_w().find_tag_w( "tracker_tag" );
					shawn::BoolTag *pass_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
					pass_tag->set_value( true );
					oss.str("");
					oss << "tracker_transmission_power_" << i;
					tracker_transmission_power = se.required_int_param( oss.str() );
					oss.str("");
					oss << "target_id_to_track_" << i;
					target_id_to_track = se.required_int_param( oss.str() );
					oss.str("");
					oss << "target_id_to_track_max_intensity_" << i;
					target_id_to_track_max_intensity = se.required_int_param( oss.str() );
					oss.str("");
					oss << "init_tracking_millis_" << i;
					init_tracking_millis = se.required_int_param( oss.str() );
					oss.str("");
					oss << "tracker_generate_agent_period_" << i;
					tracker_generate_agent_period = se.required_int_param( oss.str() );
					oss.str("");
					oss << "tracker_generate_agent_period_offset_ratio_" << i;
					tracker_generate_agent_period_offset_ratio = se.required_int_param( oss.str() );
					oss.str("");
					oss << "tracker_mini_run_times_" << i;
					tracker_mini_run_times = se.required_int_param( oss.str() );
					oss.str("");
					oss << "tracker_agent_daemon_period_" << i;
					tracker_agent_daemon_period = se.required_int_param( oss.str() );
					oss.str("");
					oss << "tracker_agent_list_max_count_" << i;
					tracker_agent_list_max_count = se.required_int_param( oss.str() );
					tracker = new PLTT_Tracker(	target_id_to_track, target_id_to_track_max_intensity, tracker_transmission_power,
												init_tracking_millis,	tracker_generate_agent_period, tracker_generate_agent_period_offset_ratio,
												tracker_mini_run_times );//, tracker_agent_daemon_period, tracker_agent_list_max_count );
					tracker->init( wiselib_radio_, wiselib_reliable_radio_, wiselib_timer_, wiselib_rand_, wiselib_clock_, wiselib_debug_ );
					tracker->enable();
				}
				return;
			}
		}
		//***

		//***passive nodes (leftovers)
		TagHandle tag_h = owner_w().find_tag_w("passive_tag");
		shawn::BoolTag *pass_tag = dynamic_cast<shawn::BoolTag*>( tag_h.get() );
		pass_tag->set_value( true );
		owner_w().add_tag(new shawn::DoubleTag( "vis_node_color", 222 ) );
		ostringstream oss;
		oss << "passive." << owner().id();
		passive = new PLTT_Passive();
		neighbor_discovery = new NeighborDiscovery();
		//neighbor_discovery->set_coords( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() );
		os_.proc = this;
		passive->init( wiselib_radio_, wiselib_reliable_radio_, wiselib_timer_, wiselib_debug_, wiselib_rand_, wiselib_clock_, *neighbor_discovery );
		neighbor_discovery->init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
		passive->set_self( PLTT_Node( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) ) );
		passive->set_intensity_detection_threshold( intensity_detection_threshold );
		passive->set_intensity_ticks( intensity_ticks );
		passive->set_nb_convergence_time( nb_convergence_time );
		passive->set_nb_convergence_time_max_counter( nb_convergence_time_max_counter );
		passive->set_nb_connections_high( nb_connections_high );
		passive->set_nb_connections_low( nb_connections_low );
		passive->set_backoff_connectivity_weight( backoff_connectivity_weight );
		passive->set_backoff_lqi_weight( backoff_lqi_weight );
		passive->set_backoff_random_weight( backoff_random_weight );
		passive->set_backoff_candidate_list_weight( backoff_candidate_list_weight );
		passive->set_transmission_power_dB( transmission_power_db );
		passive->set_random_enable_timer_range( random_enable_timer_range );
#ifdef CONFIG_PLTT_PRIVACY
		passive->set_decryption_request_timer( decryption_request_timer );
		passive->set_decryption_request_offset( decryption_request_offset );
		passive->set_decryption_max_retries( decryption_max_retries );
		passive->set_agent_hop_count_limit( agent_hop_count_limit );
#endif
#ifdef DEBUG_PLTT_STATS
		passive->set_stats_daemon_period( stats_daemon_period );
#endif
		passive->enable();
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
			//**
			//PASSIVE SPECIFIC CODE
			//**
			tags_from_traces();
			//wiselib_debug_.debug(" time : %f", owner().current_time() );
			//wiselib_debug_.debug( "nb status %d \n", neighbor_discovery->get_status() );
			//cout << "passive_id : " << passive->get_self()->get_node().get_id() << " [" << passive->get_self()->get_node().get_position().get_x() << ", " << passive->get_self()->get_node().get_position().get_y() << "], range = " << owner().transmission_range() << endl;
			//if ( owner().current_time() == 129 )
			//{
				NeighborDiscovery::Protocol* p;
				//wiselib_debug_.debug("----tr-----\n", owner().id() );
				//wiselib_debug_.debug(" node id %x\n", owner().id() );
				//p = neighbor_discovery->get_protocol_ref( NeighborDiscovery::TRACKING_PROTOCOL_ID );
			//	if ( p!= NULL )
			//	{
					//p->print( wiselib_debug_, wiselib_radio_ );
					//wiselib_debug_.debug("-----------\n", owner().id() );
					//wiselib_debug_.debug("----vs-----\n", owner().id() );
					//wiselib_debug_.debug("----nb-----\n", owner().id() );
					//wiselib_debug_.debug(" node id %x\n", owner().id() );
					//p = neighbor_discovery->get_protocol_ref( NeighborDiscovery::NB_PROTOCOL_ID );
					//p->print( wiselib_debug_, wiselib_radio_ );
					//wiselib_debug_.debug("-----------\n", owner().id() );
			//	}
			//}
			return;
		}

		shawn::ConstTagHandle target_tag;
		target_tag = owner().find_tag( "target_tag" );
		const shawn::BoolTag* tar_tag = dynamic_cast<const shawn::BoolTag*>( target_tag.get() );
		if ( tar_tag->value() == true )
		{
			//**
			//TARGET SPECIFIC CODE
			//**
			if ( target->get_init_spread_millis() < owner().current_time() * 1000 )
			{
				//target->get_self().get_position_ref()->set_x();
				//target->get_self().get_position_ref()->set_y();
				//set_xy( owner().real_position().x(), owner().real_position().y() );
//#ifdef CONFIG_PLTT_PRIVACY
//				if ( ( target->get_has_encrypted_id() == 1 ) && ( first_time_pos == 0 ) )
//				{
//					owner_w().set_real_position( shawn::Vec( rand()%30, rand()%30 ) );
//					target->get_self()->set_position( Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) );
//					first_time_pos = 1;
//				}
//#endif
				target->set_self( Node( wiselib_radio_.id(), Position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() ) ) );
				if ( ( (int) ( ((int) owner().current_time() ) % target_movement_round_intervals == 0 ) ) && (owner().current_time() != 0) )
				{
					target_waypoint( destination );
					if ( euclidean_distance( owner().real_position(), destination ) <= target_movement_distance_intervals )
					{
						destination = shawn::Vec(rand()%(long int)network_size_x, rand()%(long int)network_size_y, 0);
					}
				}
			//cout << "target_id : " << target->get_self()->get_id() << " [" << target->get_self()->get_position().get_x() << ", " << target->get_self()->get_position().get_y() << "], range = " << owner().transmission_range() << endl;
			}
		}

		shawn::ConstTagHandle tracker_tag;
		tracker_tag = owner().find_tag( "tracker_tag" );
		const shawn::BoolTag* tra_tag = dynamic_cast<const shawn::BoolTag*>( tracker_tag.get() );
		if ( tra_tag->value() == true )
		{
			//**
			//tracker SPECIFIC CODE
			//**
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
	void PLTT_Processor::receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw()
	{
		if ( from != owner().id() )
		{
			shawn::ConstTagHandle passive_tag;
			passive_tag = owner().find_tag( "passive_tag" );
			const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
			if ( pass_tag->value() == true)
			{
				//**
				//PASSIVE SPECIFIC CODE
				//**
				return;
			}
		}
	}
	//-------------------------------------------------------------------------------------------------
	void PLTT_Processor::tags_from_traces( void ) throw()
	{
		shawn::TagContainer::tag_iterator ti = owner().begin_tags();
		while( ti != owner().end_tags() )
		{
			TagHandle trace_tag = owner_w().find_tag_w(ti->first);
			if ( (ti->first).substr(0,10) == "pltt_edge." )
			{
				shawn::IntegerTag* it = dynamic_cast<shawn::IntegerTag*>( trace_tag.get() );
				owner_w().remove_tag_by_name(ti->first);
			}
			++ti;
		}
		for ( PLTT_TraceList::iterator tr_i = ( passive->get_traces())->begin(); tr_i != ( passive->get_traces() )->end(); ++tr_i )
		{
			ostringstream oss, oss2, oss3;
			if ( (tr_i->get_parent().get_id() > 0) && (tr_i->get_intensity()!=0) && ( tr_i->get_target_id() != 0 ) )
			{
				const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
				oss2.str("");
				oss2 << "target_color_" << tr_i->get_target_id();
				int target_color = se.required_int_param( oss2.str() );

				oss3.str("");
				oss3 << "trace_start_intensity_" <<  tr_i->get_target_id();
				int start_intensity = se.required_int_param(oss3.str());

				oss << "pltt_edge." << tr_i->get_parent().get_id() << "." << tr_i->get_target_id() << "." << target_color << "." << start_intensity;
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
#endif
