using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    
  /***************************************************************************
   * PersonClass */
  /**
   *
   ***************************************************************************/

  public class PersonClass : Entity
  {
    public string description;
  }
  
  /***************************************************************************
   * PersonClasses */
  /**
   *
   ***************************************************************************/
  
  public class PersonClasses : Entities
  {
    
    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
								                  , string        classPartition
								                  , string        parentID
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PERSONS_CLASS_VIEW (@userID, @userGroup, @userRank, @classPartition, @parentID, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      Object vClassPartition      = Validate.optInteger  (classPartition,  @"Invalid class partition");            
      Object vParentID            = Validate.optInteger  (parentID,        @"Invalid parent id");            
      Object vTerm                = Validate.optString   (term,            @"Invalid search term");
      
      parms.Add(Database.SqlParm("@classPartition",   SqlDbType.BigInt,  vClassPartition,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@parentID",         SqlDbType.BigInt,  vParentID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",             SqlDbType.VarChar, vTerm,             ParameterDirection.Input, 256));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , active
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        classPartition
								                      , string        parentID
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          //ss.addDisplayColumn("description as context1");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PersonClasses.view (   connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_SEL
                                                              , top
                                                              , topSize
                                                              , ""
                                                              , "Y"
                                                              , classPartition
								                                              , parentID
                                                              , term
                                                              , dc); 
                                 });                                                                    
    }
    
    /***************************************************************************
     * viewSelPersonRole */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSelPersonRole (   SqlConnection connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , bool          top
                                                , string        topSize
                                                , string        term )
    {    
    
      return Spedmon.PersonClasses.viewSel (   connSpedmon
                                             , log
                                             , uInfo
                                             , false 
                                             , topSize
                                             , @"1" /* Force partition 1 */
                                             , null
                                             , term );      
    }
       
    /***************************************************************************
     * viewSelPersonRelationship */
    /**
     *
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSelPersonRelationship (  SqlConnection connSpedmon
                                                       , DetailsLog    log
                                                       , UserInfo      uInfo
                                                       , bool          top
                                                       , string        topSize
                                                       , string        personClassRoleID
                                                       , string        term )
    {    
    
      
      long vPersonClassRoleID = Validate.reqInteger (personClassRoleID,  @"A role selection is required");
      personClassRoleID = vPersonClassRoleID.ToString();
                  
      return Spedmon.PersonClasses.viewSel (   connSpedmon
                                             , log
                                             , uInfo
                                             , false 
                                             , topSize
                                             , null /* No patition */
                                             , personClassRoleID   /* Use parent id */                                          
                                             , term );      
    }


  }
}
