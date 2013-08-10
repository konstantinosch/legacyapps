#include "module_unige_wiselib_init.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

//#define __SHAWN_LEGACYAPPS_MODULE_UNIGE_WISELIB_PLTT_PROCESSOR_H
//#define __SHAWN_LEGACYAPPS_WISELIB_PLTT_PROCESSOR_FACTORY_H

#include "legacyapps/module_unige_wiselib/pltt/PLTT_processor.h"
#include "legacyapps/module_unige_wiselib/pltt/PLTT_processor_factory.h"
#include "legacyapps/module_unige_wiselib/scld-a2tp/SCLD_A2TP_processor.h"
#include "legacyapps/module_unige_wiselib/scld-a2tp/SCLD_A2TP_processor_factory.h"
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_task_keeper.h"
#include <iostream>

extern "C" void init_module_unige_wiselib( shawn::SimulationController& sc )
{
	std::cout << "Initialising UNIGE_WISELIB module" << std::endl;
#ifdef __SHAWN_LEGACYAPPS_WISELIB_PLTT_PROCESSOR_FACTORY_H
	wiselib::PLTT_ProcessorFactory::register_factory(sc);
#endif
	wiselib::SCLD_A2TP_ProcessorFactory::register_factory(sc);
}

#endif
