using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{

  /**************************************************************************
   * SelectStoredFile */
  /**
   * 
   *************************************************************************/
  public class DataEntryRowSelectStoredFile:DataEntryRowSelectEntity
  {
    public DataEntryRowSelectStoredFile(): base()
	  {	     
      _selectTitle                        = "Name";
      _dataPrivate                        = true;
      _dataURL                            = StoredFiles.URL_WEB_SVC_VIEW_SEL;
      _hasDataSource                      = false;
      _hasAddNew                          = false;
      _hasManageFiles                     = false;
      _hasEditSelected                    = false;
      _hasViewNotes                       = false;
      _nounPlural                         = "Files";
      _nounSingular                       = "File";      
  }
    
  protected string  _ctrlIdClientID             = null;
  protected string  _ctrlIdPracID               = null;
  protected string  _ctrlIdPatID                = null;
  protected string  _ctrlIdReferencedEntityID   = null;
  protected string  _ctrlIdFileClass            = null;
  protected string  _ctrlIdFileNameSpace        = null;
  protected string  _ctrlIdFileSource           = null;
  
  public string   ctrlIdClientID           { get { return _ctrlIdClientID; }      set {_ctrlIdClientID = value;}}  
  public string   ctrlIdPracID             { get { return _ctrlIdPracID; }        set {_ctrlIdPracID = value;}}
  public string   ctrlIdPatID              { get { return _ctrlIdPatID; }         set {_ctrlIdPatID = value;}}
  public string   ctrlIdReferencedEntityID { get { return _ctrlIdReferencedEntityID; }  set { _ctrlIdReferencedEntityID = value;}}
  public string   ctrlIdFileClass          { get { return _ctrlIdFileClass; }     set {_ctrlIdFileClass = value;}}
  public string   ctrlIdFileNameSpace      { get { return _ctrlIdFileNameSpace; } set { _ctrlIdFileNameSpace = value;}}
  public string   ctrlIdFileSource         { get { return _ctrlIdFileSource; }    set {_ctrlIdFileSource = value;}}

  protected override void Render(HtmlTextWriter writer)
  {     	    
                           
      /* Use default control ids if nothing was provided */

      if (String.IsNullOrWhiteSpace(_entityControlID))          _entityControlID                = @"uploadid";
      if (String.IsNullOrWhiteSpace(_ctrlIdClientID))           _ctrlIdClientID                 = @"clientid";
      if (String.IsNullOrWhiteSpace(_ctrlIdPracID))             _ctrlIdPracID                   = @"pracid";
      if (String.IsNullOrWhiteSpace(_ctrlIdPatID))              _ctrlIdPatID                    = @"patid";
      if (String.IsNullOrWhiteSpace(_ctrlIdReferencedEntityID)) _ctrlIdReferencedEntityID       = @"referencedentityid";
      if (String.IsNullOrWhiteSpace(_ctrlIdFileClass))          _ctrlIdFileClass                = @"fileclass";
      if (String.IsNullOrWhiteSpace(_ctrlIdFileNameSpace))      _ctrlIdFileNameSpace            = @"filenamespace";
      if (String.IsNullOrWhiteSpace(_ctrlIdFileSource))         _ctrlIdFileSource               = @"filesource";

      /* Add data parm control ids (datasource is handled by base class) */

      this._dataParameterControlIDs.Add (_ctrlIdClientID);
      this._dataParameterControlIDs.Add (_ctrlIdPracID);
      this._dataParameterControlIDs.Add (_ctrlIdPatID);
      this._dataParameterControlIDs.Add (_ctrlIdReferencedEntityID);
      this._dataParameterControlIDs.Add (_ctrlIdFileClass);
      this._dataParameterControlIDs.Add (_ctrlIdFileNameSpace);
      this._dataParameterControlIDs.Add (_ctrlIdFileSource);

      base.Render(writer);
    }
  }
}
