#ifndef __SHAWN_LEGACYAPPS_WISELIB_PLTT_PROCESSOR_FACTORY_H
#define __SHAWN_LEGACYAPPS_WISELIB_PLTT_PROCESSOR_FACTORY_H
#include "_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

#include "sys/processors/processor_factory.h"

namespace shawn 
{ 
	class SimulationController; 
	class Processor;
}

namespace wiselib
{
	class PLTT_ProcessorFactory : public shawn::ProcessorFactory
	{
	public:
		PLTT_ProcessorFactory();
		virtual ~PLTT_ProcessorFactory();
		virtual std::string name( void ) const throw();
		virtual std::string description( void ) const throw();
		virtual shawn::Processor* create( void ) throw();

		static void register_factory( shawn::SimulationController& ) throw();
	};
}

#endif
#endif

