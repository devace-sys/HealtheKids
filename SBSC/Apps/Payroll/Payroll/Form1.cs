using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Reflection;
using System.IO;

using System.Security;
using System.Security.AccessControl;
using System.Security.Principal;

using System.Configuration;
using System.Net.Configuration;

using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.POIFS.FileSystem;
using NPOI.HSSF.Record;
using NPOI.Util;
using NPOI.SS.Util;
using NPOI.HSSF.Model;
using NPOI.SS.UserModel;
using NPOI.HSSF.EventModel;
using NPOI.HSSF.Util;
using NPOI.SS.Formula;
using NPOI.HSSF.Record.AutoFilter;

using System.Net.Mail;
using System.Net.Mime;

using MBA;

/***********************************************************************
 * Help links:
 * 
 * https://npoi.svn.codeplex.com/svn/NPOI/HSSF/UserModel/HSSFWorkbook.cs
 * http://www.zachhunter.com/2010/05/npoi-excel-template/
 ***********************************************************************/

namespace Payroll
{
    public partial class Form1 : System.Windows.Forms.Form
  {
     
    public Form1()
    {
      InitializeComponent();
    }

    /***************************************************************************
  * ExitCode */
    /**
     * Various exit codes.  These codes can be combined with a bitwised OR.
     * 
     * For example:
     * 
     *   int retCode = (int) ExitCode.InvalidArgument | (int) ExitCode.Failure
     ***************************************************************************/

    [Flags]

    enum ExitCode : int
    {
        Success = 0,
        InvalidArgument = 1,
        OtherError = 2,
        Failure = 32
    }

    /***************************************************************************
     * retCode */
    /**
     * Return code for this application
     ***************************************************************************/

    protected static int retcode = (int)ExitCode.Success;

    /***************************************************************************
     * log */
    /**
     * Our logging object
     ***************************************************************************/

    protected static FileLogger log = null;

    /***************************************************************************
     * WriteLogEntry */
    /**
     * Writes an entry to the log 
     * 
     ***************************************************************************/

    static void WriteLogEntry(Logger.LogLevel level, string message)
    {
        if (log != null)
            log.writeLog(level, message);
        else
            Console.WriteLine(message);
    }

    static void WriteLogEntry(string message)
    {
        log.writeLog(Logger.LogLevel.Info, message);
    }


    /******************************************************************
     * Declare global variables 
     * connstr - connection string for ST33
     ******************************************************************/
    public static string connstr         = ConfigurationManager.ConnectionStrings["Payroll"].ConnectionString.ToString(); 
    public static SqlConnection sqlconn  = new SqlConnection(connstr);
    public static SqlCommand comm        = sqlconn.CreateCommand();

    public DateTime startdate;
    public DateTime enddate;
    public int emp;
    public String sql;
    public string type;
    public SqlParameter parm1 = new SqlParameter();
    public SqlParameter parm2 = new SqlParameter();
    public SqlParameter parm3 = new SqlParameter();
    public SqlParameter parm4 = new SqlParameter();
    public int rowCount;
    public string index;
    public string fname;
    static HSSFWorkbook hssfworkbook;
    static HSSFWorkbook templateWorkbook;
    public int j = 1;
    public int i;
    public bool commmandLineMode  = false;
    public string[] commandLineArguments;
    public bool payroll           = false;
    public bool IsThreeMonthRange = false;
    public DateTime payDate;
    public DateTime toDay;
    
    protected void emailExcelFile(string file, string to)
    {
      /******************************************************************
       * Sends email to Input staff with the excel file attached 
       ******************************************************************/        
        try
        {
            WriteLogEntry(@"Sending " + fname);
            SmtpSection smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
            SmtpClient sc           = new SmtpClient(smtpSection.Network.Host.ToString());
            sc.Timeout              = 10000;
            MailMessage mm          = new MailMessage(smtpSection.From.ToString(), to);
            mm.Subject              = "Claim Lines Per Hour Report";
            mm.Body                 = "Attached please find the Claim Lines Per Hour Report for the last work week and for last 3 months."+
                                      "If you have any questions, please email Vic.";
            ContentType ct          = new ContentType(@"application/vnd.ms-excel");
            Attachment ma           = new Attachment(file, ct);
            mm.Attachments.Add(ma);
            sc.Send(mm);
        }
        catch (Exception ex)
        {
            LognSendErrorMsg(ex.Message);            
        }
    }

    private void LognSendErrorMsg(string error)
    {
        WriteLogEntry(Logger.LogLevel.Alert, error);
        WriteLogEntry(Logger.LogLevel.Crit, @"Exiting with errors, report not sent!");

        retcode = (int)ExitCode.OtherError | (int)ExitCode.Failure;
        status(false);
        sqlconn.Close();
        SmtpSection smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
        SmtpClient sc  = new SmtpClient(smtpSection.Network.Host.ToString());
        sc.Timeout     = 10000;
        MailMessage mm = new MailMessage(smtpSection.From.ToString(), ConfigurationManager.AppSettings["appErrorTo"].ToString());
        mm.CC.Add(ConfigurationManager.AppSettings["appErrorCc"].ToString());
        mm.Subject = "Error sending Claim Lines Per Hour Report";
        mm.Body = "Claim lines per hour report not sent! please see log for details.";
        sc.Send(mm);
        Environment.Exit(retcode);
    }

