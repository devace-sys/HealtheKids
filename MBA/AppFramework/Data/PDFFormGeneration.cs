using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections.ObjectModel;
using System.Web;
using System.IO;

using MBA.IdentifyData;
using MBA.Reporting;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;
using System.Text.RegularExpressions;

namespace MBA
{


  /***************************************************************************
   * PDFFormGenerationGenerateHeaderCallBack */
  /**
   * 
   ***************************************************************************/
       
  public delegate void PDFFormGenerationGenerateHeaderCallBack (ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict);
    
 
  /***************************************************************************
   * PDFFormGenerationGenerateFooterCallBack */
  /**
   * 
   ***************************************************************************/
       
  public delegate void PDFFormGenerationGenerateFooterCallBack (ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict);
  
    /***************************************************************************
     * PDFFormGeneration */
    /**
     * 
     ***************************************************************************/

    public class PDFFormGeneration
    {
        // ************************************************************************************************************************************************************************** //
        // ************************************************************************* Ary's Code Starts Here ************************************************************************* //
        // ************************************************************************************************************************************************************************** //

        // constants for this PDF section, needs to be moved to the proper place
        public static class Constants
        {
            public static Font defaultPDFFont = new Font(Font.HELVETICA, 8);
            public static int defaultPadding = 10;
            public static int defaultSignaturePadding = 12;
            public static int numTableColsBase24 = 24;
            public static int numColsBase12 = 12;
            public static int numColsBaseSix = 6;
            public static int maxCharsPerLine = 125;
            public static int maxCharsPerHalfLine = 80;
            public static int maxCharsPerLineForCheckboxRadio = 160;
            public static int maxCharsPerLineForTopSignatures = 37;
            public static int maxCharsPerLineForBottomSignatures = 50;
            public static int maxCharsPerLineForHeaderFields = 20;
            public static int numSignatureLinesInHeader = 12;
            public static float checkboxRadioPadding = 10f;
            public static float defaultFormFieldPadding = 0;
            public static float defaultTextFieldHeight = 6.5f;
            public static float defaultTextFieldHeightMultiline = 7f;
        }


        // The following two classes are used to mimick the JSON object that comes out of the form builder plugin
        public class TelecommFormQuestionsValuesObj
        {
            public string label;
            public string value;
            public bool selected;
        }


        class FormBuilderQuestionsJSONFormFieldObj
        {
            public string type;
            public string required;
            public bool inline;
            public string name;
            public bool access;
            public string other;
            public string label; // for headers
            public string subtype; // for header
            public string style; // for button
            public bool multiple; // for select
            public TelecommFormQuestionsValuesObj[] values;
        }


        /**************************************************************************
        * GetFormFieldExportValue */
        /**
        * Dynamically finds the export value of a form field
        * 
        * This function is not necessary if the form field export values in the PDF match the form field values in the HTML
        * 
        * source: https://stackoverflow.com/a/21702865
        *
        ***************************************************************************/
        static string GetFormFieldExportValue(AcroFields fields, string cbFieldName)
        {
            AcroFields.Item item = fields.GetFieldItem(cbFieldName);
            if (item.values.Count > 0)
            {
                PdfDictionary valueDict = item.values[0] as PdfDictionary;
                PdfDictionary appDict = valueDict.GetAsDict(PdfName.AP);

                if (appDict != null)
                {
                    PdfDictionary normalApp = appDict.GetAsDict(PdfName.N);

                    foreach (PdfName curKey in normalApp.Keys)
                    {
                        if (!PdfName.OFF.Equals(curKey))
                        {
                            // string will have a leading '/' character
                            return curKey.ToString().Trim('/');
                        }
                    }
                }

                PdfName curVal = valueDict.GetAsName(PdfName.AS);
                if (curVal != null)
                {
                    return curVal.ToString();
                }

            }

            return null;
        }

        /**************************************************************************
        * savedAnswersJsonToDict */
        /**
        * Turns a JSON string into a dictionary
        *
        ***************************************************************************/
        public static Dictionary<String, String> savedAnswersJsonToDict(string savedAnswersJSON)
        {
            return MBA.JSON.dictFromJSONString(savedAnswersJSON);
        }

        /**************************************************************************
        * insertAnswersToPdf */
        /**
        * fills out a set of form fields in a PDF file based on the key value pairs in the input Dictionary 'savedAnswers'
        *
        ***************************************************************************/
        public static MemoryStream insertAnswersToPdf(ref System.IO.MemoryStream ms, Dictionary<String, String> savedAnswers)
        {
            // create an instance of the file
            var reader = new PdfReader((byte[])ms.ToArray());

            // memory stream to store our bytes
            MemoryStream mem_stream = new MemoryStream();

            // This is the object used to modify form fields
            var stamper = new PdfStamper(reader, mem_stream);

            // insert answers to form fields in PDF
            foreach (KeyValuePair<string, string> savedAnswer in savedAnswers)
            {
                try
                {
                    if (stamper.AcroFields != null)
                    {
                        stamper.AcroFields.GenerateAppearances = true;

                        foreach (var field in stamper.AcroFields.Fields)
                        {
                            stamper.AcroFields.SetField(savedAnswer.Key, savedAnswer.Value);
                        }

                        stamper.FormFlattening = true;
                    }
                    //stamper.AcroFields.SetField(savedAnswer.Key, savedAnswer.Value);
                }
                catch (Exception e)
                {

                }
            }

            // Form fields should no longer be editable
            //stamper.FormFlattening = true;
            //stamper.AcroFields.GenerateAppearances = true;

            stamper.Close();
            reader.Close();

            return mem_stream;
        }
        
        /**************************************************************************
        * generateAcroFieldAppearances */
        /**
        * closes the docukent and generates appearances for form fields in a PDF
        *
        ***************************************************************************/
        public static void generateAcroFieldAppearances(ref System.IO.MemoryStream ms, ref iTextSharp.text.Document doc)
        {
            // close the document first
            doc.Close();

            // create an instance of the file
            var reader = new PdfReader((byte[])ms.ToArray());

            // memory stream to store our bytes
            MemoryStream mem_stream = new MemoryStream();

            // This is the object used to modify form fields
            var stamper = new PdfStamper(reader, mem_stream);

            // Form fields should no longer be editable
            if (stamper.AcroFields != null)
            {
                try
                {
                    stamper.AcroFields.GenerateAppearances = true;
                    stamper.FormFlattening = true;
                } catch (Exception e)
                {

                }
            }

            stamper.Close();
            reader.Close();

            ms = new MemoryStream(mem_stream.ToArray());

            return;
        }

