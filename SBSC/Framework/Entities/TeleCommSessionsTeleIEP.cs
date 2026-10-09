using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using MBA;
using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;


namespace Spedmon
{  
  
  /**************************************************************************
   * TeleCommSessionIEPSigPageDocData */
  /**
   * 
   * 
   ****************************************************************************/

  public class TeleCommSessionIEPSigPageDocData 
  {
    public string fileName          = @"";
    public string formQuestionsJSON = "{}";
    public string formAnswersJSON   = "{}";
    public string clientIdStr       = "";
    public string patIdStr          = "";
    public long   teleCommSessionID;
    public long   storedFileUserID;
    public int    storedFileUserGroup;
    public int    storedFileUserRank;    
    public string teleCommServerSessionID;
    /* Standard start of IEP signature page doc*/
    public string headerAnswersJSON = "{}";
    /* Standard end of IEP signature page doc*/
    public string footerAnswersJSON = "{}";
  }

    /**************************************************************************
    * headersJSONObj &  participantRosterJSONObj*/
    /**
     * Used together to parse the headersJSON object
     * 
     ****************************************************************************/
    public class TelecommFormHeaderParticipantRosterJSONObj
    {
      public int idx;
      public string signature;
      public string title;
      public string dateSignedStr;
      public string signatureBase64;
    }


    public class TelecommFormHeaderAnswersJSONObj
    {
      public string clientName;
      public string patName;
      public string patDOBStr;
      public string iepDateStr;
      public TelecommFormHeaderParticipantRosterJSONObj[] participantRosterJSON;
    }
    
    /**************************************************************************
     * TeleCommSessionIepPrtGrdFormsInitialValueData */
    /**
     * 
     * 
     ****************************************************************************/

    public class TeleCommSessionIepPrtGrdFormsInitialValueData
    {
      public int    numPrtGrdExpected;
	    public long   pgPrimaryId;
	    public long   pgPrimaryIdx;
	    public string pgPrimaryEmail;
	    public string pgPrimaryName;
	    public string pgPrimaryTitle;
	    public long   pgSecondaryId;
	    public long   pgSecondaryIdx;
	    public string pgSecondaryEmail;
	    public string pgSecondaryName;
	    public string pgSecondaryTitle;
    }
    
    /**************************************************************************
     * TeleCommPurposeSpecificDataTeleIEP */
    /**
     * 
     * 
     ****************************************************************************/

    public class TeleCommPurposeSpecificDataTeleIEP
  {     

    public TeleCommPurposeSpecificDataTeleIEP():this("","")
    {
    }
    
    public TeleCommPurposeSpecificDataTeleIEP (     string patid
                                                  , string iepformtype )
    {
      this.patID           = patid;
      this.iepFormType     = iepformtype;
    }

    public string  patID;
    public string  iepFormType;
    
	  public override string ToString()
    {
      return TeleCommPurposeSpecificDataTeleIEP.ToJSONString(this);
      //return base.ToString();
    }
    public static String ToJSONString (TeleCommPurposeSpecificDataTeleIEP purposeSpecificData)
    {
      return MBA.JSON.toJSONString(purposeSpecificData,JsonLibrary.NEWTONSOFT);
    }
    public static TeleCommPurposeSpecificDataTeleIEP FromJSONString (string purposeSpecificData)
    {    
      return (TeleCommPurposeSpecificDataTeleIEP) MBA.JSON.fromJSONString(purposeSpecificData,typeof(TeleCommPurposeSpecificDataTeleIEP),JsonLibrary.NEWTONSOFT);
    }
  }
  
  /**************************************************************************
   * TeleIEPSession */
  /**
   * 
   * 
   ****************************************************************************/

  public class TeleIEPSession: MBA.TeleCommSession
  {
    public TeleCommPurposeSpecificDataTeleIEP purposeSpecificDataObj;    

    /* Deserialized fields from database */

    public long    patID;
    public string  patName;
	public long    iepFormType;
	public string  iepFormTypeName;
    public const string DEFAULT_PAGING_ORDER = @"meetingDate asc, meetingTime asc";

  }

    /**************************************************************************
     * TeleIEPSessions */
    /**
     * 
     * 
     ****************************************************************************/

    public class TeleIEPSessions : MBA.TeleCommSessions
    {
    
        public const string SEL_LABEL               = @"HYQueue IEP Meetings";
        public const string SEL_LABEL_MANAGE        = SEL_LABEL;
        public const string SEL_LABEL_VIEW_UPCOMING = @"Upcoming " + SEL_LABEL;
        public const string SEL_LABEL_ADD_NEW       = @"Add New";
        public const string SEL_LABEL_EDIT          = @"Edit";
        public const string MENU_LINK_MANAGE        = @"telecommteleiepmanagelink";
        public const string URL_USER_ALL_SAVE       = @"user_all_telecomm_tele_health_save.aspx";
        public const string URL_IEP_ALL_SAVE = @"user_all_telecomm_tele_iep_save.aspx";
        public const string URL_USER_ALL_MANAGE = @"user_all_tele_iep_manage.aspx";
        public const string URL_CLIENT_MANAGE = URL_USER_ALL_MANAGE;
        public const string URL_SBS_MANAGE = URL_USER_ALL_MANAGE;
        public const string URL_TELECOMM_PAGE       = @"telecomm_iep.aspx";
        
        public static string VAL_FILE_CLASS        = MBA.StoredFiles.FILE_CLASS_TELECOMM_TELE_IEP;
        public static string VAL_FILE_NAMESPACE    = "telecomm";
        public static string VAL_FILE_SOURCE       = "teleiep";

        public const string URL_SERVICE_BASE = @"telecomm_sessions_tele_iep.asmx";
        public const string URL_IEP_ALL_DELETE_BASE = URL_SERVICE_BASE + @"/delete";
        public const string URL_IEP_ALL_SAVE_BASE   = URL_SERVICE_BASE + @"/save";
        public const string URL_REST_VIEW_BASE = @"api/v1/teleiepsessions";

