﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models.PE
{
    public class PESTPListModel
    {
        public int jobid { get; set; }

        [Display(Name = "Coversheet No.")]
        public string CoversheetNo { get; set; }

        [Display(Name = "Tier")]
        public string Tier { get; set; }

        [Display(Name = "Product")]
        public string Product { get; set; }
        public int Product_id { get; set; }

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

        [Display(Name = "Coding Start")]
        public string CodingStart { get; set; }

        [Display(Name = "Coding Done")]
        public string CodingDone { get; set; }

        [Display(Name = "Subsequent Pass")]
        public string SubsequentPass { get; set; }

        [Display(Name = "Online Start")]
        public string OnlineStart { get; set; }

        [Display(Name = "Online Done")]
        public string OnlineDone { get; set; }

        [Display(Name = "Online Timeless")]
        public string OnlineTimeless { get; set; }
    }
}