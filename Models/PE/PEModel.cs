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

namespace JobTrack_AUNZ.Models.PE
{
    public class PEModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();


        public List<PESTPListModel> GetPESTPList(int serviceNo, int product, int owner)
        {
            List<PESTPListModel> lst = new List<PESTPListModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_stp_list", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PESTPListModel
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
                    CodingStart = Convert.ToString(dr[9]),
                    CodingDone = Convert.ToString(dr[10]),
                    SubsequentPass = Convert.ToString(dr[11]),
                    OnlineStart = Convert.ToString(dr[12]),
                    OnlineDone = Convert.ToString(dr[13]),
                    OnlineTimeless = Convert.ToString(dr[14]),
                    Product_id = Convert.ToInt32(dr[15])

                });
            }

            return lst;
        }
        public List<PESTPModel> GetPESTP(int serviceNo, int product, int owner)
        {
            List<PESTPModel> lst = new List<PESTPModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_stp", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PESTPModel
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
        public List<PECoverSheetModel> GetPECoverSheet(int serviceNo, int product, int owner)
        {
            List<PECoverSheetModel> lst = new List<PECoverSheetModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_coversheet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", 1);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PECoverSheetModel
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
        public List<PEManuscriptModel> GetPEManusrcipt(int serviceNo, int product, int owner)
        {
            List<PEManuscriptModel> lst = new List<PEManuscriptModel>();
            DataTable dt = new DataTable();


            cmd = new MySqlCommand("sp_get_jobs_product_level", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PEManuscriptModel
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
                    PEJob = GetSubPEManusrcipt(Convert.ToString(dr[0]), 0, 0)
                });
            }

            return lst;
        }
        public List<PEManuscriptModel> GetSubPEManusrcipt(string JobNo, int owner, int level)
        {
            List<PEManuscriptModel> lst = new List<PEManuscriptModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_sub", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@vc_jobnumber", JobNo);
            cmd.Parameters.AddWithValue("@int_useraccess", owner);
            cmd.Parameters.AddWithValue("@int_joblevel", level);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PEManuscriptModel
                {
                    Id = Convert.ToInt32(dr[0]),
                    JobOwner = Convert.ToInt32(dr[1]),
                    JobType = Convert.ToInt32(dr[2]),
                    JobNo = Convert.ToString(dr[3]),
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
                    ManuscriptTitle = Convert.ToString(dr[45]),
                    LatupAttribution = Convert.ToString(dr[46]),
                    Instruction = Convert.ToString(dr[47]),
                    EstPages = Convert.ToString(dr[52]),
                    ActualTtat = Convert.ToString(dr[53]),
                    OnlineTimelines = Convert.ToString(dr[54])

                });
            }

            return lst;
        }
        public List<PEManuscriptModel> GetSubTaskPEManusrcipt(int Job_id)
        {
            List<PEManuscriptModel> lst = new List<PEManuscriptModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobs_task", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@int_jobid", Job_id);
            cmd.Parameters.AddWithValue("@int_useraccess", 0);
            cmd.Parameters.AddWithValue("@int_joblevel", 1);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);


            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PEManuscriptModel
                {
                    t_jobid = Convert.ToInt32(dr[0]),
                    t_ServiceNo = Convert.ToString(dr[1]),
                    t_Product = Convert.ToString(dr[2]),
                    t_TargetDate = Convert.ToString(dr[3]),
                    t_UpdateType = Convert.ToString(dr[4]),
                    t_TaskType = Convert.ToString(dr[5]),
                    t_CodingDue = Convert.ToString(dr[6]),
                    t_OnlineDue = Convert.ToString(dr[7])
                });
            }

            return lst;
        }
        public List<PEManuscriptModel> GetTasksNo()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_task", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            List<PEManuscriptModel> lst = new List<PEManuscriptModel>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new PEManuscriptModel
                {
                    task_id = Convert.ToInt32(dr[1]),
                    task_no = Convert.ToString(dr[3])
                });
            }
            return lst;
        }
        public bool PEUpdateJob(PECoverSheetModel PEC, int owner, int level)
        {
            cmd = new MySqlCommand("sp_update_jobs_coversheet", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_jobid", PEC.Id);
            cmd.Parameters.AddWithValue("@vc_guidecards", PEC.GuideCards);
            cmd.Parameters.AddWithValue("@vc_manuscriptloc", PEC.ManuscriptLocation);
            cmd.Parameters.AddWithValue("@vc_specialinstruction", PEC.SpecialInstruction);
            cmd.Parameters.AddWithValue("@vc_targetpressdate", PEC.TargetDate);

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
        public bool PEUpdateJobStp(PESTPModel pSTP, int owner, int level)
        {
            cmd = new MySqlCommand("sp_update_jobs_stp", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_jobid", pSTP.jobId);
            cmd.Parameters.AddWithValue("@vc_pathfiles", pSTP.PathInputFiles);
            cmd.Parameters.AddWithValue("@vc_specialinstruction", pSTP.SpecialInstruction);

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
        public bool PEInsertTask(PEManuscriptModel PEM)
        {
            cmd = new MySqlCommand("sp_insert_task  ", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_jobid", PEM.t_jobid);
            cmd.Parameters.AddWithValue("@vc_coversheet", PEM.t_CoversheetNo);
            cmd.Parameters.AddWithValue("@vc_taskno", PEM.t_TaskNo);
            cmd.Parameters.AddWithValue("@vc_product", PEM.t_Product);
            cmd.Parameters.AddWithValue("@vc_editor", PEM.t_Editor);
            cmd.Parameters.AddWithValue("@vc_chargecode", PEM.t_ChargeCode);
            cmd.Parameters.AddWithValue("@vc_targetdate", PEM.t_TargetDate);
            cmd.Parameters.AddWithValue("@vc_tasktype", PEM.t_TaskType);
            cmd.Parameters.AddWithValue("@vc_guidecards", PEM.t_GuideCards);
            cmd.Parameters.AddWithValue("@vc_manuscriptlocation", PEM.t_ManusciptLocation);
            cmd.Parameters.AddWithValue("@vc_updatetype", PEM.t_UpdateType);
            cmd.Parameters.AddWithValue("@vc_general", (PEM.t_General) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_specialinstruction", PEM.t_specialInstruction);
            cmd.Parameters.AddWithValue("@vc_codingdate", PEM.t_CodingDue);
            cmd.Parameters.AddWithValue("@vc_xml", (PEM.t_XML) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_onlinedate", PEM.t_OnlineDue);
            cmd.Parameters.AddWithValue("@vc_online", (PEM.t_Online) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_correctiondate", PEM.t_CorrectionDue);
            cmd.Parameters.AddWithValue("@vc_correction", PEM.t_Correction);

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
        public bool PEInsertStp(PESTPCreateModel crm)
        {
            cmd = new MySqlCommand("sp_insert_stp", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@vc_product", crm.product);
            cmd.Parameters.AddWithValue("@vc_target_press_date", crm.target_date);
            cmd.Parameters.AddWithValue("@vc_legislation_materials", crm.legislation_material);
            cmd.Parameters.AddWithValue("@vc_path_of_input_files", crm.path_input_files);
            cmd.Parameters.AddWithValue("@vc_conso_highlight", (crm.conso_highlight) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_filing_instruction", (crm.filing_instruction) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_dummy_filing1", (crm.dummy_filing1) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_dummy_filing2", (crm.dummy_filing2) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_UECJ", (crm.uecj) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_PC1PC2", (crm.pc1pc2) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_ready_to_print", (crm.ready_to_print) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_sending_to_puddingburn", (crm.sending_to_puddingburn) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_posting_back_stable_data", (crm.posting_back_stable_data) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_updating_ebinder", (crm.updating_ebinder) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@vc_special_instruction", crm.special_instruction);

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