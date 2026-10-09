using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Security.Permissions;
using System.IO;
using System.Diagnostics;
using System.Configuration;
using System.Net.Configuration;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;

using MBA;

namespace WORKFLOW
{
    public partial class EmailForm : System.Windows.Forms.Form
    {
        public EmailForm()
        {
            InitializeComponent();
        }

        private static EmailForm m_SChildform1;

        /***************************************************************************
         * if not created yet or disposed, Create an instance
         * if just created or created earlier.Return it
         ***************************************************************************/
        public static EmailForm GetChildInstance()
        {
            if ((m_SChildform1 == null) || m_SChildform1.IsDisposed)
                m_SChildform1 = new EmailForm();
            return m_SChildform1;
        }

        ContentType ct = new ContentType(@"application/pdf");
        public List<string> attachments     = new List<string>();
        public List<string> fileAttachments = new List<string>();
        public string emailCc;
        private List<string> emaillist      = new List<string> { };
        private List<SqlParameter> parms = new List<SqlParameter>();
        private bool pageLoaded = false;
        public string inputBatchID;
        private string reasons = "";

       

        /***************************************************************************
         * http://www.c-sharpcorner.com/UploadFile/frankalonzo/GlobalAddressList11262005053740AM/GlobalAddressList.aspx
         * Loads the emailIDcombobox with the Global addresses and clientscomboBox with clients               
         ***************************************************************************/
        private void EmailForm_Load(object sender, EventArgs e)
        {
            DataTable dtResult = new DataTable("Result");

            dtResult.Columns.Add("Name");
            dtResult.Columns.Add("EmailAddress");
        
            DirectorySearcher objsearch = new DirectorySearcher();
            string strrootdse = objsearch.SearchRoot.Path;
            DirectoryEntry objdirentry = new DirectoryEntry(strrootdse);

            objsearch.SearchScope       = System.DirectoryServices.SearchScope.Subtree;           
            objsearch.Sort.Direction    = System.DirectoryServices.SortDirection.Ascending;
            objsearch.Sort.PropertyName = "givenname";
           
            SearchResultCollection colresults  = objsearch.FindAll();

            dtResult.Rows.Add("", "");
            foreach (SearchResult sResultSet in colresults)
                if (GetProperty(sResultSet, "givenname") != string.Empty && 
                    GetProperty(sResultSet, "mail")      != string.Empty &&
                   !emaillist.Contains(GetProperty(sResultSet, "givenname").ToString()))
                {
                    dtResult.Rows.Add(GetProperty(sResultSet, "givenname"), GetProperty(sResultSet, "mail"));
                    emaillist.Add(GetProperty(sResultSet, "givenname").ToString());
                }
                                         
            emailIDcomboBox.DataSource    = dtResult;
            emailIDcomboBox.DisplayMember = "Name";
            emailIDcomboBox.ValueMember   = "EmailAddress";

            fromtextBox.Text = Environment.UserName+"@help4schools.com";           
            
            pageLoaded = true;
            cctextBox.Text = "";
        }

        private string GetProperty(SearchResult searchResult, string PropertyName)
        {
           if(searchResult.Properties.Contains(PropertyName))
           {
            return searchResult.Properties[PropertyName][0].ToString();
           }
           else
           {
            return string.Empty;
           }
        }
       
