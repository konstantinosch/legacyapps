#include "SCLD_A2TP_processor_factory.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB
#include "SCLD_A2TP_processor.h"
#include "sys/processors/processor_keeper.h"
#include "sys/simulation/simulation_controller.h"
#include <iostream>

using namespace std;
using namespace shawn;

namespace wiselib
{

	void SCLD_A2TP_ProcessorFactory::register_factory( SimulationController& sc ) throw()
	{
		sc.processor_keeper_w().add( new SCLD_A2TP_ProcessorFactory );
	}

	SCLD_A2TP_ProcessorFactory::SCLD_A2TP_ProcessorFactory()
	{}

	SCLD_A2TP_ProcessorFactory::~SCLD_A2TP_ProcessorFactory()
	{}

	std::string SCLD_A2TP_ProcessorFactory::name( void ) const throw()
	{ 
		return "SCLD_A2TP_Processor";
	}

	std::string SCLD_A2TP_ProcessorFactory::description( void )	const throw()
	{
		return "SCLD_A2TP_Processor";
	}

	shawn::Processor* SCLD_A2TP_ProcessorFactory::create( void ) throw()
	{
		return new SCLD_A2TP_Processor;
	}

}

#endif
