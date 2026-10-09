using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * Group */
  /**
   * Practitioner group
   ***************************************************************************/

  public class Group:MBA.Entity
  {

  }  
  
  /***************************************************************************
   * Groups */
  /**
   * Practitioner groups
   ***************************************************************************/

  public class Groups:MBA.Entities
  {
    
   /***************************************************************************
    * GROUP_TYPE_x */
   /**
    * Group type constant values
    ***************************************************************************/

    public static int GROUP_SELECT_TYPE_ALL        = 0;    // All groups    
    public static int GROUP_SELECT_TYPE_DISP       = 1;    // Allied discipline
    public static int GROUP_SELECT_TYPE_REPT       = 2;    // Report group    
    public static int GROUP_SELECT_TYPE_DISP_SUPER = 3;    // Allied discipline "super group"
    
    /***************************************************************************
     * view */
    /**
     * View group records
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID
     * @param  patID           Patient ID
     * @param  startDate       Start date
     * @param  endDate         End date
     * @return                 Group records
     ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                 int     recViewType,
                                 bool    pagedOrTop,
                                 string  idx,
                                 string  canEdit,
                                 string  active,
                                 string  clientID,
                                 int     selectType,
                                 string  name,
                                 defineCols dc) 
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms      = new List<SqlParameter>();
      string             viewUDF    = "GROUPS_VIEW(@selectType, @clientID, @name, @active, @recID)";
      
      Object             vClientID  = Validate.optClientID (uInfo, clientID);
      Object             vName      = Validate.optString   (name, Messages.INVALID_GROUP_ID);
      
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,      vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@selectType", SqlDbType.Int,      selectType, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",       SqlDbType.NVarChar, vName,      ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
    }
    

    /***************************************************************************
     * loadDisciplineGrp */
    /**
     * Implements an Entities.load() call wrapping a for Groups.view() delegate call
     * using a recID.
     * Result set filtered to GROUP_SELECT_TYPE_DISP.
     * Returns the Discipline Group object as an Spedmon.Group entity.
     * @return Spedmon.Group	
     ***************************************************************************/ 
     public static Group loadDisciplineGroup (
           SqlConnection connSpedmon
         , DetailsLog    log
         , UserInfo      uInfo
         , string        recID)
     {                  
       return (Group) Entities.load (connSpedmon, log, uInfo , recID, typeof(Group),
       delegate
       {
         return Groups.view (
                  connSpedmon
                , log
                , uInfo
                , Entities.REC_VIEW_LOAD
                , false
                , recID
                , ""
                , "Y"
                , ""
                , GROUP_SELECT_TYPE_DISP
                , ""                              
                , null);
      });
   } 

   /***************************************************************************
    * viewSel */
   /**
    * View group record selections
    * 
    * @param  groupType       Practitioner group type
    *                         0 = All
    *                         1 = Allied Discipline
    *                         2 = Reporting group
    *                         3 = Allied discipline super group
    * @return                 ReturnSel
    ***************************************************************************/   
    
    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string clientID, int selectType, string term) 
    {
      defineCols dc = null;
      
      /*----------------------------
       * Discipline groups + Proc
       * instructions 
       *----------------------------*/
       
      if ((selectType == Groups.GROUP_SELECT_TYPE_ALL))
      {
        dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
          ss.addDisplayColumn("groupTypeDescription as context1");
          ss.addSortColumn("name");
        };
      }
      
      if ((selectType == Groups.GROUP_SELECT_TYPE_DISP))
      {
        dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
          ss.addSortColumn("name");
        };
      }
      
      /*----------------------------
       * Reporting groups + Group
       * Categories (Super Groups)
       *----------------------------*/

      if (selectType == Groups.GROUP_SELECT_TYPE_REPT)
      {
        dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
          ss.addDisplayColumn("groupTypeDescription as context1");
          ss.addSortColumn("clientID desc");
          ss.addSortColumn("groupType desc");
          ss.addSortColumn("name");
        };      
      }

      /*----------------------------
       * Allied discipline "super
       * groups"
       *----------------------------*/

      if (selectType == Groups.GROUP_SELECT_TYPE_DISP_SUPER)
      {
        dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
          ss.addDisplayColumn("groupTypeDescription as context1");
          ss.addSortColumn("name");
        };      
      }

      
      return Entities.viewSel(connSpedmon, log, uInfo,top, topSize,
        delegate{return Groups.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "1", clientID, selectType, term, dc);});
    }

   /***************************************************************************
    * viewTbl */
   /**
    * View group record data table
    * 
    * @param  groupType       Practitioner group type
    *                         0 = All
    *                         1 = Allied Discipline
    *                         2 = Reporting group
    *                         3 = Allied discipline super group
    * @return                 ReturnDataTable
    ***************************************************************************/   
    
    public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool paged, string pageNumber, string clientID, int groupType) 
    {
      
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
      };

      return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate{return Groups.view (connSpedmon,log,uInfo,Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, groupType, null, dc);});
    }
  
  }
} 

