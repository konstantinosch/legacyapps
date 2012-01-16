#include "module_unige_wiselib_init.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

#include "legacyapps/module_unige_wiselib/pltt/PLTT_processor.h"
#include "legacyapps/module_unige_wiselib/pltt/PLTT_processor_factory.h"
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_task_keeper.h"
#include <iostream>

extern "C" void init_module_unige_wiselib( shawn::SimulationController& sc )
{
	std::cout << "Initialising UNIGE_WISELIB module" << std::endl;
	wiselib::PLTT_ProcessorFactory::register_factory(sc);
}

#endif