       /***************************************************************************
        * Check if emailID's are valid, atttaches the files and sends the mail.
        ***************************************************************************/
        private void sendbutton_Click(object sender, EventArgs e)
        {
            bool send = true;
            string[] ccEmailIDList;
            MailMessage mm   = new MailMessage();
            mm.BodyEncoding = System.Text.Encoding.UTF8;
            mm.SubjectEncoding = System.Text.Encoding.UTF8;
            mm.IsBodyHtml = true;
            MailAddress from = new MailAddress(fromtextBox.Text);
            mm.From = from;
            
            if (totextBox.Text != string.Empty)
            {
                if (totextBox.Text.Substring(totextBox.Text.Length-1) == ",")
                    totextBox.Text = totextBox.Text.Substring(0, totextBox.Text.Length - 1);
                
                string[] toEmailIDList;
                totextBox.Text = totextBox.Text.Replace(" ", string.Empty);
                toEmailIDList = totextBox.Text.Split(new Char [] {','});
                
                foreach (string id in toEmailIDList)
                {
                    try
                    {
                        object email = MBA.Validate.optEmail(id, "Invalid Email address!");
                        MailAddress to = new MailAddress(id);
                        mm.To.Add(to);
                    }
                    catch (Exception ex)
                    {
                        send = false;
                        MessageBox.Show(ex.Message+" Please enter the email addresses separated by commas!");
                        totextBox.Focus();
                    }
                }                
            }
            else
            {
                MessageBox.Show("To address can not be empty!");
                send = false;
                totextBox.Focus();
            }

            if (cctextBox.Text != string.Empty)
            {
                if (cctextBox.Text.Substring(cctextBox.Text.Length - 1) == ",")
                    cctextBox.Text = cctextBox.Text.Substring(0, cctextBox.Text.Length - 1);
                
                cctextBox.Text = cctextBox.Text.Replace(" ", string.Empty);
                ccEmailIDList  = cctextBox.Text.Split(new Char[] {','});
                
                foreach (string id in ccEmailIDList)
                {
                    try
                    {
                     object email =  MBA.Validate.optEmail(id,"Invalid Email address!");
                     MailAddress cc = new MailAddress(id);
                     mm.CC.Add(cc);
                    }
                    catch(Exception ex)
                    {
                        send = false;
                        MessageBox.Show(ex.Message);
                        cctextBox.Focus();
                    }
                }
            }

            if (send)
            {
                
                try
                {                      
                    int i = 0;
                    foreach (string file in attachments)
                    {
                        string source = attachments[0].ToString();
                        string fileName = fileAttachments[0].ToString();
                     
                        Attachment ma = new Attachment(file, ct);
                        ma.Name       = fileAttachments[i];
                        mm.Attachments.Add(ma);
                        i += 1;
                    }                                        

                    mm.Subject = subjecttextBox.Text;

                    StringBuilder sb = new StringBuilder();

                    sb.AppendLine(@"<!doctype html>");
                    sb.AppendLine(@"<html>");
                    sb.AppendLine(@"<head>");
                    sb.AppendLine(@"<title>");
                    sb.AppendLine(subjecttextBox.Text);
                    sb.AppendLine(@"</title>");
                    sb.AppendLine(@"</head>");
                    sb.AppendLine(@"<body>");
                    sb.AppendLine(@"<div style=""font-size:1em;"">");
                    sb.AppendLine(bodytextBox.Text.Replace(System.Environment.NewLine,@"<br/>"));
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
                   
                    // set the smtpClient object
                    SmtpClient sc1 = new SmtpClient(Constants.APP_SMTP_HOST, Constants.APP_SMTP_PORT);                                              
                    
                    sc1.Timeout = 1000000;
                   
                    //if using mail@Practi-cal account for sending, then use SBSCParent.smtp else use sc1
                    if (fromtextBox.Text.Contains("practi-cal.com"))
                        SBSCParent.smtp.Send(mm);
                    else sc1.Send(mm);                   
                    
                    this.Close();
                }                    
                catch (Exception ex) { MessageBox.Show(ex.Message); }
            }
        }

       /***************************************************************************
        * Option to change the from address If the user doesn't want to use 
        * their personal mailID 
        ***************************************************************************/
        private void fromPracticalcheckBox_CheckedChanged(object sender, EventArgs e)
        {
            if (fromPracticalcheckBox.Checked == true)
                fromtextBox.Text = "mail@practi-cal.com";
            else fromtextBox.Text = Environment.UserName + "@help4schools.com";
        }

      /***************************************************************************
       * Inserts the selected address from the dropdown to the totextBox and
       * clears the selections.
       ***************************************************************************/
        private void insertbutton_Click(object sender, EventArgs e)
        {
            if(emailIDcomboBox.Visible)
                if (totextBox.Text != "" && emailIDcomboBox.SelectedIndex != 0)
                    totextBox.Text = totextBox.Text + ","+ emailIDcomboBox.SelectedValue.ToString();
                else if(emailIDcomboBox.SelectedIndex != 0)
                    totextBox.Text = emailIDcomboBox.SelectedValue.ToString();

            
            else if(totextBox.Text == "") MessageBox.Show("Please fill the 'To' address field.");

            if(emailIDcomboBox.Items.Count > 0) emailIDcomboBox.SelectedIndex = 0;
        }

      /***************************************************************************
       * Removes all the attachments.
       ***************************************************************************/
        private void rmvAttchmtsbutton_Click(object sender, EventArgs e)
        {
            attachments.Clear();
            fileAttachments.Clear();
            attachmentslabel.Text = string.Empty;
        }

        private void cancelbutton_Click(object sender, EventArgs e)
        {
            this.Close();
        }

      /***************************************************************************
       * Refreshes the attachments label when activated.
       ***************************************************************************/
        private void EmailForm_Activated(object sender, EventArgs e)
        {
           
            foreach (string file in fileAttachments)
                if(!attachmentslabel.Text.Contains(file))
                attachmentslabel.Text = attachmentslabel.Text + file + "; ";
        }
      

        private void clrbutton_Click(object sender, EventArgs e)
        {
            bodytextBox.Text = "";
            totextBox.Text   = "";
            cctextBox.Text   = "";
            subjecttextBox.Text = "";
            //totextBox.ReadOnly = false;
        }
             
                             
    }
}
