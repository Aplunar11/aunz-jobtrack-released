using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;


namespace JobTrack_AUNZ.Models.Query
{
    public class QueryCreateModel
    {       
        [AllowHtml]
        public string Query { get; set; }
        public string Task { get; set; }
        public string Topic { get; set; }
        public int PostedBy { get; set; }
        public string file { get; set; }
    }
}