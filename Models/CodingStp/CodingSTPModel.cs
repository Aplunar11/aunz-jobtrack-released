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


namespace JobTrack_AUNZ.Models.CodingStp
{
    public class CodingSTPModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public List<CodingSTPSTPModel> GetCodingSTPMyJobs(int serviceNo, string product, int owner)
        {
            List<CodingSTPSTPModel> lst = new List<CodingSTPSTPModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_coding_stp", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", 1);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new CodingSTPSTPModel
                {
                    jobid = Convert.ToInt32(dr[0]),
                    StpNo = Convert.ToString(dr[1]),
                    Tier = Convert.ToString(dr[2]),
                    Product = Convert.ToString(dr[3]),
                    ServiceNo = Convert.ToString(dr[4]),
                    CurrentTask = Convert.ToString(dr[5]),
                    Status = Convert.ToString(dr[6]),
                    TargetDate = Convert.ToString(dr[7]),
                    PressDate = Convert.ToString(dr[8]),
                    ConsoStart = Convert.ToString(dr[9]),
                    ConsoDone = Convert.ToString(dr[10]),
                    FilingActualDate = Convert.ToString(dr[11]),
                    FilingActualDone = Convert.ToString(dr[12]),
                    DummyFilingActualStart = Convert.ToString(dr[13]),
                    DummyFilingActualDone = Convert.ToString(dr[14]),
                    DummyFilingActualStart2 = Convert.ToString(dr[15]),
                    DummyFilingActualDone2 = Convert.ToString(dr[16]),
                    UECJActualStart = Convert.ToString(dr[17]),
                    UECJActualDone = Convert.ToString(dr[18]),
                    PC1PC2ActualStart = Convert.ToString(dr[19]),
                    PC1PC2ActualDone = Convert.ToString(dr[20]),
                    STPActualDone = Convert.ToString(dr[21]),
                    SendingFinal = Convert.ToString(dr[22]),
                    PostingBackStart = Convert.ToString(dr[23]),
                    PostingBackDone = Convert.ToString(dr[24]),
                    EbinderStart = Convert.ToString(dr[25]),
                    EbinderDone = Convert.ToString(dr[26])

                });
            }

            return lst;
        }
    }
}