        /**************************************************************************
        * setCellEvent */
        /**
        * sets the event of a cell to a form field
        *
        * source:https://stackoverflow.com/a/2676638
        * 
        ***************************************************************************/
        static void setCellEvent(PdfWriter writer, ref PdfPCell cell, PdfFormField formField, float padding)
        {
            iTextSharp.text.pdf.events.FieldPositioningEvents events = new iTextSharp.text.pdf.events.FieldPositioningEvents(writer, formField);
            events.Padding = padding;
            cell.CellEvent = events; // TODO: maybe we need a new generateCell function that does this
        }

        /**************************************************************************
        * generateSpaceCell */
        /**
        * generates an empty cell to act as space between the lines
        *
        ***************************************************************************/
        public static PdfPCell generateSpaceCell(int colsPerRow)
        {
            PdfPCell spaceCell = PDFCommon.generateCell(
                                              ""
                                            , 1
                                            , colsPerRow
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_NONE
                                            , 1
                                            , ref Constants.defaultPDFFont);
            // set height
            spaceCell.FixedHeight = 2.5f;

            return spaceCell;
        }

        /**************************************************************************
        * generateLineBreakCell */
        /**
        * generates an empty cell to act as \n. The returned cell has a height of 0
        *
        ***************************************************************************/
        public static PdfPCell generateLineBreakCell(int colsPerRow)
        {
            PdfPCell breakLineCell = PDFCommon.generateCell(
                                              ""
                                            , 1
                                            , colsPerRow
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_NONE
                                            , 1
                                            , ref Constants.defaultPDFFont);
            // set height
            breakLineCell.FixedHeight = 0f;

            return breakLineCell;
        }

        /**********************************************************************************************************************************************************************
        *  TEXT FIELD 
        *  sources: https://simpledotnetsolutions.wordpress.com/2012/11/01/itextsharp-creating-form-fields/
        *           https://stackoverflow.com/a/2676638
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * addTextFieldCell */
        /**
        * adds a textfield to a table cell
        *
        ***************************************************************************/
        public static void addTextFieldCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, int labelColSpan, int fieldColSpan, int horizontalAlignment, int fieldBorders, int padding, int maxCharsPerLine, bool resizeCellIfNeeded, bool generateSpaceCellAfter, bool generateSpaceCellBefore, int colsPerRow, Dictionary<string, string> savedAnswersDict)
        {
            // validate that maxCharsPerLine is not zero or negative because it will be a divisor in a division
            if (maxCharsPerLine < 1)
            {
                maxCharsPerLine = Constants.maxCharsPerLine;
            }

            // see if field has a label
            bool hasLabel = !String.IsNullOrEmpty(label);

            // set the font used for the text field
            Font labelFont = Constants.defaultPDFFont;
            // a font for the textcell, size is 0 so the cell decides what size it should be
            Font fieldFont = Constants.defaultPDFFont;

            // create the textfield
            TextField textField = new TextField(writer, new Rectangle(10, 10), fieldName);
            textField.Alignment = Element.ALIGN_LEFT;
            textField.Text = "";
            textField.FontSize = 7;
            //textField.Alignment = Element.ALIGN_BOTTOM;

            // generate space if needed
            if (generateSpaceCellBefore)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            // generate label cell if needed
            if (hasLabel)
            {
                // add label for field
                PdfPCell labelCell = PDFCommon.generateCell(
                                          label
                                        , 1
                                        , labelColSpan
                                        , horizontalAlignment
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 0
                                        , ref labelFont);

                // add label cell to cells array
                cells.Add(labelCell);
                // if label is a whole line, we need a bit of space below it right before the box, otherwise they will be too close to each other
                if (labelColSpan == colsPerRow)
                {
                    cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells

                }

            }

            // generate a cell for the field
            PdfPCell textFieldCell = PDFCommon.generateCell(
                                              ""
                                            , 1
                                            , fieldColSpan
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , fieldBorders
                                            , padding
                                            , ref fieldFont);

            textFieldCell.FixedHeight = Constants.defaultTextFieldHeight;

            string fieldVal; // needed for validation below

            // if the content cannot fit on one line, we need to make the textfiel multiline and increase the height & padding if needed
            if ((savedAnswersDict != null) &&
                (savedAnswersDict.ContainsKey(fieldName)) &&
                (savedAnswersDict.TryGetValue(fieldName, out fieldVal)) &&
                (!String.IsNullOrEmpty(fieldVal)))
            {
                if (fieldVal.Length > maxCharsPerLine || fieldVal.Contains("\n"))
                {
                    // get number of line breaks so we make enough room
                    int numOfLineBreaks = 0;
                    foreach (char c in fieldVal)
                    {
                        if (c == '\n')
                        {
                            numOfLineBreaks++;
                        }
                    }

                    float numLines = (float)(((Math.Ceiling((float)(fieldVal.Length)) + (numOfLineBreaks * maxCharsPerLine)) / (float)(maxCharsPerLine)));
                    if (resizeCellIfNeeded)
                    {
                        textFieldCell.FixedHeight = Constants.defaultTextFieldHeightMultiline * numLines;
                    }

                    textField.Options = TextField.MULTILINE; // the text expands to multiple lines
                }
            }

            // set the textfield to be the table cell event
            setCellEvent(writer, ref textFieldCell, textField.GetTextField(), Constants.defaultFormFieldPadding);

            // add field cell to cells array
            cells.Add(textFieldCell);
            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
        }

