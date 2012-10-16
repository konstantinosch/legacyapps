#ifndef __SHAWN_VIS_CREATE_PLTT_EDGES_H
#define __SHAWN_VIS_CREATE_PLTT_EDGES_H
#include "../buildfiles/_apps_enable_cmake.h"
#ifdef ENABLE_VIS
#include "apps/vis/base/vis_task.h"
#include "apps/vis/elements/vis_group_element.h"
#include "apps/vis/elements/vis_drawable_node.h"
namespace vis
{
	class CreatePLTTEdgesTask:	public VisualizationTask
	{
	public:
		CreatePLTTEdgesTask();
		virtual ~CreatePLTTEdgesTask();
		virtual std::string name( void ) const throw();
		virtual std::string description( void ) const throw();
		virtual void run( shawn::SimulationController& sc ) throw( std::runtime_error );
	protected:
		virtual GroupElement* group( shawn::SimulationController& sc ) throw( std::runtime_error );
		virtual const DrawableNode* drawable_node( const shawn::Node&, const std::string& nprefix ) throw( std::runtime_error );
	};
}
#endif
#endif
