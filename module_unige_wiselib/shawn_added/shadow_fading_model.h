#ifndef __SHAWN_SYS_COMM_MODELS_SHADOW_FADING_MODEL_H
#define __SHAWN_SYS_COMM_MODELS_SHADOW_FADING_MODEL_H
#include "../buildfiles/_legacyapps_enable_cmake.h"
#ifdef ENABLE_MODULE_UNIGE_WISELIB

#include "sys/communication_model.h"


namespace shawn
{


   class ShadowFadingModel
      : public CommunicationModel
   {
   public:

      ///@name construction / destruction
      ///@{
      ///
      ShadowFadingModel();
      ///
      virtual ~ShadowFadingModel();
      ///
      virtual void
      init( void )
         throw();
      ///@}

      
      ///@name communication range
      ///@{
      ///
      virtual void
      set_transmission_range( double )
         throw();
      ///
      virtual double
      transmission_range( void )
         const throw();
      ///@}

      ///@name CommunicationModel interface
      ///@{
      ///
      virtual bool
      can_communicate_bidi( const Node&,
                            const Node& )
         const throw();
      ///
      virtual bool
      can_communicate_uni( const Node&,
                           const Node& )
         const throw();
      /// returns whether communication_upper_bound() returns a useful value
      virtual bool
      exists_communication_upper_bound( void )
         const throw();
      /** if exists_communication_upper_bound(), nodes whose euclidean
       *  distance exceeds communication_upper_bound() can never communicate
       *  in any direction
       */
      virtual double
      communication_upper_bound( void )
         const throw();
      ///
      virtual bool
      is_status_available_on_construction( void )
         const throw();

      virtual void
      set_size_hint(double size_hint) 
         throw();
      ///@}

   private:
      bool   initialized_;
      double range_;
      bool   has_range_;
      int lm_upper;
      int db_upper;
   };
   

}
#endif
#endif
