using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;


using MBA.Reporting;


namespace MBA
{
  /***************************************************************************
   * ManPage*/
  /**
   * 
   **************************************************************************/
  
  public class ManPage
  {                
    public long     id;	
    public string   appName;
	public DateTime startDate;
    public DateTime endDate;
    public string   name;
    public string   title;
    public string   description;
    public string   content;
    public bool     okToDisplay;
    
    public string   startDateStr;
    public string   endDateStr;
    public string   okToDisplayStr;
    public string   forUserRoleIdValsStr;
    public string   forUserRoleIdNamesStr;

    public string   forOrgsNamesStr;
    public string   forOrgsIDsStr;
    
    public DateTime created;
    public long     createdBy;
    public DateTime lastModified;
    public long     lastModifiedBy;
    public bool     active;
    public int      seenCount;
    public string   featuredImgFileData;
    public bool     includeOnDashboard;


    public bool     include_in_welcome_package;
    public int      display_order;

    public long      rowOrder;

  }
  
  /***************************************************************************
   * ManPageUserResponse */
  /**
   * 
   **************************************************************************/
  
  public class ManPageContentUserResponse
  {                
    public long     userID;
    public long     userDistrictID;
    public string   userName;
    public string   userLastName;
    public string   userFirstName;
    public string   userEmail;
    public string   userRoleName;
    public long     manPageID;
    public string   manPageTitle;
    public DateTime manPageStartDate;
    public string   manPageStartDateStr;
    public bool     userResponseNotifiedByEmail;
    public bool     userResponseUserHasSeen;
    public bool     userResponseWillReadLater;
    public bool     userResponseHasRead;
  }
  
  /***************************************************************************
   * ManPageContentUserResponsePendingEmailNotification */
  /**
   * 
   **************************************************************************/
  
  public class ManPageContentUserResponsePendingEmailNotification
  {
    public long   clientID;
    public string clientName;
    public long   userID;
    public int    userGroup;
    public int    userRank;
    public string userName;
    public string userLastName;
    public string userFirstName;
    public string userEmail;                
    public string manPageIDs;               
 
    public string manPageTitleStartdateDescriptionJSONarrs;

  }

    public class manPageTitleStartdateDescription: ListItemWImage  {
    public string manPageTitle;
    public string manPageStartDateStr;
    public string manPageDescription;
    
    public string title { get { return manPageTitle; } }
    public string description { get { return manPageDescription; } }
    public string finePrint { get { return manPageStartDateStr; } }
    public string imgSrc { get { return null; }  }
    /* this particular class doesn't need a different image for each item; but other content types, for other kinds of emails,
       might need it */
    
  } 
  
  /***************************************************************************
   * ReturnManPages */
  /**
   * 
   **************************************************************************/

  public class ReturnManPage:Return
  {
    public ReturnManPage ()                 : base(){}
    public ReturnManPage (string msg)       : base(msg){}
    public ReturnManPage (Exception e)      : base(e){}
    public ReturnManPage (Warning e)        : base(e){}
    public ReturnManPage (Critical e)       : base(e){}  
    public ReturnManPage (SessionExpired e) : base(e){}
    
    public ManPage manPage = new ManPage();    
  }
  
  /***************************************************************************
   * ManPages */
  /**
   * 
   **************************************************************************/
  
  public abstract class ManPages:Entities
  {        

    public static string PARM_USER_HAS_READ              = @"userhasread";
    public static string PARM_WELCOME_NEW_USER           = @"welcome_new_user";

    public static string PARM_USER_RESP_TYPE             = @"mpurt";
    public static string USER_RESP_TYPE_SEEN             = @"1";
    public static string USER_RESP_TYPE_WILL_READ_LATER  = @"2";
    public static string USER_RESP_TYPE_READ             = @"3";    
    public static string USER_RESP_TYPE_NOTICE_EMAILED   = @"4";    
    public static string URL_MAN_PAGE_PRIVATE            = @"man_page_content_private.ashx";
    public static string ID_NAME_MAN_PAGE                = @"manpagecontent";

