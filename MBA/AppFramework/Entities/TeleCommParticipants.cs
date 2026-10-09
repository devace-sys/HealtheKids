using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{  
  
  /***************************************************************************
   * TeleCommParticipant */
  /**
   * 
   ***************************************************************************/
  public class TeleCommParticipant
  {

    // NOTE: the class TeleCommParticipant is used extensively in the database getter methods in middleware.
    //       However, the corresponding custom table type TelecommParticipantDetails in the database is used
    //       in the TELECOM_SESSION_SAVE sproc, but not in any of the VIEW udf's or SELECTs for sessions or participants.
    public TeleCommParticipant(){}
    
    public TeleCommParticipant (long idx, string title, long roleID) {
      this.idx      = idx;
      this.name     = "";      
      this.title    = title;
      this.email    = "";
      this.phone    = "";
      this.pin      = "";
      this.roleID   = roleID;
      this.userID   = null;
      this.entityID = null;

      
    }

    [IsDataGridCol(1)]
    [DataGridColTitle("IDX")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsInputKey(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]
    public long idx;
    
    [IsDataGridCol(2)]
    [DataGridColTitle("Name")]
    [DataGridColWidth(200)]    
    public string name;
    
    [IsDataGridCol(3)]
    [DataGridColTitle("Title")]
    [DataGridColWidth(200)]    
    public string title;

    [IsDataGridCol(4)]
    [DataGridColTitle("Email")]
    [DataGridColWidth(50)]
    public string email;

    [IsDataGridCol(5)]
    [DataGridColTitle("Phone")]
    [DataGridColWidth(50)]    
    public string phone;

    [IsDataGridCol(6)]
    [DataGridColTitle("Pin")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public string pin;

    [IsDataGridCol(7)]
    [DataGridColTitle("UserID")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public long? userID;

    [IsDataGridCol(8)]
    [DataGridColTitle("RoleID")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public long? roleID;

    [IsDataGridCol(9)]
    [DataGridColTitle("EntityID")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public long? entityID;

    /*
    [IsDataGridCol(10)]
    [DataGridColTitle("inviteRsvpToken")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(128)]
    */
    public string inviteRsvpToken;

    /*
    [IsDataGridCol(11)]
    [DataGridColTitle("inviteRsvpNotes")]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(512)]
    */

    public string inviteRsvpNotes;

    public bool?  inviteRsvpWillAttend;
  }
  
  /***************************************************************************
   * TeleCommParticipants */
  /**
   * 
   ****************************************************************************/
  public class TeleCommParticipants:Entities
  {        
    
    public const long PARTICIPANT_ROLE_PRACTITIONER = 7;  /* Same as users role */   
    public const long PARTICIPANT_ROLE_OTHER        = 88; /* Same as reserved users role */
    public const long PARTICIPANT_ROLE_PATIENT      = 99; /* Same as reserved users role */
    public const long PARTICIPANT_ROLE_PARENT_GUARD = 12; /* Same as users role */
    public const long PARTICIPANT_ROLE_LEA_COOR     = 5;

    /***************************************************************************
     * view */
    /**
     * View participants
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (     SqlConnection connUsers
                                    , DetailsLog    log
                                    , UserInfo      uInfo
                                    , string        appName
                                    , long?         purpose
                                    , long?         sessionID

                                    //, string        email

                                    , Object        roleID                                    
                                    , int           recViewType
                                    , bool          pagedOrTop
                                    , string        idx
                                    , string        canEdit
                                    , string        active                                      
                                    , defineCols    dc )
    {
      
      string viewUDF = "dbo.TELECOMM_PARTICIPANTS_VIEW (@userID, @userGroup, @userRank, @appName, @sessionID, @roleID, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@appName",      SqlDbType.VarChar, appName,     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@sessionID",    SqlDbType.BigInt,  sessionID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@roleID",       SqlDbType.BigInt,  roleID,      ParameterDirection.Input));

      //parms.Add(Database.SqlParm("@email",        SqlDbType.VarChar,  email,       ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
   }
   
   /***************************************************************************
     * viewList */
    /**
     * View list of participants
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @return            ReturnDB
     ***************************************************************************/   

   public static List<TeleCommParticipant> viewList (  SqlConnection connUsers
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , string        appName
                                                     , long          purpose
                                                     , long          sessionID
                                                     , Object        roleID )
     {
       List<TeleCommParticipant> recs = new List<TeleCommParticipant>();
       ReturnDB rd = view(connUsers,log,uInfo,appName,purpose,sessionID, roleID,Entities.REC_VIEW_RAW,false,null,null,null,null);
       List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(TeleCommParticipant));
       foreach (var o in slo) {
         recs.Add((TeleCommParticipant) o);
       }
       return recs;
     }
         
  } 
}