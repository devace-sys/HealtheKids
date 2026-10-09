using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Spedmon;

namespace Spedmon
{
  public partial class FileUploadReviewAppFormMain : Form
  {
    

    private const string FILE_UPLOADS               = "treeViewFileUploads";
    private const string FILE_UPLOADS_UNPROCESSED   = "treeNodeUploadFilesUnprocessed";
    private const string FILE_UPLOADS_REQ_REVIEW    = "treeNodeUploadFilesRequiresReview";
    private const string FILE_UPLOADS_FILED         = "treeNodeUploadFilesFiled";
    
    //private TreeNode treeNodeUploadFilesUnprocessed;
    //private TreeNode treeNodeUploadFilesRequiresReview;
    //private TreeNode treeNodeUploadFilesFiled;
    
    /***************************************************************************
     * selectedFileUpload */
    /**
     * 
     * 
     ****************************************************************************/     

    private FileUpload selectedFileUpload           = null;
 
    /***************************************************************************
     * Constructor */
    /**
     * 
     * 
     ****************************************************************************/     

    public FileUploadReviewAppFormMain()
    {
      InitializeComponent();
  
      /*###########################################################################
        # Decorate buttons with images
        ###########################################################################*/  
      
      this.exitToolStripMenuItem.Image      = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_EXIT);
      this.toolStripButtonReplaceFile.Image = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_OPEN); 
      this.toolStripButtonRefresh.Image     = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_REFRESH);
    }
         
    /***************************************************************************
     * RefreshStatus */
    /**
     * 
     * 
     ****************************************************************************/     

    private void RefreshStatus()
    {
      this.toolStripStatusLabelUser.Text = FileUploadReviewApp.GetUserStatusLabelText();                    

    }
                
    /***************************************************************************
     * ClearSelected */
    /**
     * 
     * 
     ****************************************************************************/     
     
    private void ClearSelected ()
    {
      this.toolStripLabelSelectedFile.Text = FileUploadReviewApp.NO_FILE_SELECTED;         
      this.selectedFileUpload = null;      
      
      this.richTextBoxFileSummary.Clear();
      this.richTextBoxFileSummary.Text = "";
      this.richTextBoxFileSummary.Rtf  = "";
      
      dataGridViewFormData.DataSource  = null;
      dataGridViewFormData.Rows.Clear();
      dataGridViewFormData.Refresh();

      dataGridViewStatusLog.DataSource = null;            
      dataGridViewStatusLog.Rows.Clear();
      dataGridViewStatusLog.Refresh();
      
      toolStripButtonReplaceFile.Visible = false;
    }
    
    /***************************************************************************
     * ClearSelections */
    /**
     * 
     ****************************************************************************/     

    private void ClearSelections ()
    {
      treeViewFileUploads.Nodes[FILE_UPLOADS_UNPROCESSED].Nodes.Clear();
      treeViewFileUploads.Nodes[FILE_UPLOADS_REQ_REVIEW].Nodes.Clear();      
      treeViewFileUploads.Nodes[FILE_UPLOADS_FILED].Nodes.Clear();      
    }
    
    /***************************************************************************
     * GetSelections */
    /**
     * 
     * 
     ****************************************************************************/     

    private void GetSelections ()
    {
      
     /*###########################################################################
       # Clear list
       ###########################################################################*/    
     
     ClearSelections();
     
     /*###########################################################################
       # Load current file upload data
       ###########################################################################*/    
    
      ReturnFileUploads rd = FileUploadReviewApp.getFileUploads();            
      treeViewFileUploads.Tag = rd;
       
     /*###########################################################################
       # Populate tree
       ###########################################################################*/    

      foreach (FileUpload fileUpload in rd.fileUploads)
      {
        TreeNode treeNodeFileUpload = new TreeNode();          
        
        treeNodeFileUpload.Name = fileUpload.id.ToString();
        treeNodeFileUpload.Text = fileUpload.fileAsName;
        treeNodeFileUpload.Tag  = fileUpload.id;
        
        /*============================================================
         * Unprocessed
         *============================================================*/

        if (fileUpload.processFile == true) 
        {          
          treeViewFileUploads.Nodes[FILE_UPLOADS_UNPROCESSED].Nodes.Add(treeNodeFileUpload);
          continue;
        }
        
        /*============================================================
         * Waiting for review
         *============================================================*/

        if (fileUpload.reviewFile == true)
        {
          treeViewFileUploads.Nodes[FILE_UPLOADS_REQ_REVIEW].Nodes.Add(treeNodeFileUpload);                          
          continue;
        }
        
        /*============================================================
         * Processed
         *============================================================*/

        if ((fileUpload.processFile == false) && (fileUpload.reviewFile == false))
        {
          treeViewFileUploads.Nodes[FILE_UPLOADS_FILED].Nodes.Add(treeNodeFileUpload);      
          continue;
        }        
        
      }
      
      treeViewFileUploads.Refresh();
    }
    
    /***************************************************************************
     * setTreeNodeVisibiliy */
    /**
     * 
     * 
     ****************************************************************************/   
    
    private void SetTreeNodeVisibility()
    {      
      if (toolStripButtonShowUnprocessed.Checked == true) treeViewFileUploads.Nodes[FILE_UPLOADS_UNPROCESSED].Expand();    else treeViewFileUploads.Nodes[FILE_UPLOADS_UNPROCESSED].Collapse();
      if (toolStripButtonShowReview.Checked      == true) treeViewFileUploads.Nodes[FILE_UPLOADS_REQ_REVIEW].Expand();     else treeViewFileUploads.Nodes[FILE_UPLOADS_REQ_REVIEW].Collapse();
      if (toolStripButtonShowFiled.Checked       == true) treeViewFileUploads.Nodes[FILE_UPLOADS_FILED].Expand();          else treeViewFileUploads.Nodes[FILE_UPLOADS_FILED].Collapse();     
    }
    
    
    /***************************************************************************
     * RefreshList */
    /**
     * 
     * 
     ****************************************************************************/     
   
    private void RefreshList()
    {
      Spedmon.FileUploadReviewApp.ShowWaitForm();
      ClearSelected ();
      GetSelections();
      SetTreeNodeVisibility();
    }
   
    /***************************************************************************
     * GetSelection */
    /**
     * 
     * 
     ****************************************************************************/     

    private void GetSelection (TreeNode n)
    {
           
      /*============================================================
       * Exit if we cant work with this
       *============================================================*/

      if (n        == null)  return;
      if (n.Level  == 0)     return;
      if (n.Tag    == null)  return;     
      if (n.Parent == null)  return;      
      
      long uploadID = (long) n.Tag;     
      
      /*============================================================
       * Get details 
       *============================================================*/

      ReturnFileUpload rd = FileUploadReviewApp.getFileUpload(uploadID);
      
      /*============================================================
       * Refresh selected link label
       *============================================================*/

      toolStripLabelSelectedFile.Text = rd.fileUpload.currentWorkingCopyRootPathFileName;      

      /*============================================================
       * Refresh controls
       *============================================================*/

      string parentName = n.Parent.Name;
      
      if (parentName == FILE_UPLOADS_UNPROCESSED)
      {      
        toolStripButtonReplaceFile.Visible = false;            
      }      
      else if (parentName == FILE_UPLOADS_REQ_REVIEW)
      {             
        toolStripButtonReplaceFile.Visible = true;       
      }      
      else if (parentName == FILE_UPLOADS_FILED)
      {
        toolStripButtonReplaceFile.Visible = false;
      }
      else
      {
        toolStripButtonReplaceFile.Visible = false;
      }

      /*============================================================
       * Refresh selected file upload object
       *============================================================*/

      this.selectedFileUpload = rd.fileUpload;
      
      /*============================================================
       * Summary 
       *============================================================*/
       
      this.richTextBoxFileSummary.Clear();
      this.richTextBoxFileSummary.ReadOnly  = true;
      this.richTextBoxFileSummary.Multiline = true;
      this.richTextBoxFileSummary.Rtf = "";
      this.richTextBoxFileSummary.Tag = rd;
      this.richTextBoxFileSummary.BackColor = Color.White;
      this.richTextBoxFileSummary.ForeColor = Color.Black;
      
      StringBuilder sb = new StringBuilder();
      
      sb.Append(@"{\rtf1\ansi");                    
      
      sb.Append(@"\b File Class : \b0 ");
      sb.Append(rd.fileUpload.fileClassName);
      sb.Append(@" \line ");
      
      sb.Append(@"\b File Sub Class : \b0 ");
      sb.Append(rd.fileUpload.fileSubClass);
      sb.Append(@" \line ");
      sb.Append(@" \par ");
      
      sb.Append(@"\b MIME Type : \b0 "); 
      if (!String.IsNullOrEmpty(rd.fileUpload.fileMimeType))     
        sb.Append(rd.fileUpload.fileMimeType.Replace(@"\",@"\\"));
      sb.Append(@" \line ");
      
      sb.Append(@"\b Size : \b0 ");
      sb.Append(rd.fileUpload.fileSize.ToString());
      sb.Append(@" \line ");
      
      sb.Append(@" \par ");
      
      sb.Append(@"\b Uploaded From : \b0 ");
      sb.Append(rd.fileUpload.fileUploadedFromName);
      sb.Append(@" \line ");

      sb.Append(@"\b Uploaded On : \b0 ");
      sb.Append(rd.fileUpload.fileUploadedOn.ToString().Replace(@"\",@"\\"));
      sb.Append(@" \line ");

      sb.Append(@"\b Uploaded By : \b0 ");
      sb.Append(rd.fileUpload.fileUploaderContactEmail);
      sb.Append(@" \line ");      
      
      sb.Append(@" \par ");           
      sb.Append("}");
      
      this.richTextBoxFileSummary.Rtf = sb.ToString();
            
      /*============================================================
       * Form data
       *============================================================*/

      foreach (FileUploadFormDataEntryLine line in rd.formDataEntryLines)
      {
        int newRowNum = dataGridViewFormData.Rows.Add();
        dataGridViewFormData.Rows[newRowNum].Cells[0].Value = line.QuestionText;
        dataGridViewFormData.Rows[newRowNum].Cells[1].Value = line.AnswerText;
        dataGridViewFormData.Rows[newRowNum].Cells[2].Value = line.AnswerValues;        
      }
     
      /*============================================================
       * Status log
       *============================================================*/

      foreach(FileUploadStatus statusLogEntry in rd.statusLog)
      {
                
        int newRowNum = dataGridViewStatusLog.Rows.Add();
        
        dataGridViewStatusLog.Rows[newRowNum].Cells[0].Value = MBA.EmbeddedResources.CommonImages.GetReturnStateImage(statusLogEntry.returnStatusCode);
        dataGridViewStatusLog.Rows[newRowNum].Cells[1].Value = statusLogEntry.createdOn.ToString();
        dataGridViewStatusLog.Rows[newRowNum].Cells[2].Value = statusLogEntry.statusCode.ToString();
        dataGridViewStatusLog.Rows[newRowNum].Cells[3].Value = statusLogEntry.statusName;
        dataGridViewStatusLog.Rows[newRowNum].Cells[4].Value = statusLogEntry.source;
        dataGridViewStatusLog.Rows[newRowNum].Cells[5].Value = statusLogEntry.destination;
        dataGridViewStatusLog.Rows[newRowNum].Cells[6].Value = statusLogEntry.note;     
      }      
    }
        
    /***************************************************************************
     * RefreshListItem */
    /**
     * 
     * 
     ****************************************************************************/     

    private void RefreshListItem (TreeNode n)
    {
      Spedmon.FileUploadReviewApp.ShowWaitForm();
      ClearSelected ();
      GetSelection(n);                                         
    }

    /***************************************************************************
     * OpenReplaceForm */
    /**
     * 
     * 
     ****************************************************************************/     
    
    private void OpenReplaceForm ()
    {
      if (FileUploadReviewApp.ValidFolderOrFileNameSelected(this.toolStripLabelSelectedFile.Text))
      {  
        FileUploadReviewAppFormReplaceFile frm = new FileUploadReviewAppFormReplaceFile( this.selectedFileUpload,this.toolStripLabelSelectedFile.Text);        
        DialogResult                       dr  = frm.ShowDialog(this);                
        if (dr == DialogResult.OK) RefreshList();      
        frm.Dispose();
      }
    }
                
    /***************************************************************************
     * Exit */
    /**
     * 
     * 
     ****************************************************************************/     

    protected void Exit()
    {
      /*----------------------------
       * Exit application
       *----------------------------*/

      Application.Exit();
    }

    private void Form1_Load (object sender, EventArgs e)
    {
       RefreshStatus();                  
       RefreshList();       
    }

    private void exitToolStripMenuItem_Click (object sender, EventArgs e)
    {
      Exit();
    }
        
    private void treeViewFileUploads_AfterSelect (object sender, TreeViewEventArgs e)
    {      
      RefreshListItem (e.Node);
    }

    private void toolStripButtonRefresh_Click (object sender, EventArgs e)
    {
      RefreshList();
    }

    private void toolStripButtonReplaceFile_Click (object sender, EventArgs e)
    {      
      OpenReplaceForm();
    }
    
    private void toolStripLabelSelectedFile_Click (object sender, EventArgs e)
    {
      FileUploadReviewApp.OpenFolderOrFile(toolStripLabelSelectedFile.Text);      
    }

    private void toolStripButtonShowUnprocessed_Click(object sender, EventArgs e)
    {
      SetTreeNodeVisibility();
    }

    private void toolStripButtonShowReview_Click(object sender, EventArgs e)
    {
      SetTreeNodeVisibility();
    }

    private void toolStripButtonShowFiled_Click(object sender, EventArgs e)
    {
      SetTreeNodeVisibility();
    }

    
  }
}
