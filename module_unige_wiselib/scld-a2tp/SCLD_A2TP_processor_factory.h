#ifndef __SHAWN_LEGACYAPPS_WISELIB_SCLD_A2TP_PROCESSOR_FACTORY_H
#define __SHAWN_LEGACYAPPS_WISELIB_SCLD_A2TP_PROCESSOR_FACTORY_H
#include "/home/konstantinos/Desktop/shawn/buildfiles/_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

#include "sys/processors/processor_factory.h"

namespace shawn 
{ 
	class SimulationController; 
	class Processor;
}

namespace wiselib
{
	class SCLD_A2TP_ProcessorFactory : public shawn::ProcessorFactory
	{
	public:
		SCLD_A2TP_ProcessorFactory();
		virtual ~SCLD_A2TP_ProcessorFactory();
		virtual std::string name( void ) const throw();
		virtual std::string description( void ) const throw();
		virtual shawn::Processor* create( void ) throw();

		static void register_factory( shawn::SimulationController& ) throw();
	};
}

#endif
#endif

