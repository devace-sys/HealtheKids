using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Spedmon
{
  public partial class FileUploadReviewAppFormReplaceFile : Form
  {
    
    public FileUploadReviewAppFormReplaceFile (FileUpload selectedFileUpload, string selectedFile)
    {
      InitializeComponent();
     
     /*============================================================
      * Put images in controls
      *============================================================*/
     
      this.buttonCancel.Image                 = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_EXIT);
      this.buttonProceed.Image                = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PROCEED);
      this.buttonSelectReplacementFile.Image  = MBA.EmbeddedResources.CommonImages.GetImage(MBA.EmbeddedResources.CommonImages.IMAGE_NAME_FOLDER_OPEN);
       
     /*============================================================
      * Pass in constructor parms into properties
      *============================================================*/

      this.ExistingFileUpload                 = selectedFileUpload;
      this.ExistingFile                       = selectedFile;
          
     /*============================================================
      * Init state
      *============================================================*/

      this.linkLabelReplacementFile.Text      = FileUploadReviewApp.NO_FILE_SELECTED;      
      this.checkBoxReplaceFileConfirm.Checked = false;
      this.buttonProceed.Enabled              = false;

      this.openFileDialogReplacement.Multiselect                  = false;
      this.openFileDialogReplacement.SupportMultiDottedExtensions = true;
      this.openFileDialogReplacement.Title                        = "Select a replacement file for " + ExistingFile;
      this.openFileDialogReplacement.InitialDirectory             = ExistingFileUpload.reviewFiledRootPath;
      this.openFileDialogReplacement.FileName                     = "";
      CheckIfItIsOKToReplace();
    }

    protected FileUpload _ExistingFileUpload;
    protected FileUpload _ReplacementFileUpload;
    
    public FileUpload ExistingFileUpload     { get { return this._ExistingFileUpload;                } set { this._ExistingFileUpload                = value; } }
    public string     ExistingFile           { get { return this.linkLabelSelectedFile.Text;         } set { this.linkLabelSelectedFile.Text         = value; } }
    public string     ReplacementFile        { get { return this.linkLabelReplacementFile.Text;      } set { this.linkLabelReplacementFile.Text      = value; } }    
    public bool       ReplaceFileConfirm     { get { return this.checkBoxReplaceFileConfirm.Checked; } set { this.checkBoxReplaceFileConfirm.Checked = value; } }
    public FileUpload ReplacementFileUpload  { get { return this._ReplacementFileUpload;             } set { this._ReplacementFileUpload             = value; } }

    private bool IsItOKToReplace()
    {
      if (!FileUploadReviewApp.ValidFolderOrFileNameSelected(linkLabelSelectedFile.Text))    return false;
      if (!FileUploadReviewApp.ValidFolderOrFileNameSelected(linkLabelReplacementFile.Text)) return false;      
      if (checkBoxReplaceFileConfirm.Checked == false)                                       return false;
      return true;
    } 
       
    private void CheckIfItIsOKToReplace ()
    {
      this.buttonProceed.Enabled = false;
      if (IsItOKToReplace() == false) return;      
      this.buttonProceed.Enabled = true;
    }

    private void SelectReplacementFile()
    {
      DialogResult dr = this.openFileDialogReplacement.ShowDialog();
      string oldReplacementFile = linkLabelReplacementFile.Text;
            
      if (dr == DialogResult.OK)
      {
        linkLabelReplacementFile.Text = this.openFileDialogReplacement.FileName;
      }
      else if (dr == DialogResult.Cancel)
      {
        linkLabelReplacementFile.Text = oldReplacementFile;
      }
      
      CheckIfItIsOKToReplace ();
    }
    
    private void buttonSelectReplacementFile_Click(object sender, EventArgs e)
    {
      SelectReplacementFile();
    }

    private void linkLabelSelectedFile_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      FileUploadReviewApp.OpenFolderOrFile(this.linkLabelSelectedFile.Text);           
    }

    private void linkLabelReplacementFile_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
    {
      if (FileUploadReviewApp.ValidFolderOrFileNameSelected(this.linkLabelReplacementFile.Text) == false)
      {
        SelectReplacementFile();
        return;        
      }
      FileUploadReviewApp.OpenFolderOrFile(this.linkLabelReplacementFile.Text);
    }

    private void buttonProceed_Click(object sender, EventArgs e)
    {          
      if (IsItOKToReplace() == true)
      {
        Spedmon.FileUploadReviewApp.ShowWaitForm();
        this.buttonProceed.Enabled = false;
        this.buttonCancel.Enabled  = false;
        
        FileUploadReviewApp.replaceFile(  this.ExistingFileUpload.id
                                        , ExistingFileUpload
                                        , this.linkLabelReplacementFile.Text);                                        
      }
    }

    private void checkBoxReplaceFileConfirm_CheckedChanged(object sender, EventArgs e)
    {
      CheckIfItIsOKToReplace();
    }

    private void buttonCancel_Click(object sender, EventArgs e)
    {
      
    }
    
  }
}
