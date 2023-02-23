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

namespace JobTrack_AUNZ.Models.LE
{
    public class LEModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public List<LEManuscriptModel> GetLEManusrcipt(int owner, int level)
        {
            List<LEManuscriptModel> lst = new List<LEManuscriptModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_product_level", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new LEManuscriptModel
                {
                    m_JobNumber = Convert.ToString(dr[0]),
                    m_Tier = Convert.ToString(dr[1]),
                    m_Product = Convert.ToString(dr[2]),
                    m_ServiceNo = Convert.ToString(dr[3]),
                    m_TargetDate = Convert.ToString(dr[4]),
                    m_PressDate = Convert.ToString(dr[5]),
                    m_Copyedit = "Ongoing",
                    m_Coding = "Ongoing",
                    m_Online = "Ongoing",
                    m_STP = Convert.ToString(dr[9]),
                    LEJob = GetSubLEManusrcipt(Convert.ToString(dr[0]), 0, 0)

                });
            }

            return lst;
        }
        public List<LEManuscriptModel> GetSubLEManusrcipt(string JobNo, int owner, int level)
        {
            List<LEManuscriptModel> lst = new List<LEManuscriptModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_sub", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@vc_jobnumber", JobNo);
            cmd.Parameters.AddWithValue("@int_useraccess", owner);
            cmd.Parameters.AddWithValue("@int_joblevel", level);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new LEManuscriptModel
                {
                    Id = Convert.ToInt32(dr[0]),
                    JobOwner = Convert.ToInt32(dr[1]),
                    JobType = Convert.ToInt32(dr[2]),
                    JobNumber = Convert.ToString(dr[3]),
                    ServiceNo = Convert.ToString(dr[4]),
                    Tier = Convert.ToString(dr[6]),
                    Product = Convert.ToString(dr[7]),
                    Status = Convert.ToString(dr[8]),
                    UpdateType = Convert.ToString(dr[9]),
                    TaskType = Convert.ToString(dr[10]),
                    DateFromAuthor = Convert.ToString(dr[15]),
                    DateCreated = Convert.ToString(dr[16]),
                    TargetDate = Convert.ToString(dr[17]),
                    PressDate = Convert.ToString(dr[18]),
                    CopyeditDue = Convert.ToString(dr[19]),
                    CopyeditDone = Convert.ToString(dr[21]),
                    CodingDue = Convert.ToString(dr[22]),
                    CodingDone = Convert.ToString(dr[24]),
                    OnlineDue = Convert.ToString(dr[25]),
                    OnlineDone = Convert.ToString(dr[27]),
                    RevisedDate = Convert.ToString(dr[43]),
                    Manuscript = Convert.ToString(dr[45]),
                    LatupAttribution = Convert.ToString(dr[46]),
                    Instruction = Convert.ToString(dr[47]),
                    EstPages = Convert.ToString(dr[52]),
                    ActualTtat = Convert.ToString(dr[53]),
                    OnlineTimelines = Convert.ToString(dr[54])

                });
            }

            return lst;
        }
        public List<LECoversheetModel> GetLECoverSheet(int serviceNo, int product, int owner)
        {
            List<LECoversheetModel> lst = new List<LECoversheetModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_coversheet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", 1);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new LECoversheetModel
                {

                    Id = Convert.ToInt32(dr[0]),
                    CoversheetNo = Convert.ToString(dr[1]),
                    Tier = Convert.ToString(dr[2]),
                    Product = Convert.ToString(dr[3]),
                    ServiceNo = Convert.ToString(dr[4]),
                    GuideCards = Convert.ToString(dr[5]),
                    ManuscriptLocation = Convert.ToString(dr[6]),
                    SpecialInstruction = Convert.ToString(dr[7]),
                    CurrentTask = Convert.ToString(dr[8]),
                    Status = Convert.ToString(dr[9]),
                    TargetDate = Convert.ToString(dr[10]),
                    PressDate = Convert.ToString(dr[9]),
                    CodingDueDate = Convert.ToString(dr[10]),
                    CodingStart = Convert.ToString(dr[11]),
                    CodingDone = Convert.ToString(dr[12]),
                    SubsequentPass = Convert.ToString(dr[13]),
                    OnlineDueDate = Convert.ToString(dr[14]),
                    OnlineStart = Convert.ToString(dr[15]),
                    OnlineDone = Convert.ToString(dr[16]),
                    OnlineTimeless = Convert.ToString(dr[17]),
                    Reason = Convert.ToString(dr[18])

                });
            }

            return lst;
        }
        public List<LESTPModel> GetLESTP(int serviceNo, int product, int owner)
        {
            List<LESTPModel> lst = new List<LESTPModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_stp", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new LESTPModel
                {
                    jobId = Convert.ToInt32(dr[0]),
                    StpNo = Convert.ToString(dr[1]),
                    Tier = Convert.ToString(dr[2]),
                    Product = Convert.ToString(dr[3]),
                    ServiceNo = Convert.ToString(dr[4]),
                    CurrentTask = Convert.ToString(dr[5]),
                    Status = Convert.ToString(dr[6]),
                    PathInputFiles = Convert.ToString(dr[7]),
                    SpecialInstruction = Convert.ToString(dr[8]),
                    TargetDate = Convert.ToString(dr[9]),
                    PressDate = Convert.ToString(dr[10]),
                    ConsoStart = Convert.ToString(dr[11]),
                    ConsoDone = Convert.ToString(dr[12]),
                    FilingActualDate = Convert.ToString(dr[13]),
                    FilingActualDone = Convert.ToString(dr[14]),
                    DummyFilingActualStart = Convert.ToString(dr[15]),
                    DummyFilingActualDone = Convert.ToString(dr[16]),
                    DummyFilingActualStart2 = Convert.ToString(dr[17]),
                    DummyFilingActualDone2 = Convert.ToString(dr[18]),
                    UECJActualStart = Convert.ToString(dr[19]),
                    UECJActualDone = Convert.ToString(dr[20]),
                    PC1PC2ActualStart = Convert.ToString(dr[21]),
                    PC1PC2ActualDone = Convert.ToString(dr[22]),
                    PressActualDone = Convert.ToString(dr[23]),
                    SendingFinal = Convert.ToString(dr[24]),
                    PostingBackStart = Convert.ToString(dr[25]),
                    PostingBackDone = Convert.ToString(dr[26]),
                    EbinderDone = Convert.ToString(dr[27])


                });
            }

            return lst;
        }
        public bool LEUpdateJob(LEManuscriptModel LEm, int owner, int level)
        {
            cmd = new MySqlCommand("sp_update_jobs_LE", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_jobid", LEm.Id);
            cmd.Parameters.AddWithValue("@vc_Tier", LEm.Tier);
            cmd.Parameters.AddWithValue("@vc_Product", LEm.Product);
            cmd.Parameters.AddWithValue("@vc_ServiceNo", LEm.ServiceNo);
            cmd.Parameters.AddWithValue("@vc_manuscripttitle", LEm.Manuscript);
            cmd.Parameters.AddWithValue("@vc_TargetDate", LEm.TargetDate);
            cmd.Parameters.AddWithValue("@vc_LatupAttribution", LEm.LatupAttribution);
            cmd.Parameters.AddWithValue("@vc_UpdateType", LEm.UpdateType);
            cmd.Parameters.AddWithValue("@vc_JobInstruction", LEm.Instruction);


            if (conn.State == ConnectionState.Closed)
                conn.Open();
            int x = cmd.ExecuteNonQuery();
            if (x >= 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public bool LEAddJob(LECreateJobModel LEc, int owner, int level)
        {

            cmd = new MySqlCommand("sp_insert_jobs", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_useraccess", owner);
            cmd.Parameters.AddWithValue("@int_joblevel", level);
            //cmd.Parameters.AddWithValue("@int_jobid", LEc.Id);
            cmd.Parameters.AddWithValue("@int_jobno", null);
            cmd.Parameters.AddWithValue("@vc_serviceno", LEc.ServiceNo);
            cmd.Parameters.AddWithValue("@vc_coversheetno", null);
            cmd.Parameters.AddWithValue("@vc_tier", LEc.Tier);
            cmd.Parameters.AddWithValue("@vc_product", LEc.Product);
            cmd.Parameters.AddWithValue("@vc_status", null);
            cmd.Parameters.AddWithValue("@vc_updatetype", LEc.UpdateType);
            cmd.Parameters.AddWithValue("@vc_tasktype", LEc.TaskType);
            cmd.Parameters.AddWithValue("@vc_currenttask", null);
            cmd.Parameters.AddWithValue("@vc_stp", null);
            cmd.Parameters.AddWithValue("@vc_stpno", null);
            cmd.Parameters.AddWithValue("@vc_stpactualdone", null);
            cmd.Parameters.AddWithValue("@vc_datereceived", LEc.DateFromAuthor);
            cmd.Parameters.AddWithValue("@vc_datecreated", DateTime.Now.ToString("dd/MM/yyyy"));
            cmd.Parameters.AddWithValue("@vc_targetpressdate", LEc.TargetDate);
            cmd.Parameters.AddWithValue("@vc_actualpressdate", null);
            cmd.Parameters.AddWithValue("@vc_copyeditduedate", LEc.CopyeditDueDate);
            cmd.Parameters.AddWithValue("@vc_copyeditstart", null);
            cmd.Parameters.AddWithValue("@vc_copyeditdone", null);
            cmd.Parameters.AddWithValue("@vc_codingduedate", LEc.CodingDueDate);
            cmd.Parameters.AddWithValue("@vc_codingstart", null);
            cmd.Parameters.AddWithValue("@vc_codingdone", null);
            cmd.Parameters.AddWithValue("@vc_onlineduedate", LEc.OnlineDueDate);
            cmd.Parameters.AddWithValue("@vc_onlinestart", null);
            cmd.Parameters.AddWithValue("@vc_onlinedone", null);
            cmd.Parameters.AddWithValue("@vc_consostart", null);
            cmd.Parameters.AddWithValue("@vc_consodone", null);
            cmd.Parameters.AddWithValue("@vc_filingstart", null);
            cmd.Parameters.AddWithValue("@vc_filingdone", null);
            cmd.Parameters.AddWithValue("@vc_dummyfilingstart1", null);
            cmd.Parameters.AddWithValue("@vc_dummyfilingdone1", null);
            cmd.Parameters.AddWithValue("@vc_dummyfilingstart2", null);
            cmd.Parameters.AddWithValue("@vc_dummyfilingdone2", null);
            cmd.Parameters.AddWithValue("@vc_EUCJstart", null);
            cmd.Parameters.AddWithValue("@vc_EUCJdone", null);
            cmd.Parameters.AddWithValue("@vc_puddingbirn", null);
            cmd.Parameters.AddWithValue("@vc_postingstart", null);
            cmd.Parameters.AddWithValue("@vc_postingdone", null);
            cmd.Parameters.AddWithValue("@vc_ebinderstart", null);
            cmd.Parameters.AddWithValue("@vc_ebinderdone", null);
            cmd.Parameters.AddWithValue("@vc_revised", null);
            cmd.Parameters.AddWithValue("@vc_readypress", null);
            cmd.Parameters.AddWithValue("@vc_manuscript", LEc.Manuscript);
            cmd.Parameters.AddWithValue("@vc_latup", LEc.LatupAttribution);
            cmd.Parameters.AddWithValue("@vc_instruction", LEc.JobSpecificInstruction);
            cmd.Parameters.AddWithValue("@vc_guide", null);
            cmd.Parameters.AddWithValue("@vc_subsequent", null);
            cmd.Parameters.AddWithValue("@vc_path", null);
            cmd.Parameters.AddWithValue("@vc_location", null);
            cmd.Parameters.AddWithValue("@vc_estpages", null);
            cmd.Parameters.AddWithValue("@vc_actualtat", null);
            cmd.Parameters.AddWithValue("@vc_onlinetimeless", null);
            cmd.Parameters.AddWithValue("@vc_reason", null);
            if (conn.State == ConnectionState.Closed)
                conn.Open();
            int x = cmd.ExecuteNonQuery();
            if (x >= 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        

    }
}