        /**************************************************************************
        * addTextFieldCellAsPar */
        /**
        * adds a field with the label in the form of a paragraph
        *
        ***************************************************************************/
        public static void addTextFieldCellAsPar(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, int horizontalAlignment, int fieldBorders, int padding, int maxCharsPerLine, bool resizeCellIfNeeded, bool generateSpaceCellAfter, bool generateSpaceCellBefore, int colsPerRow, Dictionary<string, string> savedAnswersDict)
        {
            // validate that maxCharsPerLine is not zero or negative because it will be a divisor in a division
            if (maxCharsPerLine < 1)
            {
                maxCharsPerLine = Constants.maxCharsPerLine;
            }

            // see if field has a label
            bool hasLabel = !String.IsNullOrEmpty(label);

            // set the font used for the text field
            Font fieldFont = Constants.defaultPDFFont;

            // set up the label and append the answer to it if exists
            if (hasLabel)
            {
                if (label.EndsWith(":")) label += " ";
                else if (label.EndsWith(": ")) { }
                else label += ": ";
            }
            else label = "";

            string fieldVal; // needed for validation below

            // variable used to determine the column span for the field
            int colSpan = colsPerRow;

            if ((savedAnswersDict != null) &&
                (savedAnswersDict.ContainsKey(fieldName)) &&
                (savedAnswersDict.TryGetValue(fieldName, out fieldVal)) &&
                (!String.IsNullOrEmpty(fieldVal)))
            {
                label += fieldVal;
            }

            // Update the columns span if the field only needs half of the line
            if (label.Length <= Constants.maxCharsPerHalfLine)
            {
                colSpan = colsPerRow / 2;
            }
            else
            {
                cells.Add(generateLineBreakCell(colsPerRow));
            }

            // generate a cell for the field
            addParagraphCell(writer, ref cells, label, null, colSpan, Rectangle.ALIGN_MIDDLE, generateSpaceCellBefore, generateSpaceCellAfter, colsPerRow);

            //// if the content cannot fit on one line, we need to make the textfiel multiline and increase the height & padding if needed
            //if ((savedAnswersDict != null) &&
            //    (savedAnswersDict.ContainsKey(fieldName)) &&
            //    (savedAnswersDict.TryGetValue(fieldName, out fieldVal)) &&
            //    (!String.IsNullOrEmpty(fieldVal)))
            //{
            //    fieldVal
            //    if (fieldVal.Length > maxCharsPerLine || fieldVal.Contains("\n"))
            //    {
            //        // get number of line breaks so we make enough room
            //        int numOfLineBreaks = 0;
            //        foreach (char c in fieldVal)
            //        {
            //            if (c == '\n')
            //            {
            //                numOfLineBreaks++;
            //            }
            //        }

            //        float numLines = (float)(((Math.Ceiling((float)(fieldVal.Length)) + (numOfLineBreaks * maxCharsPerLine)) / (float)(maxCharsPerLine)));
            //        if (resizeCellIfNeeded)
            //        {
            //            textFieldCell.FixedHeight = Constants.defaultTextFieldHeightMultiline * numLines;
            //        }

            //        textField.Options = TextField.MULTILINE; // the text expands to multiple lines
            //    }
            //}

            // set the textfield to be the table cell event
            //setCellEvent(writer, ref textFieldCell, textField.GetTextField(), Constants.defaultFormFieldPadding);
        }

        /**********************************************************************************************************************************************************************
        *  RADIO FIELD 
        *  sources: https://simpledotnetsolutions.wordpress.com/2012/11/01/itextsharp-creating-form-fields/
        *           https://stackoverflow.com/a/2676638
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * generateRadioCell */
        /**
        * generates a radio button field cell
        *
        * cells are returned in (field, label) order
        * 
        ***************************************************************************/
        public static (PdfPCell, PdfPCell) generateRadioCell(PdfWriter writer, string fieldName, string fieldValue, string fieldLabel, int labelColSpan, Dictionary<string, string> savedAnswersDict)
        {
            // set the font for the radio button label
            Font labelFont = Constants.defaultPDFFont;

            // create radio button and set its appearance
            RadioCheckField radioButton = new RadioCheckField(writer, new Rectangle(10, 10), fieldName, fieldValue);
            radioButton.BorderColor = GrayColor.BLACK;
            radioButton.BackgroundColor = GrayColor.WHITE;
            radioButton.CheckType = RadioCheckField.TYPE_CIRCLE;
            radioButton.FieldName = fieldName;

            // if radio field is checked in JSON, check it in PDF
            if ((savedAnswersDict != null) &&
                (savedAnswersDict.ContainsKey(fieldName)) &&
                (savedAnswersDict[fieldName] == fieldValue))
            {
                radioButton.Checked = true;//.BackgroundColor = GrayColor.GRAYWHITE;                
            }

            // add the button to a field and add the field to the radio group
            PdfFormField radioField = radioButton.RadioField;
            //radioGroupField.AddKid(radioField);

            // generate a cell for the radio field
            PdfPCell radioCell = PDFCommon.generateCell(
                                    ""
                                    , 1
                                    , 1
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , 0
                                    , ref labelFont);

            setCellEvent(writer, ref radioCell, radioField, Constants.checkboxRadioPadding);

            // add label cell for field
            PdfPCell labelCell = PDFCommon.generateCell(
                                      fieldLabel
                                    , 1
                                    , labelColSpan
                                    , Rectangle.ALIGN_LEFT
                                    , Rectangle.ALIGN_TOP
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , 0
                                    , ref labelFont);

            // set the height of the cells
            radioCell.FixedHeight = labelCell.FixedHeight = 10f;

            if (fieldLabel.Length > Constants.maxCharsPerLineForCheckboxRadio)
            {
                float numLines = (float)(Math.Ceiling((float)(fieldLabel.Length) / (float)(Constants.maxCharsPerLineForCheckboxRadio)));
                radioCell.FixedHeight *= numLines;
            }

            return (radioCell, labelCell);
        }

