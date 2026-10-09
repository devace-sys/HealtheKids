using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{

	/**************************************************************************
     * DataEntryBoxSelectReportFormat */
	/**
     * 
     **************************************************************************/
	public class DataEntryBoxSelectReportFormat : DataEntryBoxSelectBase
	{
		public DataEntryBoxSelectReportFormat() {                
        }

        protected bool _includeCSV  = true;
        protected bool _includePDF  = false;
        protected bool _includeHTML = false;
        protected bool _includePSV  = false;

        public bool includeCSV {
            get { return _includeCSV; } 
            set {_includeCSV = value;}
        }
        public bool includePDF {
            get { return _includePDF; } 
            set {_includePDF = value;}
        }
        public bool includeHTML {
            get { return _includeHTML; } 
            set {_includeHTML = value;}
        }
        public bool includePSV { 
            get { return _includePSV; } 
            set {_includePSV = value;}
        }

		protected override void Render(HtmlTextWriter writer)
        { 
          this._addSelectOneSelection = false;
         
          this.addSelection( new NameValue(@"Excel Report File", Constants.REPT_FORMAT_XLS,  @""));
          
          if (_includeCSV)  this.addSelection( new NameValue(@"CSV Export File",            Constants.REPT_FORMAT_CSV,  @""));
          if (_includeHTML) this.addSelection( new NameValue(@"HTML Report File",           Constants.REPT_FORMAT_HTML, @""));
          if (_includePDF)  this.addSelection( new NameValue(@"PDF Report File",            Constants.REPT_FORMAT_PDF,  @""));
          if (_includePSV)  this.addSelection( new NameValue(@"Pipe Delimited Export File", Constants.REPT_FORMAT_PSV,  @""));

          this.value     = Constants.REPT_FORMAT_XLS.ToString();
          this._valueStr = this.value;
          base.Render(writer);
        }			
    }
}