        public const string URL_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
        public const string URL_JOIN_MEETING_BASE = URL_SERVICE_BASE + @"/gettelecommsessionparticipantforuserid";

        /***************************************************************************
         * URL_ADD_NEW_IEP */
        /**
         * 
         **************************************************************************/
        public static string URL_ADD_NEW_IEP()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_IEP_ALL_SAVE
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                  );
        }

        /***************************************************************************
         * URL_EDIT_IEP */
        /**
         * 
         **************************************************************************/
        public static string URL_EDIT_IEP()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_IEP_ALL_SAVE
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                  , new NameValue(Constants.PARM_REC_ID, "")
                                                  );
        }

        /***************************************************************************
         * URL_DELETE_ORDER_PRESCRIPTION_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_DELETE_IEP()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_IEP_ALL_DELETE_BASE
                                                   , true
                                                 );
        }
        /***************************************************************************
         * URL_REST_VIEW_IEP */
        /**
         * 
         **************************************************************************/
        public static string URL_REST_VIEW_IEP()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_REST_VIEW_BASE, true);
        }

        /***************************************************************************
         * URL_JOIN_MEETING */
        /**
         * 
         **************************************************************************/

        public static string URL_JOIN_MEETING()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_JOIN_MEETING_BASE, true);
        }

        public static string URL_SAVE_IEP()
        {
            return MBA.HttpApplication.createLink(TeleIEPSessions.URL_IEP_ALL_SAVE_BASE
                                                   , true
                                                 );
        }

        /***************************************************************************
         * clientHasAccess */
        /**
         *  
         *
         ***************************************************************************/

        public static bool clientHasAccess (ReturnWebUser wu) {
           return wu.usr.teleCommTeleIEPAccessGranted;
         }

    /***************************************************************************
     * clientHasAccess */
    /**
     *  
     * Looks up directly
     ***************************************************************************/

    public static bool clientHasAccess (  SqlConnection   connSpedmon
                                        , DetailsLog      log
                                        , UserInfo        uInfo
                                        , string          clientID)
    {
    
      Client c = Clients.load(connSpedmon,log,uInfo,clientID);            
      var accessGranted = c.teleCommTeleIEPAccessGranted;
      /* TODO: Access grant date check */
      return accessGranted;
    }
    
    /***************************************************************************
     * validateClientAccessForMethodOrHandler */
    /**
     * 
     *
     ***************************************************************************/

    public static bool validateClientAccessForMethodOrHandler (   SqlConnection   connSpedmon
                                                                , DetailsLog      log
                                                                , UserInfo        uInfo
                                                                , string          clientID)
    {
      bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);
      if (hasAccess == false) throw new MBA.Critical(@"Subscription required");
      return hasAccess;
    }
    
    /***************************************************************************
     * validateClientAccessForPage */
    /**
     *  
     *
     ***************************************************************************/

    public static void validateClientAccessForPage (   SqlConnection   connSpedmon
                                                     , DetailsLog      log
                                                     , UserInfo        uInfo
                                                     , string          clientID
                                                     , HttpResponse    Response
                                                     , HttpContext     Context )
    {           	     
      
      bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);     
      if (hasAccess == false)
      {
        throw new MBA.Critical(@"Subscription required");
        //string url = MBA.HttpApplication.createLink(PlanWriterRecords.URL_USER_ALL_SUBSCRIPTION_NOTICE,true);
        //Response.Redirect(url,false);
        //Context.ApplicationInstance.CompleteRequest();
      }   
    }

    /**************************************************************************
    * addTopSignatureLine */
    /**
    * used in the top part of the IEP to add a line of 2 signatures and dates
    *
    ***************************************************************************/
    static void addTopSignatureLine(PdfWriter writer, ref List<PdfPCell> cells, string idx_1, string field_1_label, iTextSharp.text.Image signatureImg1, string idx_2, string field_2_label,  iTextSharp.text.Image signatureImg2, Dictionary<string, string> TelecommTopSectionAnswers)
    {
        int colsPerRow = PDFFormGeneration.Constants.numTableColsBase24;

        PDFFormGeneration.addTextFieldCell(writer
                                         , ref cells
                                         , "signature_" + idx_1
                                         , null
                                         , 0
                                         , ((signatureImg1 == null) ? 7 : 5)
                                         , Rectangle.ALIGN_LEFT
                                         , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE
                                         , PDFFormGeneration.Constants.defaultSignaturePadding
                                         , PDFFormGeneration.Constants.maxCharsPerLineForTopSignatures
                                         , false, false, false, colsPerRow, TelecommTopSectionAnswers);
        // render signatrue if it exists
        if (signatureImg1 != null) {
            signatureImg1.ScaleAbsolute(55f, 20f);
            cells.Add(PDFCommon.generateCell(signatureImg1, 1, 2, Rectangle.ALIGN_CENTER, Rectangle.ALIGN_MIDDLE, Color.WHITE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE));
        }
        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addTextFieldCell(writer, ref cells, "date_" + idx_1, null, 0, 3, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, 0, PDFFormGeneration.Constants.maxCharsPerLineForTopSignatures, false, false, false, colsPerRow, TelecommTopSectionAnswers);

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);

        PDFFormGeneration.addTextFieldCell(writer
                                         , ref cells
                                         , "signature_" + idx_2
                                         , null
                                         , 0
                                         , ((signatureImg2 == null) ? 7 : 5)
                                         , Rectangle.ALIGN_LEFT
                                         , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE
                                         , PDFFormGeneration.Constants.defaultSignaturePadding
                                         , PDFFormGeneration.Constants.maxCharsPerLineForTopSignatures
                                         , false, false, false, colsPerRow, TelecommTopSectionAnswers);
        // render signatrue if it exists
        if (signatureImg2 != null) {
            signatureImg2.ScaleAbsolute(55f, 20f);
            cells.Add(PDFCommon.generateCell(signatureImg2, 1, 2, Rectangle.ALIGN_CENTER, Rectangle.ALIGN_MIDDLE, Color.WHITE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE));
        }
        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addTextFieldCell(writer, ref cells, "date_" + idx_2, null, 0, 3, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, 0, PDFFormGeneration.Constants.maxCharsPerLineForTopSignatures, false, false, false, colsPerRow, TelecommTopSectionAnswers);

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);

        PDFFormGeneration.addParagraphCell(writer, ref cells, field_1_label, null, 7, Rectangle.ALIGN_TOP, false, false, colsPerRow);
        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addParagraphCell(writer, ref cells, "Date", null, 3, Rectangle.ALIGN_TOP, false, false, colsPerRow);

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_TOP, false, false, colsPerRow);

        PDFFormGeneration.addParagraphCell(writer, ref cells, field_2_label, null, 7, Rectangle.ALIGN_TOP, false, false, colsPerRow);
        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addParagraphCell(writer, ref cells, "Date", null, 3, Rectangle.ALIGN_TOP, false, false, colsPerRow);

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_TOP, false, false, colsPerRow);
    }

    /**************************************************************************
    * getSignatureLineTitle */
    /**
    * Returns a title for the top signature lines of the PDF 
    * 
    * if the passed in string is null, this function sets it to the proper title
    * based on the passed in index
    *
    ***************************************************************************/
    static string getSignatureLineTitle(string sigTitle, int index)
    {
        // This is the variable that will be returned
        string returnSigTitle = "";

        // If value is provided, just return it
        if (!String.IsNullOrEmpty(sigTitle))
        {
            return sigTitle;
        }

        // Otherwise return a preset string based on the index
        switch(index)
        {
            case 1:
            case 2:
                returnSigTitle = "Parent / Guardian / Surrogate";
                break;

            case 3:
                returnSigTitle = "Student / Adult Student";
                break;

            case 4:
                returnSigTitle = "General Education Teacher";
                break;

            case 5:
                returnSigTitle = "LEA Representative / Admin. Designee";
                break;

            case 6:
                returnSigTitle = "Special Education Specialist";
                break;

            default:
                returnSigTitle = "Additional Participant";
                break;
        }

        // Return the correct string
        return returnSigTitle;
    }

    /**************************************************************************
    * addTemplateTopFormFields */
    /**
    * adds the top fields of the default PDF template
    *
    ***************************************************************************/
    static void addTemplateTopFormFields(PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> TelecommTopSectionAnswers)
    {
        int colsPerRow = PDFFormGeneration.Constants.numTableColsBase24;

        // get client name from TelecommTopSectionAnswers
        string clientName; // the name of the client which will come from TelecommTopSectionAnswers["clientName"]
        TelecommTopSectionAnswers.TryGetValue("clientName", out clientName);
        clientName = String.IsNullOrEmpty(clientName) ? "No District Name Provided" : clientName; 

        // add the top 2 headers
        PDFFormGeneration.addHeaderCell(writer, ref cells, "", "h6", 8, false, false, colsPerRow);
        PDFFormGeneration.addHeaderCell(writer, ref cells, clientName, "h6", 8, false, false, colsPerRow);
        PDFFormGeneration.addHeaderCell(writer, ref cells, "", "h6", 8, false, false, colsPerRow);
        PDFFormGeneration.addHeaderCell(writer, ref cells, "", "h6", 8, false, false, colsPerRow);
        PDFFormGeneration.addHeaderCell(writer, ref cells, "Signature(s) and Parent Consent", "h6", 10, false, false, colsPerRow);
        PDFFormGeneration.addHeaderCell(writer, ref cells, "", "h6", 6, false, false, colsPerRow);
        //cells.Add(generateSpaceCell());colsPerRow, 

        // add the name, date of birth and IEP date fields
        PDFFormGeneration.addTextFieldCell(writer, ref cells, "patName", "      Student Name", 3, 5, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, PDFFormGeneration.Constants.defaultPadding, PDFFormGeneration.Constants.maxCharsPerLineForHeaderFields, false, false, false, colsPerRow, TelecommTopSectionAnswers);
        PDFFormGeneration.addTextFieldCell(writer, ref cells, "patDOBStr", "        Date of Birth ", 3, 5, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, PDFFormGeneration.Constants.defaultPadding, PDFFormGeneration.Constants.maxCharsPerLineForHeaderFields, false, false, false, colsPerRow, TelecommTopSectionAnswers);
        PDFFormGeneration.addTextFieldCell(writer, ref cells, "iepDateStr", "           IEP Date ", 3, 5, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, PDFFormGeneration.Constants.defaultPadding, PDFFormGeneration.Constants.maxCharsPerLineForHeaderFields, false, false, false, colsPerRow, TelecommTopSectionAnswers);

        //cells.Add(generateSpaceCell());

        // add signature section
        PDFFormGeneration.addHeaderCell(writer, ref cells, "IEP MEETING PARTICIPANTS", "h6", PDFFormGeneration.Constants.numTableColsBase24, false, true, colsPerRow);
        for (int i = 1; i <= PDFFormGeneration.Constants.numSignatureLinesInHeader; i += 2) {
            // get our index variable as a string
            string iString = i.ToString();
            string iPlusOneString = (i + 1).ToString();
            
            // get 2 signature lines at a time
            string signatureTitle1;
            TelecommTopSectionAnswers.TryGetValue("title_" + iString, out signatureTitle1);
            signatureTitle1 = getSignatureLineTitle(signatureTitle1, i); // if the string is empty, we need to use a preset for the title

            string signatureTitle2;
            TelecommTopSectionAnswers.TryGetValue("title_" + iPlusOneString, out signatureTitle2);
            signatureTitle2 = getSignatureLineTitle(signatureTitle2, i + 1); // if the string is empty, we need to use a preset for the title
                        
            // get 2 signature images at a time
            string signatureImg1;
            TelecommTopSectionAnswers.TryGetValue("signatureBase64_" + iString, out signatureImg1);

            string signatureImg2;
            TelecommTopSectionAnswers.TryGetValue("signatureBase64_" + iPlusOneString, out signatureImg2);
            
            // add signature lines
            addTopSignatureLine(writer
                              , ref cells
                              , iString
                              , signatureTitle1
                              , (String.IsNullOrEmpty(signatureImg1)
                                   ?
                                   null
                                   :
                                   iTextSharp.text.Image.GetInstance(Convert.FromBase64String(signatureImg1.Split(',')[1]))
                                )
                              , iPlusOneString
                              , signatureTitle2
                              , (String.IsNullOrEmpty(signatureImg2)
                                   ?
                                   null
                                   :
                                   iTextSharp.text.Image.GetInstance(Convert.FromBase64String(signatureImg2.Split(',')[1]))
                                )
                              , TelecommTopSectionAnswers);
        }
        
        PDFFormGeneration.addBarrierCell(writer, ref cells, colsPerRow);

    }

    /**************************************************************************
    * addSignatureSectionRadioField */
    /**
    * used by addBottomSignatureSection function to render radios for the different roles for the signature pieces
    *
    ***************************************************************************/
    static void addSignatureSectionRadioField(PdfWriter writer, ref List<PdfPCell> cells, string id, string value, string label, Dictionary<string, string> TelecommBottomSignatureAnswers)
    {
        var (radioCell, labelCell) = PDFFormGeneration.generateRadioCell(writer, id, value, label, 3, TelecommBottomSignatureAnswers);
        radioCell.PaddingLeft = 50;
        radioCell.PaddingTop = 3;
        cells.Add(radioCell);
        cells.Add(labelCell);
    }

    /**************************************************************************
    * addBottomSignatureSection */
    /**
    * adds the bottom signature pieces of the default PDF template
    *
    ***************************************************************************/
    static void addBottomSignatureSection(PdfWriter writer
                                        , ref List<PdfPCell> cells
                                        , string signatureId
                                        , string dateFieldId
                                        , string roleFieldId
                                        , string[] values
                                        , string[] labels
                                        , iTextSharp.text.Image signatureImg
                                        , Dictionary<string, string> TelecommBottomSignatureAnswers) {
        int colsPerRow = PDFFormGeneration.Constants.numTableColsBase24;

        // add the first line
        PDFFormGeneration.addParagraphCell(writer, ref cells, "Signature", null, 2, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addTextFieldCell(writer
                                         , ref cells
                                         , signatureId
                                         , null
                                         , 0
                                         , ((signatureImg == null) ? 16 : 14)
                                         , Rectangle.ALIGN_LEFT
                                         , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE
                                         , PDFFormGeneration.Constants.defaultPadding
                                         , PDFFormGeneration.Constants.maxCharsPerLineForBottomSignatures
                                         , false, false, false, colsPerRow, null);
        // set absolute size for image
        if (signatureImg != null) {
                signatureImg.ScaleAbsolute(55f, 20f);
                cells.Add(PDFCommon.generateCell(signatureImg, 1, 2, Rectangle.ALIGN_CENTER, Rectangle.ALIGN_MIDDLE, Color.WHITE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE));
        }
        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 2, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addTextFieldCell(writer
                                         , ref cells
                                         , dateFieldId
                                         , null
                                         , 0
                                         , 4
                                         , Rectangle.ALIGN_LEFT
                                         , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE
                                         , PDFFormGeneration.Constants.defaultPadding
                                         , PDFFormGeneration.Constants.maxCharsPerLineForBottomSignatures
                                         , false, false, false, colsPerRow, null);

        cells.Add(PDFFormGeneration.generateSpaceCell(colsPerRow));

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 2, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);

        // add radios for each value in the array
        for (int i = 0; i < values.Length; i++)
        {
            addSignatureSectionRadioField(writer, ref cells, roleFieldId, values[i], labels[i], TelecommBottomSignatureAnswers);
        }

        PDFFormGeneration.addParagraphCell(writer, ref cells, "", null, 2, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
        PDFFormGeneration.addParagraphCell(writer, ref cells, "Date", null, 4, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
    }
    
    /**************************************************************************
    * addTemplateTopFormFields */
    /**
    * adds the top fields of the default PDF template
    *
    ***************************************************************************/
    static void addTemplateBottomFormFields(PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> TelecommBottomSignatureAnswersJSON)
    {
        int colsPerRow = PDFFormGeneration.Constants.numTableColsBase24;

        PDFFormGeneration.addBarrierCell(writer, ref cells, colsPerRow);

        PDFFormGeneration.addHeaderCell(writer, ref cells, "Signature below is to authorize and approve the IEP", "h6", PDFFormGeneration.Constants.numTableColsBase24, false, false, colsPerRow);

        addBottomSignatureSection(writer
                                , ref cells
                                , "parent-signature-primary-signature"
                                , "parent-signature-primary-date-signed"
                                , "parent-signature-primary-role"
                                , new string[] { "parent", "guardian", "surrogate", "adult" }
                                , new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" }
                                , (String.IsNullOrEmpty(TelecommBottomSignatureAnswersJSON["parent-signature-primary-signatureImgBase64"])
                                   ?
                                   null
                                   :
                                   iTextSharp.text.Image.GetInstance(Convert.FromBase64String(TelecommBottomSignatureAnswersJSON["parent-signature-primary-signatureImgBase64"].Split(',')[1]))
                                  )
                                , TelecommBottomSignatureAnswersJSON);
        cells.Add(PDFFormGeneration.generateSpaceCell(colsPerRow));
        addBottomSignatureSection(writer
                                , ref cells
                                , "parent-signature-secondary-signature"
                                , "parent-signature-secondary-date-signed"
                                , "parent-signature-secondary-role"
                                , new string[] { "parent", "guardian", "surrogate", "adult" }
                                , new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" }
                                , ((String.IsNullOrEmpty(TelecommBottomSignatureAnswersJSON["parent-signature-secondary-signatureImgBase64"])) 
                                   ?
                                   null
                                   :
                                   iTextSharp.text.Image.GetInstance(Convert.FromBase64String(TelecommBottomSignatureAnswersJSON["parent-signature-secondary-signatureImgBase64"].Split(',')[1]))
                                  )
                                , TelecommBottomSignatureAnswersJSON);

        PDFFormGeneration.addBarrierCell(writer, ref cells, colsPerRow);

        PDFFormGeneration.addParagraphCell(writer
                                         , ref cells
                                         , "If my child is or may become eligible for public benefits (Medi-Cal): I authorize the LEA/district to release student information for the limited purpose of billing Medi-Cal/Medicaid and to access Medi-Cal: health insurance benefits for applicable services."
                                         , null
                                         , PDFFormGeneration.Constants.numTableColsBase24
                                         , Rectangle.ALIGN_MIDDLE
                                         , false
                                         , false
                                         , colsPerRow);
        addBottomSignatureSection(writer
                                , ref cells
                                , "lea-bop-consent-parent-signature"
                                , "lea-bop-consent-parent-date-signed"
                                , "lea-bop-consent-parent-role"
                                , new string[] { "parent", "guardian", "surrogate", "adult" }
                                , new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" }
                                , ((String.IsNullOrEmpty(TelecommBottomSignatureAnswersJSON["lea-bop-consent-parent-signatureImgBase64"]))
                                    ?
                                    null
                                    :
                                    iTextSharp.text.Image.GetInstance(Convert.FromBase64String(TelecommBottomSignatureAnswersJSON["lea-bop-consent-parent-signatureImgBase64"].Split(',')[1]))
                                  )
                                , TelecommBottomSignatureAnswersJSON);
        //cells.Add(generateSpaceCell());
    }


    /***************************************************************************
     * createNewParticipantDetails */
    /**
     * 
     * 1. Parent/ Guardian/ Surrogate 
     * 2. Parent/ Guardian/ Surrogate 
     * 3. Student / Adult Student
     * 4. General Education Teacher             (has meeting facilitator who is participating privs)
     * 5. LEA Representative / Admin. Designee  (has meeting facilitator who is participating privs)
     * 6. Special Education Specialist          (has meeting facilitator who is participating privs)
     * 7. Additional Participant
     * 8. Additional Participant
     * 9. Additional Participant
     * 10. Additional Participant
     * 11. Additional Participant
     * 12. Additional Participant
     ****************************************************************************/    
    public static string createNewParticipantDetails ()
    {
      var detailsObj                = new MBA.TeleCommParticipantsDetails();
      detailsObj.participantdetails = new List<TeleCommParticipant>(); 
  
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(1,  @"Parent / Guardian / Surrogate",         TeleCommParticipants.PARTICIPANT_ROLE_PARENT_GUARD));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(2,  @"Parent / Guardian / Surrogate",         TeleCommParticipants.PARTICIPANT_ROLE_PARENT_GUARD));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(3,  @"Student / Adult Student",               TeleCommParticipants.PARTICIPANT_ROLE_PATIENT));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(4,  @"General Education Teacher",             TeleCommParticipants.PARTICIPANT_ROLE_PRACTITIONER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(5,  @"LEA Representative / Admin. Designee",  TeleCommParticipants.PARTICIPANT_ROLE_LEA_COOR));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(6,  @"Special Education Specialist",          TeleCommParticipants.PARTICIPANT_ROLE_PRACTITIONER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(7,  @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(8,  @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(9,  @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(10, @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(11, @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));
      detailsObj.participantdetails.Add(new MBA.TeleCommParticipant(12, @"Additional Participant",                TeleCommParticipants.PARTICIPANT_ROLE_OTHER));

      var detailsStr = MBA.JSON.toJSONString(detailsObj,JsonLibrary.NEWTONSOFT);
      var detailsStrMod = Util.jsonStringReplaceAllNonStringValuesWithStringValues (detailsStr);
      return detailsStrMod;
    }

    /***************************************************************************
     * getTeleCommSessionParticipantForUserID */
    /**
     * 
     * 
     ****************************************************************************/    
    public static ReturnTeleCommSessionParticipant getTeleCommSessionParticipantForUserID (   SqlConnection connUsers
                                                                                            , DetailsLog    log
                                                                                            , UserInfo      uInfo
                                                                                            , string        roomID )       
    {
      return TeleCommSessions.getTelecommSessionParticipantForUserID (connUsers, log, uInfo, roomID, URL_TELECOMM_PAGE);
    }

         /***************************************************************************
          * save */
         /**
          * 
          * 
          ****************************************************************************/    
         public static ReturnSaveRecordWithJSONData save (   SqlConnection connUsers
                                                           , SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        facilitatorUserID
                                                           , string        patID
                                                           , string        iepFormType
 	     									                                  , string        meetingDate
                                                           , string        meetingTime
	     										                                , string        meetingDurationInMins
                                                           , string        title  
                                                           , string        participantDetails
                                                           , string        filesToShareUploadIDs
                                                           , string        saveType
                                                           , string        validateRec
                                                           , string        editDelReason
                                                           , string        recID )
         {           
                                        
           
           ReturnSaveRecordWithJSONData so = new ReturnSaveRecordWithJSONData();
         
           /*============================================================
            * Validate required fields
            *============================================================*/  
         
           clientID          = Validate.reqClientID (uInfo,clientID).ToString();
           patID             = Validate.reqInteger  (patID,Messages.INVALID_PAT_ID).ToString();
           iepFormType       = Validate.reqInteger  (iepFormType,       @"Invalid IEP Format").ToString();
           facilitatorUserID = Validate.reqInteger  (facilitatorUserID, @"Invalid meeting contact").ToString();
         
           /*============================================================
            * Generate teleiep specific data to save with this session
            *============================================================*/  
         
           string vPurposeSpecificData = new TeleCommPurposeSpecificDataTeleIEP (patID,iepFormType).ToString();
         
           /*============================================================
            * Load data for the meeting contact (non participating 
            * facilitator)
            *============================================================*/  
         
           var u = Spedmon.Users.load(connUsers,log,uInfo,facilitatorUserID);
         
           /*============================================================
            * Load HTML and JSON form data used for this room
            *============================================================*/  
         
           var iepType = TeleCommIEPTypes.load(connSpedmon,log,uInfo,iepFormType);
           
           /*============================================================
            * Call the general purpose save method
            * TODO: Replace with a specific method
            *============================================================*/  
         
           so = MBA.TeleCommSessions.save (  connUsers
                                             , log
                                             , uInfo
                                             , Constants.APP_NAME
                                             , Constants.OPEN_VIDU_APP_ENVIRONMENT
                                             , Constants.TELECOMM_PURPOSE_IEP
                                             , Constants.TELECOM_PARTICIPANT_AUTH_METHOD_EMAIL_PIN
                                             , Validate.reqClientID(uInfo,clientID)
                                             , true
                                             , false
                                             , u.name
                                             , u.clientName
                                             , u.email
                                             , u.phone
                                             , u.id
                                             , u.roleID
                                             , u.pracID
                                             , meetingDate
                                             , meetingTime
                                             , meetingDurationInMins
                                             , title
                                             , ""
                                             , iepType.formsHTML
                                             , iepType.formsJSON
                                             , vPurposeSpecificData
                                             , participantDetails
                                             , filesToShareUploadIDs
                                             , saveType
                                             , validateRec
                                             , editDelReason
                                             , recID);
           
          
           return so;
         }
  
        /***************************************************************************
         * delete */
        /**
         * "Deletes" a session
         * 
         * @param  editDelReason   Reason for edit/delete 
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for edit and delete
         * @return                 ReturnSaveNewRecord
         ***************************************************************************/   
    
        public static ReturnSaveRecord delete (  SqlConnection connUsers
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , string        editDelReason
                                               , string        validateRec
                                               , string        recID)
        {           
         
          /*----------------------------
           * Check for required and 
           * optional parameters
           * and validate data integrity
           * of all supplied parameters
           *----------------------------*/
        
          Object vClientID = Validate.optClientID(uInfo, ""); /*Ensures that clients can only deactivate their records */
          string appName   = Constants.APP_NAME;
           
         /*----------------------------
          * Call base method 
          *----------------------------*/
        
         return MBA.TeleCommSessions.delete (   connUsers
                                              , log
                                              , uInfo
                                              , appName
                                              , vClientID
                                              , editDelReason
                                              , validateRec
                                              , recID );
        
        }

 
        /***************************************************************************
         * view */
        /**
         * View Sessions
         * 
         * @return            ReturnDB
         ***************************************************************************/   

        public static ReturnDB view (   SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , string        clientID
                                       , string        patID
                                       , int           recViewType
                                       , bool          pagedOrTop
                                       , string        idx
                                       , string        canEdit
                                       , string        active                                      
                                       , defineCols    dc )
        {
           
           Object vClientID = Validate.optClientID (uInfo, clientID);
           Object vPatID    = Validate.optInteger  (patID,Messages.INVALID_PAT_ID);
        
           string viewUDF = @"dbo.TELECOMM_SESSIONS_IEP_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @active, @recID)";
           
           List<SqlParameter> parms = new List<SqlParameter>();
           
           parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
           parms.Add(Database.SqlParm("@patID",      SqlDbType.BigInt,   vPatID,     ParameterDirection.Input));
                                              
           /*###########################################################################
             # Call base method which handles the rest and return the results
             ###########################################################################*/  
           
           return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
        
        }

        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<TeleIEPSession> viewList(SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo
                                                      , string clientID
                                                      , string patID
                                                      , string active)

        {
            var recs = new List<TeleIEPSession>();

            ReturnDB rd = TeleIEPSessions.view(connSpedmon, log, uInfo, clientID, patID, Entities.REC_VIEW_RAW, false, null, "", active, null);
            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(TeleIEPSession));
            foreach (var o in slo)
            {
                recs.Add((TeleIEPSession)o);
            }
            return recs;
        }

        /***************************************************************************
         * viewTbl */
        /**
         * View Table * 
         * @param  appName     Application name (from web.config or app.config) 
         * @param  clientID    Client ID record (if any)
         * @return             ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl (   SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , string        clientID
                                               , string        patID
                                               , bool          paged
                                               , string        pageNumber
                                               , string        canEdit
                                               , string        active ) 
       {
         defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
           ss.addDisplayColumn ("id as [id]", true);
           ss.addDisplayColumn ("patName as [Patient]");
           ss.addDisplayColumn ("title as [Meeting Title]");
           ss.addDisplayColumn ("meetingDateStr as [Meeeting Date]");
           ss.addDisplayColumn ("meetingTimeStr as [Meeting Time]");
           ss.addDisplayColumn ("roomID as [Room ID]");
           pageroworder = ss.pageRowOrder();     
         };
         
         return Entities.viewTbl( connSpedmon
                                , log
                                , uInfo
                                , paged
                                , pageNumber
                                , delegate{
                                    return TeleIEPSessions.view (  connSpedmon
                                                                  , log
                                                                  , uInfo  
                                                                  , clientID
                                                                  , patID
                                                                  , Entities.REC_VIEW_TBL
                                                                  , paged
                                                                  , pageNumber
                                                                  , canEdit
                                                                  , active
                                                                  , dc);}
                               , TeleIEPSessions.SEL_LABEL_VIEW_UPCOMING
                               , Messages.CONFIDENTIAL
           );
       }

       /***************************************************************************
        * load */
       /**
        * Outputs data for a single record
        * 
        * Note: This calls the view method and the view method takes care of
        * enforcing the client id and the pracid
        * 
        * @return TeleIEPSession 
        *************************************************************************/
       
       public static TeleIEPSession load (   SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , string        recID )
       {      
         TeleIEPSession so = new TeleIEPSession();
       
         so = (TeleIEPSession) Entities.load (   connSpedmon
                                               , log
                                               , uInfo
                                               , recID
                                               , typeof(TeleIEPSession)
                                               , delegate { 
                                                   return TeleIEPSessions.view (  connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , ""
                                                                                 , ""
                                                                                 , Entities.REC_VIEW_LOAD
                                                                                 , false
                                                                                 , recID
                                                                                 , ""
                                                                                 , ""
                                                                                 , null);
                                                   });
       
         so.purposeSpecificDataObj = TeleCommPurposeSpecificDataTeleIEP.FromJSONString(so.purposeSpecificData);
         return so;
       }

       /***************************************************************************
        * loadLastEnteredForClientPatient */
       /**
        * Outputs data for a single record
        * 
        * @return TeleIEPSession 
        ***************************************************************************/
       public static TeleIEPSession loadLastEnteredForClientPatient (   SqlConnection connSpedmon
                                                                      , DetailsLog    log
                                                                      , UserInfo      uInfo
                                                                      , string        clientID
                                                                      , string        patID )
       {      
         TeleIEPSession so = new TeleIEPSession();
         
         long vClientID  = Validate.reqClientID(uInfo,clientID);
         long vPatientID = Validate.reqInteger(patID,Messages.INVALID_PAT_ID);
       
         List<SqlParameter> parms = new List<SqlParameter>();   
         
         parms.Add(Database.SqlParm("@clientID",    SqlDbType.BigInt,  vClientID,     ParameterDirection.Input));
         parms.Add(Database.SqlParm("@patID",       SqlDbType.BigInt,  vPatientID,    ParameterDirection.Input));
       
         string sql =  @"select top 1 * from dbo.TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED (@clientID, @patID)";
       
         ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
       
         if (rd.hasRecords) {
           so = (TeleIEPSession) Database.convertRecord(rd.records,typeof(TeleIEPSession));
           so.purposeSpecificDataObj = TeleCommPurposeSpecificDataTeleIEP.FromJSONString(so.purposeSpecificData);
         }
         
         /* No record found so we can generate the starter values needed */
         
         else {
           
           so.participantDetailsEnteredJSON = createNewParticipantDetails();
         }
       
         return so;
       }

       /***************************************************************************
        * joinJSONObjects */
       /**
        * merges an array of JSONs into one JSON string
        * 
        ****************************************************************************/
       public static string joinJSONObjects(string[] objs)
       {   
           // procedure: remove the beginning { and ending } from the strings and place a comma between appended strings
           string result = objs[0].Replace("{", "").Replace("}", "");
           
           for (int i = 1; i < objs.Length; i++) {
               string modifiedString = objs[i].Replace("{", ",").Replace("}", "");
               result += modifiedString;
           }
       
           return "{" + result + "}";
       }
        
       /***************************************************************************
        * formatHeadersJSON */
       /**
        * takes a JSON string and turns it into a name-value pair JSON
        * 
        ****************************************************************************/
       public static string formatHeadersJSON(string headerAnswersJSON)
       {
           if (String.IsNullOrEmpty(headerAnswersJSON)) { return ""; }
           // procedure: remove the beginning { and ending } from the strings and place a comma between appended strings
           string result = "";
           
           // get the answers from JSON to an object array
           TelecommFormHeaderAnswersJSONObj JSONObj = (TelecommFormHeaderAnswersJSONObj)JSON.fromJSONString(headerAnswersJSON, typeof(TelecommFormHeaderAnswersJSONObj), JsonLibrary.NEWTONSOFT);
           
           // put in fields that were originally name-value pairs as they were
           result += "\"clientName\":\"" + JSONObj.clientName + "\","
                   + "\"patName\":\""    + JSONObj.patName    + "\","
                   + "\"patDOBStr\":\""  + JSONObj.patDOBStr  + "\","
                   + "\"iepDateStr\":\"" + JSONObj.iepDateStr + "\"";
           
           // parse the roster array into key-value pairs by their idx
           for (int i = 0; i < JSONObj.participantRosterJSON.Length; i++)
           {
                   result += ",\"signature_" + JSONObj.participantRosterJSON[i].idx.ToString() + "\":\"" + JSONObj.participantRosterJSON[i].signature + "\"" +
                             ",\"date_" + JSONObj.participantRosterJSON[i].idx.ToString() + "\":\"" + JSONObj.participantRosterJSON[i].dateSignedStr + "\"" +
                             ",\"title_" + JSONObj.participantRosterJSON[i].idx.ToString() + "\":\"" + JSONObj.participantRosterJSON[i].title + "\"" +
                             ",\"signatureBase64_" + JSONObj.participantRosterJSON[i].idx.ToString() + "\":\"" + JSONObj.participantRosterJSON[i].signatureBase64 + "\"";
           }
       
           return "{" + result + "}";
       }
    
       /***************************************************************************
        * saveSigPageQuestions */
       /**
        * Called by 
        * 
        ****************************************************************************/
       public static ReturnSaveRecord saveSigPageQuestions (   SqlConnection connUsers
                                                             , SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , RequestResponse rr
                                                             , string        roomID
                                                             , string        participantEmail
                                                             , string        participantPIN
                                                             , string        formID
                                                             , string        formData
                                                             , string        validateRec )
       {           
         
         var so    = new ReturnSaveRecord();
         var parms = new List<SqlParameter>();     
         
         bool noUserInfo = false;
       
         /*============================================================
          * If there is no user info passed 
          *============================================================*/  
       
         if (uInfo == null) {     
           uInfo = new UserInfo();
           uInfo.userid    = 0;
           uInfo.userGroup = 0;
           uInfo.userRank  = 0;
           noUserInfo = true;
         }
         
         /*============================================================
          * Get validation state.  Note we need this data to determine
          * if we generate a file or not
          *============================================================*/  
           
         bool  vValidateRec = Validate.reqFlag (validateRec,  Messages.INVALID_VALIDATE_FLAG);
       
         /*============================================================
          * Validate session form data parameters
          *============================================================*/  
       
         MBA.TeleCommSessionParticipants.validateAndAddCommonSaveSessionFormDataParms (   roomID
                                                                                        , participantEmail
                                                                                        , participantPIN
                                                                                        , rr
                                                                                        , formID
                                                                                        , formData
                                                                                        , ref parms );
         
         /*============================================================
          * Call form data finalize save
          *============================================================*/  
       
         ReturnSaveRecordWithJSONData sfd = Entities.saveAndReturnJSONData (   connSpedmon
                                                                             , log
                                                                             , uInfo
                                                                             , Constants.SAVE_TYPE_NEW.ToString()
                                                                             , validateRec
                                                                             , ""
                                                                             , ""
                                                                             , "TELECOMM_IEP_SAVE_SIG_PAGE"
                                                                             , "This page has already been saved"
                                                                             , ref parms
                                                                             , null );
       
         /*============================================================
          * Pass back
          *============================================================*/  
       
         so = sfd;
         
         /*============================================================
          * If we are not validating and the call returned OK then
          * generate signature file and share it
          *============================================================*/  
       
         if ((!vValidateRec) && (sfd.status == Return.RET_SUCCESS))
         {
          
           /*-------------------------------    
            * Extract data from finalize
            * save
            *------------------------------*/ 
       
           TeleCommSessionIEPSigPageDocData spdd = (TeleCommSessionIEPSigPageDocData) JSON.fromJSONString(sfd.jsonData,typeof(TeleCommSessionIEPSigPageDocData),JsonLibrary.NEWTONSOFT);
       
           /*-------------------------------    
            * If no userinfo was passed then
            * we use the user info of the
            * person who created or last
            * modified the telecomm session
            * record for the file upload
            *------------------------------*/ 
       
           if (noUserInfo)
           {
             uInfo = new UserInfo();
             uInfo.userid    = spdd.storedFileUserID;
             uInfo.userGroup = spdd.storedFileUserGroup;
             uInfo.userRank  = spdd.storedFileUserRank;
           }
           
           /*-------------------------------    
            * Create the delegates for the 
            * header and footer
            *------------------------------*/ 
       
            PDFFormGenerationGenerateHeaderCallBack generateHeaderCb = delegate(ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict)
            {
                addTemplateTopFormFields(writer, ref cells, answersDict); 
            };
            
            PDFFormGenerationGenerateFooterCallBack generateFooterCb = delegate(ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict)
            {
                addTemplateBottomFormFields(writer, ref cells, answersDict);
            };
       
           
           /*-------------------------------    
           * Append the answers JSON
           * strings into one JSON string
           *------------------------------*/
           string answersJSON = joinJSONObjects(new string[] { spdd.formAnswersJSON, formatHeadersJSON(spdd.headerAnswersJSON.Replace("\"[", "[").Replace("]\"", "]")), spdd.footerAnswersJSON });
       
           /*-------------------------------    
            * Generate PDF file bytes for
            * the signature page
            *------------------------------*/ 
       
           ReturnFileBytes rfb = MBA.PDFFormGeneration.generateDocument (  spdd.fileName
                                                                         , generateHeaderCb /* Add delegate that calls functions */
                                                                         , PDFFormGeneration.Constants.numTableColsBase24
                                                                         , spdd.formQuestionsJSON
                                                                         , answersJSON
                                                                         , generateFooterCb);
           /*-------------------------------    
            * Save the file bytes via file 
            * upload
            *------------------------------*/ 
       
           ReturnSaveRecord sfs  = StoredFiles.save (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , VAL_FILE_CLASS
                                                      , ""
                                                      , ""
                                                      , VAL_FILE_NAMESPACE
                                                      , VAL_FILE_SOURCE
                                                      , spdd.clientIdStr
                                                      , ""
                                                      , spdd.patIdStr
                                                      , @"" /* referencedEntityID*/
                                                      , rfb
                                                      , @""
                                                      , @"N"
                                                      , Constants.SAVE_TYPE_NEW.ToString()
                                                      , "");
           
           /*-------------------------------    
            * Append the file upload to the 
            * session file shares
            *------------------------------*/ 
       
           ReturnSaveRecord afs = MBA.TeleCommSessionFileShares.appendFileShare (  connUsers
                                                                                 , log
                                                                                 , uInfo
                                                                                 , sfs.recordID.ToString()
                                                                                 , "N"
                                                                                 , ""
                                                                                 , spdd.teleCommSessionID.ToString());
         
          
                                                                                 
           //afs.recordID   
           MBA.TeleCommSessionParticipants.sendSignalRefreshFileShares(spdd.teleCommServerSessionID,"Signatures Page Ready");
                                                                                                                                                   
         }
       
         return so;                                                                               
       
       }

        /***************************************************************************
         * viewObjects 
         *
         * Returns 
         * 
         ***************************************************************************/

        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , bool pageObjectList
                                                , string pageOrder
                                                , string idx
                                                , string active
                                                , string clientID
                                                , string patID)

        {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = TeleIEPSession.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                         , log
                                         , uInfo
                                         , typeof(TeleIEPSession)
                                         , pageObjectList
                                         , pageOrder
                                         , delegate {
                                             return TeleIEPSessions.view(connSpedmon
                                                                           , log
                                                                           , uInfo
                                                                           , clientID
                                                                           , patID
                                                                           , Entities.REC_VIEW_OBJECTS
                                                                           , pageObjectList
                                                                           , idx
                                                                           , ""
                                                                           , active
                                                                           , dc);
                                         });


            return rd;
        }


        public static List<ReturnTeleCommSessionParticipant> getUpcomingTelecommSessionsForUserID(SqlConnection connUsers
                                                                                            , DetailsLog log
                                                                                            , UserInfo uInfo
                                                                                            )
        {

            return TeleCommSessions.getUpcomingTelecommSessionsForUserID(
                connUsers,
                log,
                uInfo,
                //roomID,
                Constants.TELECOMM_PURPOSE_IEP ,
                URL_TELECOMM_PAGE
                );

        }


    }
}