        /**************************************************************************
        * addRadioGroupCells */
        /**
        * adds cells of a radio group to table cells
        *
        ***************************************************************************/
        public static void addRadioGroupCells(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, TelecommFormQuestionsValuesObj[] values, bool inline, bool generateSpaceCellBefore,  bool generateSpaceCellAfter, int colsPerRow, Dictionary<string, string> savedAnswersDict) {
            // create radio group field
            //PdfFormField radioGroupField = PdfFormField.CreateRadioButton(writer, true);
            //radioGroupField.FieldName = fieldName;

            // see if field has a label
            bool hasLabel = !String.IsNullOrEmpty(label);

            // any font used for field, this needs to be figured out later
            Font labelFont = Constants.defaultPDFFont;

            // set label colSpan based on inline
            int labelColSpan = (inline) ? ((colsPerRow / 2) - 1) : (colsPerRow - 1);

            // generate label if needed
            if (hasLabel)
            {
                // add label for field
                PdfPCell labelCell = PDFCommon.generateCell(
                                          label
                                        , 1
                                        , colsPerRow
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 0
                                        , ref labelFont);
                cells.Add(labelCell);
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            // add a radio button for each value in this radio group
            for (int i = 0; i < values.Length; i++)
            {
                // generate the radio cell and its label cell
                (PdfPCell radioCell, PdfPCell labelCell) = generateRadioCell(writer, fieldName, values[i].value, Regex.Replace(values[i].label, "<.*?>", String.Empty), labelColSpan, savedAnswersDict);

                // add field and label to cells list
                cells.Add(radioCell);
                cells.Add(labelCell);
            }

            cells.Add(generateLineBreakCell(colsPerRow));

            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            //writer.AddAnnotation(radioGroupField); // this is needed for radio fields for some reason
        }

        /**********************************************************************************************************************************************************************
        *  CHECKBOX FIELD 
        *  sources: https://simpledotnetsolutions.wordpress.com/2012/11/01/itextsharp-creating-form-fields/
        *           https://stackoverflow.com/a/2676638
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * generateCheckboxCell */
        /**
        * generates a checkbox field cell
        *
        * cells are returned in (field, label) order
        * 
        ***************************************************************************/
        public static(PdfPCell, PdfPCell) generateCheckboxCell(PdfWriter writer, string fieldName, string fieldValue, string fieldLabel, int labelColSpan, int? index, Dictionary<string, string> savedAnswersDict)
        {
            // set font used for this checkbox
            Font labelFont = Constants.defaultPDFFont;

            // generate a checkbox and set its appearance
            RadioCheckField checkbox = new RadioCheckField(writer, new Rectangle(10, 10), fieldName, fieldValue);
            checkbox.BackgroundColor = GrayColor.WHITE;
            checkbox.BorderColor = GrayColor.BLACK;
            checkbox.CheckType = RadioCheckField.TYPE_CHECK;

            // if checkbox field is checked in JSON, check it in PDF
            // note that we will do a double check here to accomodate for the way formBuilder renders checkboxes
            if (index != null && index >= -1)
            {
                string modifiedFieldName = fieldName + "-" + index;

                if ((savedAnswersDict != null) &&
                (savedAnswersDict.ContainsKey(modifiedFieldName))
                /*(savedAnswersDict[modifiedFieldName] == fieldValue)*/)
                {
                    checkbox.Checked = true;//.BackgroundColor = GrayColor.GRAYWHITE;                
                }

            }

            PdfFormField checkboxField = checkbox.CheckField;

            // generate a cell for the field
            PdfPCell checkboxCell = PDFCommon.generateCell(
                                    ""
                                    , 1
                                    , 1
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , 0
                                    , ref labelFont);

            // set the event of the cell to the checkbox
            setCellEvent(writer, ref checkboxCell, checkboxField, Constants.checkboxRadioPadding);

            // add label for field
            PdfPCell labelCell = PDFCommon.generateCell(
                                      fieldLabel
                                    , 1
                                    , labelColSpan
                                    , Rectangle.ALIGN_LEFT
                                    , Rectangle.ALIGN_TOP
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , 0
                                    , ref labelFont);

            // set the height of the cells
            checkboxCell.FixedHeight = labelCell.FixedHeight = 10f;

            if (fieldLabel.Length > Constants.maxCharsPerLineForCheckboxRadio)
            {
                float numLines = (float)(Math.Ceiling((float)(fieldLabel.Length) / (float)(Constants.maxCharsPerLineForCheckboxRadio)));
                checkboxCell.FixedHeight *= numLines;
            }


            return (checkboxCell, labelCell);
        }

        /**************************************************************************
        * addCheckboxGroupCell */
        /**
        * adds a checkbox to a table cell
        *
        ***************************************************************************/
        public static void addCheckboxGroupCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, TelecommFormQuestionsValuesObj[] values, bool inline, bool generateSpaceCellBefore, bool generateSpaceCellAfter, int colsPerRow, Dictionary<string, string> savedAnswersDict)
        {
            if (generateSpaceCellBefore)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            // see if field has a label
            bool hasLabel = !String.IsNullOrEmpty(label);

            // any font used for field, this needs to be figured out later
            Font labelFont = Constants.defaultPDFFont;

            // determine column span of table
            int labelColSpan = (inline) ? ((colsPerRow / 2) - 1) : (colsPerRow - 1);

            // generate label if needed
            if (hasLabel)
            {
                // add label for field
                PdfPCell labelCell = PDFCommon.generateCell(
                                          label
                                        , 1
                                        , colsPerRow
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 0
                                        , ref labelFont);
                cells.Add(labelCell);
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            // generate a checkbox field cell for each value in this checkbox group
            for (int i = 0; i < values.Length; i++)
            {
                // generate the radio cell and its label cell
                (PdfPCell checkboxCell, PdfPCell labelCell) = generateCheckboxCell(writer, fieldName, values[i].value, Regex.Replace(values[i].label, "<.*?>", String.Empty), labelColSpan, i, savedAnswersDict);

                // add field and label to cells list
                cells.Add(checkboxCell);
                cells.Add(labelCell);
            }

            cells.Add(generateLineBreakCell(colsPerRow));

            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

        }

        /**********************************************************************************************************************************************************************
        *  SELECT BOX
        *  source: https://www.worldbestlearningcenter.com/index_files/csharp-pdf-list-combobox.htm
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * generateSelectBoxValuesArrays */
        /**
        * returns two arrays generated from labels and values in the passed in values parameter
        *
        * return arrays are in (labels, values) order
        * 
        ***************************************************************************/
        public static(string[], string[]) generateSelectBoxValuesArrays(TelecommFormQuestionsValuesObj[] values)
        {
            List<string> optionsLabelArr = new List<string>();
            List<string> optionsValArr = new List<string>();

            // populate the above lists
            foreach (var val in values)
            {
                optionsLabelArr.Add(Regex.Replace(val.label, "<.*?>", String.Empty));
                optionsValArr.Add(val.value);
            }

            return (optionsLabelArr.ToArray(), optionsValArr.ToArray());
        }

        /**************************************************************************
        * addSelectCell */
        /**
        * adds a Select field to a table cell
        * 
        ***************************************************************************/
        public static void addSelectCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, TelecommFormQuestionsValuesObj[] values, bool generateSpaceCellAfter, int colsPerRow)
        {
            // see if field has a label
            bool hasLabel = !String.IsNullOrEmpty(label);

            // any font used for field, this needs to be figured out later
            Font labelFont = Constants.defaultPDFFont;

            // create a list of labels and values for the combobox/selectbox
            (string[] optionsLabelArr, string[] optionsValArr) = generateSelectBoxValuesArrays(values);

            // set up proper variables for radio group
            TextField selectBox = new TextField(writer, new Rectangle(10, 10), fieldName);
            selectBox.Choices = optionsLabelArr;
            selectBox.ChoiceExports = optionsValArr;
            selectBox.ChoiceSelection = 1;

            // generate label if needed
            if (hasLabel)
            {
                // add label for field
                PdfPCell labelCell = PDFCommon.generateCell(
                                            label
                                        , 1
                                        , colsPerRow
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 0
                                        , ref labelFont);
                cells.Add(labelCell);
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }

            // generate a cell for the field
            PdfPCell selectCell = PDFCommon.generateCell(
                                    ""
                                    , 1
                                    , colsPerRow
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , PDFCommon.CELL_BORDERS_ALL
                                    , 10
                                    , ref labelFont);

            // set the event of the cell to the select box
            setCellEvent(writer, ref selectCell, selectBox.GetTextField(), Constants.defaultFormFieldPadding);

            // add field and label to cells list
            cells.Add(selectCell);

            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
        }

