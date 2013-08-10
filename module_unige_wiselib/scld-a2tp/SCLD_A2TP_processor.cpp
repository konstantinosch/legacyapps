#include "SCLD_A2TP_processor.h"
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
	SCLD_A2TP_Processor::SCLD_A2TP_Processor()	:
		wiselib_radio_	( os_ ),
		wiselib_timer_	( os_ ),
		wiselib_debug_	( os_ ),
		wiselib_rand_	( os_ ),
		wiselib_clock_	( os_ )
	{
		wiselib_reliable_radio_.init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
	}
	//-------------------------------------------------------------------------------------------------
	SCLD_A2TP_Processor::~SCLD_A2TP_Processor()
	{}
	//-------------------------------------------------------------------------------------------------
	void SCLD_A2TP_Processor::boot( void ) throw()
	{
		const shawn::SimulationEnvironment& se = owner().world().simulation_controller().environment();
		ostringstream oss;
		oss << "boot: " << owner().id();
		//***topology attributes
		network_size_x = se.required_int_param( "network_size_x" );
		network_size_y = se.required_int_param( "network_size_y" );
		network_size_z = se.required_int_param( "network_size_z" );
		if (owner().id() == 0 ) { printf("TOPO:%f:%f:%f\n",network_size_x, network_size_y, network_size_z ); }
		os_.proc = this;
		wiselib_radio_.reg_recv_callback<SCLD_A2TP_Processor, &SCLD_A2TP_Processor::receive>(this);
	    wiselib_rand_.srand( wiselib_radio_.id() );
#ifdef CONFIG_SCLD_ATP_RELIABLE_RADIO
	    reliable_radio.init(  wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
	    reliable_radio.enable_radio();
	    neighbor_discovery.init( reliable_radio, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
	    at2p.init( reliable_radio, wiselib_timer_, wiselib_debug_, wiselib_rand_, wiselib_clock_, neighbor_discovery );
	    at2p.enable();
#else
		neighbor_discovery.set_position( owner().real_position().x(), owner().real_position().y(), owner().real_position().z() );
	    neighbor_discovery.init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_clock_, wiselib_rand_ );
	    a2tp.init( wiselib_radio_, wiselib_timer_, wiselib_debug_, wiselib_rand_, wiselib_clock_, neighbor_discovery );
	    a2tp.enable();
#endif
	}
	//-------------------------------------------------------------------------------------------------
	void SCLD_A2TP_Processor::work( void ) throw()
	{
		return;
	}
	//-------------------------------------------------------------------------------------------------
	void SCLD_A2TP_Processor::receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw()
	{
		if ( from != owner().id() )
		{
			return;
		}
	}
	//-------------------------------------------------------------------------------------------------
}
#endif
