using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using MBA;

namespace PdfFormTests
{

    /***************************************************************************
     * PDFFormGenerationGenerateHeaderCallBack */
    /**
     * 
     ***************************************************************************/

    public delegate void PDFFormGenerationGenerateHeaderCallBack(ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict);


    /***************************************************************************
     * PDFFormGenerationGenerateFooterCallBack */
    /**
     * 
     ***************************************************************************/

    public delegate void PDFFormGenerationGenerateFooterCallBack(ref PdfWriter writer, ref List<PdfPCell> cells, Dictionary<string, string> answersDict);

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
            public static int numTableCols = 24;
            public static int maxCharsPerLine = 125;
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


        class TelecommFormQuestionsJSONFormFieldObj
        {
            public string type;
            public string required;
            public string inline;
            public string name;
            public bool access;
            public string other;
            public string label; // for headers
            public string subtype; // for header
            public string style; // for button
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
        static Dictionary<String, String> savedAnswersJsonToDict(string savedAnswersJSON)
        {
            return MBA.JSON.dictFromJSONString(savedAnswersJSON);
        }

        /**************************************************************************
        * insertAnswersToPdf */
        /**
        * fills out a set of form fields in a PDF file based on the key value pairs in the input Dictionary 'savedAnswers'
        *
        ***************************************************************************/
        static MemoryStream insertAnswersToPdf(ref System.IO.MemoryStream ms, Dictionary<String, String> savedAnswers)
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
                    stamper.AcroFields.SetField(savedAnswer.Key, savedAnswer.Value);
                }
                catch (Exception e)
                {

                }
            }

            // Form fields should no longer be editable
            stamper.FormFlattening = true;
            stamper.AcroFields.GenerateAppearances = true;

            stamper.Close();
            reader.Close();

            return mem_stream;
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
        public static PdfPCell generateSpaceCell()
        {
            PdfPCell spaceCell = PDFCommon.generateCell(
                                              ""
                                            , 1
                                            , Constants.numTableCols
                                            , Rectangle.ALIGN_LEFT
                                            , Rectangle.ALIGN_MIDDLE
                                            , PDFCommon.CELL_BORDERS_NONE
                                            , 1
                                            , ref Constants.defaultPDFFont);
            // set height
            spaceCell.FixedHeight = 2.5f;

            return spaceCell;
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
        public static void addTextFieldCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, int labelColSpan, int fieldColSpan, int horizontalAlignment, int fieldBorders, int padding, int maxCharsPerLine, bool resizeCellIfNeeded, bool generateSpaceCellAfter, bool generateSpaceCellBefore, Dictionary<string, string> savedAnswersDict)
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
                cells.Add(generateSpaceCell()); // add a space between the cells
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
                if (labelColSpan == Constants.numTableCols)
                {
                    cells.Add(generateSpaceCell()); // add a space between the cells

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
                cells.Add(generateSpaceCell()); // add a space between the cells
            }
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
        public static void addRadioGroupCells(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, TelecommFormQuestionsValuesObj[] values, bool generateSpaceCellBefore, bool generateSpaceCellAfter, Dictionary<string, string> savedAnswersDict)
        {
            // create radio group field
            //PdfFormField radioGroupField = PdfFormField.CreateRadioButton(writer, true);
            //radioGroupField.FieldName = fieldName;

            // add a radio button for each value in this radio group
            for (int i = 0; i < values.Length; i++)
            {
                // generate the radio cell and its label cell
                (PdfPCell radioCell, PdfPCell labelCell) = generateRadioCell(writer, fieldName, values[i].value, values[i].label, Constants.numTableCols - 1, savedAnswersDict);

                if (generateSpaceCellBefore)
                {
                    cells.Add(generateSpaceCell()); // add a space between the cells
                }

                // add field and label to cells list
                cells.Add(radioCell);
                cells.Add(labelCell);
            }

            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
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
        public static (PdfPCell, PdfPCell) generateCheckboxCell(PdfWriter writer, string fieldName, string fieldValue, string fieldLabel)
        {
            // set font used for this checkbox
            Font labelFont = Constants.defaultPDFFont;

            // generate a checkbox and set its appearance
            RadioCheckField checkbox = new RadioCheckField(writer, new Rectangle(10, 10), fieldName, fieldValue);
            checkbox.BackgroundColor = GrayColor.WHITE;
            checkbox.BorderColor = GrayColor.BLACK;
            checkbox.CheckType = RadioCheckField.TYPE_CHECK;
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
                                    , Constants.numTableCols - 1
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
        public static void addCheckboxGroupCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, TelecommFormQuestionsValuesObj[] values, bool generateSpaceCellBefore, bool generateSpaceCellAfter)
        {
            if (generateSpaceCellBefore)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
            }

            // generate a checkbox field cell for each value in this checkbox group
            for (int i = 0; i < values.Length; i++)
            {
                // generate the radio cell and its label cell
                (PdfPCell checkboxCell, PdfPCell labelCell) = generateCheckboxCell(writer, fieldName, values[i].value, values[i].label);

                // add field and label to cells list
                cells.Add(checkboxCell);
                cells.Add(labelCell);
            }

            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
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
        public static (string[], string[]) generateSelectBoxValuesArrays(TelecommFormQuestionsValuesObj[] values)
        {
            List<string> optionsLabelArr = new List<string>();
            List<string> optionsValArr = new List<string>();

            // populate the above lists
            foreach (var val in values)
            {
                optionsLabelArr.Add(val.label);
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
        public static void addSelectCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, TelecommFormQuestionsValuesObj[] values, bool generateSpaceCellAfter)
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
                                        , Constants.numTableCols
                                        , Rectangle.ALIGN_LEFT
                                        , Rectangle.ALIGN_MIDDLE
                                        , PDFCommon.CELL_BORDERS_NONE
                                        , 0
                                        , ref labelFont);
                cells.Add(labelCell);
                cells.Add(generateSpaceCell()); // add a space between the cells
            }

            // generate a cell for the field
            PdfPCell selectCell = PDFCommon.generateCell(
                                    ""
                                    , 1
                                    , Constants.numTableCols
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
                cells.Add(generateSpaceCell()); // add a space between the cells
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
        public static void addHeaderCell(PdfWriter writer, ref List<PdfPCell> cells, string textContent, string headerType, int colSpan, bool generateSpaceCellAfter, bool generateSPaceCellBefore)
        {
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
                cells.Add(generateSpaceCell()); // add a space between the cells
                cells.Add(generateSpaceCell()); // add a space between the cells
            }
            cells.Add(headerCell);
            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
            }
        }

        /**************************************************************************
        * addParagraphCell */
        /**
        * adds a paragraph to a table cell
        * 
        ***************************************************************************/
        public static void addParagraphCell(PdfWriter writer, ref List<PdfPCell> cells, string textContent, string parType, int colSpan, int verticalAlign, bool generateSpaceCellBefore, bool generateSpaceCellAfter)
        {

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

            if (generateSpaceCellBefore)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
            }
            cells.Add(parCell);
            if (generateSpaceCellAfter)
            {
                cells.Add(generateSpaceCell()); // add a space between the cells
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
        public static void addButtonCell(PdfWriter writer, ref List<PdfPCell> cells, string fieldName, string label, string butStyle)
        {

            (Color buttonColor, Color buttonFontColor) = generateButtonColor(butStyle);     // get the color of the button color and font color based on the button style       

            Font buttonFont = new Font(Font.HELVETICA, 12, 0, buttonFontColor); // the font that will be used for the button

            Paragraph buttonParagraph = new Paragraph(label, buttonFont); // a paragraph which holds the label for our button
            buttonParagraph.Alignment = Element.ALIGN_CENTER; // center align the text in the paragraph

            // generate the cell and append it to the cells array
            PdfPCell buttonCell = PDFCommon.generateCell(
                                    buttonParagraph
                                    , 1
                                    , Constants.numTableCols / 4
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , buttonColor
                                    , PDFCommon.CELL_BORDERS_ALL);

            // create a button field
            PushbuttonField button = new PushbuttonField(writer, new Rectangle(10, 10), fieldName);

            // set the event for the cell to the button field
            setCellEvent(writer, ref buttonCell, button.Field, Constants.defaultFormFieldPadding);

            cells.Add(buttonCell);
            cells.Add(generateSpaceCell()); // add a space between the cells
            cells.Add(generateSpaceCell()); // add a space between the cells
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
        public static void addBarrierCell(PdfWriter writer, ref List<PdfPCell> cells)
        {
            Paragraph barrierParagraph = new Paragraph(new Chunk(new iTextSharp.text.pdf.draw.LineSeparator(0.0F, 100.0F, Color.BLACK, Element.ALIGN_LEFT, 1)));

            // generate the cell and append it to the cells array
            PdfPCell barrierCell = PDFCommon.generateCell(
                                      barrierParagraph
                                    , 1
                                    , Constants.numTableCols
                                    , Rectangle.ALIGN_MIDDLE
                                    , Rectangle.ALIGN_MIDDLE
                                    , Color.WHITE
                                    , PDFCommon.CELL_BORDERS_NONE);

            cells.Add(barrierCell);
            //cells.Add(generateSpaceCell()); // add a space between the cells
        }

        /*********************************************************************************************************************************************************************/

        /**************************************************************************
        * addFormFieldCell */
        /**
        * adds a form field to a table cell
        *
        ***************************************************************************/
        static void addFormFieldCell(PdfWriter writer, iTextSharp.text.Document document, ref List<PdfPCell> bodyCells, TelecommFormQuestionsJSONFormFieldObj formObj, Dictionary<string, string> savedAnswersDict)
        {
            // generate a cell based on the field type
            switch (formObj.type)
            {
                case "text":
                case "number":
                case "date":
                case "textarea":
                    addTextFieldCell(writer
                                     , ref bodyCells
                                     , formObj.name
                                     , formObj.label
                                     , Constants.numTableCols
                                     , Constants.numTableCols
                                     , Rectangle.ALIGN_LEFT
                                     , PDFCommon.CELL_BORDERS_ALL
                                     , Constants.defaultPadding
                                     , Constants.maxCharsPerLine
                                     , true
                                     , false
                                     , true
                                     , savedAnswersDict);
                    break;

                case "radio-group":
                    addRadioGroupCells(writer, ref bodyCells, formObj.name, formObj.values, true, false, savedAnswersDict);
                    break;

                case "checkbox-group":
                    addCheckboxGroupCell(writer, ref bodyCells, formObj.name, formObj.values, true, false);
                    break;

                case "select":
                    addSelectCell(writer, ref bodyCells, formObj.name, formObj.label, formObj.values, false);
                    break;

                case "header":
                    addHeaderCell(writer, ref bodyCells, formObj.label, formObj.subtype, Constants.numTableCols, false, true);
                    break;

                case "paragraph":
                    addParagraphCell(writer, ref bodyCells, formObj.label, formObj.subtype, Constants.numTableCols, Rectangle.ALIGN_TOP, false, false);
                    break;

                case "button":
                    addButtonCell(writer, ref bodyCells, formObj.name, formObj.label, formObj.style);
                    break;

                case "barrier":
                    addBarrierCell(writer, ref bodyCells);
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
        static void insertFormFieldsToPDF(ref PdfWriter writer
                                           , ref iTextSharp.text.Document document
                                           , ref MemoryStream ms
                                           , ref PDFFormGenerationGenerateHeaderCallBack generateHeaderCb
                                           , string questionsJSON
                                           , Dictionary<string, string> savedAnswersDict
                                           , ref PDFFormGenerationGenerateFooterCallBack generateFooterCb)
        {
            // get the answers from JSON to an object array
            TelecommFormQuestionsJSONFormFieldObj[] JSONString = Newtonsoft.Json.JsonConvert.DeserializeObject<TelecommFormQuestionsJSONFormFieldObj[]>(questionsJSON);

            // source: https://stackoverflow.com/a/2676638
            List<PdfPCell> cells = new List<PdfPCell>(); // the PDF cells go in here

            // create and open a PDF document for the fields to go inside of
            //iTextSharp.text.Document document = new iTextSharp.text.Document();
            //PdfWriter writer = PdfWriter.GetInstance(document, new FileStream("C:\\MBA\\Common\\StandAloneNet4Tools\\PdfFormTests\\PdfFormTests\\output_from_html.pdf", FileMode.Create));
            document.Open();


            // add the top of the form
            generateHeaderCb(ref writer, ref cells, savedAnswersDict);


            // add the custp, form fields to the cells array from JSON object
            foreach (TelecommFormQuestionsJSONFormFieldObj formField in JSONString)
            {
                addFormFieldCell(writer, document, ref cells, formField, savedAnswersDict);
            }

            // add the bottom of the form
            generateFooterCb(ref writer, ref cells, savedAnswersDict);

            // create a table, add cells to the table and add the table to the page
            PdfPTable formTable = createPDFTable(cells);
            document.Add(formTable);

            document.Close();
        }

        /*
            This function takes an input PDF file name with some form fields and answers to those form fields in a stringified JSON. 
            Then it writes an output PDF file identical to the input but with the form fields filled out with the answers from the JSON string 
        */
        static void fillFormFieldsWithAnswers(string inputFilePathName, string outputFilePathName, string savedAnswersJSON, string questionsJSON)
        {
            // get the answers from JSON to an object array
            TelecommFormQuestionsJSONFormFieldObj[] JSONString = Newtonsoft.Json.JsonConvert.DeserializeObject<TelecommFormQuestionsJSONFormFieldObj[]>(questionsJSON);


            // get a dictionary of our answers
            var savedAnswersDict = savedAnswersJsonToDict(savedAnswersJSON);

            // source: https://stackoverflow.com/a/2676638
            List<PdfPCell> bodyCells = new List<PdfPCell>(); // the PDF cells go in here

            // create and open a PDF document for the fields to go inside of
            iTextSharp.text.Document document = new iTextSharp.text.Document();
            PdfWriter writer = PdfWriter.GetInstance(document, new FileStream("C:\\MBA\\Common\\StandAloneNet4Tools\\PdfFormTests\\PdfFormTests\\output_from_html.pdf", FileMode.Create));
            document.Open();


            // add the form fields to the cells array from JSON object
            foreach (TelecommFormQuestionsJSONFormFieldObj formField in JSONString)
            {
                addFormFieldCell(writer, document, ref bodyCells, formField, savedAnswersDict);
            }

            // create a table, add cells to the table and add the table to the page
            PdfPTable formTable = createPDFTable(bodyCells);
            document.Add(formTable);

            document.Close();


            // populate the pdf with the user's answers
            //insertAnswersToPdf(inputFilePathName, outputFilePathName, savedAnswersDict);
        }
        static void Main(string[] args)
        {
            Console.WriteLine("PDF Form Tests");
            //var savedAnswersJSON = @"{""agree_to_iep"":""partial"",""partial_agree_exceptions"":""All of it"",""eligible_for_sped"":""no-longer"",""rec_assessment"":""yes"",""rec_proc_safeguards"":""yes"",""rec_iep_plan"":""yes"",""rec_protections"":""yes"",""improve"":""yes""}";
            var savedAnswersJSON = @"{""stuff"":""good"", ""agreement"":""agree"", ""stuff_text"":""I am just text inside a textbox!"", ""numberStuff"":""5"", ""selectStuff"":""option-1"", ""dateStuff"":""02/02/2020""}";
            var questionsJSON = @"[
                              {
                                ""type"": ""radio-group"",
                                ""required"": false,
                                ""inline"": false,
                                ""name"": ""stuff"",
                                ""access"": false,
                                ""other"": false,
                                ""values"": [
                                  {
                                    ""label"": ""Good stuff"",
                                    ""value"": ""good""
                                  },
                                  {
                                    ""label"": ""Bad stuff"",
                                    ""value"": ""bad""
                                  },
                                  {
                                    ""label"": ""Neutral stuff"",
                                    ""value"": ""neutral""
                                  }
                                ]
                              },
                              {
                                ""type"": ""checkbox-group"",
                                ""required"": false,
                                ""toggle"": false,
                                ""inline"": false,
                                ""name"": ""agreement"",
                                ""access"": false,
                                ""other"": false,
                                ""values"": [
                                  {
                                    ""label"": ""I agree"",
                                    ""value"": ""agree""
                                  }
                                ]
                              },
                              {
                                ""type"": ""text"",
                                ""required"": false,
                                ""label"": """",
                                ""className"": ""form-control"",
                                ""name"": ""stuff_text"",
                                ""access"": false,
                                ""subtype"": ""text""
                              },
                              {
                                ""type"": ""header"",
                                ""subtype"": ""h1"",
                                ""label"": ""I Am A Big Header"",
                                ""access"": false
                              },
                              {
                                ""type"": ""header"",
                                ""subtype"": ""h3"",
                                ""label"": ""I Am A Smaller Header"",
                                ""access"": false
                              },
                              {
                                ""type"": ""paragraph"",
                                ""subtype"": ""p"",
                                ""label"": ""I am a paragraph and I'm here to stay."",
                                ""access"": false
                              },
                              {
                                ""type"": ""number"",
                                ""required"": false,
                                ""label"": ""This is a number field"",
                                ""className"": """",
                                ""name"": ""numberStuff"",
                                ""access"": false,
                                ""value"": """"
                              },
                              {
                                ""type"": ""select"",
                                ""required"": false,
                                ""label"": ""Oh here's a select box:"",
                                ""className"": """",
                                ""name"": ""selectStuff"",
                                ""access"": false,
                                ""multiple"": false,
                                ""values"": [
                                  {
                                    ""label"": ""Option 1"",
                                    ""value"": ""option-1"",
                                    ""selected"": true
                                  },
                                  {
                                    ""label"": ""Option 2"",
                                    ""value"": ""option-2""
                                  },
                                  {
                                    ""label"": ""Option 3"",
                                    ""value"": ""option-3""
                                  }
                                ]
                              },
                              {
                                ""type"": ""button"",
                                ""label"": ""I am a button"",
                                ""subtype"": ""button"",
                                ""className"": """",
                                ""name"": ""stuffButton"",
                                ""value"": ""buttonVal"",
                                ""access"": false,
                                ""style"": ""danger""
                              },
                              {
                                ""type"": ""button"",
                                ""label"": ""I am a different button"",
                                ""subtype"": ""button"",
                                ""className"": """",
                                ""name"": ""stuffButton2"",
                                ""value"": ""buttonVal"",
                                ""access"": false,
                                ""style"": ""primary""
                              },
                              {
                                ""type"": ""date"",
                                ""required"": false,
                                ""label"": ""This is a date field"",
                                ""name"": ""dateStuff"",
                                ""access"": false
                              },
                              {
                                ""type"": ""barrier"",
                                ""required"": false,
                                ""label"": """",
                                ""name"": ""barrierStuff"",
                                ""access"": false
                              }
                        ]";

            fillFormFieldsWithAnswers("C:\\MBA\\Common\\StandAloneNet4Tools\\PdfFormTests\\PdfFormTests\\output_from_html.pdf"
                                    , "C:\\MBA\\Common\\StandAloneNet4Tools\\PdfFormTests\\PdfFormTests\\output.pdf"
                                    , savedAnswersJSON
                                    , questionsJSON);


            //AcroFields form_fields = stamper.AcroFields;

            // Geta all fields in PDF
            //Hashtable fields = reader.AcroFields.Fields;



            //// List all fields and values and list an associated generated HTML element for each
            //foreach (var key in fields.Keys)
            //{
            //    Console.Write("{0}, ", key);

            //    // source: https://stackoverflow.com/a/33244524
            //    switch (reader.AcroFields.GetFieldType(key.ToString()))
            //    {
            //        case AcroFields.FIELD_TYPE_CHECKBOX:
            //            Console.Write("Checkbox, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_CHECKBOX, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_COMBO:
            //            Console.Write("Combobox, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_COMBO, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_LIST:
            //            Console.Write("List, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_LIST, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_NONE:
            //            Console.Write("None, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_NONE, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_PUSHBUTTON:
            //            Console.Write("Pushbutton, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_PUSHBUTTON, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_RADIOBUTTON:
            //            Console.Write("Radio Button, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_RADIOBUTTON, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_SIGNATURE:
            //            Console.Write("Signature, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_SIGNATURE, key.ToString()));
            //            break;
            //        case AcroFields.FIELD_TYPE_TEXT:
            //            Console.Write("Text, {0}\n\n", generateHTMLElement(reader, form_fields, AcroFields.FIELD_TYPE_TEXT, key.ToString()));
            //            break;
            //        default:
            //            Console.Write("?\n\n");
            //            break;
            //    }
            //}

            // set student name & date of birth
            //stamper.AcroFields.SetField("Student Name", "John Doe");
            //stamper.AcroFields.SetField("Date of Birth", "05   05   2005");

            //// For checkbox or radio, we need to attain the export value
            //var export_val = GetFormFieldExportValue(stamper.AcroFields, "Improve Yes");
            //stamper.AcroFields.SetField("Improve Yes", export_val);

            //Console.WriteLine("Press any key");
            //Console.Read();
        }
    }
}