    /***************************************************************************
     * delete */
    /**
     * "Deletes" an announcement
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   

    protected static ReturnSaveRecord delete (  SqlConnection connUsers
	                                            , DetailsLog    log
											                        , UserInfo      uInfo											  
											                        , string        appName
											                        , string        editDelReason
											                        , string        validateRec
											                        , string        recID )
    {           
                
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms  = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, appName, ParameterDirection.Input,50));  
      
      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete(connUsers,log,uInfo, editDelReason,validateRec,recID,"APP_MAN_PAGE_DELETE",ref parms);
    }
    
    /***************************************************************************
     * load */
    /**
     * loads a man page
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  userID          User record id
     * @return                 User
     ***************************************************************************/ 
    
    protected static ManPage load (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string appName, string recID)
    { 
      return (ManPage) Entities.load (connUsers, log, uInfo, recID, typeof(ManPage),
      delegate 
      {    
        return ManPages.view (connUsers,log,uInfo,appName,Entities.REC_VIEW_LOAD,false,recID,null,null,"Y",null,null);
      });      
    } 
      
    /***************************************************************************
     * resetAndRepublish */
    /**
     * resets all log statistics for this man page and republishes it
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  recID           Record id of announcement
     * @return                 User
     ***************************************************************************/ 
    public static ReturnSaveRecord resetAndRepublish (   SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        appName
                                                        , string        recID )
    {
      string vAppName = Validate.reqString ( appName, Messages.NO_APP_NAME );
      var opSproc     = "APP_MAN_PAGES_RESET_AND_REPUBLISH";
      var parms       = new List<SqlParameter>();        
      parms.Add(Database.SqlParm( "@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, 50) );
      return Entities.recordOp (connUsers,log,uInfo,"","0",recID,opSproc,ref parms);       
    }


    /*************************************************************************
     * pinToTop */
    /**
     * Sets the display_order of the selected man page to 1.
     * Increments the display_order of all others so that they will be ordered afterwards
     * 
     * @param  appName           string
     * @param  recID             string
 
     *
     ***************************************************************************/

    public static ReturnSaveRecord pinToTop (   SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        appName
                                                        , string        recID )
    {
      string vAppName = Validate.reqString ( appName, Messages.NO_APP_NAME );
      var opSproc     = "APP_MAN_PAGE_PIN_TO_TOP";
      var parms       = new List<SqlParameter>();        
      parms.Add(Database.SqlParm( "@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, 50) );
      return Entities.recordOp (connUsers,log,uInfo,"","0",recID,opSproc,ref parms);       
    }

    /***************************************************************************
     * save */
    /**
     * Creates a new or edits an existing user account
     * 
     * @param  username       User name
     * @param  password1      Password entered
     * @param  password2      Password entered again
     * @param  roleID         Users role
     * @param  lname          Users last name
     * @param  fname          Users first name
     * @param  email          Users email
     * @param  phone          Users phone number
     * @param  clientID       Users client record id
     * @param  personID       Entitiy ID of person to attach to this account
     * @return                ReturnSaveRecord
     ***************************************************************************/               
    
    protected static ReturnSaveRecord save (  SqlConnection connUsers
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        appName                                            
                                            , string        startDate
                                            , string        endDate
                                            , string        forUserRoleIds
                                            , string        forClientIds
                                            , string        title  
                                            , string        featuredimgfiledata  
                                            , string        description                                          
                                            , string        content											
                                            , string        includeondashboard											
										    , string        okToDisplay

                                            , string        include_in_welcome_package
                                            , string        display_order

                                            , string        saveType
                                            , string        validateRec
                                            , string        editDelReason
                                            , string        recID )
      {           
    

        /*----------------------------
         * Validate parameters specific
         * to this entity.save
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
      
        List<SqlParameter> parms = new List<SqlParameter>();  
   
        string    saveSproc             = "APP_MAN_PAGE_SAVE";   
             
        string    vAppName              = Validate.reqString        ( appName,              Messages.NO_APP_NAME );
        DateTime  vStartDate            = Validate.reqDate          ( startDate,            Messages.INVALID_START_DATE );
        Object    vEndDate              = Validate.optDate          ( endDate,              Messages.INVALID_END_DATE );
		string    vForUserRoleIds       = Validate.reqRecIDMultiStr ( forUserRoleIds,       @"Invalid role ids");
        string    vForClientIds         = Validate.optRecIDMultiStr ( forClientIds,         @"Invalid client ids");
        string    vTitle                = Validate.reqString        ( title,                @"Invalid title" );      
        string    vFeaturedImgFileData  = Validate.optBase64String  (featuredimgfiledata,   @"Invalid image file");
        string    vDescription          = Validate.optString        ( description,          @"Invalid description" );      
        string    vContent              = Validate.reqString        ( content,              @"Invalid content" );     
        bool      vIncludeOnDashboard   = Validate.reqFlag          (includeondashboard,    @"Invalid include on dashboard value", true);     
		bool      vOkToDisplay          = Validate.reqFlag          ( okToDisplay,          @"Invalid OK to display" );
         
            
        bool      vIncludeInWelcomePackage = Validate.reqFlag(include_in_welcome_package, @"include in welcome package?");
        Object      vDisplayOrder = Validate.optInteger(display_order, @"display order?", false);

        if (vDisplayOrder == null)
          vDisplayOrder = 0;


        parms.Add(Database.SqlParm( "@appName",              SqlDbType.VarChar,   vAppName,             ParameterDirection.Input, 50) );
        parms.Add(Database.SqlParm( "@startDate",            SqlDbType.DateTime,  vStartDate,           ParameterDirection.Input) );
        parms.Add(Database.SqlParm( "@endDate",              SqlDbType.DateTime,  vEndDate,             ParameterDirection.Input) );
		parms.Add(Database.SqlParm( "@forUserRoleIdsStr",    SqlDbType.VarChar,   vForUserRoleIds,      ParameterDirection.Input, 8000) );

        parms.Add(Database.SqlParm( "@forClientIdsStr",      SqlDbType.VarChar,   vForClientIds,      ParameterDirection.Input, 8000) );

        parms.Add(Database.SqlParm( "@title",                SqlDbType.VarChar,   vTitle,               ParameterDirection.Input, 512)  );
        parms.Add(Database.SqlParm( "@description",          SqlDbType.VarChar,   vDescription,         ParameterDirection.Input, 2000) );
        parms.Add(Database.SqlParm( "@content",              SqlDbType.VarChar,   vContent,             ParameterDirection.Input, -1) );
		parms.Add(Database.SqlParm( "@okToDisplay",          SqlDbType.Bit,       vOkToDisplay,         ParameterDirection.Input) );
		parms.Add(Database.SqlParm( "@featuredimgfiledata",  SqlDbType.VarChar,   vFeaturedImgFileData, ParameterDirection.Input, -1) );
		parms.Add(Database.SqlParm( "@includeondashboard",   SqlDbType.Bit,       vIncludeOnDashboard,  ParameterDirection.Input) );


		parms.Add(Database.SqlParm( "@include_in_welcome_package",   SqlDbType.Bit,   vIncludeInWelcomePackage,  ParameterDirection.Input) );
		parms.Add(Database.SqlParm( "@display_order"             ,   SqlDbType.Int,   vDisplayOrder    ,  ParameterDirection.Input) );


                     
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/  

        ReturnSaveRecord so = Entities.save (  connUsers
                                             , log
                                             , uInfo
                                             , saveType
                                             , validateRec
                                             , editDelReason
                                             , recID
                                             , saveSproc
                                             , @"Duplicate content"
                                             , ref parms
                                             , delegate(){});
    
        return so;

    }
    
    /***************************************************************************
     * view */
    /**
     * View announcements
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB view (  SqlConnection connUsers
                                    , DetailsLog    log
                                    , UserInfo      uInfo
                                    , string        appName
                                    , int           recViewType
                                    , bool          pagedOrTop
                                    , string        idx
                                    , string        canEdit
                                    , string        active  
                                    , string        includeContent
                                    , string        term
                                    , defineCols    dc )
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms        = new List<SqlParameter>();   
      
      string             viewUDF             = "APP_MAN_PAGES_VIEW (@userID, @userGroup, @userRank, @appName, null, null, getdate(), @active, @includeContent, @term, @recID)";
      Object             vAppName            = Validate.optString  (appName,            Messages.NO_APP_NAME);
      bool               vIncludeContent     = Validate.reqFlag    (includeContent,     @"Invalid include content flag");    
      Object             vTerm               = Validate.optString  (term,               Messages.INVALID_SEARCH_TERM);
            
      parms.Add(Database.SqlParm("@appName",            SqlDbType.VarChar, vAppName,            ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@includeContent",     SqlDbType.Bit,     vIncludeContent,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",               SqlDbType.VarChar, vTerm,               ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
   }

   /***************************************************************************
    * viewTbl */
   /**
    * View announcements record table for admin purposes
    * 
    * @param  appName     Application name (from web.config or app.config) 
    * @param  clientID    Client ID record (if any)
    * @return             ReturnDataTable
    ***************************************************************************/   
    
    protected static ReturnDataTable viewTbl (  SqlConnection connUsers
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          paged
                                              , string        pageNumber
                                              , string        appName
                                              , string        canEdit
                                              , string        active ) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
    
        ss.addDisplayColumn ("id as [id]");
        ss.addDisplayColumn ("startDateStr as [Start Date]");
        ss.addDisplayColumn ("title        as [Title]");   
        ss.addDisplayColumn ("okToDisplayStr as [OK To Display]");
        ss.addDisplayColumn ("forUserRoleIdNamesStr as [For User Roles/Groups]");
        ss.addDisplayColumn ("rowOrder",true); 
        pageroworder = ss.pageRowOrder();     
      };
      
      return Entities.viewTbl(connUsers, log, uInfo, paged, pageNumber,
        delegate{return ManPages.view (connUsers,log,uInfo, appName, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, "N", null,dc);}
        , @"Announcements and Help - View"
        , Messages.CONFIDENTIAL
        );
    }

    public static ReturnObjects viewObjects(    SqlConnection connUsers
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string appName
                                              , string canEdit
                                              , string active)
    {
        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = "rowOrder";

        /* Define columns delegate is used to specify columns and page order 
            * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects(connUsers
                                        , log
                                        , uInfo
                                        , typeof(ManPage)
                                        , pageObjectList
                                        , pageOrder
                                        , delegate {
                                            return ManPages.view
                                                                                (connUsers
                                                                                , log
                                                                                , uInfo
                                                                                , appName
                                                                                , Entities.REC_VIEW_OBJECTS
                                                                                , pageObjectList
                                                                                , idx
                                                                                , canEdit
                                                                                , active
                                                                                , "N"
                                                                                , null
                                                                                , dc);
                                        });

        return rd;
    }
   
    /***************************************************************************
     * viewSel */
    /**
     * View selection list of man pages
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnSel viewSel (  SqlConnection connUsers
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , string        appName                                            
                                        , bool          top
                                        , string        topSize
                                        , string        term )
    {           
      
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){
        
        ss.addSortColumn("startDate");
        ss.addSortColumn("title");
        ss.addDisplayColumn("forUserRoleIdNamesStr as [context1]"); 
        
      };
      
      return Entities.viewSel(connUsers, log, uInfo,top, topSize,
      
      delegate{
          return view (connUsers,log,uInfo,appName,Entities.REC_VIEW_SEL, top, topSize, "", "1", "N", term, dc);
      });
                                                  
    }
    
    /***************************************************************************
     * viewList */
    /**
     * View a list
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  userID          User record id
     * @return                 User
     ***************************************************************************/ 
    
    protected static List<ManPage> viewList (

        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , string        appName
      , string        includeContent )
    
    { 
      List<ManPage> recs = new List<ManPage>();      
      ReturnDB        rd = ManPages.view (connUsers,log,uInfo,appName,Entities.REC_VIEW_RAW,false,null,null,"Y",includeContent,null,null);
      List<Object>   slo = Database.convertRecordsToList (ref rd.records, typeof(ManPage));
      foreach (Object o in slo) {recs.Add ((ManPage) o);}
      return recs;
    } 
    
    /***************************************************************************
     * userHasUnreadAnnouncements */
    /**
     * Returns true if there are unread announcments
     * 
     ***************************************************************************/   
    
    protected static bool userHasUnreadManPages (   ref RequestResponse rd								  
                                                  , string appName	
											                          ) 
    {   
      if (rd.wu.usr.numUnreadManPages > 0) return true;
      return false;
    }
    
    /***************************************************************************
     * viewContent */
    /**
     * View content
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB viewContent ( SqlConnection connUsers
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , int           recViewType
                                           , bool          pagedOrTop
                                           , string        idx
                                           , string        canEdit
                                           , string        active  
                                           , string        appName
                                           , string        term
                                           , string        userHasRead
                                           , string        welcome_new_user
                                           , string        includeContent
                                           , defineCols    dc )
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();   
      
      string    viewUDF         = "dbo.APP_MAN_PAGES_VIEW_CONTENT (@userID, @userGroup, @userRank, @appName, @userHasRead, getdate(), @welcome_new_user, @includeContent, @recID)";
      Object    vAppName        = Validate.optString (appName, Messages.NO_APP_NAME);
      Object    vUserHasRead    = Validate.optFlag   (userHasRead, @"Invalid user has read");
      bool      vIncludeContent = Validate.reqFlag(includeContent,@"Invalid include content flag");
            
      Object    vWelcomeNewUser = Validate.optFlag(welcome_new_user, "filter for New User Welcome content?");    
      
      parms.Add(Database.SqlParm("@appName",        SqlDbType.VarChar, vAppName,         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@userHasRead",    SqlDbType.Bit,     vUserHasRead,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeContent", SqlDbType.Bit,     vIncludeContent,  ParameterDirection.Input));

      parms.Add(Database.SqlParm("@welcome_new_user", SqlDbType.Bit,   vWelcomeNewUser,  ParameterDirection.Input));


      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

     return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
      
   }
    /***************************************************************************
     * loadContent */
    /**
     * loads a man page
     * 
     * @param  connUsers       Users database connection object
     * @param  log             Logging object
     * @param  userID          User record id
     * @return                 User
     ***************************************************************************/ 
    
    protected static ManPage loadContent (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string appName, string recID)
    { 
      return (ManPage) Entities.load (connUsers, log, uInfo, recID, typeof(ManPage),
      delegate 
      {    
        return ManPages.viewContent (connUsers,log,uInfo,Entities.REC_VIEW_LOAD,false,recID,null,null,appName,null,null, null, "Y",null);
      });      
    } 
     
    /***************************************************************************
     * viewSelContentSelections */
    /**
     * View list of user roles
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnSel viewContentSel (   SqlConnection connUsers
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        appName                                            
                                             , bool          top
                                             , string        topSize
                                             , string        term
                                             , string        userHasRead
                                             , string        welcome_new_user)
    {           
      
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){
        
        ss.addSortColumn("rowOrder");
        ss.addSortColumn("userHasRead");
        
        ss.addDisplayColumn("startDateStr as [context1]");        
        ss.addDisplayColumn(@"'" + URL_MAN_PAGE_PRIVATE  + @"' as [recData1]"); 
        ss.addDisplayColumn(@"'" + Constants.PARM_REC_ID + @"' as [recData2]"); 
        ss.addDisplayColumn(@"convert(varchar(100),id) as [recData3]");
        ss.addDisplayColumn(@"convert(varchar(10),userHasRead) as [recData4]"); 
        
      };
      
      return Entities.viewSel(connUsers, log, uInfo,top, topSize,
      
      delegate{
          return viewContent (connUsers,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "1", appName, term, userHasRead, welcome_new_user, "N", dc);
      });
                                                  
    }
              
    /***************************************************************************
     * viewSelDashboard */
    /**
     * View list of user roles
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnSel viewSelDashboard (   SqlConnection connUsers
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , string        appName                                            
                                             , bool          top
                                             , string        topSize )
    {           
      
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms){
                
        ss.addDisplayColumn("startDateStr          as [context1]");        
        ss.addDisplayColumn("title                 as [recData1]");                  
        ss.addDisplayColumn("description           as [recData2]");        
        ss.addDisplayColumn("featuredImgFileData   as [recData3]");    
        ss.addDisplayColumn(@"convert(varchar(10),includeOnDashboard) as [recData5]");         
      };
      
      return Entities.viewSel(connUsers, log, uInfo,top, topSize,
      
      delegate{
          return viewContent (connUsers,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "1", appName, null, null, null, "N", dc);
      });
                                                  
    }
     
    /***************************************************************************
     * viewContentList */
    /**
     * Returns list of man pages
     * 
     ***************************************************************************/     
    protected static List<ManPage> viewContentList (
          SqlConnection connUsers
        , DetailsLog    log
        , UserInfo      uInfo
        , string        appName
        , string        includeContent )
    { 
      var recs = new List<ManPage>();   
      var rd = ManPages.viewContent (connUsers,log,uInfo,Entities.REC_VIEW_RAW,false,null,null,null,appName,null,null, null,includeContent,null);
      var slo = Database.convertRecordsToList (ref rd.records, typeof(ManPage));
      foreach (Object o in slo) {recs.Add ((ManPage) o);}
      return recs;
    }     

    /***************************************************************************
     * logUserResponse */
    /**
     * Logs has read response
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   

    protected static ReturnSaveRecord logUserResponse (  SqlConnection connUsers
	                                                     , DetailsLog    log
											                                 , UserInfo      uInfo											  
											                                 , string        appName											                                 											                        
											                                 , string        responseTypeID
											                                 , string        recID )
    {                           
      string logSproc       = @"APP_MAN_PAGE_LOG_USER_RESPONSE"; 
      Object vAppName = Validate.optString (appName, Messages.NO_APP_NAME);
      List<SqlParameter> parms  = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, appName, ParameterDirection.Input,50));       
      return Entities.logUserResponse (connUsers, log, uInfo, logSproc, responseTypeID, recID, ref parms);
    }
    
    /***************************************************************************
     * logUserResponses */
    /**
     * 
     ***************************************************************************/
    
    protected static ReturnSaveRecord logUserResponses ( 
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , string        appName											                                 											                        
      , string        responseTypeID      			
      , string        recIDMulti )
      
    {
      
      string logSproc   = @"APP_MAN_PAGE_LOG_USER_RESPONSES"; 
      Object vAppName   = Validate.optString (appName, Messages.NO_APP_NAME);
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, appName, ParameterDirection.Input,50));       
      
      return Entities.logUserResponses (connUsers, log, uInfo, logSproc, responseTypeID, recIDMulti, ref parms);

    }    
    
    /***************************************************************************
     * returnContentSelection */
    /**
     * View content data.  Used for content display.
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnManPage returnContentSelection (  SqlConnection connUsers
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        appName
                                                           , string        recID )
    {      
      ReturnManPage rd = new ReturnManPage();
      rd.manPage = loadContent(connUsers,log,uInfo,appName,recID);
      logUserResponse(connUsers,log,uInfo,appName,USER_RESP_TYPE_SEEN,recID);
      return rd;
    }

    /***************************************************************************
     * viewSelUserRoles */
    /**
     * View selection list of user roles for announcements
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   
   
    protected static ReturnSel viewSelUserRoles (  SqlConnection connUsers
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , bool          top
                                                 , string        topSize
                                                 , string        appName
                                                 , string        term )
    {
      return ManPagesUserRoles.viewSel(connUsers,log,uInfo,top,topSize,appName,term);
    }
        
    /***************************************************************************
     * viewContentUserResponses */
    /**
     * View content
     * 
     * @param  appName    Application name (from web.config or app.config)
     * @param  clientID   Client record id (if any)
     * @param  userName   Username
     * @param  email      User's email
     * @param  token      Security token (if any)
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB viewContentUserResponses ( SqlConnection connUsers
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , int           recViewType
                                                        , bool          pagedOrTop
                                                        , string        idx
                                                        , string        canEdit
                                                        , string        active  
                                                        , string        appName
                                                        , Object        clientID
                                                        , string        userNotifiedByEmail
                                                        , string        userHasSeen
                                                        , string        userWillReadLater
                                                        , string        userHasRead                                                                                     
                                                        , defineCols    dc )
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();   
      
      string    viewUDF              = "dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES (@userID, @userGroup, @userRank, @appName, @clientID, @userNotifiedByEmail, @userHasSeen, @userWillReadLater, @userHasRead, @recID)";
      Object    vAppName             = Validate.optString (appName, Messages.NO_APP_NAME);

      Object    vUserNotifiedByEmail = Validate.optFlag   (userNotifiedByEmail, @"Invalid user notified by email");
      Object    vUserHasSeen         = Validate.optFlag   (userHasSeen,         @"Invalid user has seen");
      Object    vUserWillReadLater   = Validate.optFlag   (userWillReadLater,   @"Invalid user will read later");      
      Object    vUserHasRead         = Validate.optFlag   (userHasRead,         @"Invalid user has read");
      
      parms.Add(Database.SqlParm("@appName",             SqlDbType.VarChar,  vAppName,              ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   clientID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userNotifiedByEmail", SqlDbType.Bit,      vUserNotifiedByEmail,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userHasSeen",         SqlDbType.Bit,      vUserHasSeen,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userWillReadLater",   SqlDbType.Bit,      vUserWillReadLater,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@userHasRead",         SqlDbType.Bit,      vUserHasRead,          ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

     return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
      
   }
   
   /***************************************************************************
    * viewManPageContentUserResponsePendingEmailNotificationList */
   /**
    * View email notifications
    ***************************************************************************/   
 
   protected static List<ManPageContentUserResponsePendingEmailNotification> viewManPageContentUserResponsePendingEmailNotificationList (
       SqlConnection connUsers
     , DetailsLog    log
     , UserInfo      uInfo
     , string        appName )
   
   {

     List<ManPageContentUserResponsePendingEmailNotification> Notifications = new List<ManPageContentUserResponsePendingEmailNotification>();
     List<SqlParameter>                                       parms         = new List<SqlParameter>();
     
     string  sql     = "select * from dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS_ALL (@userID, @userGroup, @userRank, @appName)";
     Object vAppName = Validate.optString (appName, Messages.NO_APP_NAME);
     
     parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
     parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
     parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
     parms.Add(Database.SqlParm("@appName",    SqlDbType.VarChar,  vAppName,         ParameterDirection.Input, 50));
      
     ReturnDB rd = Database.execQuery (  connUsers
                                       , log
                                       , sql
                                       , false
                                       , parms
                                      );
                                                         
      List<Object> slo = Database.convertRecordsToList (   ref rd.records
                                                         , typeof(ManPageContentUserResponsePendingEmailNotification)
                                                       );
      
      foreach (Object o in slo) {
        Notifications.Add ( (ManPageContentUserResponsePendingEmailNotification) o) ;
      }
      
      return Notifications;
   }
   
    /***************************************************************************
     * rptReviewUserResponses */
    /**
     *
     *****************************************************************************/

    protected static ReturnDataTable rptReviewUserResponses (
    
        SqlConnection connUsers
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        appName
      , string        canEdit
      , string        active
      , Object        clientID
      , string        pageID
      , string        userHasBeenEmailedNoticeOfContent
      , string        userHasSeenContent
      , string        userWillReadContentLater
      , string        userHasReadContent )
    
    {

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
        
        Object vAppName                           = Validate.optString  (appName,                           Messages.NO_APP_NAME);        
        Object vPageID                            = Validate.optInteger (pageID,                            Messages.INVALID_PAGE_ID);
        Object vUserHasBeenEmailedNoticeOfContent = Validate.optFlag    (userHasBeenEmailedNoticeOfContent, Messages.INVALID_FLAG);
        Object vUserHasSeenContent                = Validate.optFlag    (userHasSeenContent,                Messages.INVALID_FLAG);
        Object vUserWillReadContentLater          = Validate.optFlag    (userWillReadContentLater,          Messages.INVALID_FLAG);
        Object vUserHasReadContent                = Validate.optFlag    (userHasReadContent,                Messages.INVALID_FLAG);
        
        List<SqlParameter> prms = new List<SqlParameter>();
    
        string viewUDF = "dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES ( @userID, @userGroup, @userRank, @appName, @clientID, @userNotifiedByEmail, @userHasSeen, @userWillReadLater, @userHasRead, @pageID )";
    
        prms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   clientID,                           ParameterDirection.Input));
        prms.Add(Database.SqlParm("@appName",             SqlDbType.VarChar,  vAppName,                           ParameterDirection.Input, 50));
        prms.Add(Database.SqlParm("@userNotifiedByEmail", SqlDbType.Bit,      vUserHasBeenEmailedNoticeOfContent, ParameterDirection.Input));        
        prms.Add(Database.SqlParm("@userHasSeen",         SqlDbType.Bit,      vUserHasSeenContent,                ParameterDirection.Input));
        prms.Add(Database.SqlParm("@userWillReadLater",   SqlDbType.Bit,      vUserWillReadContentLater,          ParameterDirection.Input));
        prms.Add(Database.SqlParm("@userHasRead",         SqlDbType.Bit,      vUserHasReadContent,                ParameterDirection.Input));
        prms.Add(Database.SqlParm("@pageID",              SqlDbType.BigInt,   vPageID,                            ParameterDirection.Input));

        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

          ss.addDisplayColumn("rowOrder",true);
          
          ss.addDisplayColumn("dbo.RPT_DATE_FMT(manPageStartDate) as [Start Date]");
          ss.addDisplayColumn("manPageTitle                       as [Content Title]");

          ss.addDisplayColumn ("userDistrictName as [Client]");
          ss.addDisplayColumn ("userLastName     as [Last Name]");
          ss.addDisplayColumn ("userFirstName    as [First Name]");
         
          ss.addDisplayColumn("dbo.RPT_BIT_TO_YN (userResponseHasRead)             as [Has Reviewed]");
          ss.addDisplayColumn("dbo.RPT_BIT_TO_YN (userResponseUserHasSeen)         as [Has Seen]");
          ss.addDisplayColumn("dbo.RPT_BIT_TO_YN (userResponseWillReadLater)       as [Will Review Later]");
          ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(userResponseNotifiedByEmail)      as [Notified By Email]");

          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseHasReadFirst)        as [Has Reviewed \nFirst Date]");
          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseHasReadLast)         as [Has Reviewed \nLast Date]");
          ss.addDisplayColumn("userResponseHasReadCount                            as [Has Reviewed \nCount]");

          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseSeenFirst)           as [Has Seen\nFirst Date]");
          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseSeenLast)            as [Has Seen\nLast Date]");
          ss.addDisplayColumn("userResponseSeenCount                               as [Has Seen\nCount]");


          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseWillReadLaterFirst)  as [Will Review Later\nFirst Date]"); 
          ss.addDisplayColumn("dbo.RPT_DATE_FMT  (userResponseWillReadLaterLast)   as [Will Review Later\nLast Date]"); 
          ss.addDisplayColumn("userResponseWillReadLaterCount                      as [Will Review Later\nCount]"); 

          ss.addDisplayColumn("dbo.RPT_DATE_FMT(userResponseNotifiedByEmailFirst)  as [Notified By Email\nFirst Date]");
          ss.addDisplayColumn("dbo.RPT_DATE_FMT(userResponseNotifiedByEmailLast)   as [Notified By Email\nLast Date]");
          ss.addDisplayColumn("userResponseNotifiedByEmailCount                    as [Notified By Email\nCount]");

          ss.addDisplayColumn ("userName      as [User\nUserName]");
          ss.addDisplayColumn ("userID        as [User\nUserID]");
          ss.addDisplayColumn ("userRoleName  as [User\nRole Name]");
          ss.addDisplayColumn ("userEmail     as [User\nEmail]");          
                    
          pageroworder = ss.pageRowOrder();

        };


        string viewTitle  = @"Announcements or Help - User Responses";
        string viewFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

         return Entities.viewRpt(connUsers, log, uInfo, paged, pageNumber, active, viewUDF, prms, null, dc,viewTitle,viewFooter);

    }
             
  }
}
