using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;

using MBA;

namespace Spedmon
{
    
  /***************************************************************************
   * ServiceAuthorizationRequestOrResponseReturnData */
  /**
   * 
   **************************************************************************/  
  public class ServiceAuthorizationRequestOrResponseReturnData
  {
    public bool     userNeedsToDownloadRequest;
	  public long     userNeedsToDownloadRequestID;
    public string   userNeedsToDownloadRequestURL           = @"";
    public string   userNeedsToDownloadRequestDialogTitle   = @"";
    public string   userNeedsToDownloadRequestDialogContent = @"";
	
    public List<NewUserAccount>      accounts;  
    public List<NotificationMessage> messages;
  }
            
  /***************************************************************************
   * ServiceAuthorization*/
  /**
   * 
   **************************************************************************/
  public class ServiceAuthorizationCommon
  {          
    
    public const string SEL_LABEL_REQUEST                 = @"Service Authorization Request";
    public const string URL_REQUEST_RESPONSE_FILE_BASE    = @"service_authorization_request_response_file.ashx";
    public const string URL_UPLOAD_COMPLETED_REQUEST_FORM = @"https://app.smartsheet.com/b/form/da864e58ee6d45be8cd9a831d4740691";

    public const string LABEL_ATTEST_INTRO_ELECTRONIC     = @"I herby attest by submitting my response that :";
    public const string LABEL_ATTEST_INTRO_PAPER          = @"I herby attest by signing this form that : ";
    public const string LABEL_I_HAVE_REVIEWED_RESPONSE    = @"I have reviewed the information in this request and I :";
    
    public static ReturnSaveRecordWithJSONData ExtractAndProcessReturnData (ref ReturnSaveRecordWithJSONData so, bool validateRec)
    {
    
       /*###########################################################################
         # Email messages if we are not validating and save suceeded
         ###########################################################################*/                 

       ServiceAuthorizationRequestOrResponseReturnData r2 = new ServiceAuthorizationRequestOrResponseReturnData();        

       if ((!validateRec) && (so.status == Return.RET_SUCCESS))
       { 
         ServiceAuthorizationRequestOrResponseReturnData r1 = (ServiceAuthorizationRequestOrResponseReturnData) JSON.fromJSONString(so.jsonData,typeof(ServiceAuthorizationRequestOrResponseReturnData));
         Users.emailNewAccountsToNewUsers(r1.accounts);
         NotificationMessages.emailNotificationMessages(r1.messages);
        
        r2.userNeedsToDownloadRequest = r1.userNeedsToDownloadRequest;

        if (r1.userNeedsToDownloadRequest == true) {
           r2.userNeedsToDownloadRequestURL           = ServiceAuthorizationCommon.generateRequestResponseFileURL(r1.userNeedsToDownloadRequestID.ToString());
           r2.userNeedsToDownloadRequestDialogTitle   = r1.userNeedsToDownloadRequestDialogTitle;
           r2.userNeedsToDownloadRequestDialogContent = r1.userNeedsToDownloadRequestDialogContent;
        }

       }

       /* Create new structure just containing data we want to return to the client */

       so.jsonData = JSON.toJSONString(r2);
       
       return so;
    }
      
    /***************************************************************************
     * doesPracHaveServiceAuthorizationRequestsPending */
    /**
     *
     ***************************************************************************/ 
    
    public static bool doesPracHaveServiceAuthorizationRequestsPending (ref RequestResponse rd) 
    {
      if (rd.wu.pr != null) 
        if (rd.wu.pr.serviceAuthorizationRequestsPendingCount > 0) 
          return true;      
       return false;
    }
    
    /***************************************************************************
     * doesParentGuardianHaveServiceAuthorizationRequestsPending */
    /**
     *
     ***************************************************************************/ 

    public static bool doesParentGuardianHaveServiceAuthorizationRequestsPending (ref RequestResponse rd)
    {
      if (rd.wu.associatedPatientPersons != null)
      {
        foreach (var patientPerson in rd.wu.associatedPatientPersons)
        {
          if (patientPerson.serviceAuthorizationRequestsPendingCount > 0) return true;
        }
      }
      return false;
    }
    
