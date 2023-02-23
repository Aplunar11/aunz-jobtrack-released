using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace JobTrack.Models
{
    public class dbConnection
    {
        // CREATE A LIST VARIABLE
        // LIST <CONTENT AS CLASS>

        public List<logoutInfo> listLogOutInfo { get; set; }
        public string LoginDate { get; set; }
    }
    public class logoutInfo
    {
        public string transactionID { get; set; }
        public string loginDate { get; set; }
        public string logoutDate { get; set; }
        public string loginTime { get; set; }

    }
}