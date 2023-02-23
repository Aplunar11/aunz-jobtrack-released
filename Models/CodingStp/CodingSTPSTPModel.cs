using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace JobTrack_AUNZ.Models.CodingStp
{
    public class CodingSTPSTPModel
    {
        public int jobid { get; set; }

        [Display(Name = "STP No.")]
        public string StpNo { get; set; }

        [Display(Name = "Tier")]
        public string Tier { get; set; }

        [Display(Name = "Product")]
        public string Product { get; set; }

        [Display(Name = "Service No.")]
        public string ServiceNo { get; set; }

        [Display(Name = "Current Task")]
        public string CurrentTask { get; set; }

        [Display(Name = "Status")]
        public string Status { get; set; }

        [Display(Name = "Target Press Date")]
        public string TargetDate { get; set; }

        [Display(Name = "Actual Press Date")]
        public string PressDate { get; set; }

        [Display(Name = "Conso Highlight Actual Start")]
        public string ConsoStart { get; set; }

        [Display(Name = "Conso Highlight Actual Done")]
        public string ConsoDone { get; set; }

        [Display(Name = "Filing Instrucion Actual Start")]
        public string FilingActualDate { get; set; }

        [Display(Name = "Filing Instrucion Actual Done")]
        public string FilingActualDone { get; set; }

        [Display(Name = "Dummy Filing Actual Start")]
        public string DummyFilingActualStart { get; set; }

        [Display(Name = "Dummy Filing Actual Done")]
        public string DummyFilingActualDone { get; set; }

        [Display(Name = "Dummy Filing 2 Actual Start")]
        public string DummyFilingActualStart2 { get; set; }

        [Display(Name = "Dummy Filing 2 Actual Done")]
        public string DummyFilingActualDone2 { get; set; }

        [Display(Name = "UECJ Actual Start")]
        public string UECJActualStart { get; set; }

        [Display(Name = "UECJ Actual Done")]
        public string UECJActualDone { get; set; }

        [Display(Name = "PC1/PC2 Actual Start")]
        public string PC1PC2ActualStart { get; set; }

        [Display(Name = "PC1/PC2 Actual Done")]
        public string PC1PC2ActualDone { get; set; }

        [Display(Name = "STP Actual Done")]
        public string STPActualDone { get; set; }

        [Display(Name = "Sending Final Pages to Puddingburn")]
        public string SendingFinal { get; set; }

        [Display(Name = "Posting Back to Stable Data Actual Start")]
        public string PostingBackStart { get; set; }

        [Display(Name = "Posting Back to Stable Data Actual Done")]
        public string PostingBackDone { get; set; }


        [Display(Name = "Updating of Ebinder Actual Start")]
        public string EbinderStart { get; set; }

        [Display(Name = "Updating of Ebinder Actual Done")]
        public string EbinderDone { get; set; }
    }
}