        /**********************************************************************************************************************************************************************
        *  HEADER & PARAGRAPH
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * generateHeaderFontSize */
        /**
        * return a font size based on the headerType
        * 
        * source: https://stackoverflow.com/a/30287926
        * 
        ***************************************************************************/
        static float generateHeaderFontSize(string headerType)
        {
            switch (headerType)
            {
                case "h1":
                    return 14;
                case "h2":
                    return 13;
                case "h3":
                    return 12;
                case "h4":
                    return 11;
                case "h5":
                    return 10;
                case "h6":
                    return 9;
                default:
                    return 0;
            }
        }

        /**************************************************************************
        * addHeaderCell */
        /**
        * adds a header to a table cell
        * 
        ***************************************************************************/
        public static void addHeaderCell(PdfWriter writer, ref List<PdfPCell> cells, string textContent, string headerType, int colSpan, bool generateSpaceCellAfter, bool generateSPaceCellBefore, int colsPerRow) {
            float fontSize = generateHeaderFontSize(headerType); // the font size based on the header type (h1, h2, ... , h6)

            Font headerFont = new Font(Font.HELVETICA, fontSize, Font.BOLD); // the font that will be used for the header

            // generate the cell and append it to the cells array
            PdfPCell headerCell = PDFCommon.generateCell(
                                      textContent
                                    , 1
                                    , colSpan
                                    , Rectangle.ALIGN_LEFT
                                    , Rectangle.ALIGN_MIDDLE
                                    , PDFCommon.CELL_BORDERS_NONE
                                    , 0
                                    , ref headerFont);

            // add the cells with proper spaces
            if (generateSPaceCellBefore)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
            cells.Add(headerCell);
            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
        }

