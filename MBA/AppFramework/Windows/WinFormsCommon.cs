using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;
using wf = System.Windows.Forms;
using System.Net.Configuration;
using System.Net.Mail;
using System.Net.Mime;
using System.IO;
using System.ComponentModel;


using MBA;

namespace MBA
{
   public delegate DataTable view();

   public class WinFormsCommon
    {
        private static List<SqlParameter> parms = new List<SqlParameter>(); //TODO: refactor this out


        public static DataTable tableFromSqlExecQuery(SqlCommand com)
        {
            DataTable dt = new DataTable();
            bool isSproc = (com.CommandType == CommandType.StoredProcedure);

            /* execQuery expects a List<SqlParameter> */
            /* Note for future refactoring: execQuery distributes the list back into an SqlParameterCollection. */
             
            List<SqlParameter> p = new List<SqlParameter>();
            foreach (SqlParameter tp in com.Parameters)
            {
                p.Add(new SqlParameter(tp.ParameterName, tp.Value));
            }

            try
            {
                ReturnDB rd = Database.execQuery(com.Connection, null, com.CommandText, isSproc, p);
                dt = Database.convertReturnDBToDatatable(ref rd);
            }
            catch (Exception e)
            {
                dt = null;
                throw e;
                
            }
            
            return dt;
        }

        /***************************************************************************
         * Method(s) to populate a combobox. Fills the combo box if the datatable has 
         * rows else clears the items in the combobox. 
         ***************************************************************************/