    private void Form1_Load(object sender, EventArgs e)
    {

        string sql = "select Emp_ID as emp,FirstName+' '+ LastName as name from dbo.Employees where Emp_ID != 1 and Office != 0 order by FirstName";

      /******************************************************************
       * Checks users access level and provides permissions.
       ******************************************************************/
        if (UserFileAccess() == false)
        {
            
            claimLinesbutton.Visible                  = false;
            accountabilitybutton.Visible              = false;
            payrollbutton.Visible                     = false;
            changeJobTitleToolStripMenuItem.Visible   = false;
            changeRateToolStripMenuItem.Visible       = false;
            changeRemoteFlagToolStripMenuItem.Visible = false;
            sql = "select Emp_ID as emp,FirstName+' '+ LastName as name from dbo.Employees where Login like '%" + Environment.UserName + "%'";

        }
        toDay = DateTime.Now;
        status(false);
        ShowRates(false);
        changeTitle(false);
        radioButton1.Visible = false;
        radioButton2.Visible = false;
        hidebutton.Visible   = false;
        parm1.ParameterName  = "@startDate";
        parm1.Direction      = ParameterDirection.Input;
        parm1.DbType         = DbType.Date;
        parm2.ParameterName  = "@endDate";
        parm2.Direction      = ParameterDirection.Input;
        parm2.DbType         = DbType.Date;
        parm3.ParameterName  = "@emp";
        parm3.Direction      = ParameterDirection.Input;
        parm4.ParameterName  = "@paid";
        parm4.Direction      = ParameterDirection.Input;
        
        commandLineArguments = Environment.GetCommandLineArgs();
        /*-------------------------------
        * Test to see if a config file
        * exists and if it does not
        * throw an exception
        *------------------------------*/
        string appname    = WindowsApplication.GetExeName();
        string configname = WindowsApplication.GetAppConfigName();
        WindowsApplication.AppConfigExists(configname);

        /*-------------------------------
         * Fetch base path for log file
         * from config file
         *------------------------------*/

        string logpath = ConfigurationManager.AppSettings["logFilePath"].ToString();

        /*-------------------------------
         * Create log file
         *------------------------------*/

        string logname = appname;
        

        // TODO: Refactor to use details log exclusively

        DetailsLog dlog = new DetailsLog();
       
      

        /******************************************************************
         * If command line arguments exist then process required method and
         * exit the app.
         ******************************************************************/     
        if (commandLineArguments.Length > 1)
         {
          /*-------------------------------
           * Starting
           *------------------------------*/
            log = new FileLogger(logpath, logname);
            WriteLogEntry(@"Starting");
            commmandLineMode = true;
            RunFromCommandline();
            emailExcelFile(@"\\sbscfs\Acct\Payroll\00 TTFN Time Summary\claims per hour\" + fname, ConfigurationManager.AppSettings["appEmailTo"].ToString());//ClaimsPerHour@help4schools.com
            Application.Exit();
            Environment.Exit(1);
         }     

       /******************************************************************
        * Fill employee combo box
        ******************************************************************/        
        try
         {
            sqlconn.Open();
            DataSet ds        = new DataSet();

            SqlDataAdapter da = new SqlDataAdapter(sql, sqlconn);
            da.TableMappings.Add("Table", "Employee");
            da.Fill(ds);

            // Insert a blank row here for an option to select all employees(only for authorised users who have access to Q:drive).

            if (UserFileAccess())
            {
                DataRow TopRow = ds.Tables["Employee"].NewRow();
                TopRow["name"] = "";
                TopRow["emp"]  = DBNull.Value;
                ds.Tables["Employee"].Rows.InsertAt(TopRow, 0);
            }
            empcomboBox.DataSource    = ds.Tables["Employee"];
            empcomboBox.DisplayMember = "name";
            empcomboBox.ValueMember   = "emp";
            sqlconn.Close();
         }
        catch (Exception ex)
         {
            MessageBox.Show(ex.ToString());            
            status(false);
         }
        finally
         {
            sqlconn.Close();
         }
    }


    private bool UserFileAccess()
     {
         DirectoryInfo di = new DirectoryInfo(@"\\sbscfs\Acct\Payroll");  

        try {
            // Determines whether the user has access to the given directory.
            di.GetAccessControl();                           
            return true;            
            }
        catch 
        {
            return false;
        }
     }

    private void status(bool a)
    {
     /******************************************************************
      * Display Label to show the user that some action is going on behind
      ******************************************************************/

      statuslabel.Visible = a;
      Application.DoEvents();
    }    

    private void payrollbutton_Click(object sender, EventArgs e)
    {
        /******************************************************************
         * Creates an excel with payroll infromation from a template
         * This workbook has 9 sheets, Payroll Instructions,
         * QuickBooks, MBA, SBSC, By Date, By Task and Email Templates.         
         ******************************************************************/
        status(true);
        ShowRates(false);
        InitializeWorkbook();
        payroll = true;     

        try
        {
            GetFileName(" Payday - Hours for ");

            type = "FN";
           
            FileStream fs = new System.IO.FileStream( WindowsApplication.GetExePath() + @"\PayrollTemplate.xls",
                                                   System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
            HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("Payroll Instructions");

            // Load the template into a NPOI workbook  
            templateWorkbook = new HSSFWorkbook(fs, true);

            // Load the sheet1 from template  
            sheet1 = (HSSFSheet)templateWorkbook.GetSheet("Payroll Instructions");

            HSSFSheet sheet4 = (HSSFSheet)hssfworkbook.CreateSheet("QuickBooks");
            sheet4 = (HSSFSheet)templateWorkbook.GetSheet("QuickBooks");
            MBAQuickBooksEntry(sheet4);

            sql = "select  Last_Name,first_name,Employee_ID,Emp_Type,Job_Title,Hours_Reported,UnPaid_TimeOff,Paid_break,Make_Up_Time," +
                  "(Regular_Hours+PayOver_Time+PayDouble_Time),Missing_Time,PayRegular_Hours,PaySick_Hours,PayVacation,PayHoliday_Hours,PayOver_Time,PayDouble_Time," +
                  "Total_Hours_To_Pay,Notes_For_Doug,Needs_Attention from EMPLOYEE_PAYROLL(@startDate,@endDate) where company = 'MBA' and Emp_Type != 'Independent'";
            HSSFSheet sheet5 = (HSSFSheet)hssfworkbook.CreateSheet("MBA");
            sheet5 = (HSSFSheet)templateWorkbook.GetSheet("MBA");
            FillData(sql, sheet5, null,templateWorkbook);
            payrollFormat(sheet5);

            sql = "select  Last_Name,first_name,Employee_ID,Emp_Type,Job_Title,Hours_Reported,UnPaid_TimeOff,Paid_break,Make_Up_Time," +
                  "(Regular_Hours+PayOver_Time+PayDouble_Time),Missing_Time,PayRegular_Hours,PaySick_Hours,PayVacation," +
                  "PayHoliday_Hours,PayOver_Time,PayDouble_Time,Total_Hours_To_Pay,Notes_For_Doug,Needs_Attention from " +
                  "EMPLOYEE_PAYROLL(@startDate,@endDate) where company = 'SBSC' and Emp_Type != 'Independent'";
            HSSFSheet sheet6 = (HSSFSheet)hssfworkbook.CreateSheet("SBSC");
            sheet6 = (HSSFSheet)templateWorkbook.GetSheet("SBSC");
            FillData(sql, sheet6, null,templateWorkbook);
            payrollFormat(sheet6);

            HSSFSheet sheet7 = (HSSFSheet)hssfworkbook.CreateSheet("By Date");
            sheet7 = (HSSFSheet)templateWorkbook.GetSheet("By Date");
            HSSFSheet sheet8 = (HSSFSheet)hssfworkbook.CreateSheet("By Task");
            sheet8 = (HSSFSheet)templateWorkbook.GetSheet("By Task");
            EmpDetails(sheet7, sheet8);

            //AddAutoFilter(hssfworkbook, "'SBSC'!$A$1:$R$200");            

            HSSFSheet sheet9 = (HSSFSheet)hssfworkbook.CreateSheet("Email Templates");
            sheet9 = (HSSFSheet)templateWorkbook.GetSheet("Email Templates");

            WriteToFile(fname, true);
            fs.Close();
            status(false);
            payroll = false;
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString());
            status(false);
        }
    }

    private void payrollFormat(HSSFSheet sheet)
    {
        /******************************************************************
         * Special formating for payroll excel
         ******************************************************************/

        //Applying conditional formatting with two rules
        HSSFSheetConditionalFormatting hscf = sheet.SheetConditionalFormatting;
        HSSFConditionalFormattingRule rule1 = hscf.CreateConditionalFormattingRule(ComparisonOperator.LT, "80", null);
        HSSFConditionalFormattingRule rule2 = hscf.CreateConditionalFormattingRule(ComparisonOperator.GT, "80", null);
        HSSFConditionalFormattingRule rule3 = hscf.CreateConditionalFormattingRule(ComparisonOperator.GT, "0", null);
        CellRangeAddress[] regions = { new CellRangeAddress(1, j - 1, 17, 17) };
        HSSFPatternFormatting patternFmt1 = rule1.CreatePatternFormatting();
        patternFmt1.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
        HSSFPatternFormatting patternFmt2 = rule2.CreatePatternFormatting();
        patternFmt2.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.ROSE.index;
        hscf.AddConditionalFormatting(regions, rule1, rule2);

        //Applying conditional formatting with one rule
        int[] range = new int[4] { 1, j, 11, 16 };
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ROSE.index, sheet);
        range[2] = 8; range[3] = 8;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet);
        range[2] = 10; range[3] = 10;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet);
        range[2] = 12; range[3] = 12;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet);
        range[2] = 19; range[3] = 19;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.RED.index, sheet);
        //Group columns 1 through 2 and 6 through 10          
        sheet.GroupColumn(2, 10);
        //Adjust column widths
        sheet.SetColumnWidth(4, 3000);
        sheet.SetColumnWidth(15, 7000);
        sheet.SetColumnWidth(16, 5000);
        sheet.SetColumnWidth(18, 10000);
        sheet.CreateFreezePane(5, 1);
        // Calculate totals from columns F to R and starting from column number 5
        AddTotals(templateWorkbook,sheet, 'F', 'R', 5);
    }

    private void IndependentsFormat(HSSFSheet sheet)
    {
        /******************************************************************
         * Special formating for independent contractors
         * Applying conditional formatting with two rules for Total_hours_topay
         * column.
         ******************************************************************/

        HSSFSheetConditionalFormatting hscf = sheet.SheetConditionalFormatting;
        HSSFConditionalFormattingRule rule1 = hscf.CreateConditionalFormattingRule(ComparisonOperator.LT, "80", null);
        HSSFConditionalFormattingRule rule2 = hscf.CreateConditionalFormattingRule(ComparisonOperator.GT, "80", null);
        HSSFConditionalFormattingRule rule3 = hscf.CreateConditionalFormattingRule(ComparisonOperator.GT, "0", null);
        CellRangeAddress[] regions = { new CellRangeAddress(1, j - 1, 14, 14) };
        HSSFPatternFormatting patternFmt1 = rule1.CreatePatternFormatting();
        patternFmt1.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
        HSSFPatternFormatting patternFmt2 = rule2.CreatePatternFormatting();
        patternFmt2.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.ROSE.index;
        hscf.AddConditionalFormatting(regions, rule1, rule2);

        //Applying conditional formatting with one rule
        int[] range = new int[4] { 1, j, 6, 8 };
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.RED.index, sheet);
        range[2] = 11; range[3] = 13;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.RED.index, sheet);
        range[2] = 10; range[3] = 10;

        //Group columns 1 through 2 and 6 through 10
        sheet.GroupColumn(2, 13);
        //Adjust column widths
        sheet.SetColumnWidth(1, 3000);
        sheet.SetColumnWidth(4, 3000);
        sheet.SetColumnWidth(15, 10000);
        sheet.CreateFreezePane(4, 0);
        // Calculate totals from columns F to R and starting from column number 5
        AddTotals(templateWorkbook,sheet, 'F', 'O', 5);
    }

    public void AddAutoFilter(HSSFWorkbook wb, string formula)
    {
        wb.CreateAutoFilter(formula);
    }

    private void MBAQuickBooksEntry(HSSFSheet sheet)
    {
        /******************************************************************
         * Calculates amt owed to MBA and amt to pay Doug Osanna Sr.
         ******************************************************************/
        decimal TotalHoursMBA;
        decimal MBArate;
        try
        {
            sqlconn.Open();
            startdate  = startdateTimePicker.Value.Date;
            enddate    = enddateTimePicker.Value.Date;
            string sql = "select SUM(Total_Hours_To_Pay) from EMPLOYEE_PAYROLL(@startDate,@endDate) where Company like 'MBA%'";
            comm.CommandText = sql;
            comm.CommandType = CommandType.Text;
            comm.CommandTimeout = 10000;
            AddParms(true);
            GetParmValues();


            string r = Convert.ToString(comm.ExecuteScalar());
            if (r != "")
                TotalHoursMBA = Convert.ToDecimal(r);
            else
                TotalHoursMBA = 0;            

            sql = "select rate from organization_contract_rates where org_id = 1 and '"+ payDate.ToShortDateString() +"' between startdate and enddate";
            comm.CommandText = sql;
            r = Convert.ToString(comm.ExecuteScalar());
            if (r != "")
                MBArate = Convert.ToDecimal(comm.ExecuteScalar());
            else
                MBArate = 0;            

            if (mbatextBox.Text != string.Empty)
                MBArate = Convert.ToDecimal(mbatextBox.Text);

            sqlconn.Close();

            DataFormat format = templateWorkbook.CreateDataFormat();
            NPOI.SS.UserModel.CellStyle style1 = templateWorkbook.CreateCellStyle();
            FormatStyle(style1, templateWorkbook, NPOI.HSSF.Util.HSSFColor.BLACK.index, 14, true, false);
            
            style1.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.LIGHT_TURQUOISE.index2;
            style1.FillPattern = FillPatternType.SOLID_FOREGROUND;
            style1.DataFormat  = format.GetFormat("$#,##0.##");

            NPOI.SS.UserModel.CellStyle style2 = templateWorkbook.CreateCellStyle();
            FormatStyle(style2, templateWorkbook, NPOI.HSSF.Util.HSSFColor.BLACK.index, 12, false, false);

            NPOI.SS.UserModel.CellStyle style3 = templateWorkbook.CreateCellStyle();
            FormatStyle(style3, templateWorkbook, NPOI.HSSF.Util.HSSFColor.BLACK.index, 12, false, false);
            style3.DataFormat = format.GetFormat("$#,##0.##");           

            Row row = sheet.CreateRow(1);

            Cell cell = row.CreateCell(0);
            cell.SetCellValue("Total Hours by MBA");
            cell.CellStyle = style2;
            cell = row.CreateCell(1);
            cell.SetCellValue(Convert.ToDouble(TotalHoursMBA));
            cell.CellStyle = style2;

            row  = sheet.CreateRow(2);
            cell = row.CreateCell(0);
            cell.SetCellValue("Amount Owed to MBA");
            cell.CellStyle = style1;
            cell = row.CreateCell(1);
            cell.SetCellValue(Convert.ToDouble(TotalHoursMBA * MBArate));
            cell.CellStyle = style1;
            AddParms(false);

        }

        catch (Exception ex)
        { MessageBox.Show(ex.ToString()); }

        finally { sqlconn.Close(); }
    }

    private void ConditionalFormat(int[] r, string formula, short colorIndex, HSSFSheet sheet)
    {
        /******************************************************************
         * Adds a conditional formating to the range supplied in the array 'r'
         * with one rule,with the formula and colorIndex supplied
         ******************************************************************/
        HSSFSheetConditionalFormatting hscf = sheet.SheetConditionalFormatting;
        HSSFConditionalFormattingRule rule  = hscf.CreateConditionalFormattingRule(ComparisonOperator.GT, formula, null);
        HSSFPatternFormatting patternFmt    = rule.CreatePatternFormatting();
        patternFmt.FillBackgroundColor      = colorIndex;
        CellRangeAddress[] regions          = { new CellRangeAddress(r[0], r[1], r[2], r[3]) };
        hscf.AddConditionalFormatting(regions, rule);
    }

    private void GetFileName(string name)
    {
        /******************************************************************
         * Creates a name for the excel file with given date range values.
         ******************************************************************/
        startdate = startdateTimePicker.Value.Date;
        enddate   = enddateTimePicker.Value.Date;
        payDate   = enddate.AddDays(6);
        fname     = payDate.ToString("yyyyMMdd") + name + startdate.ToString("yyyyMMdd") +
                         "-" + enddate.ToString("MMdd") + ".xls";
    }

    static void WriteToFile(string name, bool template)
    {
        /******************************************************************
        * Opens a savefile dialog to save the excel in a desired location
        ******************************************************************/
         
         SaveFileDialog saveFileDialog1 = new SaveFileDialog();
         saveFileDialog1.Filter = "Microsoft Office Excel Workbook |*.xls";
         saveFileDialog1.DefaultExt = "xls";
         saveFileDialog1.Title = "Save a File";
         saveFileDialog1.InitialDirectory = @"\\sbscfs\Acct\Payroll\00 TTFN Time Summary\";
         saveFileDialog1.FileName = name;
         try
         {

             if (saveFileDialog1.ShowDialog() == DialogResult.OK)
             {
                 System.IO.FileStream fs = (System.IO.FileStream)saveFileDialog1.OpenFile();
                 if (template)
                     templateWorkbook.Write(fs);
                 else
                     hssfworkbook.Write(fs);
                 fs.Close();
             }
             else
                 saveFileDialog1.Dispose();
         }
         catch
         {
             if (CheckIfFileIsBeingUsed(name) == true)
                 MessageBox.Show("A file with the name " + name + " is already open.");
         }
    }

    private static bool CheckIfFileIsBeingUsed(string fileName)
    {
        /******************************************************************
         * Checks if the given file is being used.
         ******************************************************************/
        try
        {
           System.IO.File.Open(fileName, FileMode.Open, FileAccess.Read, FileShare.None);

        }
        catch
        {
            return true;
        }
        return false;
    }

    static void InitializeWorkbook()
    {
        hssfworkbook = new HSSFWorkbook();
        //create a entry of DocumentSummaryInformation
        DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
        dsi.Company = "NPOI Team";
        hssfworkbook.DocumentSummaryInformation = dsi;
        //create a entry of SummaryInformation
        SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
        si.Subject = "NPOI SDK Example";
        hssfworkbook.SummaryInformation = si;
    }

    private void AddTotals(HSSFWorkbook hssfworkbook,HSSFSheet sheet, char c1, char c2, int start)
    {

        /******************************************************************
         * Calculates the total for each column starting from column c1
         * to column c2 and populates them in the last row of the sheet.
         ******************************************************************/
        NPOI.SS.UserModel.CellStyle style1;
        NPOI.SS.UserModel.CellStyle style2;
       
        style1 = hssfworkbook.CreateCellStyle();
        style2 = hssfworkbook.CreateCellStyle();
        FormatStyle(style1, hssfworkbook, NPOI.HSSF.Util.HSSFColor.BLUE.index, 14, true, true);
        style1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;
        FormatStyle(style2, hssfworkbook, NPOI.HSSF.Util.HSSFColor.BLUE.index,12, false,false);
        
        char c;
        i = start;
        Row row = sheet.CreateRow(j + 1);
        Cell cell1 = row.CreateCell(i - 1);
        cell1.CellStyle = style1;
        cell1.SetCellValue("Total:");
        style1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.RIGHT;
        for (c = c1; c <= c2; c++)
        {
            Cell cell = row.CreateCell(i);
            cell.CellFormula = "SUM(" + c + "2:" + c + j.ToString() + ")";
            cell.CellStyle = style1;
            i++;
        }

    }

    private void EmpDetails(HSSFSheet sheet1, HSSFSheet sheet2)
    {
        type = "FN";
        sql = "select Last_Name,First_Name,Employee_ID,Emp_Type,Job_Title,convert(char,Date,101),Hours_Reported,UnPaid_TimeOff,Paid_break,Make_Up_Time," +
               "(Regular_Hours + daily_Over_Time + Double_Time + weekly_Over_Time)," +
               "Sick_Hours,Paid_Vaca,Holiday_Hours,Regular_Hours + Paid_break,daily_Over_Time,Double_Time,weekly_Over_Time from " +
               "[TTFN].[dbo].EMPLOYEE_DETAIL_BY_DATE(@emp,@startDate,@endDate)";

        FillData(sql, sheet1, null,templateWorkbook);
        //Apply conditional formatting
        int[] range = new int[4] { 1, j, 11, 17 };
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ROSE.index, sheet1);
        //Conditional format for make up time
        range[2] = 9; range[3] = 9;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet1);
        //Conditional format for upaid time off
        range[2] = 7; range[3] = 7;
        ConditionalFormat(range, "1", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet1);
        //Conditional format for Paid break
        range[2] = 8; range[3] = 8;
        ConditionalFormat(range, "0.50", NPOI.HSSF.Util.HSSFColor.RED.index, sheet1);
        sheet1.SetColumnWidth(3, 4000);
        sheet1.SetColumnWidth(4, 3000);
        sheet1.SetColumnWidth(5, 3000);

        AddTotals(templateWorkbook,sheet1, 'G', 'R', 6);
        sql = "select Last_Name,First_Name,Employee_ID,Emp_Type,Job_Title,convert(char,Date,101),Task,Hours_Reported,UnPaid_TimeOff,Paid_break," +
              "Make_Up_Time,Regular_Hours,Sick_Hours,Paid_Vaca,Holiday_Hours,Client,StartTime,EndTime,Notes from [TTFN].[dbo].EMPLOYEE_DETAIL_SUBTOTAL_new(@emp,@startDate,@endDate) order by ID,Employee_ID";

        FillData(sql, sheet2, null,templateWorkbook);
        range[0] = 1;
        range[1] = j - 2;
        //Conditional format for paid break
        range[2] = 9; range[3] = 9;
        ConditionalFormat(range, "0.35", NPOI.HSSF.Util.HSSFColor.RED.index, sheet2);
        //Conditional format for upaid time off
        range[2] = 8; range[3] = 8;
        ConditionalFormat(range, "1", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet2);
        //Conditional format for make up time
        range[2] = 10; range[3] = 10;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ORANGE.index, sheet2);
        range[2] = 12; range[3] = 14;
        ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ROSE.index, sheet2);
        //set column width's
        sheet2.SetColumnWidth(4, 3000);
        sheet2.SetColumnWidth(5, 3000);
        sheet2.SetColumnWidth(3, 4000);
        sheet2.SetColumnWidth(6, 7000);
        sheet2.SetColumnWidth(18, 40000);
        sheet2.SetColumnWidth(15, 7000);
    }

        private void FormatStyle(NPOI.SS.UserModel.CellStyle style1, HSSFWorkbook hssfworkbook, short colorIndex, short fontsize, bool isbold, bool wrapText)
     {
       /******************************************************************
        * Special formating for column headings.
        ******************************************************************/
          NPOI.SS.UserModel.Font font = hssfworkbook.CreateFont();
          font.Color = colorIndex;
          if (isbold)
           font.Boldweight.Equals(FontBoldWeight.BOLD);
          font.FontHeightInPoints = fontsize;
          font.FontName = "Times New Roman";
          style1.WrapText = wrapText;
          style1.SetFont(font);
          style1.DataFormat = HSSFDataFormat.GetBuiltinFormat("0.00");
      }

    private int onlyPaid;
    private void claimLinesbutton_Click(object sender, EventArgs e)
      {
          /******************************************************************
           * Creates a workbook from the template for Claims lines per hour 
           * info and  Marilyns report(with Input hours and claimlines 
           * perhour for Input hours).
           ******************************************************************/
          status(true);
          try
          {

              InitializeWorkbook();

              FileStream fs = new System.IO.FileStream(WindowsApplication.GetExePath() + @"\ClaimLinesChart_template.xls",
                                                       System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
              HSSFSheet sheet = (HSSFSheet)hssfworkbook.CreateSheet("Claim lines perHour");

              // Load the template into a NPOI workbook  

              templateWorkbook = new HSSFWorkbook(fs, true);

              // Load the sheet you are going to use as a template into NPOI  
              sheet = (HSSFSheet)templateWorkbook.GetSheet("Claim lines perHour");
              type = "SP";
              //Fill the sheet with the data
              onlyPaid = 0;
              FillData("ClaimLinesPerHour", sheet, null, templateWorkbook);
              GetChartName(sheet, 15, IsThreeMonthRange, "Input Hours");

              onlyPaid = 1;
              FillData("ClaimLinesPerHour", sheet, null, templateWorkbook);
              GetChartName(sheet, 32, IsThreeMonthRange, "Paid Hours");

              //Get the name for the excel file for the given dates 
              GetFileName(" ClaimLines ");
              fname = fname.Substring(9);

              WriteToFile(fname, true);
              fs.Close();
              status(false);
              sqlconn.Close();
          }
          catch (Exception ex)
          {
              MessageBox.Show(ex.ToString());
              status(false);
              sqlconn.Close();
          }
          finally { sqlconn.Close(); }
      }

    private void RunFromCommandline()
      {
          try
          {

              /******************************************************************
               * Get the command line arguments
               ******************************************************************/

              int? commandLineReportNumber = null;
              DateTime? commandLineStartDate = null;
              DateTime? commandLineEndDate = null;
              bool hasParameters = false;
              int commandLineArgNum = 0;
              if (commandLineArguments.Length > 2) hasParameters = true;
              foreach (string arg in commandLineArguments)
              {
                  commandLineArgNum++;
                  //Since the first element in the arguments array will be app name(payroll.exe)Contitnue the loop.
                  if (commandLineArgNum == 1) continue;
                  if (commandLineArgNum == 3) hasParameters = true;
                  string token = arg.Trim().ToLower();

                  if (token.Length > 4)
                  {
                      string option = token.Substring(0, 4);
                      string value = token.Substring(4);

                      try
                      {
                          if (option == "/rn:") commandLineReportNumber = Convert.ToInt32(value);
                          if (option == "/d1:") commandLineStartDate    = Convert.ToDateTime(value);
                          if (option == "/d2:") commandLineEndDate      = Convert.ToDateTime(value);
                      }
                      catch
                      {
                          WriteLogEntry(@"Creating the report failed. Arguments supplied are invalid.");
                          Application.Exit();
                          Environment.Exit(1);
                      }
                  }
              }
              /******************************************************************
               * If no arguments are passed for the dates set the date range to
               * the recent finished work week.
               ******************************************************************/
              DateTime now = toDay.AddDays(0 - Convert.ToInt16(toDay.DayOfWeek));
              if (hasParameters == false)
              {
                  commandLineStartDate = now.AddDays(-(int)now.DayOfWeek - 7); //DateTime.Now.AddDays(-6);
                  commandLineEndDate   = now.AddDays(-(int)now.DayOfWeek - 7).AddDays(6); //DateTime.Now;
              }

              startdate = Convert.ToDateTime(commandLineStartDate);
              enddate = Convert.ToDateTime(commandLineEndDate);
            
              InitializeWorkbook();
             
              FileStream fs = new System.IO.FileStream("ClaimLinesChart_EmailTemplate.xls",
                                                       System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);

              HSSFSheet sheet = (HSSFSheet)hssfworkbook.CreateSheet("Claim lines perHour");

              // Load the template into a NPOI workbook  
              templateWorkbook = new HSSFWorkbook(fs, true);

              // Load the sheet1 you are going to use as a template into NPOI  
              sheet = (HSSFSheet)templateWorkbook.GetSheet("Claim lines perHour");
             
              //Fill the sheet with the data for the previous week in chart-1
              CreateChart(sheet, templateWorkbook);
              GetChartName(sheet, 15, IsThreeMonthRange, "Input Hours");             
              GetChartName(sheet, 32, IsThreeMonthRange, "Paid Hours");

              fname = "ClaimLines " + startdate.ToString("yyyyMMdd") +
                       "-" + enddate.ToString("MMdd") + ".xls";

              //Fill the sheet with the data for the last 3 months in chart-2
              IsThreeMonthRange = true;             
              CreateChart(sheet, templateWorkbook);
              GetChartName(sheet, 15, IsThreeMonthRange, "Input Hours");             
              GetChartName(sheet, 32, IsThreeMonthRange, "Paid Hours");

              FileStream fs1 = new System.IO.FileStream(@"\\sbscfs\Acct\Payroll\00 TTFN Time Summary\claims per hour\" + fname,
                                                       System.IO.FileMode.Create);
              templateWorkbook.Write(fs1);
              fs.Close();
              fs1.Close();
              status(false);
              IsThreeMonthRange = false;
              sqlconn.Close();
          }
          catch (Exception ex)
          {
              LognSendErrorMsg(ex.Message);
          }
          finally 
          {
              if (commmandLineMode)
              {
                  if (log != null)
                      log.Dispose();
                  WindowsApplication.cleanup();
              }
          }
      }

    private void FillData(string sp, HSSFSheet sheet, string[] colHeadings, HSSFWorkbook hssfworkbook1)
    {

      /******************************************************************
       * Fills the sheet with data from sql and adds basic formating.
       * Converts the string values from column n1 to column n2
       * to numeric values. 
       ******************************************************************/
      try
      {
      /******************************************************************
       * Check if the program is run from command line, if not assign the 
       * Input parameters with the values selected in the combo boxes.
       ******************************************************************/
          AddParms(true);
          GetParmValues();
          j = 1;
          
          sqlconn.Open();
          sqlconn.ConnectionTimeout.Equals(5000);

          if (type == "FN")      comm.CommandType = CommandType.Text;
          else if (type == "SP") comm.CommandType = CommandType.StoredProcedure;          
         
          comm.CommandText = sp;
                    
          if (sp == "ClaimLinesPerHour")
          {
              comm.Parameters.Add(parm4);
              comm.Parameters["@paid"].Value = onlyPaid;
          }
          comm.CommandTimeout = 10000;
          SqlDataReader dr    = comm.ExecuteReader();          

          //Style to apply for column headings
          NPOI.SS.UserModel.CellStyle style1;
          NPOI.SS.UserModel.CellStyle style2;
          NPOI.SS.UserModel.CellStyle style3;
          
          style1 = hssfworkbook1.CreateCellStyle();
          style2 = hssfworkbook1.CreateCellStyle();
          style3 = hssfworkbook1.CreateCellStyle();
          FormatStyle(style1, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLUE.index, 14, true, true);
          style1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;
          
          FormatStyle(style2, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLACK.index, 12, false, false);
          FormatStyle(style3, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLACK.index,14, true,false);
          
          Row row;

          // set the coumn headings for the sheet
          if (colHeadings != null)
          {
              row = sheet.CreateRow(0);
              for (i = 0; i < colHeadings.Length; i++)
              {
                  Cell cell = row.CreateCell(i);
                  cell.SetCellValue(colHeadings[i]);
                  cell.CellStyle = style1;
                  cell.Row.Height = 1700;
                  sheet.AutoSizeColumn(i);
              }              
          }
         
          int SecondChart = 0;
          if ((sp == "ClaimLinesPerHour") && onlyPaid == 1)
           SecondChart = 17;
         
          i = 0;
          double d;

          /******************************************************************
           * Go through each row in the data reader and copy them to the sheet
           * Convert the string values from datareader into numeric values.
           * This is needed to apply conditional formating and formulas.
           ******************************************************************/          
          int numrows = sheet.LastRowNum;
          bool skipSummaryRows = false; 
          int k = 0;
          
          if (dr.HasRows)
          {
              while (dr.Read())             
              {
                  if (j + 1 >= numrows)
                      row = sheet.CreateRow(j);
                  else
                      row = sheet.GetRow(j);

                  for (i = 0; i < dr.VisibleFieldCount; i++)
                  {
                      //if commandlinemode is true do not add summary rows(totals and company averages)
                      if ((dr.GetValue(i).ToString() == "1000") && (commmandLineMode == true))
                      {
                          skipSummaryRows = true;
                          break;
                      }

                      try { sheet.GetRow(j).GetCell(i + SecondChart).SetCellValue(dr.GetValue(i).ToString()); }
                      catch
                      {
                          Cell cell = row.CreateCell(i + SecondChart);
                          cell.SetCellValue(dr.GetValue(i).ToString());
                      }
                      // Convert number values to double

                      if (double.TryParse(dr.GetValue(i).ToString(), out d))
                      {
                          sheet.GetRow(j).GetCell(i + SecondChart).SetCellValue(d);
                      }

                      sheet.GetRow(j).GetCell(i + SecondChart).CellStyle = style2;                      
                      
                      if ((dr.GetValue(i).ToString() == "TOTAL")          || (dr.GetValue(i).ToString() == "Average") ||
                          (dr.GetValue(i).ToString() == "SBSC Avg:")      || (dr.GetValue(i).ToString() == "MBA Avg:")||
                          (dr.GetValue(i).ToString() == "SBSC-WSac Avg:") || (dr.GetValue(i).ToString() == "Total:")  || 
                          (dr.GetValue(i).ToString() == "SBSC-Remote Avg:"))
                        k = i;                                               
                  }
                  //highlight the summary rows
                  if  (k!=0)
                  {
                      if (dr.GetValue(k).ToString() == "Total:")
                          for (i = k; i < dr.VisibleFieldCount; i++)
                          {
                              sheet.GetRow(j).GetCell(i + SecondChart).CellStyle = style3;
                          }
                      else
                          for (i = k; i < dr.VisibleFieldCount; i++)
                          {
                              sheet.GetRow(j).GetCell(i + SecondChart).CellStyle = style1;
                          }
                      k = 0;
                  }

                  if (skipSummaryRows == true) break;
                  j = j + 1;
              }
              
              sheet.ForceFormulaRecalculation = true;
          }
          
          dr.Dispose();
          sheet.DisplayZeros = false;
          sheet.HorizontallyCenter = true;
          sqlconn.Close();
          AddParms(false);
          if (sp == "ClaimLinesPerHour") comm.Parameters.Remove(parm4);
          
      }
      catch (Exception ex)
      {
          MessageBox.Show(ex.ToString());
      }
      finally
      {
          sqlconn.Close();         
      }
  }

    private void GetChartName(HSSFSheet sheet,int col,bool IsThreeMonthRange,string type)
      {
          /******************************************************************
           * Creates the name for the chart with the given dates, displays 
           * both years if the dates span two years.
           ******************************************************************/
          //Row row;
          if (IsThreeMonthRange == false)
          {
              //row = sheet.GetRow(2);
              //Cell cell = row.CreateCell(col);

              if (startdate.ToString("yyyy") == enddate.ToString("yyyy"))
                  sheet.GetRow(2).GetCell(col).SetCellValue("CLAIMS PER HOUR - " + type + "\n" + startdate.ToString("MMMM") + " " + startdate.ToString("dd") + " - " +
                                                                                              enddate.ToString("MMMM") + " " + enddate.ToString("dd") + ", " + startdate.ToString("yyyy"));
              else
                  sheet.GetRow(2).GetCell(col).SetCellValue("CLAIMS PER HOUR - " + type + "\n" + startdate.ToString("MMMM") + " " + startdate.ToString("dd") + ", " + startdate.ToString("yyyy") + " - " +
                                                             enddate.ToString("MMMM") + " " + enddate.ToString("dd") + ", " + enddate.ToString("yyyy"));
          }
          else
          {
              //row = sheet.GetRow(45);
              //Cell cell = row.CreateCell(col);
              if (startdate.ToString("yyyy") == enddate.ToString("yyyy"))

                  sheet.GetRow(45).GetCell(col).SetCellValue("CLAIMS PER HOUR - " + type + "\n" + startdate.ToString("MMMM") + " " + startdate.ToString("dd") + " - " +
                                                                                            enddate.ToString("MMMM") + " " + enddate.ToString("dd") + ", " + startdate.ToString("yyyy"));
              else
                  sheet.GetRow(45).GetCell(col).SetCellValue("CLAIMS PER HOUR - " + type + "\n" + startdate.ToString("MMMM") + " " + startdate.ToString("dd") + ", " + startdate.ToString("yyyy") + " - " +
                                                                  enddate.ToString("MMMM") + " " + enddate.ToString("dd") + ", " + enddate.ToString("yyyy"));
          }
      }

    private void accountabilitybutton_Click(object sender, EventArgs e)
    {
        /******************************************************************
         * Creates a sheet with a list of users who logged in to TS5 between
         * the given dates,the time of login and time of logout and difference
         * between these times and number of service records entered between 
         * login and logout time.
         ******************************************************************/
        status(true);
      try
      {
          InitializeWorkbook();

          string[] colHeadings = {" Employee ID "," First Name "," Last Name ",                               
                                " LOGIN TIME ",
                                " LOGOUT TIME ",
                                " Difference between LOGIN AND LOGOUT TIME(hours) ",
                                " SpEdCare SERVICE RECORDS(not including HEBS claims Input) "};

          sql = "ACCOUNTABILITY_NEW";

          //Sheet with data from the Log file 
          HSSFSheet sheet = (HSSFSheet)hssfworkbook.CreateSheet("Accountability");
          //Sheet with the data from the old Accountability report(for MC)
          HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("Accountability(old)");
          type = "SP";
          FillData(sql, sheet, colHeadings,hssfworkbook);
          sheet.GroupColumn(1, 2);
          sheet.SetColumnWidth(3, 6000);
          sheet.SetColumnWidth(4, 6000);
          sheet.SetColumnWidth(5, 5000);
          sheet.SetColumnWidth(6, 6000);
          sheet.CreateFreezePane(0, 1);

          string[] colHeadings1 = {" Last Name "," First Name "," Employee ID "," Employee Type "," Date ",
                                 " Hours Reported "," UnPaid Time off "," Paid break "," Make Up Time "," Work Hours ",
                                 " Sick Hours "," Vacation Hours "," Holiday Hours "," Regular Hours "," Daily Over Time Hours ",
                                 " Double Time "," Weekly Over Time Hours ",
                                 " SpEdCare Service Record Count (not including HEBS claims Input)",
                                 " Time of FIRST SpEdCare Service Record Entry of the day ",
                                 " Time of LAST SpEdCare Service Record Entry of the day ",
                                 " Difference between FIRST and LAST Service Record Entered (hours) "};
          sql = "ACCOUNTABILITY_OLD";
          FillData(sql, sheet1, colHeadings1,hssfworkbook);
          AddTotals(hssfworkbook,sheet1, 'F', 'R', 5);
          sheet1.SetColumnWidth(14, 4000);
          sheet1.SetColumnWidth(17, 5000);
          sheet1.SetColumnWidth(18, 6000);
          sheet1.SetColumnWidth(19, 6000);
          sheet1.SetColumnWidth(20, 6000);
          sheet1.SetColumnWidth(4, 3000);
          sheet1.SetColumnWidth(16, 4000);
          sheet1.CreateFreezePane(0, 1);

          GetFileName(" Accountability ");
          fname = fname.Substring(9);
          WriteToFile(fname, false);

          status(false);
        }
        catch (Exception ex)
        {
          MessageBox.Show(ex.ToString());
          status(false);
        }
        finally
        {
          sqlconn.Close();
        }
    }

    private void exitToolStripMenuItem_Click(object sender, EventArgs e)
    {
      //Closes the form
        Application.Exit();
    }

    private void ShowRates(bool show)
   {
   /******************************************************************
    * Show the controls to change rates
    ******************************************************************/
      mbalabel.Visible    = show;
      mbatextBox.Visible  = show;
      douglabel.Visible   = show;
      dougtextBox.Visible = show;
      hidebutton.Visible  = show;
   }

    private void changeTitle(bool show)
      {
     /******************************************************************
      * Show the controls to change job title
      ******************************************************************/
          chngtitlelabel.Visible   = show;
          chngtitletextBox.Visible = show;
          chngTitlebutton.Visible  = show;          
      }

    private void changeRateToolStripMenuItem_Click(object sender, EventArgs e)
    {
      ShowRates(true);
      hidebutton.Visible = true;
    }

    private void changeRemoteFlagToolStripMenuItem_Click(object sender, EventArgs e)
    {
     /******************************************************************
      * Show options to change remote flag
      ******************************************************************/
      radioButton1.Visible = true;
      radioButton2.Visible = true;
      hidebutton.Visible   = true;
    }

    private void radioButton1_CheckedChanged(object sender, EventArgs e)
    {
     ChangeRemoteFlag('1');
    }
      
    private void ChangeRemoteFlag(char f)
    {
        /******************************************************************
         * Check if the an employee is selected and update the 
         * remote column of employee table 
         *****************************************************************/
        try
        {
            if (empcomboBox.SelectedIndex != 0)
            {
                sqlconn.Open();
                string sql = "update dbo.Employees set RemoteStaff = " + f + " where Emp_ID =" + Convert.ToString(empcomboBox.SelectedValue);
                comm.CommandType = CommandType.Text;
                comm.CommandText = sql;
                comm.ExecuteNonQuery();
                sqlconn.Close();
                radioButton1.Visible = false;
                radioButton2.Visible = false;
            }
            else
                MessageBox.Show("Please select an Employee from the combo box");
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString());
            sqlconn.Close();
        }
        finally
        {
            sqlconn.Close();
        }          
    }

    private void radioButton2_CheckedChanged(object sender, EventArgs e)
    {
      ChangeRemoteFlag('0');
    }

    private void hidebutton_Click(object sender, EventArgs e)
    {
      /******************************************************************
       * Hides all the extra controls 
       ******************************************************************/
      radioButton1.Visible = false;
      radioButton2.Visible = false;
      ShowRates(false);
      changeTitle(false);
    }

    private void changeJobTitleToolStripMenuItem_Click(object sender, EventArgs e)
      {
          /******************************************************************
            * show the controls to change the job tile for an employee
            ******************************************************************/
          hidebutton.Visible = true;
          changeTitle(true);
      }

    private void chngTitlebutton_Click(object sender, EventArgs e)
      {
          /******************************************************************
            * Check if an employee is selected and update the table 
            * with new job title
            ******************************************************************/
          try
          {
              if ((empcomboBox.SelectedIndex != 0) && (chngtitletextBox.Text != string.Empty))
              {
                  sqlconn.Open();
                  string sql = "update dbo.Employees set jobTitle = '" + chngtitletextBox.Text + "' where Emp_ID =" + Convert.ToString(empcomboBox.SelectedValue);
                  comm.CommandType = CommandType.Text;
                  comm.CommandText = sql;
                  comm.ExecuteNonQuery();
                  sqlconn.Close();
                  changeTitle(false);
              }
              else
                  MessageBox.Show("Please select an Employee from the combo box and enter new job title");
          }
          catch (Exception ex)
          {
              MessageBox.Show(ex.ToString());
              sqlconn.Close();
          }
          finally
          {
              sqlconn.Close();
          }          
      }

    private void staffInfobutton_Click(object sender, EventArgs e)
      {
          /******************************************************************
          * Creates an excel with details of an employee
          ******************************************************************/
          status(true);
          try
          {
              InitializeWorkbook();
              
              HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.CreateSheet("Work Hours");              

              string sql = "select Last_Name,First_Name,convert(char,Date,101),Task,Hours_Reported,UnPaid_TimeOff,Paid_break," +
                            "Regular_Hours,Sick_Hours,Paid_Vaca,Holiday_Hours,RegHoursPerDay,Daily_OT,Double_Time,Weekly_OT,Client," +
                            "StartTime,EndTime,Notes from [TTFN].[dbo].EMPLOYEE_DETAIL_SUBTOTAL_new(@emp,@startDate,@endDate) order by ID";

              string[] colHeadings = {"Last Name","First Name","Date","Task","Hours Reported","UnPaid Time off","Paid break","Work Hours",
                                       "Sick Hours","Vacation Hours","Holiday Hours","Regular Hours","Daily Over Time Hours",
                                       "Double Time","Weekly Over Time Hours","Client","Start Time","End Time","Entry Notes"};
              type = "FN";
              FillData(sql, sheet1, colHeadings,hssfworkbook);
                            
              sheet1.SetColumnWidth(2, 3000);
              sheet1.SetColumnWidth(3, 7000);
              sheet1.SetColumnWidth(12, 3000);
              sheet1.SetColumnWidth(14, 3000);
              sheet1.SetColumnWidth(18, 40000);
              sheet1.SetColumnWidth(15, 7000);

              //Applying conditional formatting with one rule
              int[] range = new int[4] { 1, j, 8, 14 };
              ConditionalFormat(range, "0", NPOI.HSSF.Util.HSSFColor.ROSE.index, sheet1);
              //Group columns 
              sheet1.GroupColumn(12, 14);
              sheet1.GroupColumn(8, 10);
              sheet1.GroupColumn(5, 5);
              sheet1.CreateFreezePane(5,1);

              HSSFSheet sheet2 = (HSSFSheet)hssfworkbook.CreateSheet("Claim lines perHour");
              string[] colHeadings2 = { "Employee ID", "Name", "Spedmon ClaimLines", "Hebs ClaimLines", "Total Claim Lines", 
                                        "Paid Hours", "ClaimLines PerHour PaidHours","Input Hours","ClaimLines PerHour InputHours" };
              type = "SP";
              onlyPaid = 0;
              FillData("ClaimLinesPerHour", sheet2, colHeadings2,hssfworkbook);            
              
              sheet2.SetColumnWidth(1, 5000);
              sheet2.SetColumnWidth(6, 4000);
              sheet2.SetColumnWidth(8, 4000);
              GetFileName(" Work-Hours for " + empcomboBox.Text+" ");
              fname = fname.Substring(9);
              WriteToFile(fname, false);
              status(false);              
          }
          catch (Exception ex)
          {
              MessageBox.Show(ex.ToString());
              status(false);
          }
          finally
          {
              sqlconn.Close();
          }
      }

    private void GetParmValues()
      {
       /******************************************************************
        * sets the parm values according to UserFileAccess
        ******************************************************************/
          startdate = startdateTimePicker.Value.Date;
          enddate   = enddateTimePicker.Value.Date;   
          
          comm.Parameters["@startDate"].Value = startdate;
          comm.Parameters["@endDate"].Value   = enddate;
          comm.Parameters["@emp"].Value       = empcomboBox.SelectedValue;
      }

    private void AddParms(bool add)
      {
          if (add)
          {
              comm.Parameters.Add(parm1);
              comm.Parameters.Add(parm2);
              comm.Parameters.Add(parm3);
          }
          else
          {
              comm.Parameters.Remove(parm1);
              comm.Parameters.Remove(parm2);
              comm.Parameters.Remove(parm3);
          }

      }

    private void Form1_FormClosing(object sender, FormClosingEventArgs e)
      {
          // make sure the connections are closed before closing
          sqlconn.Close();
      }


    /******************************************************************
     * 
     ******************************************************************/

      private void CreateChart(HSSFSheet sheet, HSSFWorkbook hssfworkbook1)
      {
          try
          {                         
              if (IsThreeMonthRange)
              {
                  startdate = enddate.AddMonths(-3);
                  j = 44;
              }
              else j = 1;

              sqlconn.Open();
              sqlconn.ConnectionTimeout.Equals(5000);

              comm.CommandType = CommandType.StoredProcedure;
              comm.CommandText = "ClaimLinesPerHour";

              AddParms(true);
              comm.Parameters.Add(parm4);
              comm.Parameters["@paid"].Value = DBNull.Value;
              comm.Parameters["@startDate"].Value = startdate;
              comm.Parameters["@endDate"].Value = enddate;
              comm.Parameters["@emp"].Value = DBNull.Value;
            
              comm.CommandTimeout = 5000;

              SqlDataAdapter da = new SqlDataAdapter(comm);              
              DataTable dt = new DataTable();
              da.Fill(dt);
              
              //Style to apply for column headings
              NPOI.SS.UserModel.CellStyle style1;
              NPOI.SS.UserModel.CellStyle style2;
              NPOI.SS.UserModel.CellStyle style3;

              style1 = hssfworkbook1.CreateCellStyle();
              style2 = hssfworkbook1.CreateCellStyle();
              style3 = hssfworkbook1.CreateCellStyle();
              FormatStyle(style1, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLUE.index, 14, true, true);
              style1.Alignment = NPOI.SS.UserModel.HorizontalAlignment.CENTER;

              FormatStyle(style2, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLACK.index, 12, false, false);
              FormatStyle(style3, hssfworkbook1, NPOI.HSSF.Util.HSSFColor.BLACK.index, 14, true, false);

              Row row;              
              int SecondChart = 17;
              
              i = 0;
              double d;

              /******************************************************************
               * Go through each row in the data table and fill the charts
               ******************************************************************/
              int numrows = sheet.LastRowNum;
              bool skipSummaryRows = false;
              if (dt.Rows.Count > 0)
              {
                  
                  foreach (DataRow dr in dt.Rows)
                  {
                    
                      if (j + 1 >= numrows)
                          row = sheet.CreateRow(j);
                      else
                          row = sheet.GetRow(j);
                      int m = 0;
                      for (i = 0; i < dt.Columns.Count; i++)
                      {
                          //remove the staff who does not have input hours from the chart
                          string etst = dr[8].ToString();
                          if (dr[8].ToString() == "0.00") continue;
                              
                          if (dr[i].ToString() == "1000")
                          {
                              skipSummaryRows = true;
                              break;
                          }
                          //For input hours chart, skip paid hours columns
                          if (i == 5 || i == 6)
                          {
                              m = m + 1;
                              continue;
                          }                          

                          try { sheet.GetRow(j).GetCell(i-m).SetCellValue(dr[i].ToString()); }
                          catch
                          {
                              Cell cell = row.CreateCell(i-m);
                              cell.SetCellValue(dr[i].ToString());
                          }
                          // Convert number values to double
                          if (double.TryParse(dr[i].ToString(), out d))
                              sheet.GetRow(j).GetCell(i-m).SetCellValue(d);                          

                          sheet.GetRow(j).GetCell(i-m).CellStyle = style2;                        
                          
                      }
                      if (skipSummaryRows == true) break;
                      j = j + 1;
                  }
                 
                  DataView v = dt.DefaultView;

                  for (i = dt.Rows.Count - 1; i >= dt.Rows.Count - 5; i--)
                     v.Delete(i);

                  v.Sort="CLPerHour_PaidHours desc"; 
                  dt = v.ToTable();
                  //Second chart
                  if (IsThreeMonthRange)
                      j = 44;
                  else   j = 1;
                 
                  foreach (DataRow dr in dt.Rows)
                  {
                      row = sheet.GetRow(j);

                      for (i = 0; i < dt.Columns.Count; i++)
                      {
                          if ((dr[i].ToString() == "1000") || (dr[i].ToString() == "0" && dr[i+1].ToString() != "Average"))
                          {                             
                              break;
                          }                          
                          if (i <= 6)
                          {
                              try { sheet.GetRow(j).GetCell(i + SecondChart).SetCellValue(dr[i].ToString()); }
                              catch
                              {
                                  Cell cell = row.CreateCell(i + SecondChart);
                                  cell.SetCellValue(dr[i].ToString());
                              }
                              // Convert number values to double
                              if (double.TryParse(dr[i].ToString(), out d))
                              {
                                  sheet.GetRow(j).GetCell(i + SecondChart).SetCellValue(d);
                              }
                              sheet.GetRow(j).GetCell(i + SecondChart).CellStyle = style2;                             
                          }
                      }                      
                      j = j + 1;
                  }                 
                  sheet.ForceFormulaRecalculation = true;
              }

              da.Dispose();
              sheet.DisplayZeros = false;
              sheet.HorizontallyCenter = true;
              sqlconn.Close();
              AddParms(false);
              comm.Parameters.Remove(parm4);

          }
          catch (Exception ex)
          {
              LognSendErrorMsg(ex.Message);
          }
          finally
          {
              sqlconn.Close();
              if (commmandLineMode)
              {
                  if (log != null)
                      log.Dispose();
                  WindowsApplication.cleanup();
              }
          }
      }


      
  }
}