        /**************************************************************************
        * addParagraphCell */
        /**
        * adds a paragraph to a table cell
        * 
        ***************************************************************************/
        public static void addParagraphCell(PdfWriter writer, ref List<PdfPCell> cells, string textContent, string parType, int colSpan, int verticalAlign, bool generateSpaceCellBefore, bool generateSpaceCellAfter, int colsPerRow) {

            // create the font that will be used for the paragraph
            Font parFont = Constants.defaultPDFFont;

            // create the paragraph
            Paragraph par = new Paragraph(textContent, parFont);

            // generate the cell and append it to the cells array
            PdfPCell parCell = PDFCommon.generateCell(
                                      par
                                    , 1
                                    , colSpan
                                    , Rectangle.ALIGN_LEFT
                                    , verticalAlign
                                    , Color.WHITE
                                    , PDFCommon.CELL_BORDERS_NONE
            );

            parCell.Padding = 1f;

            if (generateSpaceCellBefore)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
            cells.Add(parCell);
            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            }
        }

        /**********************************************************************************************************************************************************************
        *  BUTTON
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * generateButtonColor */
        /**
        * gets the right color for a button background and font color based on its style (primary, info, danger, etc)
        * 
        * return value order is (background color, font color)
        * 
        ***************************************************************************/
        static (Color, Color) generateButtonColor(string butStyle)
        {
            switch (butStyle)
            {
                case "danger":
                    return (Color.RED, Color.WHITE);
                case "info":
                    return (Color.CYAN, Color.WHITE);
                case "primary":
                    return (Color.BLUE, Color.WHITE);
                case "success":
                    return (Color.GREEN, Color.WHITE);
                case "warning":
                    return (Color.ORANGE, Color.BLACK);
                default:
                    return (Color.WHITE, Color.BLACK);
            }
        }

        /**************************************************************************
        * addButtonCell */
        /**
        * adds a button to a table cell
        * 
        ***************************************************************************/
        public static void addButtonCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, string butStyle, int colsPerRow) {

            (Color buttonColor, Color buttonFontColor) = generateButtonColor(butStyle);     // get the color of the button color and font color based on the button style       

            Font buttonFont = new Font(Font.HELVETICA, 12, 0, buttonFontColor); // the font that will be used for the button

            Paragraph buttonParagraph = new Paragraph(label, buttonFont); // a paragraph which holds the label for our button
            buttonParagraph.Alignment = Element.ALIGN_CENTER; // center align the text in the paragraph

            // generate the cell and append it to the cells array
            PdfPCell buttonCell = PDFCommon.generateCell(
                                    buttonParagraph
                                    , 1
                                    , colsPerRow / 4
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , buttonColor
                                    , PDFCommon.CELL_BORDERS_ALL);

            // create a button field
            PushbuttonField button = new PushbuttonField(writer, new Rectangle(10, 10), fieldName);

            // set the event for the cell to the button field
            setCellEvent(writer, ref buttonCell, button.Field, Constants.defaultFormFieldPadding);

            cells.Add(buttonCell);
            cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
            cells.Add(generateSpaceCell(colsPerRow)); // add a space between the cells
        }

        /**********************************************************************************************************************************************************************
        *  BARRIER
        **********************************************************************************************************************************************************************/

        /**************************************************************************
        * addBarrierCell */
        /**
        * adds a horizontal barrier to a table cell
        * 
        * Source: https://www.aspforums.net/Threads/549841/Draw-Horizontal-line-using-iTextSharp-in-ASPNet/
        * 
        ***************************************************************************/
        public static void addBarrierCell(PdfWriter writer, ref List<PdfPCell> cells, int colsPerRow)
        {
            Chunk barrierChunk = new Chunk();
            Paragraph barrierParagraph = new Paragraph(barrierChunk);            

            // generate the cell and append it to the cells array
            PdfPCell barrierCell = PDFCommon.generateCell(
                                      barrierParagraph
                                    , 1
                                    , colsPerRow
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , Color.WHITE
                                    , PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE);

            cells.Add(barrierCell);
            //cells.Add(generateSpaceCell()); // add a space between the cells
        }

        /*********************************************************************************************************************************************************************/

        /**************************************************************************
        * convertMultiSelectValsToLabels */
        /**
        * converts multiselect values to labels
        *
        ***************************************************************************/
        private static void convertMultiSelectValsToLabels(FormBuilderQuestionsJSONFormFieldObj formObj, string fieldVal, ref Dictionary<string, string> savedAnswersDict)
        {
            List<string> finalValList = new List<string>(); // the final solution with the labels of all selected values

            // remove brackets so we can parse
            fieldVal = fieldVal.Remove(fieldVal.Length - 1).Remove(0, 1).Replace("\"", "");

            // get all strings inside the value
            string[] valsArr = fieldVal.Split(',');

            // turn the value into label for each value that is selected
            foreach (string selectedVal in valsArr)
            {
                foreach (var val in formObj.values)
                {
                    if (selectedVal == val.value)
                    {
                        finalValList.Add(val.label);
                        break;
                    }
                }
            }

            savedAnswersDict[formObj.name] = string.Join(", ", finalValList);
        }

        /**************************************************************************
        * convertSelectValToLabel */
        /**
        * change select value to be the label instead of the value
        *
        ***************************************************************************/
        private static void convertSelectValToLabel(FormBuilderQuestionsJSONFormFieldObj formObj, ref Dictionary<string, string> savedAnswersDict)
        {
            // for select box, we need to choose the display value to be the label instead of the value
            // this way the text displayed as the answer will be the text for the option in the selectbox
            // instead of the value, which can be strings like 'option-1', which will not be the proper value to display
            string fieldVal; // needed for below

            // using the value in the answers dictionary, get the label for that value from the form objects 'values' array
            if ((savedAnswersDict != null) &&
                (savedAnswersDict.ContainsKey(formObj.name)) &&
                (savedAnswersDict.TryGetValue(formObj.name, out fieldVal)) &&
                (!String.IsNullOrEmpty(fieldVal)))
            {
                // multi value selection
                if (formObj.multiple && fieldVal.StartsWith("[") && fieldVal.EndsWith("]"))
                {
                    convertMultiSelectValsToLabels(formObj, fieldVal, ref savedAnswersDict);
                }
                // single value selection
                else
                {
                    foreach (var val in formObj.values)
                    {
                        if (fieldVal == val.value)
                        {
                            savedAnswersDict[formObj.name] = val.label;
                            break;
                        }
                    }
                }
            }
        }

        /**************************************************************************
        * addFormFieldCell */
        /**
        * adds a form field to a table cell
        *
        ***************************************************************************/
        static void addFormFieldCell(PdfWriter writer, iTextSharp.text.Document document, ref List<PdfPCell> bodyCells, FormBuilderQuestionsJSONFormFieldObj formObj, int borderForTextInputs, int colsPerRow, Dictionary<string, string> savedAnswersDict)
        {
            // if border not passed, default to cell_borders_all
            if (String.IsNullOrEmpty(borderForTextInputs.ToString()))
            {
                borderForTextInputs = PDFCommon.CELL_BORDERS_ALL;
            }

            // generate a cell based on the field type
            switch (formObj.type)
            {
                case "text":
                case "number":
                case "date":
                case "textarea":
                    string sanitizedLabelText = (String.IsNullOrEmpty(formObj.label)) ? null : Regex.Replace(formObj.label, "<.*?>", String.Empty);
                    addTextFieldCellAsPar(  writer
                                          , ref bodyCells
                                          , formObj.name
                                          , sanitizedLabelText
                                          , Rectangle.ALIGN_LEFT
                                          , borderForTextInputs
                                          , Constants.defaultPadding
                                          , Constants.maxCharsPerLine
                                          , true
                                          , false
                                          , false
                                          , colsPerRow
                                          , savedAnswersDict);
                    break;

                case "radio-group":
                    string sanitizedLabelRadio = (String.IsNullOrEmpty(formObj.label)) ? null : Regex.Replace(formObj.label, "<.*?>", String.Empty);
                    bodyCells.Add(generateLineBreakCell(colsPerRow));

                    addRadioGroupCells(writer, ref bodyCells, formObj.name, sanitizedLabelRadio, formObj.values, formObj.inline, true, false, colsPerRow, savedAnswersDict);
                    break;

                case "checkbox-group":
                    string sanitizedLabelCheckbox = (String.IsNullOrEmpty(formObj.label)) ? null : Regex.Replace(formObj.label, "<.*?>", String.Empty);
                    bodyCells.Add(generateLineBreakCell(colsPerRow));

                    addCheckboxGroupCell(writer, ref bodyCells, formObj.name, sanitizedLabelCheckbox, formObj.values, formObj.inline, true, false, colsPerRow, savedAnswersDict);
                    break;

                case "select":
                case "autocomplete":
                    // for select box, we need to choose the display value to be the label instead of the value
                    // this way the text displayed as the answer will be the text for the option in the selectbox
                    // instead of the value, which can be strings like 'option-1', which will not be the proper value to display

                    convertSelectValToLabel(formObj, ref savedAnswersDict);

                    string sanitizedLabelSelect = (String.IsNullOrEmpty(formObj.label)) ? null : Regex.Replace(formObj.label, "<.*?>", String.Empty);

                    addTextFieldCellAsPar(writer
                                        , ref bodyCells
                                        , formObj.name
                                        , sanitizedLabelSelect
                                        , Rectangle.ALIGN_LEFT
                                        , borderForTextInputs
                                        , Constants.defaultPadding
                                        , Constants.maxCharsPerLine
                                        , true
                                        , false
                                        , false
                                        , colsPerRow
                                        , savedAnswersDict);

                    //    addSelectCell(writer, ref bodyCells, formObj.name, HttpUtility.HtmlDecode(Regex.Replace(formObj.label, "<.*?>", String.Empty)), formObj.values, false);
                    break;

                case "header":
                    string sanitizedLabelHeader = (String.IsNullOrEmpty(formObj.label)) ? null : HttpUtility.HtmlDecode(Regex.Replace(formObj.label, "<.*?>", String.Empty));

                    bodyCells.Add(generateLineBreakCell(colsPerRow));
                    addHeaderCell(writer, ref bodyCells, sanitizedLabelHeader, formObj.subtype, colsPerRow, false, false, colsPerRow);
                    break;

                case "paragraph":
                    string sanitizedLabelPar = (String.IsNullOrEmpty(formObj.label)) ? null : HttpUtility.HtmlDecode(Regex.Replace(formObj.label, "<.*?>", String.Empty));

                    bodyCells.Add(generateLineBreakCell(colsPerRow));
                    addParagraphCell(writer, ref bodyCells, sanitizedLabelPar, formObj.subtype, colsPerRow, Rectangle.ALIGN_MIDDLE, false, false, colsPerRow);
                    break;

                case "button":
                    string sanitizedLabelBut = (String.IsNullOrEmpty(formObj.label)) ? null : HttpUtility.HtmlDecode(Regex.Replace(formObj.label, "<.*?>", String.Empty));

                    bodyCells.Add(generateLineBreakCell(colsPerRow));
                    addButtonCell(writer, ref bodyCells, formObj.name, sanitizedLabelBut, formObj.style, colsPerRow);
                    break;

                case "barrier":
                    bodyCells.Add(generateLineBreakCell(colsPerRow));
                    addBarrierCell(writer, ref bodyCells, colsPerRow);
                    break;

                default:
                    break;
            }
        }

        /**************************************************************************
        * createPDFTable */
        /**
        * creates a PDF table and appends the passed in cells to it
        *
        ***************************************************************************/
        static PdfPTable createPDFTable(List<PdfPCell> cells)
        {
            // generate the table which is supposed to mimick the bootstrap 12 column layout
            PdfPTable formTable = PDFCommon.generateTable(24, cells);
            formTable.TotalWidth = 600f;  // calculated to fit inside main table
            formTable.LockedWidth = true;
            float[] widths = new float[] { 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f, 25f };
            formTable.SetWidths(widths);
            formTable.SpacingBefore = 10;
            formTable.SpacingAfter = 10;
            return formTable;
        }

        /**************************************************************************
        * fillFormFieldsWithAnswers */
        /**
        * This function takes an input PDF file name with some form fields and answers to those form fields in a stringified JSON
        *
        * Then it writes an output PDF file identical to the input but with the form fields filled out with the answers from the JSON string 
        *
        ***************************************************************************/
        public static void insertFormFieldsToPDF(   ref PdfWriter writer
                                           , ref iTextSharp.text.Document document
                                           , ref MemoryStream ms
                                           , ref PDFFormGenerationGenerateHeaderCallBack generateHeaderCb
                                           , int colsPerRow
                                           , string questionsJSON
                                           , Dictionary<string, string> savedAnswersDict
                                           , ref PDFFormGenerationGenerateFooterCallBack generateFooterCb)
        {
            // get the answers from JSON to an object array
            FormBuilderQuestionsJSONFormFieldObj[] JSONString = Newtonsoft.Json.JsonConvert.DeserializeObject<FormBuilderQuestionsJSONFormFieldObj[]>(questionsJSON);

            // source: https://stackoverflow.com/a/2676638
            List<PdfPCell> cells = new List<PdfPCell>(); // the PDF cells go in here

            // create and open a PDF document for the fields to go inside of
            //iTextSharp.text.Document document = new iTextSharp.text.Document();
            //PdfWriter writer = PdfWriter.GetInstance(document, new FileStream("C:\\MBA\\Common\\StandAloneNet4Tools\\PdfFormTests\\PdfFormTests\\output_from_html.pdf", FileMode.Create));
            document.Open();


            // add the top of the form
            generateHeaderCb(ref writer, ref cells, savedAnswersDict);


            // add the custom form fields to the cells array from JSON object
            foreach (FormBuilderQuestionsJSONFormFieldObj formField in JSONString)
            {
                addFormFieldCell(writer, document, ref cells, formField, PDFCommon.CELL_BORDERS_ALL, colsPerRow, savedAnswersDict);
            }

            cells.Add(generateLineBreakCell(colsPerRow));


            // add the bottom of the form
            generateFooterCb(ref writer, ref cells, savedAnswersDict);
            
            // create a table, add cells to the table and add the table to the page
            PdfPTable formTable = createPDFTable(cells);
            document.Add(formTable);

            document.Close();
        }

        /**************************************************************************
        * insertFormFieldsToPDFCells */
        /**
        * This function takes an input PDF cells array with some form fields and answers to those form fields in a stringified JSON
        *
        * Then it writes form fields to the cells array
        *
        ***************************************************************************/
        public static void insertFormFieldsToPDFCells(ref PdfWriter writer
                                           , ref iTextSharp.text.Document document
                                           , ref List<PdfPCell> cells
                                           , string questionsJSON
                                           , Dictionary<String, String> answersDict
                                           , int colsPerRow)
        {
                                                
            // Attempt to get the answers from JSON to an object array
            
            FormBuilderQuestionsJSONFormFieldObj[] formQuestionsJSONArray;
            try { 
              formQuestionsJSONArray = Newtonsoft.Json.JsonConvert.DeserializeObject<FormBuilderQuestionsJSONFormFieldObj[]>(Newtonsoft.Json.JsonConvert.DeserializeObject<string>(questionsJSON));
            }

            // If that does not work try creating object array explicity (one record case)

            catch {
              formQuestionsJSONArray = new FormBuilderQuestionsJSONFormFieldObj[1];
              formQuestionsJSONArray[0] = Newtonsoft.Json.JsonConvert.DeserializeObject<FormBuilderQuestionsJSONFormFieldObj>(questionsJSON);
            }

            // add the custom form fields to the cells array from JSON object

            foreach (FormBuilderQuestionsJSONFormFieldObj formField in formQuestionsJSONArray)
            {
                addFormFieldCell(writer, document, ref cells, formField, PDFCommon.CELL_BORDERS_NONE, colsPerRow, answersDict);
            }

            cells.Add(generateLineBreakCell(colsPerRow));

        }

        /**************************************************************************
        * addTopSignatureLine */
        /**
        * used in the top part of the IEP to add a line of 2 signatures and dates
        *
        ***************************************************************************/
        //static void addTopSignatureLine(PdfWriter writer, ref List<PdfPCell> cells, string field_1_id, string field_1_label, string field_2_id, string field_2_label)
        //{
        //    addTextFieldCell(writer, ref cells, field_1_id, null, 0, 3, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addTextFieldCell(writer, ref cells, field_1_id + "_date", null, 0, 1, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addTextFieldCell(writer, ref cells, field_2_id, null, 0, 3, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addTextFieldCell(writer, ref cells, field_2_id + "_date", null, 0, 1, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);

        //    addParagraphCell(writer, ref cells, field_1_label, null, 3, Rectangle.ALIGN_TOP, false, false);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addParagraphCell(writer, ref cells, "Date", null, 1, Rectangle.ALIGN_TOP, false, false);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_TOP, false, false);
        //    addParagraphCell(writer, ref cells, field_2_label, null, 3, Rectangle.ALIGN_TOP, false, false);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addParagraphCell(writer, ref cells, "Date", null, 1, Rectangle.ALIGN_TOP, false, false);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_TOP, false, false);
        //}

        ///**************************************************************************
        //* addTemplateTopFormFields */
        ///**
        //* adds the top fields of the default PDF template
        //*
        //***************************************************************************/
        //static void addTemplateTopFormFields(PdfWriter writer, ref List<PdfPCell> cells)
        //{
        //    // add the top 2 headers
        //    addHeaderCell(writer, ref cells, "", "h6", 4, false, false);
        //    addHeaderCell(writer, ref cells, "STATE SELPA IEP TEMPLATE", "h6", 4, false, false);
        //    addHeaderCell(writer, ref cells, "", "h6", 4, false, false);
        //    addHeaderCell(writer, ref cells, "", "h6", 4, false, false);
        //    addHeaderCell(writer, ref cells, "Signature(s) and Parent Consent", "h6", 5, false, false);
        //    addHeaderCell(writer, ref cells, "", "h6", 3, false, false);
        //    //cells.Add(generateSpaceCell());


        //    // add the name, date of birth and IEP date fields
        //    addTextFieldCell(writer, ref cells, "student_name", "   Student Name", 2, 2, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addTextFieldCell(writer, ref cells, "dob", "    Date of Birth ", 2, 2, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addTextFieldCell(writer, ref cells, "iep_date", "   IEP Date ", 2, 2, Rectangle.ALIGN_MIDDLE, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    //cells.Add(generateSpaceCell());


        //    // add signature section
        //    addHeaderCell(writer, ref cells, "IEP MEETING PARTICIPANTS", "h6", 12, false, true);
        //    addTopSignatureLine(writer, ref cells, "parent_guardian_surrogate", "Parent / Guardian / Surrogate", "parent_guardian", "Parent / Guardian");
        //    addTopSignatureLine(writer, ref cells, "student_adult_student", "Student / Adult Student", "general_ed_teacher ", "General Education Teacher");
        //    addTopSignatureLine(writer, ref cells, "lea_rep", "LEA Representative/Admin. Designee", "sped_specialist ", "Special Education Specialist");
        //    addTopSignatureLine(writer, ref cells, "extra_1", "Additional Participant/Title", "extra_2", "Additional Participant/Title");
        //    addTopSignatureLine(writer, ref cells, "extra_3", "Additional Participant/Title", "extra_4", "Additional Participant/Title");
        //    addTopSignatureLine(writer, ref cells, "extra_5", "Additional Participant/Title", "extra_6", "Additional Participant/Title");
        //    addBarrierCell(writer, ref cells);

        //}

        ///**************************************************************************
        //* addSignatureSectionRadioField */
        ///**
        //* used by addBottomSignatureSection function to render radios for the different roles for the signature pieces
        //*
        //***************************************************************************/
        //static void addSignatureSectionRadioField(PdfWriter writer, ref List<PdfPCell> cells, string id, string value, string label)
        //{
        //    var (radioCell, labelCell) = generateRadioCell(writer, id, value, label, 1, null);
        //    radioCell.PaddingLeft = 50;
        //    radioCell.PaddingTop = 3;
        //    cells.Add(radioCell);
        //    cells.Add(labelCell);
        //}

        ///**************************************************************************
        //* addBottomSignatureSection */
        ///**
        //* adds the bottom signature pieces of the default PDF template
        //*
        //***************************************************************************/
        //static void addBottomSignatureSection(PdfWriter writer, ref List<PdfPCell> cells, string signatureId, string[] values, string[] labels) {

        //    // add the first line
        //    addParagraphCell(writer, ref cells, "Signature", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addTextFieldCell(writer, ref cells, signatureId, null, 0, 8, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);
        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addTextFieldCell(writer, ref cells, signatureId + "_date", null, 0, 2, Rectangle.ALIGN_LEFT, PDFCommon.CELL_BORDERS_BOTTOM_MIDDLE, false, false, null);

        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);

        //    // add radios for each value in the array
        //    for (int i = 0; i < values.Length; i++)
        //    {
        //        addSignatureSectionRadioField(writer, ref cells, signatureId + "_role", values[i], labels[i]);
        //    }

        //    addParagraphCell(writer, ref cells, "", null, 1, Rectangle.ALIGN_MIDDLE, false, false);
        //    addParagraphCell(writer, ref cells, "Date", null, 2, Rectangle.ALIGN_MIDDLE, false, false);
        //}

        ///**************************************************************************
        //* addTemplateTopFormFields */
        ///**
        //* adds the top fields of the default PDF template
        //*
        //***************************************************************************/
        //static void addTemplateBottomFormFields(PdfWriter writer, ref List<PdfPCell> cells)
        //{
        //    addBarrierCell(writer, ref cells);

        //    addHeaderCell(writer, ref cells, "Signature below is to authorize and approve the IEP", "h6", 12, false, false);

        //    addBottomSignatureSection(writer, ref cells, "signature_1", new string[] { "parent", "guardian", "surrogate", "adult" }, new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" });
        //    addBottomSignatureSection(writer, ref cells, "signature_2", new string[] { "parent", "guardian", "surrogate", "adult" }, new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" });

        //    addBarrierCell(writer, ref cells);

        //    addParagraphCell(writer, ref cells, "If my child is or may become eligible for public benefits (Medi-Cal): I authorize the LEA/district to release student information for the limited purpose of billing Medi-Cal/Medicaid and to access Medi-Cal: health insurance benefits for applicable services.", null, 12, Rectangle.ALIGN_MIDDLE, false, true);
        //    addBottomSignatureSection(writer, ref cells, "signature_3", new string[] { "parent", "guardian", "surrogate", "adult" }, new string[] { "Parent", "Guardian", "Surrogate", "Adult Student" });
        //    //cells.Add(generateSpaceCell());
        //}

        /**************************************************************************
         * generateDocument*/
        /**
         * 
         ***************************************************************************/
        public static ReturnFileBytes generateDocument (  string filename
                                                        , PDFFormGenerationGenerateHeaderCallBack generateHeaderCb
                                                        , int colsPerRow
                                                        , string contentQuestionsJSON
                                                        , string contentAnswersJSON
                                                        , PDFFormGenerationGenerateFooterCallBack generateFooterCb) 
        {
      
          ReturnFileBytes rd = new ReturnFileBytes();
      
          rd.contentType     = @"application/pdf";
          rd.fileName        = @"emptyfile";
          rd.fileBytes       = null;
      
          MemoryStream  ms     = new MemoryStream();
          iTextSharp.text.Document doc = new iTextSharp.text.Document(PDFCommon.ORIENTATION_PORTRAIT
                                                                      , 1f
                                                                      , 1f
                                                                      , 1f
                                                                      , 10f);

          PdfWriter writer = PdfWriter.GetInstance(doc, ms);

          writer.CloseStream = false;

          // get a dictionary of our answers
          var savedAnswersDict = savedAnswersJsonToDict(contentAnswersJSON);

          // add form questions to PDF file
          insertFormFieldsToPDF( ref writer
                               , ref doc
                               , ref ms
                               , ref generateHeaderCb
                               , colsPerRow
                               , contentQuestionsJSON
                               , savedAnswersDict
                               , ref generateFooterCb);

          // add answers to PDF file
          MemoryStream mem_stream  = insertAnswersToPdf(ref ms, savedAnswersDict);

          writer.CloseStream = true;

          /*-------------------------------
            * Build a byte array from the
            * document and return it
            *------------------------------*/

          rd.fileName  = File.GenerateFileName(filename,"pdf");	    
          rd.fileBytes = mem_stream.ToArray();

          return rd;		
    
        }

  }
}