    /***************************************************************************
     * doesPracHaveServiceAuthorizationRequestsTheyAreAuthToView */
    /**
     *
     ***************************************************************************/ 
    
    public static bool doesPracHaveServiceAuthorizationRequestsTheyAreAuthToView (ref RequestResponse rd) 
    {
      if (rd.wu.pr != null) 
        if (rd.wu.pr.serviceAuthorizationRequestsAuthToViewCount > 0) 
          return true;      
       return false;
    }

    /***************************************************************************
     * canPracAccessServiceAuthorizationRequestsManageSystem */
    /**
     *
     ***************************************************************************/ 
            
    public static bool canPracAccessServiceAuthorizationRequestsManageSystem (ref RequestResponse rd) 
    {
      if (doesPracHaveServiceAuthorizationRequestsPending(ref rd)) return true;
      if ( doesPracHaveServiceAuthorizationRequestsTheyAreAuthToView(ref rd)) return true;
      return false;
    }

    /*############################################################################################################
      #
      # Custom PDF Generation
      #
      ###########################################################################################################*/ 
        
    public static PdfPTable generateAuthorizationSection (  string sectionTitle
                                                            , long reqSvcAuthMethodSelectionID                                                            
                                                            , long currentResponseCode
                                                            , string responseNotes
                                                            , string responseRecordedOnStr                                                            
                                                            , string disclaimer
                                                            , string signature
                                                            , string effectiveDate
                                                            , string name
                                                            , string npi                                                            
                                                            , string email
                                                            , string phone
                                                            , bool includeNPI
                                                            , Color backGroundColor                                                      
                                                            , ref Font docDiscFont
                                                            , ref Font cellLabelFont
                                                            , ref Font cellTextFont )
   {
                      
     List<PdfPCell> cells = new List<PdfPCell>();

     bool displayNotes = false;
     string attestIntro;
     bool isFromElectronicRequest = (reqSvcAuthMethodSelectionID == (int) RequestServiceAuthorizationMethod.ELECTRONIC);
     if (isFromElectronicRequest)
     {       
       attestIntro = LABEL_ATTEST_INTRO_ELECTRONIC;             
       if (!String.IsNullOrWhiteSpace(responseNotes)) displayNotes = true;
     }
     else
     {       
       attestIntro = LABEL_ATTEST_INTRO_PAPER;       
       if ((currentResponseCode == (int) RequestServiceAuthorizationResponse.PENDING))
       {
         displayNotes = true;
         responseNotes = "\n\n";
       }      
     }

     /* Section title */
     
     cells.Add(PDFCommon.generateCell ( sectionTitle
                                       , 1
                                       , 12
                                       , Rectangle.ALIGN_CENTER
                                       , Rectangle.ALIGN_MIDDLE
                                       , PDFCommon.CELL_BORDERS_NONE
                                       , 3
                                       , ref cellLabelFont
                                       , backGroundColor));
     
     /* Response title */
     
     cells.Add(PDFCommon.generateCell ( Spedmon.ServiceAuthorizationCommon.LABEL_I_HAVE_REVIEWED_RESPONSE
                                        , 1
                                        , 6
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));
  
     /* Response section */
     
     cells.Add(PDFCommon.generateCell ( @"Approve this request"
                                        , 1
                                        , 2
                                        , Rectangle.ALIGN_RIGHT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));
     
      cells.Add(PDFCommon.generateCell ( currentResponseCode == (int) RequestServiceAuthorizationResponse.APPROVED ? @"X" : @" "
                                        , 1
                                        , 1
                                        , Rectangle.ALIGN_CENTER
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , 3
                                        , ref cellTextFont
                                        , Color.WHITE)); 

       cells.Add(PDFCommon.generateCell ( @"Decline this request"
                                        , 1
                                        , 2
                                        , Rectangle.ALIGN_RIGHT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));
     
       cells.Add(PDFCommon.generateCell ( currentResponseCode == (int) RequestServiceAuthorizationResponse.DECLINED ? @"X" : @" "
                                        , 1
                                        , 1
                                        , Rectangle.ALIGN_CENTER
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , 3
                                        , ref cellTextFont
                                        , Color.WHITE)); 

      /* Response notes */
      
      if (displayNotes == true)
      { 
      
      cells.Add(PDFCommon.generateCell ( @"Notes"
                                        , 1
                                        , 12
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));
 
      cells.Add(PDFCommon.generateCell ( responseNotes
                                        , 1
                                        , 12
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , 3
                                        , ref cellTextFont
                                        , Color.WHITE)); 
      }                             

      /* Attest statement */


      cells.Add(PDFCommon.generateCell (  attestIntro
                                        , 1
                                        , 12
                                        , Rectangle.ALIGN_CENTER
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));
     
     cells.Add(PDFCommon.generateCell (   disclaimer
                                        , 1
                                        , 12
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref docDiscFont
                                        , backGroundColor));
     
     /* Signature & Date Label */


     cells.Add(PDFCommon.generateCell ( @"Signature"
                                        , 1
                                        , 10
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));

     cells.Add(PDFCommon.generateCell ( @"Effective Date"
                                        , 1
                                        , 2
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));

     /* Signature & Date Fill Out */
     
     cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? signature : @" ")
                                        , 1
                                        , 10
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , ((isFromElectronicRequest && String.IsNullOrEmpty(signature)) ? 10 : 3)
                                        , ref cellTextFont
                                        , Color.WHITE));

     cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? effectiveDate : @" ")
                                        , 1
                                        , 2
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , ((isFromElectronicRequest && String.IsNullOrEmpty(effectiveDate)) ? 10 : 3)
                                        , ref cellTextFont
                                        , Color.WHITE));
   
     /* Name & NPI Label */

     cells.Add(PDFCommon.generateCell ( @"Name (Please Print)"
                                        , 1
                                        , (includeNPI ? 10 : 12)
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 3
                                        , ref cellTextFont
                                        , backGroundColor));

      if (includeNPI)
      { 
        cells.Add(PDFCommon.generateCell ( @"NPI #"
                                           , 1
                                           , 2
                                           , Rectangle.ALIGN_LEFT
                                           , Rectangle.ALIGN_MIDDLE
                                           , PDFCommon.CELL_BORDERS_NONE
                                           , 3
                                           , ref cellTextFont
                                           , backGroundColor));
      }

      /* Name & NPI Fill Out */
     
      cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? name : @" ")
                                        , 1
                                        , (includeNPI ? 10 : 12)
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , ((isFromElectronicRequest && String.IsNullOrEmpty(name)) ? 8 : 2)
                                        , ref cellTextFont
                                        , Color.WHITE));

      if (includeNPI) {
      
        cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? npi : @" ")
                                          , 1
                                          , 2
                                          , Rectangle.ALIGN_LEFT
                                          , Rectangle.ALIGN_MIDDLE
                                          , PDFCommon.CELL_BORDERS_ALL
                                          , ((isFromElectronicRequest && String.IsNullOrEmpty(npi)) ? 8 : 2)
                                          , ref cellTextFont
                                          , Color.WHITE));
      }

      /* Email & Phone Label and Fill Out */
     
       cells.Add(PDFCommon.generateCell ( "Email"
                                         , 1
                                         , 1
                                         , Rectangle.ALIGN_LEFT
                                         , Rectangle.ALIGN_MIDDLE
                                         , PDFCommon.CELL_BORDERS_NONE
                                         , 3
                                         , ref cellTextFont
                                         , backGroundColor));

       cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? email : @" ")
                                        , 1
                                        , 3
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , 3
                                        , ref cellTextFont
                                        , Color.WHITE));

      
        cells.Add(PDFCommon.generateCell ( "Phone"
                                         , 1
                                         , 1
                                         , Rectangle.ALIGN_LEFT
                                         , Rectangle.ALIGN_MIDDLE
                                         , PDFCommon.CELL_BORDERS_NONE
                                         , 3
                                         , ref cellTextFont
                                         , backGroundColor));

      cells.Add(PDFCommon.generateCell ( (isFromElectronicRequest ? phone : @" ")
                                        , 1
                                        , 3
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_ALL
                                        , 3
                                        , ref cellTextFont
                                        , Color.WHITE));
      
      PdfPTable tbl  = PDFCommon.generateTable(12,cells);      
      tbl.TotalWidth  = 576f;  // calculated to fit inside main table
      tbl.LockedWidth = true;   
      float[] widths = new float[] { 48f, 48f, 48f, 48f, 48f, 48f, 48f, 48f, 48f, 48f, 48f, 48f};
      tbl.SetWidths(widths);
      tbl.SpacingBefore = 3;
      tbl.SpacingAfter  = 3;
      return tbl;            
   }

    /**************************************************************************
     * generateRequestResponseFileDocumentSectionRequestedService */
    /**
     *
     **************************************************************************/  

    protected static void generateRequestResponseFileDocumentSectionRequestedService (  ref iTextSharp.text.Document doc
                                                                                      , ref PdfWriter writer
                                                                                      , ref MemoryStream ms
                                                                                      , ref ServiceAuthorizationRequest sar  )

    {
      
      /* Grab copies of the fonts we are going to use */
      
      Font docTitleFont     = PDFCommon.generateCommonDocumentTitleFontNotItalic();
      Font docDiscFont      = PDFCommon.generateCommonDocumentDisclaimerFont();
      Font cellLabelFont    = PDFCommon.generateCommonDocumentCellLabelFont();
      Font cellTextFont     = PDFCommon.generateCommonDocumentCellTextFont();
      Font cellTextFontDesc = PDFCommon.generateCommonDocumentCellTextFontDescription();
      Font cellDocKeyFont   = PDFCommon.generateCommonDocumentCellUniqueKeyFont();

      List<PdfPCell> headerCells = new List<PdfPCell>();
      List<PdfPCell> bodyCells   = new List<PdfPCell>();

      // create a dictionary of the answers if form builder data is being used
      Dictionary<String, String> formAnswersDict = new Dictionary<string, string>();

      if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) && !String.IsNullOrEmpty(sar.formBuilderAnswersJSON))
            formAnswersDict = PDFFormGeneration.savedAnswersJsonToDict(sar.formBuilderAnswersJSON);

      /* Logo and return key as barcode */
      
      bodyCells.Add(PDFCommon.generateCell (   MBA.EmbeddedResources.CommonImages.IMAGE_NAME_LOGO_SPEDCARE
                                        , 1
                                        , 2
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE ));


      bodyCells.Add(PDFCommon.generateCell (  sar.productKey
                                              , PDFCommon.BARCODE_TYPE_128
                                              , 1
                                              , 10
                                              , Rectangle.ALIGN_RIGHT
                                              , Rectangle.ALIGN_MIDDLE
                                              , Color.WHITE
                                              , Rectangle.NO_BORDER));

      
      /* Return key as text */

      bodyCells.Add(PDFCommon.generateCell (   sar.productKey
                                               , 1
                                               , 12
                                               , Rectangle.ALIGN_RIGHT
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 1
                                               , ref cellDocKeyFont
                                               ));
                                              


      /* Client name + Form label */

      bodyCells.Add(PDFCommon.generateCell (  sar.clientName + " - " + SEL_LABEL_REQUEST
                                               , 1
                                               , 12
                                               , Rectangle.ALIGN_CENTER
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 1
                                               , ref docTitleFont ));
     
             
      
      /* Instructions */

      if (sar.reqSvcAuthMethodSelectionID == (int) RequestServiceAuthorizationMethod.ELECTRONIC)
      {
        bodyCells.Add(PDFCommon.generateCell ( "This is a record of an electronic request and response."
                                              , 1
                                              , 12
                                              , Rectangle.ALIGN_CENTER
                                              , Rectangle.ALIGN_MIDDLE
                                              , PDFCommon.CELL_BORDERS_NONE
                                              , 3
                                              , ref docDiscFont));

      }
      else
      { 
        bodyCells.Add(PDFCommon.generateCell ( "Medical services provided in the school setting must be appropriately authorized."
                                              + "\n"
                                              + "Please review this service request, sign, and return as quickly as possible."
                                              , 1
                                              , 12
                                              , Rectangle.ALIGN_CENTER
                                              , Rectangle.ALIGN_MIDDLE
                                              , PDFCommon.CELL_BORDERS_NONE
                                              , 3
                                              , ref docDiscFont));
     }

     /* Requested for name, Request date, and Request ID */      
                      
      bodyCells.Add(PDFCommon.generateCell ( "Authorization Requested For"
                                               , 1
                                               , 8
                                               , Rectangle.ALIGN_LEFT
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 3
                                               , ref cellLabelFont));
      
      bodyCells.Add(PDFCommon.generateCell ( "Requested On"
                                              , 1
                                              , 2
                                              , Rectangle.ALIGN_CENTER
                                              , Rectangle.ALIGN_MIDDLE
                                              , PDFCommon.CELL_BORDERS_NONE
                                              , 3
                                              , ref cellLabelFont));
      
      bodyCells.Add(PDFCommon.generateCell (  "Request ID"
                                               , 1
                                               , 2
                                               , Rectangle.ALIGN_RIGHT
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 3
                                               , ref cellLabelFont));
      
      
      bodyCells.Add(PDFCommon.generateCell ( sar.name
                                               , 1
                                               , 8
                                               , Rectangle.ALIGN_LEFT
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_ALL
                                               , 3
                                               , ref cellTextFont));
      
      bodyCells.Add(PDFCommon.generateCell ( sar.requestDateStr
                                              , 1
                                              , 2
                                              , Rectangle.ALIGN_CENTER
                                              , Rectangle.ALIGN_MIDDLE
                                              , PDFCommon.CELL_BORDERS_ALL
                                              , 3
                                              , ref cellTextFont));
      
      bodyCells.Add(PDFCommon.generateCell (  sar.id.ToString()
                                               , 1
                                               , 2
                                               , Rectangle.ALIGN_RIGHT
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_ALL
                                               , 3
                                               , ref cellTextFont));

     /* Blank Space */
       
     //bodyCells.Add(PDFCommon.generateCell (   "\n"
     //                                          , 1
     //                                          , 12
     //                                          , Rectangle.ALIGN_CENTER
     //                                          , Rectangle.ALIGN_MIDDLE
     //                                          , PDFCommon.CELL_BORDERS_NONE
     //                                          , 5
     //                                          , ref cellTextFont));
                                          
     /* Body */      
       

     /* Svc Description */
            
     bodyCells.Add(PDFCommon.generateCell (@"Description of Request"
                                            , 1
                                            , 12
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_NONE
                                            , 3
                                            , ref cellLabelFont));
     
     // if form data exists, use it instead of service description
     if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) /*&& !String.IsNullOrEmpty(sar.formBuilderAnswersJSON)*/) {                  
        PDFFormGeneration.insertFormFieldsToPDFCells(
                                 ref writer
                               , ref doc
                               , ref bodyCells
                               , sar.formBuilderQuestionsJSON
                               , formAnswersDict
                               , PDFFormGeneration.Constants.numColsBase12);
     } 

     // otherwise use service description
     else {
        bodyCells.Add(PDFCommon.generateCell (sar.svcDescription
                                    , 1
                                    , 12
                                    , Rectangle.ALIGN_LEFT
                                    , Rectangle.ALIGN_MIDDLE
                                    , PDFCommon.CELL_BORDERS_ALL
                                    , 3
                                    , ref cellTextFontDesc));
     }
      
     /* District Contact */
      
     bodyCells.Add(PDFCommon.generateCell (@"Requested By" 
                                           , 1
                                           , 6
                                           , Rectangle.ALIGN_LEFT
                                           , Rectangle.ALIGN_MIDDLE
                                           , PDFCommon.CELL_BORDERS_NONE
                                           , 3
                                           , ref cellLabelFont));
     
     bodyCells.Add(PDFCommon.generateCell (@"Email"
                                           , 1
                                           , 4
                                           , Rectangle.ALIGN_LEFT
                                           , Rectangle.ALIGN_MIDDLE
                                           , PDFCommon.CELL_BORDERS_NONE
                                           , 3
                                           , ref cellLabelFont));
     
     bodyCells.Add(PDFCommon.generateCell (@"Phone"
                                           , 1
                                           , 2
                                           , Rectangle.ALIGN_LEFT
                                           , Rectangle.ALIGN_MIDDLE
                                           , PDFCommon.CELL_BORDERS_NONE
                                           , 3
                                           , ref cellLabelFont));

     bodyCells.Add(PDFCommon.generateCell (  sar.districtContactName + "\n" + sar.pracTitle
                                            , 1
                                            , 6
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_ALL
                                            , 3
                                            , ref cellTextFont));
     
     bodyCells.Add(PDFCommon.generateCell (sar.districtContactEmail
                                           , 1
                                           , 4
                                           , Rectangle.ALIGN_LEFT
                                           , Rectangle.ALIGN_MIDDLE
                                           , PDFCommon.CELL_BORDERS_ALL
                                           , 3
                                           , ref cellTextFont));
     
     bodyCells.Add(PDFCommon.generateCell (  sar.districtContactPhone
                                            , 1
                                            , 2
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_ALL
                                            , 3
                                            , ref cellTextFont));
           
       
     /* Previous authorization section */

     if (sar.showPrevResponseInChain)
     { 
       var prevAuthSecTbl = generateAuthorizationSection (   sar.prevChainResponseSectionTitle
                                                           , sar.prevChainReqSvcAuthMethodSelectionID
                                                           , sar.prevChainResponseCode
                                                           , sar.prevChainResponseNotes
                                                           , sar.prevChainResponseRecordedOnStr                                                        
                                                           , sar.prevChainResponseAttestStatement
                                                           , sar.prevChainRespondantSignature
                                                           , sar.prevChainResponseEffectiveDateStr
                                                           , sar.prevChainRespondantName
                                                           , sar.prevChainRespondantNPI
                                                           , sar.prevChainRespondantEmail
                                                           , sar.prevChainRespondantPhone
                                                           , sar.prevChainShowRespondantNPI
                                                           , PDFCommon.COLOR_F5_F5_DC                                                      
                                                           , ref docDiscFont
                                                           , ref cellLabelFont
                                                           , ref cellTextFont );     
      
        bodyCells.Add(PDFCommon.generateCell (  "\n"
                                               , 1
                                               , 12
                                               , Rectangle.ALIGN_CENTER
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 1
                                               , ref cellTextFont));


        bodyCells.Add(PDFCommon.generateCell( ref prevAuthSecTbl
                                            , 1
                                            , 12
                                            , Rectangle.ALIGN_CENTER
                                            , Rectangle.ALIGN_TOP
                                            , PDFCommon.COLOR_F5_F5_DC
                                            , PDFCommon.CELL_BORDERS_ALL
                                            , 3));

     }

    /* Current authorization section */

    var curAuthSecTbl = generateAuthorizationSection (     sar.currChainResponseSectionTitle
                                                         , sar.currChainReqSvcAuthMethodSelectionID
                                                         , sar.currChainResponseCode
                                                         , sar.currChainResponseNotes
                                                         , sar.currChainResponseRecordedOnStr                                                        
                                                         , sar.currChainResponseAttestStatement
                                                         , sar.currChainRespondantSignature
                                                         , sar.currChainResponseEffectiveDateStr
                                                         , sar.currChainRespondantName
                                                         , sar.currChainRespondantNPI
                                                         , sar.currChainRespondantEmail
                                                         , sar.currChainRespondantPhone
                                                         , sar.currChainShowRespondantNPI
                                                         , PDFCommon.COLOR_F5_F5_DC                                                      
                                                         , ref docDiscFont
                                                         , ref cellLabelFont
                                                         , ref cellTextFont );  
      
        bodyCells.Add(PDFCommon.generateCell (  "\n"
                                               , 1
                                               , 12
                                               , Rectangle.ALIGN_CENTER
                                               , Rectangle.ALIGN_MIDDLE
                                               , PDFCommon.CELL_BORDERS_NONE
                                               , 1
                                               , ref cellTextFont));


        bodyCells.Add(PDFCommon.generateCell( ref curAuthSecTbl
                                            , 1
                                            , 12
                                            , Rectangle.ALIGN_CENTER
                                            , Rectangle.ALIGN_TOP
                                            , PDFCommon.COLOR_F5_F5_DC
                                            , PDFCommon.CELL_BORDERS_ALL
                                            , 3));

     


    /* Generate table that holds document itself */

      PdfPTable tbl  = PDFCommon.generateTable(  12
                                               , 0
                                               , headerCells
                                               , bodyCells);
      
      tbl.TotalWidth  = 600f;  // 8.5 in (1 in = 72 pts) and subtracting 12 for margins
      tbl.LockedWidth = true;   
      float[] widths = new float[] { 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f, 50f};

      tbl.SetWidths(widths); 
      doc.Add(tbl);

        // insert answers to PDF if required
        if (!String.IsNullOrEmpty(sar.formBuilderQuestionsJSON) /*&& !String.IsNullOrEmpty(sar.formBuilderAnswersJSON)*/)
        {    
            PDFFormGeneration.generateAcroFieldAppearances(ref ms, ref doc);
        }

    } 

     /**************************************************************************
      * generatePaperRequestResponseFile */
     /**
      *
      **************************************************************************/  

     public static ReturnFileBytes generateRequestResponseFile (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        requestID )
     {                        
                              
       RenderPdfCallBack cb = new RenderPdfCallBack ( delegate (   ref iTextSharp.text.Document     doc
                                                                  , ref MemoryStream                 ms
                                                                  , ref PdfWriter                    writer
                                                                  , ref String                       title
                                                                  , ref String                       author
                                                                  , ref String                       batch
                                                                  , ref String                       filename
                                                              )
      {
          
        ServiceAuthorizationRequest sar = ServiceAuthorizationRequests.load(connSpedmon,log,uInfo,requestID);
  
        /* Build document */
             
        generateRequestResponseFileDocumentSectionRequestedService (ref doc, ref writer, ref ms, ref sar);
                                                                                      
        /* PDF Meta data */
        
        title    = sar.name;
        author   = sar.clientName;
        batch    = "";
        
        /* PDF file name */
        
        string fn = String.Format (@"{0}-{1}-{2}-{3}-{4}-{5}-{6}"
                                   , sar.clientName
                                   , SEL_LABEL_REQUEST
                                   , sar.name
                                   , sar.created.Year
                                   , sar.created.Month
                                   , sar.created.Day
                                   , sar.id);
                                      
        filename = fn;             
                    
      });
      
      PageEventHelperPageNumberAndCreateDate peh = new PageEventHelperPageNumberAndCreateDate();
      
      string _title    = "";
      string _author   = "";
      string _batch    = "";
      string _filename = "";

      return PDFCommon.generateDocument (   _title
                                          , _author
                                          , _batch
                                          , _filename
                                          , PDFCommon.ORIENTATION_PORTRAIT
                                          , 1f
                                          , 1f
                                          , 1f
                                          , 10f
                                          , peh
                                          , cb);
      
    }

    public static string generateRequestResponseFileURL (string requestID = @"" )
    {
      return MBA.HttpApplication.createLink (   URL_REQUEST_RESPONSE_FILE_BASE
                                              , true
                                              , new NameValue(Constants.PARM_REC_ID,requestID));
    
    }
  
  }
}
