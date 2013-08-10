#ifndef __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_SCLD_A2TP_PROCESSOR_H
#define __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_SCLD_A2TP_PROCESSOR_H
#include "/home/konstantinos/Desktop/shawn/buildfiles/_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

#include "apps/wiselib/ext_iface_processor.h"
#include "sys/processor.h"
#include "sys/event_scheduler.h"
#include "../../../wiselib/wiselib.testing/external_interface/shawn/shawn_os.h"
#include "../../../wiselib/wiselib.stable/util/serialization/simple_types.h"
#include "../../../wiselib/wiselib.stable/util/pstl/vector_static.h"
#include "../../../wiselib/wiselib.testing/internal_interface/node/node_new.h"
#include "../../../wiselib/wiselib.testing/internal_interface/position/position_new.h"
#include "../../../wiselib/wiselib.testing/algorithms/neighbor_discovery/neighbor_discovery.h"
#include "../../../wiselib/wiselib.testing/radio/reliable/reliable_radio.h"
#include "../../../wiselib/wiselib.testing/algorithms/topology/atp/ATP.h"
#include <iostream>
#include <sstream>
#include "sys/vec.h"
#include <ctime>
#include <cstdlib>
#include <math.h>


using namespace shawn;
using namespace std;

namespace wiselib
{

typedef wiselib::ShawnOsModel Os;
typedef Os::TxRadio Radio;
typedef Radio::node_id_t node_id_t;
typedef Radio::ExtendedData ExtendedData;
typedef Os::Debug Debug;
typedef Os::Rand Rand;
typedef Os::Timer Timer;
typedef Os::Clock Clock;
typedef int AgentID;
typedef double CoordinatesNumber;
typedef wiselib::ReliableRadio_Type<Os, Radio, Clock, Timer, Rand, Debug> ReliableRadio;
#ifdef CONFIG_SCLD_ATP_RELIABLE_RADIO
	typedef wiselib::NeighborDiscovery_Type<Os, ReliableRadio, Clock, Timer, Rand, Debug> NeighborDiscovery;
	typedef wiselib::ATP_Type<Os, ReliableRadio, NeighborDiscovery, Timer, Rand, Clock, Debug> ATP;
#else
	typedef wiselib::NeighborDiscovery_Type<Os, Radio, Clock, Timer, Rand, Debug> NeighborDiscovery;
	typedef wiselib::ATP_Type<Os, Radio, NeighborDiscovery, Timer, Rand, Clock, Debug> ATP;
#endif
	class SCLD_A2TP_Processor : public virtual ExtIfaceProcessor
	{
	public:
		SCLD_A2TP_Processor();
		virtual ~SCLD_A2TP_Processor();
		virtual void boot( void ) throw();
		virtual void work( void ) throw();
		void receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw();
private:
		NeighborDiscovery neighbor_discovery;
		ShawnOs os_;
		Radio wiselib_radio_;
		ReliableRadio wiselib_reliable_radio_;
		Timer wiselib_timer_;
		Debug wiselib_debug_;
		Rand wiselib_rand_;
		Clock wiselib_clock_;
		CoordinatesNumber network_size_x;
		CoordinatesNumber network_size_y;
		CoordinatesNumber network_size_z;
		ATP a2tp;
	};
}

#endif
#endif