        public static void depPopulateComboBox(SqlCommand com, System.Windows.Forms.ComboBox cb, string tbName, string display, string value, bool addBlank, string blankMsg)
        {
        /* Deprecated. Egg on my face! -DW */


            try
            {
                DataTable dt = new DataTable();
                dt = tableFromSqlExecQuery(com);

                /* Todo: Add additional check to confirm that output from dt source method is suitable for use in combobox. */
                if (dt.Rows.Count > 0)
                {
                    dt.TableName = tbName;

                    if (addBlank)
                    {
                        /*-------------------------------------------
                         * Add a blank row to the Combobox, this allows 
                         * to have an option to select none of the items 
                         * in the combobox
                         * ------------------------------------------*/
                        DataRow TopRow = dt.NewRow();
                        TopRow[display] = blankMsg;
                        if (value != null)
                            TopRow[value] = DBNull.Value;
                        dt.Rows.InsertAt(TopRow, 0);
                    }

                    cb.DataSource = dt;
                    cb.DisplayMember = display;
                    if (value != null)
                        cb.ValueMember = value;
                }
                else
                {
                    cb.DataSource = null;
                    cb.Items.Clear();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public static void PopulateComboBox(SqlConnection conn, string sql, bool isSproc, List<SqlParameter> parms,
             System.Windows.Forms.ComboBox cb, string tbName, string display, string value, bool addBlank, string blankMsg)
        {
            /* New form of PopulateComboBox, overloaded to allow specification of whether or not the query being run to fill the dropdown is a sproc */
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, isSproc, parms);
                DataTable dt = new DataTable();
                dt = Database.convertReturnDBToDatatable(ref rd);
                if (dt.Rows.Count > 0)
                {
                    dt.TableName = tbName;

                    if (addBlank)
                    {
                        /*-------------------------------------------
                         * Add a blank row to the Combobox, this allows 
                         * to have an option to select none of the items 
                         * in the combobox
                         * ------------------------------------------*/
                        DataRow TopRow = dt.NewRow();
                        TopRow[display] = blankMsg;
                        if (value != null)
                            TopRow[value] = DBNull.Value;
                        dt.Rows.InsertAt(TopRow, 0);
                    }

                    cb.DataSource = dt;
                    cb.DisplayMember = display;
                    if (value != null)
                        cb.ValueMember = value;
                }
                else
                {
                    cb.DataSource = null;
                    cb.Items.Clear();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public static void PopulateComboBox(SqlConnection conn, string sql, List<SqlParameter> parms,
            System.Windows.Forms.ComboBox cb, string tbName, string display, string value, bool addBlank, string blankMsg)

        {
            try
            {
                ReturnDB rd = Database.execQuery(conn, null, sql, false, parms);
                DataTable dt = new DataTable();
                dt = Database.convertReturnDBToDatatable(ref rd);
                if (dt.Rows.Count > 0)
                {
                    dt.TableName = tbName;

                    if (addBlank)
                    {
                        /*-------------------------------------------
                         * Add a blank row to the Combobox, this allows 
                         * to have an option to select none of the items 
                         * in the combobox
                         * ------------------------------------------*/
                        DataRow TopRow = dt.NewRow();
                        TopRow[display] = blankMsg;
                        if (value != null)
                            TopRow[value] = DBNull.Value;
                        dt.Rows.InsertAt(TopRow, 0);
                    }

                    cb.DataSource = dt;
                    cb.DisplayMember = display;
                    if (value != null)
                        cb.ValueMember = value;
                }
                else
                {
                    cb.DataSource = null;
                    cb.Items.Clear();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public static bool FileInUse(string file)
        {
            /******************************************************************
             * Checks if the given file is being used.
             ******************************************************************/
            FileStream stream = null;
            if (!System.IO.File.Exists(file))
            {
                MessageBox.Show("File not found!");
                return true;
            }
            else
                try
                {
                    stream = System.IO.File.Open(file, FileMode.Open, FileAccess.ReadWrite, FileShare.None);
                }
                catch
                {
                    return true;
                }
                finally
                {
                    if (stream != null)
                    {
                        stream.Close();
                        stream.Dispose();
                    }
                }
            return false;
        }

        /***************************************************************************
         * If 'o' is null returns empty string
         ***************************************************************************/
        public static String IsNull(object o)
        {
            if (o == null)
                return "";
            else
                return o.ToString();
        }

        public static void DeleteFiles(string path)
        {
            /***************************************************************************
             * Deletes all the files from a folder 
             ***************************************************************************/
            DirectoryInfo sourceDirectory = new DirectoryInfo(path);
            FileInfo[] fi = sourceDirectory.GetFiles();
            foreach (FileInfo f in fi)
            {
                f.Delete();
            }
        }

        public static int FilesCount(string path)
        {
            /***************************************************************************
             * Returns the Count of the number of files in a given folder.
             ***************************************************************************/
            DirectoryInfo sourceDirectory = new DirectoryInfo(path);

            FileInfo[] fi = sourceDirectory.GetFiles();
            int count = fi.Count();
            return count;
        }
        /***************************************************************************
         * Moves the file if the destination folder does not already have a file
         * with the same name
         ***************************************************************************/
        public static void MoveFile(string source, string destination, string filename)
        {
            try
            {
                //if (!Methods.FileExists(destination, filename))
                if (!System.IO.File.Exists(destination + filename))
                    System.IO.File.Move(source + filename, destination + filename);
                else
                    MessageBox.Show("A file with the same name already exists in " + destination);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        /***************************************************************************
         * Moves the file and returns true if the destination folder does not already 
         * have a file with the same name otherwise returns false.
         ***************************************************************************/
        public static bool CanMoveFile(string source, string destination, string filename)
        {
            bool canmove = true;
            try
            {
                if (Directory.Exists(destination))
                {
                    if (System.IO.File.Exists(source + filename))
                        if (!System.IO.File.Exists(destination + filename))
                        {
                            if (System.IO.File.Exists(source + filename))
                                System.IO.File.Move(source + "/" + filename, destination + "/" + filename);
                            else
                            {
                                canmove = false;
                                MessageBox.Show("File does not exist in " + source + "!");
                            }
                        }
                        else
                        {
                            canmove = false;
                            MessageBox.Show("A file with the same name already exists in " + destination);
                        }
                    else MessageBox.Show("File not found!");
                }
                else
                {
                    canmove = false;
                    MessageBox.Show("The specified path " + destination + " does not exists!");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message + ". Please close the app and try again.");
                canmove = false;
            }
            return canmove;
        }

        /***************************************************************************
         * optFloat */
        /**
        * Checks to see if value is a valid floating (single, or double) point 
        * number.  Returns value as an Double
        * Throws an exception using msg as the error message if not valid.
        * 
        * @param  value           Incoming value
        * @param  msg             Invalid value message
        * @return                 value as double
        ***************************************************************************/

        public static Double optFloat(string value, string msg)
        {
            value = Validate.optString(value, msg);
            string pattern = @"^[-+]?\d*\.?\d*$";
            if (Regex.IsMatch(value, pattern)) { return Convert.ToDouble(value); }
            else { throw new Warning(msg); }
        }

        /***************************************************************************
         * Cnverts and returns the 12 hour time format string to 24 hour time format string.
         ***************************************************************************/
        public static string optTime(string value)
        {
            if (Util.IsNullOrEmpty(value)) return null;
            else
                if (value.Contains("p") || value.Contains("P"))
                {
                    int t;
                    if (value.Length >= 7)
                    {
                        t = Convert.ToInt16(value.Substring(0, 2));
                        value = value.Substring(2, value.Length - 2);
                    }
                    else
                    {
                        t = Convert.ToInt16(value.Substring(0, 1));
                        value = value.Substring(1, value.Length - 1);
                    }
                    if (t != 12)
                        t = t + 12;
                    value = t.ToString() + value;
                }
            value = value.Substring(0, value.Length - 2) + ":00";
            return value;
        }       

        /**********************************************************
         * Verifies if the file name is in correct format
         * as per bussiness rule and all the information
         * supplied are valid using regular expressions
         * 
         * for example : 20121024-ELKGROVE-3467314-HS.pdf
         * is in correct format, 
         * the date 20121024 in the file name, the district
         * short name - ELKGROVE or CDS - 3467314 and the 
         * Work type - HS are all correct.
         * if any of these is incorrect it is considered as 
         * incorrect file name
         ***********************************************************/
        public static bool CheckFileName(SqlConnection conn, string filename, ref string dateSent, ref string workType, ref string clientID, ref string clientCDS, ref string clientShortName)
        {
            Regex rx;
            if (filename.Contains("-1-1"))
                rx = new Regex(@"(\d+)-(.+-?.+)-(\d{7})-(\w+-?\w+)");
            else
                rx = new Regex(@"(\d+)-(.+-?.+)-(\d{7})-(\w+)");

            Match m = rx.Match(filename);
            DateTime date;

            if (m.Success)
            {
                dateSent = m.Groups[1].ToString();
                if (dateSent.Length == 8)
                    dateSent = dateSent.Substring(0, 4) + "-" + dateSent.Substring(4, 2) + "-" + dateSent.Substring(6, 2);
                else
                {
                    MessageBox.Show("Invalid filename "+filename+", the date on the file should be in yyyymmdd format.");
                    return false;
                }
            }

            if (m.Success && DateTime.TryParse(dateSent, out date))
            {
                clientShortName = m.Groups[2].ToString();
                clientCDS = m.Groups[3].ToString();
                workType = m.Groups[4].ToString();

                string sql = "select CLIENT_ID from CLIENTS_Client where ShortName = @clientShrtName or CLIENT_CDS = @clientCDS";
                parms.Clear();
                parms.Add(Database.SqlParm("@clientCDS", SqlDbType.VarChar, clientCDS, ParameterDirection.Input));
                parms.Add(Database.SqlParm("@clientShrtName", SqlDbType.VarChar, clientShortName, ParameterDirection.Input));
                clientID = execScalar(conn, sql, parms);

                parms.Clear();
                sql = "select id from TYPE_OF_WORK where @workType like '%'+WorkCode+'%'";
                parms.Add(Database.SqlParm("@workType", SqlDbType.VarChar, workType, ParameterDirection.Input));

                workType = execScalar(conn, sql, parms);

                if (clientID == null || workType == null)
                {
                    MessageBox.Show("Incorrect file name! please check the file name format and veryfy if the client shortname and CDS are correct.");
                    return false;
                }
                else
                {
                    sql = "select count(*) from Input_batches where File_Name = @filename and active = 1";
                    parms.Clear();
                    parms.Add(Database.SqlParm("@filename", SqlDbType.VarChar, filename, ParameterDirection.Input));
                    int dup = Convert.ToInt16(execScalar(conn, sql, parms));

                    if (dup > 0)
                    {
                        MessageBox.Show("A file with this name already exists! please use a different filename.");
                        return false;
                    }
                    else return true;
                }
            }
            else
            {
                MessageBox.Show("Incorrect file name! please check the file name format and veryfy if the client shortname,CDS and Work type are correct.");
                return false;
            }
        }

        /***************************************************************************
         * execScalar */
        /**
         * Executes a scalar query
         * 
         * @param   conn         SQL Connection
         * @param   sql          SQL statement to be executed
         * @param   parms        list of sql parameters
         * @return  
         ****************************************************************************/
        public static string execScalar(SqlConnection conn, string sql, List<SqlParameter> parms)
        {
            try
            {
                SqlCommand comm = new SqlCommand(sql, conn);
                if (parms != null)
                    foreach (SqlParameter parm in parms)
                        comm.Parameters.Add(parm);
              
                return IsNull(comm.ExecuteScalar());
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
                return null;
            }
        }

        public static void emailFile(SmtpClient sc , string from, string[] to, string[] cc, string subject, string body, List<string> attachments)
        {
            /******************************************************************
             * Sends email to Input staff with the excel file attached 
             ******************************************************************/
            try
            {
                if (to != null && body != "")
                {
                    //SmtpSection smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as SmtpSection;
                    //SmtpClient sc = new SmtpClient(Constants.APP_SMTP_HOST, Constants.APP_SMTP_PORT);
                    MailMessage mm     = new MailMessage();
                    mm.BodyEncoding    = System.Text.Encoding.UTF8;
                    mm.SubjectEncoding = System.Text.Encoding.UTF8;
                    
                    mm.IsBodyHtml = true;
                   

                    if (attachments != null)
                        foreach (string file in attachments)
                        {
                            ContentType ct = new ContentType(@"application/vnd.ms-excel");
                            Attachment ma = new Attachment(file, ct);
                            mm.Attachments.Add(ma);
                        }

                    MailAddress fromID = new MailAddress(from);
                    mm.From = fromID;

                    /******************************************************************
                     * The email's list is comma separated string with multiple emails
                     *  we are doing this to add each emaill Id in the string 
                     ******************************************************************/
                    if (to != null)
                        foreach (string id in to)
                        {
                            if (!string.IsNullOrEmpty(id))
                            {
                                object email = MBA.Validate.optEmail(id, "Invalid Email address!");
                                MailAddress emailTo = new MailAddress(id);
                                mm.To.Add(emailTo);
                            }
                        }

                    if (cc != null)
                        foreach (string id in cc)
                        {
                            if (!string.IsNullOrEmpty(id))
                            {
                                object email = MBA.Validate.optEmail(id, "Invalid Email address!");
                                MailAddress emailCc = new MailAddress(id);
                                mm.CC.Add(emailCc);
                            }
                        }

                    mm.Subject = subject;
                    /*----------------------------
                     * Body
                     *----------------------------*/

                    StringBuilder sb = new StringBuilder();

                    sb.AppendLine(@"<!doctype html>");
                    sb.AppendLine(@"<html>");
                    sb.AppendLine(@"<head>");
                    sb.AppendLine(@"<title>");
                    sb.AppendLine(subject);
                    sb.AppendLine(@"</title>");
                    sb.AppendLine(@"</head>");
                    sb.AppendLine(@"<body>");
                    sb.AppendLine(@"<div style=""font-size:1em;"">");
                    sb.AppendLine(body);
                    sb.AppendLine(@"</div>");
                    sb.AppendLine(@"<br/>");
                    sb.AppendLine(@"<hr/>");
                    sb.AppendLine(@"<div>");
                    sb.AppendLine(@"<em style=""font-style:italic;font-size:.75em;"">");
                    sb.AppendLine(Messages.CONFIDENTIAL_EMAIL);
                    sb.AppendLine(@"</em>");
                    sb.AppendLine(@"</div>");
                    sb.AppendLine(@"</body>");
                    sb.AppendLine(@"</html>");

                    mm.Body = sb.ToString();

                    sc.Send(mm);
                }
                else
                    throw new Exception("Email can not be sent! please provide all the required fields to send the email");
            }
            catch (Exception ex)
            {
                throw ex;
            }


        }

        public static string[] splitString(string s)
        {
            if (s != string.Empty)
            {
                if (s.Substring(s.Length - 1) == ",")
                    s = s.Substring(0, s.Length - 1);

                string[] splitList;
                s = s.Replace(" ", string.Empty);

                splitList = s.Split(new Char[] { ',' });

                return splitList;
            }
            else return null;

        }

        
        /***************************************************************************
         * Refreshes the datagrid and restores the sort order and selected rows.
         * also hides the columns starting from column number hideFrom to hideTo
         ***************************************************************************/
        public static void loadDataGrid(ref DataGridView dv, int hideFrom, int hideTo, view vc)
        {
             ListSortDirection oldSortOrder;
            DataGridViewColumn oldSortColumn;
            List<String> selectedRows = new List<String>();

            // Store the sort details.
            switch (dv.SortOrder)
            {
                case System.Windows.Forms.SortOrder.Ascending:
                    oldSortOrder = ListSortDirection.Ascending;
                    break;
                case System.Windows.Forms.SortOrder.Descending:
                    oldSortOrder = ListSortDirection.Descending;
                    break;
                default:
                    oldSortOrder = ListSortDirection.Ascending;
                    break;
            }

            oldSortColumn = dv.SortedColumn;

            selectedRows.Clear();
            // Store the selected rows
            foreach (DataGridViewRow row in dv.SelectedRows)
            {
                selectedRows.Add(row.Cells["id"].Value.ToString());
            }

            DataTable dt = new DataTable();
            dt = vc();
            dv.DataSource = dt;
            // hide unwanted columns
            if (dt.Rows.Count != 0)
            {
                for (int j = hideFrom; j <= hideTo; j++)
                    dv.Columns[j].Visible = false;
            }

            //Restore the sort
            try
            {
                if (oldSortColumn != null)
                    dv.Sort(dv.Columns[oldSortColumn.Name], oldSortOrder);
            }
            catch { };

            //Restore Selected rows
            int i = 0;
            try
            {
                foreach (DataGridViewRow row in dv.Rows)
                {
                    row.Selected = false;
                    if (selectedRows.Contains(row.Cells["id"].Value.ToString()))
                    {
                        row.Selected = true;
                        dv.FirstDisplayedScrollingRowIndex = i;
                    }
                    i += 1;
                }
            }
            catch { }
        }

    }
}


