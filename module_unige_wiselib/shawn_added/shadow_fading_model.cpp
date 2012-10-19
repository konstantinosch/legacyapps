#include "sys/comm_models/shadow_fading_model.h"
#include "sys/node.h"
#include "sys/world.h"
#include "sys/simulation/simulation_controller.h"

#include <cassert>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>




using namespace std;

namespace shawn
{

   ShadowFadingModel::
   ShadowFadingModel()
      : initialized_ ( false ),
        range_       ( 1.0 ),
        has_range_   ( false )
   {}
   // ----------------------------------------------------------------------
   ShadowFadingModel::
   ~ShadowFadingModel()
   {}
   // ----------------------------------------------------------------------
   void
   ShadowFadingModel::
   init( void )
      throw()
   {
      CommunicationModel::init();
      initialized_ = true;
   }
   // ----------------------------------------------------------------------
   void
   ShadowFadingModel::
   set_transmission_range( double tr )
      throw()
   {
      assert( !initialized_ );
      range_ = tr;
      has_range_ = true;
      cout << "ShadowFadeModel: Transmission range set to ["<< range_ <<"]" << endl;
   }
   double
   ShadowFadingModel::
   transmission_range( void )
      const throw()
   {
      return range_;
   }
   // ----------------------------------------------------------------------
   bool
   ShadowFadingModel::
   can_communicate_bidi( const Node& u,
                         const Node& v )
      const throw()
   {
	   return true;
   }
   // ----------------------------------------------------------------------
   bool
   ShadowFadingModel::
   can_communicate_uni( const Node& u,
                        const Node& v )
      const throw()
   {
   	   const shawn::SimulationEnvironment& se = world().simulation_controller().environment();
   	   double PX = 0;
   	   double x = euclidean_distance( u.real_position(), v.real_position() );
   	   double R = range_ * se.required_double_param( "r_parameter" ) * u.transmission_range();
   	   double Range = range_ * u.transmission_range();
   	   double beta = se.required_double_param( "beta" );
   	   if ( x < R )
   	   {
   		   PX =  1 - ( pow( x / R, 2 * beta ) / 2 );
   	   }
   	   else if (x >= R)
   	   {
   		   PX = pow( ( ( 2 * R - x ) / R ), 2 * beta ) / 2;
   	   }
   	   else if ( x > Range )
   	   {
   		   return false;
   	   }
   	   //if ( u.id() != v.id() )
   	   //{
   	   //   printf( "source id=%x, dest_id=%x, distance=%f, Range=%f, R=%f, PX=%f, beta=%f, Range_upper=%f, u_tr_r=%f\n", u.id(), v.id(), x, Range, R, PX, beta, range_, u.transmission_range() );
   	   //}
   	   return ( rand() % 100 <= PX * 100 );
   }
   // ----------------------------------------------------------------------
   bool
   ShadowFadingModel::
   exists_communication_upper_bound( void )
      const throw()
   {
      return true;
   }
   // ----------------------------------------------------------------------
   double
   ShadowFadingModel::
   communication_upper_bound( void )
      const throw()
   {
      return range_;
   }
   // ----------------------------------------------------------------------
   bool
   ShadowFadingModel::
   is_status_available_on_construction( void )
      const throw()
   {
      return true;
   }
   // ----------------------------------------------------------------------
   void 
   ShadowFadingModel::
   set_size_hint(double size_hint)
   throw()
   {
        if(has_range_) 
            return;

        has_range_ = true;
        range_ = size_hint;
        cout << "ShadowFadingModel: Using size hint ["<< range_ <<"] as comm range" << endl;
   }

}
