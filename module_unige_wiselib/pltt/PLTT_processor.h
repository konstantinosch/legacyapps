#ifndef __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_PLTT_PROCESSOR_H
#define __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_PLTT_PROCESSOR_H
#include "/home/konstantinos/Desktop/shawn/buildfiles/_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

//#define PLTT_SECURE

#include "apps/wiselib/ext_iface_processor.h"
#include "sys/processor.h"
#include "sys/event_scheduler.h"
#include "../../../wiselib/wiselib.testing/external_interface/shawn/shawn_os.h"
#include "../../../wiselib/wiselib.stable/util/serialization/simple_types.h"
#include "../../../wiselib/wiselib.stable/util/pstl/vector_static.h"
#include "../../../wiselib/wiselib.testing/internal_interface/node/node_new.h"
#include "../../../wiselib/wiselib.testing/internal_interface/position/position_new.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_node.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_node_target.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_trace_revision.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_passive_nb_revision.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_target.h"
#include "../../../wiselib/wiselib.testing/algorithms/neighbor_discovery/neighbor_discovery.h"
#include <iostream>
#include <sstream>
#include "sys/vec.h"
#include <ctime>
#include <cstdlib>
#include <math.h>

#ifdef PLTT_SECURE
#include "../../../wiselib/wiselib.testing/algorithms/privacy/privacy.h"
#include "../../../wiselib/wiselib.testing/algorithms/privacy/privacy_message.h"
#include "../../../wiselib/wiselib.testing/algorithms/tracking/PLTT_secure_trace_revision.h"
#define MAX_SECURE_TRACES_SUPPORTED 400
#endif

#define MAX_NEIGHBORS_SUPPORTED 400
#define MAX_TARGETS_SUPPORTED 400

using namespace shawn;
using namespace std;

namespace wiselib
{

typedef wiselib::ShawnOsModel Os;
typedef Os::TxRadio Radio;
typedef Radio::node_id_t node_id_t;
typedef Radio::ExtendedData ExtendedData;
typedef Os::Rand Rand;
typedef Os::Debug Debug;
typedef Os::Clock Clock;
typedef Os::Timer Timer;
typedef Timer::millis_t millis_t;
typedef double CoordinatesNumber;
typedef int8_t IntensityNumber;
typedef int TimesNumber;
typedef int SecondsNumber;

typedef wiselib::Position2DType<Os, Radio, CoordinatesNumber, Debug> Position;
typedef wiselib::NodeType<Os, Radio, node_id_t, Position, Debug> Node;
typedef wiselib::NeighborDiscovery_Type<Os, Radio, Clock, Timer, Debug> NeighborDiscovery;
#ifdef PLTT_SECURE
typedef wiselib::PLTT_SecureTraceType<Os, Radio, TimesNumber, SecondsNumber, IntensityNumber, Node, node_id_t, Debug> PLTT_SecureTrace;
typedef wiselib::vector_static<Os, PLTT_SecureTrace, MAX_SECURE_TRACES_SUPPORTED> PLTT_SecureTraceList;
typedef wiselib::PrivacyMessageType<Os, Radio> PrivacyMessage;
typedef wiselib::vector_static<Os, PrivacyMessage, 100> PrivacyMessageList;
typedef wiselib::PrivacyType<Os, Radio, Timer, PrivacyMessage, PrivacyMessageList, Debug> Privacy;
#endif
typedef wiselib::PLTT_TraceType<Os, Radio, TimesNumber, SecondsNumber, IntensityNumber, Node, node_id_t, Debug> PLTT_Trace;
typedef wiselib::vector_static<Os, PLTT_Trace, MAX_TARGETS_SUPPORTED> PLTT_TraceList;
typedef wiselib::PLTT_NodeTargetType<Os, Radio, node_id_t, IntensityNumber, Debug > PLTT_NodeTarget;
typedef wiselib::vector_static<Os, PLTT_NodeTarget, MAX_TARGETS_SUPPORTED> PLTT_NodeTargetList;
typedef wiselib::PLTT_NodeType<Os, Radio, Node, PLTT_NodeTarget, PLTT_NodeTargetList, PLTT_TraceList, Debug> PLTT_Node;
typedef wiselib::vector_static<Os, PLTT_Node, MAX_NEIGHBORS_SUPPORTED> PLTT_NodeList;
#ifdef PLTT_SECURE
typedef wiselib::PLTT_PassiveType<Os, Node, PLTT_Node, PLTT_NodeList, PLTT_Trace, PLTT_TraceList, PLTT_SecureTrace, PLTT_SecureTraceList, NeighborDiscovery, Timer, Radio, Rand, Clock, Debug> PLTT_Passive;
#else
typedef wiselib::PLTT_PassiveType<Os, Node, PLTT_Node, PLTT_NodeList, PLTT_Trace, PLTT_TraceList, NeighborDiscovery, Timer, Radio, Rand, Clock, Debug> PLTT_Passive;
#endif
#ifdef PLTT_SECURE
typedef wiselib::PLTT_TargetType<Os, PLTT_SecureTrace, Node, Timer, Radio, PrivacyMessage, Clock, Debug> PLTT_Target;
#else
typedef wiselib::PLTT_TargetType<Os, PLTT_Trace, Node, Timer, Radio, Clock, Debug> PLTT_Target;
#endif

