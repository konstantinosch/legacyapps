#ifndef __SHAWN_SYS_TRANS_MODELS_SHADOW_FADING_MODEL_FACTORY_H
#define __SHAWN_SYS_TRANS_MODELS_SHADOW_FADING_MODEL_FACTORY_H
#include "../buildfiles/_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB


#include "sys/util/keeper_managed.h"
#include "sys/util/refcnt_pointer.h"
#include "sys/util/defutils.h"
#include "sys/comm_models/communication_model_factory.h"

#include <string>
#include <vector>

namespace shawn
{
   class CommunicationModel;
   class SimulationController;

	//----------------------------------------------------------------------------
	/**
	  *
	  */
	class ShadowFadingCommunicationModelFactory
		: public CommunicationModelFactory
	{
	public:
		virtual ~ShadowFadingCommunicationModelFactory();
		virtual CommunicationModel* create( const SimulationController& ) const throw();
		virtual std::string name(void)  const throw();
		virtual std::string description(void) const throw();
	};

}

#endif
#endif
