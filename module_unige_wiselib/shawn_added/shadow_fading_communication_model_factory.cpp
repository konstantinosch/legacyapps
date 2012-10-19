#include "sys/comm_models/shadow_fading_model.h"
#include "sys/comm_models/shadow_fading_communication_model_factory.h"
#include "sys/simulation/simulation_controller.h"
#include "sys/simulation/simulation_environment.h"

#include <limits>

using namespace std;

namespace shawn
{

	// ----------------------------------------------------------------------
	ShadowFadingCommunicationModelFactory::
		~ShadowFadingCommunicationModelFactory()
	{}

	// ----------------------------------------------------------------------
	std::string 
		ShadowFadingCommunicationModelFactory::
		name(void) 
		const throw()
	{
		return "shadow_fading";
	}

	// ----------------------------------------------------------------------
	std::string 	
		ShadowFadingCommunicationModelFactory::
		description(void) 
		const throw()
	{
		return "Shadow Fading Communication Model";
	}

	// ----------------------------------------------------------------------
	CommunicationModel* 
		ShadowFadingCommunicationModelFactory::
		create( const SimulationController& sc) 
		const throw()
	{
		double range = sc.environment().optional_double_param("range", std::numeric_limits<int>::max() );
		ShadowFadingModel* dgm = new ShadowFadingModel;
		if( range != std::numeric_limits<int>::max() )
		{
			dgm->set_transmission_range(range);
		}
		return dgm;
	}


}
