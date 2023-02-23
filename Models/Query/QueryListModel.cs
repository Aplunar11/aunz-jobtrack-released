using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace JobTrack_AUNZ.Models.Query
{
    public class QueryListModel
    {
        public int jobId { get; set; }
        public string Status { get; set; }
        public int QueryId { get; set; }
        public string Topic { get; set; }
        public string DatePosted { get; set; }
        public string PostedBy { get; set; }

        public string query { get; set; }
        public string subDatePosted { get; set; }
        public string subPostedBy { get; set; }
        public string filename { get; set; }
    }
}