	class PLTT_Processor : public virtual ExtIfaceProcessor
	{
	public:
		PLTT_Processor();
		virtual ~PLTT_Processor();
		virtual void boot( void ) throw();
		virtual void work( void ) throw();
		void receive( int from, long len, unsigned char* data, const ExtendedData& exdata ) throw();
		void tags_from_traces( void ) throw();
		void target_waypoint( shawn::Vec );
		//void tracker_waypoint( shawn::Vec );
	private:
		PLTT_Passive* passive;
		PLTT_Target* target;
#ifdef PLTT_SECURE
		Privacy* helper;
		Privacy* central_authority;
		Privacy* privacy_target;
#endif
		NeighborDiscovery* neighbor_discovery;
		ShawnOs os_;
		Radio wiselib_radio_;
		Timer wiselib_timer_;
		Debug wiselib_debug_;
		Rand wiselib_rand_;
		Clock wiselib_clock_;
		shawn::Vec destination;
		int target_movement_round_intervals;
		int tracker_movement_round_intervals;
		double target_movement_distance_intervals;
		//double tracker_movement_distance_intervals;
		millis_t target_spread_milis;
		//millis_t tracker_spread_milis;
		int target_transmission_power;
		//int tracker_transmission_power_as_target;
		SecondsNumber trace_diminish_seconds;
		//SecondsNumber tracker_trace_diminish_seconds;
		IntensityNumber trace_diminish_amount;
		IntensityNumber tracker_trace_diminish_amount;
		IntensityNumber trace_start_intensity;
		//IntensityNumber tracker_trace_start_intensity;
		IntensityNumber trace_spread_penalty;
		//IntensityNumber tracker_trace_spread_penalty;

		CoordinatesNumber network_size_x;
		CoordinatesNumber network_size_y;
		CoordinatesNumber network_size_z;
		CoordinatesNumber communication_range;
		double communication_range_mutator;

		int intensity_detection_threshold;
		millis_t nb_convergence_time;
		int backoff_connectivity_weight;
		int backoff_lqi_weight;
		int backoff_random_weight;
		int backoff_candidate_list_weight;
		int transmission_power_db;
		int random_enable_timer_range;
		//int reliable_tracking_expiration_time;
		//int reliable_tracking_recurring_time;
		//int reliable_tracking_daemon_time;
		//int tracker_tracking_metrics_timer;
		//int metrics_timeout;
		int target_color;
		//node_id_t tracker_id_to_track;
		//double tracker_send_milis;
		//int tracker_transmission_power;
		//int tracker_color;
		//IntensityNumber tracker_target_to_track_max_intensity;
#ifdef PLTT_SECURE
		int decryption_request_timer;
		int decryption_request_offset;
		int erase_daemon_timer;
		int decryption_max_retries;
		int helper_color;
		int privacy_power_db;
#endif
	};
}

#endif
#endif

