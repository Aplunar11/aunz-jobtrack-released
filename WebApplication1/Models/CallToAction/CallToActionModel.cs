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

namespace JobTrack.Models.CallToAction
{
    public class CallToActionData
    {
        public int CallToActionID { get; set; }
        [Display(Name = "ID")]
        public int CallToActionIdentity { get; set; }
        [Display(Name = "Name")]
        public string CallToActionName { get; set; }
        [Display(Name = "Product")]
        public string BPSProductID { get; set; }
        [Display(Name = "Service Number")]
        public string ServiceNumber { get; set; }
        [Display(Name = "Type")]
        public string CallToActionType { get; set; }
        [Display(Name = "Status")]
        public string CallToActionStatus { get; set; }
        [Display(Name = "Date Created")]
        public DateTime DateCreated { get; set; }
        public string UserName { get; set; }
    }
}