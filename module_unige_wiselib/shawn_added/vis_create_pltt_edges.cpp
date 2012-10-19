#include "../buildfiles/_apps_enable_cmake.h"
#ifdef ENABLE_VIS
#include "apps/vis/tasks/vis_create_pltt_edges.h"
#include "apps/vis/elements/vis_drawable_pltt_edge.h"
#include "apps/vis/elements/vis_drawable_node_default.h"
#include "sys/taggings/basic_tags.h"
#include "sys/taggings/node_reference_tag.h"
#include <iostream>
#include <sstream>
using namespace shawn;
using namespace std;
namespace vis
{
	CreatePLTTEdgesTask::CreatePLTTEdgesTask()
	{}
	// ----------------------------------------------------------------------
	CreatePLTTEdgesTask::~CreatePLTTEdgesTask()
	{}
	// ----------------------------------------------------------------------
	std::string	CreatePLTTEdgesTask::name( void ) const throw()
	{ return "vis_create_pltt_edges"; }
	// ----------------------------------------------------------------------
	std::string	CreatePLTTEdgesTask::description( void ) const throw()
	{ return "Minimal spanning tree view for PLTT algorithm set."; }
	// ----------------------------------------------------------------------
	void CreatePLTTEdgesTask::run( shawn::SimulationController& sc ) throw( std::runtime_error )
	{
		VisualizationTask::run(sc);
		visualization_w().all_edges_removed();
		std::string pref = sc.environment().optional_string_param( "prefix",DrawablePLTTEdge::PREFIX );
		std::string node_prefix = sc.environment().optional_string_param("node_prefix",DrawableNodeDefault::PREFIX);
		for( shawn::World::const_node_iterator it = visualization().world().begin_nodes(), endit = visualization().world().end_nodes(); it != endit; ++it )
		{
			shawn::ConstTagHandle passive_tag;
			passive_tag = (*it).find_tag( "passive_tag" );
			shawn::ConstTagHandle color_tag;
			if (passive_tag.is_not_null())
			{
				const shawn::BoolTag* pass_tag = dynamic_cast<const shawn::BoolTag*>( passive_tag.get() );
				if ( pass_tag->value() )
				{
					for(shawn::TagContainer::tag_iterator ti = it->begin_tags(); ti != it->end_tags(); ++ti)
					{
						if ( ( ti->first ).substr(0,10) == "pltt_edge." )
						{
							shawn::ConstTagHandle trace_tag = it->find_tag( ti->first );
							const shawn::IntegerTag* itag = dynamic_cast<const shawn::IntegerTag*>( trace_tag.get() );
							if ( itag->value() != 0 )
							{
								std::string tag_string = ( ti->first ).substr( 10,500 );
								const DrawableNode* dsrc = drawable_node( *it, node_prefix );
								const shawn::Node* ait = visualization().world().find_node_by_id( atoi( tag_string.substr(0, tag_string.find( ".",0 ) ).c_str() ) );
								const DrawableNode* dtgt = drawable_node( *ait, node_prefix);
								int start_intensity = atoi(tag_string.substr( tag_string.find_last_of(".") + 1 ).c_str());
								int color = atoi(tag_string.substr(tag_string.find(".", tag_string.find(".")+1 ) + 1, tag_string.find_last_of(".")-1 - ( tag_string.find(".", tag_string.find(".")+1 ) + 1 )+1 ).c_str());
								DrawablePLTTEdge* ded = new DrawablePLTTEdge(*it,*ait,*dsrc,*dtgt,pref +  tag_string.substr(tag_string.find(".", tag_string.find(".")+1 ) + 1, tag_string.find_last_of(".")-1 - ( tag_string.find(".", tag_string.find(".")+1 ) + 1)+1) );
								ded->Width = (itag->value()/(double)start_intensity)*0.3;
								ded->R = (double)(((int)color)/100)/10;
								ded->G = (double)(((int)color%100)/10)/10;;
								ded->B = (double)((((int)color%100)%10))/10;;
								ded->init();
								visualization_w().add_element( ded );
							}
						}
					}
				}
			}
		}
	}
	// ----------------------------------------------------------------------
	GroupElement* CreatePLTTEdgesTask::group( shawn::SimulationController& sc ) throw( std::runtime_error )
	{
		std::string n = sc.environment().optional_string_param("group","");
		if( n.empty() )
			return NULL;
		ElementHandle eh = visualization_w().element_w( n );
		if( eh.is_null() )
			throw std::runtime_error(std::string("no such group: ")+n);
		GroupElement* ge = dynamic_cast<GroupElement*>(eh.get());
		if( ge == NULL )
			throw std::runtime_error(std::string("element is no group: ")+n);
		return ge;
	}
	// ----------------------------------------------------------------------
	const DrawableNode*	CreatePLTTEdgesTask::drawable_node( const shawn::Node& v, const std::string& nprefix ) throw( std::runtime_error )
	{
		std::ostringstream oss;
		oss << "v" << v.id();
	    std::string n = nprefix+std::string(".")+v.label();
		ConstElementHandle eh =
		visualization().element( n );
		if( eh.is_null() )
			throw std::runtime_error(std::string("no such element: ")+n);
		const DrawableNode* dn = dynamic_cast<const DrawableNode*>(eh.get());
		if( dn == NULL )
			throw std::runtime_error(std::string("element is no DrawableNode: ")+n);
		return dn;
	}
}
#endif
