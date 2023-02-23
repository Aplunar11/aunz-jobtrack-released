using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Configuration;
using MySql.Data;
using MySql.Data.MySqlClient;
using System.Data.SqlClient;
using System.Web.Mvc;
using JobTrack.Models;
using System.ComponentModel.DataAnnotations;


namespace JobTrack.Models.Coversheet
{
    public class CoversheetViewModel
    {
        public List<CoversheetData> ListCoversheet { get; set; }
        public string ErrorMessage { get; set; }
    }
    public class UpdateTypeData
    {
        public int UpdateTypeID { get; set; }
        public string UpdateType { get; set; }
        public string TaskType { get; set; }
        public int CopyEditDays { get; set; }
        public int ProcessDays { get; set; }
        public int OnlineDays { get; set; }
        public int PDFQADays { get; set; }
        public int BenchmarkDays { get; set; }
        public int IsEdit { get; set; }
    }

    public class EditCoversheetViewModelBase
    {
        public CoversheetData model1 { get; set; }
        public SubsequentPassData model2 { get; set; }
    }

    public class EditCoversheetViewModel: EditCoversheetViewModelBase
    {

    }
    public class SubsequentPassData
    {
        public int SubsequentPassID { get; set; }
        public int CoversheetID { get; set; }
        [Display(Name = "Product:")]
        public string BPSProductID { get; set; }
        [Display(Name = "Service Number:")]
        public string ServiceNumber { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? SubsequentPassDueDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? SubsequentPassStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        public DateTime? SubsequentPassCompletionDate { get; set; }
        [Display(Name = "Completion Email Template:")]
        public string AttachmentBody { get; set; }
        [Display(Name = "Attachment: [pdf, word, excel, csv, jpeg, png, txt]")]
        public string AttachmentName { get; set; }
        public int AttachmentSize { get; set; }
        public string ActionType { get; set; }
        public string ActionStatus { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Created:")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
    }
    public class CoversheetData
    {
        public int CoversheetID { get; set; }

        [Display(Name = "Coversheet Number:")]
        public string CoversheetNumber { get; set; }
        [Display(Name = "Product:")]
        public string BPSProductID { get; set; }
        [Display(Name = "Service Number:")]
        public string ServiceNumber { get; set; }
        [Display(Name = "Task Number:")]
        public string TaskNumber { get; set; }
        [Display(Name = "Tier:")]
        public string CoversheetTier { get; set; }
        [Display(Name = "Editor:")]
        public string Editor { get; set; }
        [Display(Name = "Charge Code:")]
        public string ChargeCode { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Target Press Date:")]
        public DateTime? TargetPressDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Actual Press Date:")]
        public DateTime? ActualPressDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Revised Online Due Date:")]
        public DateTime? RevisedOnlineDueDate { get; set; }
        [Display(Name = "Current Task:")]
        public string CurrentTask { get; set; }
        [Display(Name = "Status:")]
        public string TaskStatus { get; set; }
        [Display(Name = "Task Type:")]
        public string TaskType { get; set; }
        [Display(Name = "Guide Card(s):")]
        public string GuideCard { get; set; }
        [Display(Name = "Location of manuscript/legislation/further instructions:")]
        public string LocationOfManuscript { get; set; }
        [Display(Name = "leg ref check")]
        public bool GeneralLegRefCheck { get; set; }
        [Display(Name = "TOC")]
        public bool GeneralTOC { get; set; }
        [Display(Name = "TOS")]
        public bool GeneralTOS { get; set; }
        [Display(Name = "reprints")]
        public bool GeneralReprints { get; set; }
        [Display(Name = "fascicle insertion")]
        public bool GeneralFascicleInsertion { get; set; }
        [Display(Name = "graphic - link")]
        public bool GeneralGraphicLink { get; set; }
        [Display(Name = "graphic - embed")]
        public bool GeneralGraphicEmbed { get; set; }
        [Display(Name = "handtooling")]
        public bool GeneralHandtooling { get; set; }
        [Display(Name = "non-content@")]
        public bool GeneralNonContent { get; set; }
        [Display(Name = "sample pages")]
        public bool GeneralSamplePages { get; set; }
        [Display(Name = "complex task")]
        public bool GeneralComplexTask { get; set; }

        [Display(Name = "Further Instructions:")]
        public string FurtherInstruction { get; set; }
        [Display(Name = "Update Type:")]
        public string UpdateType { get; set; }

        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Accepted Date:")]
        public DateTime? AcceptedDate { get; set; }
        [Display(Name = "Job Owner:")]
        public string JobOwner { get; set; }
        [Display(Name = "Update Email CC:")]
        public string UpdateEmailCC { get; set; }

        [Display(Name = "XML Editing:")]
        public bool IsXMLEditing { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Coding - Due Date:")]
        public DateTime? CodingDueDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Coding - Start Date:")]
        public DateTime? CodingStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Coding - Done Date:")]
        public DateTime? CodingDoneDate { get; set; }
        [Display(Name = "Coding - Status:")]
        public string CodingStatus { get; set; }
        [Display(Name = "Subtask:")]
        public string SubTask { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "PDF QC - Start Date:")]
        public DateTime? PDFQCStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "PDF QC - Done Date:")]
        public DateTime? PDFQCDoneDate { get; set; }
        [Display(Name = "PDF QA - Status:")]
        public string PDFQAStatus { get; set; }

        [Display(Name = "XML - Status:")]
        public string XMLStatus { get; set; }
        [Display(Name = "Online:")]
        public bool IsOnline { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Online - Due Date:")]
        public DateTime? OnlineDueDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Online - Start Date:")]
        public DateTime? OnlineStartDate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Online - Done Date:")]
        public DateTime? OnlineDoneDate { get; set; }
        [Display(Name = "Online - Status:")]
        public string OnlineStatus { get; set; }

        [Display(Name = "Online Timeliness:")]
        public string OnlineTimeliness { get; set; }

        [Display(Name = "Remarks:")]
        public string ReasonIfLate { get; set; }
        [System.ComponentModel.DataAnnotations.DisplayFormat(ApplyFormatInEditMode = true, DataFormatString = "{0:d-MMM-yy} {0:hh:mm tt}")]
        [Display(Name = "Date Created:")]
        public DateTime DateCreated { get; set; }
        public int CreatedEmployeeID { get; set; }
        public DateTime DateUpdated { get; set; }
        public int UpdateEmployeeID { get; set; }
        public int RowCount { get; set; }
        public string Response { get; set; }
        public string ErrorMessage { get; set; }
        public int JobCoversheetID { get; set; }
        public string LatestTaskNumber { get; set; }

    }
}