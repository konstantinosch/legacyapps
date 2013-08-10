#ifndef __SHAWN_LEGACYAPPS_WISELIB_PLTT_PROCESSOR_FACTORY_H
#else
#include "PLTT_processor_factory.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB
#include "PLTT_processor.h"
#include "sys/processors/processor_keeper.h"
#include "sys/simulation/simulation_controller.h"
#include <iostream>

using namespace std;
using namespace shawn;

namespace wiselib
{

	void PLTT_ProcessorFactory::register_factory( SimulationController& sc ) throw()
	{
		sc.processor_keeper_w().add( new PLTT_ProcessorFactory );
	}

	PLTT_ProcessorFactory::PLTT_ProcessorFactory()
	{}

	PLTT_ProcessorFactory::~PLTT_ProcessorFactory()
	{}

	std::string PLTT_ProcessorFactory::name( void ) const throw()
	{ 
		return "PLTT_Processor"; 
	}

	std::string PLTT_ProcessorFactory::description( void )	const throw()
	{
		return "PLTT_Processor";
	}

	shawn::Processor* PLTT_ProcessorFactory::create( void ) throw()
	{
		return new PLTT_Processor;
	}

}

#endif
#endif
