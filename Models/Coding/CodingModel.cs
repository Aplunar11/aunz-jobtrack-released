using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using MySql.Data;
using System.Text;
using System.Security.Cryptography;
using System.IO;

namespace JobTrack_AUNZ.Models.Coding
{
    public class CodingModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public List<CodingCoverSheetModel> GetCodingCoversheet()
        {
            List<CodingCoverSheetModel> lst = new List<CodingCoverSheetModel>();

            DataTable dt = new DataTable();
            cmd = new MySqlCommand("sp_get_jobs_coding_coversheet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", 1);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new CodingCoverSheetModel
                {
                    jobid = Convert.ToInt32(dr[0]),
                    CoversheetNo = Convert.ToString(dr[1]),
                    Tier = Convert.ToString(dr[2]),
                    Product = Convert.ToString(dr[3]),
                    ServiceNo = Convert.ToString(dr[4]),
                    CurrentTask = Convert.ToString(dr[5]),
                    Status = Convert.ToString(dr[6]),
                    TargetDate = Convert.ToString(dr[7]),
                    PressDate = Convert.ToString(dr[8]),
                    CodingDueDate = Convert.ToString(dr[9]),
                    CodingStart = Convert.ToString(dr[10]),
                    CodingDone = Convert.ToString(dr[11]),
                    SubsequentPass = Convert.ToString(dr[12]),
                    OnlineDueDdate = Convert.ToString(dr[13]),
                    OnlineStart = Convert.ToString(dr[14]),
                    OnlineDone = Convert.ToString(dr[15]),
                    OnlineTimeless = Convert.ToString(dr[16]),
                    ReasonIfLate = Convert.ToString(dr[17])

                });
            }



            return lst;
        }
    }
}