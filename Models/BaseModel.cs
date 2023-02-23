using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace JobTrack_AUNZ.Models
{
    public class BaseModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public List<ContextModel> GetUpdateType()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_updatetype", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            List<ContextModel> lst = new List<ContextModel>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new ContextModel
                {
                    UpdateType_id = Convert.ToInt32(dr[0]),
                    UpdateType = Convert.ToString(dr[1]),
                    TaskType = Convert.ToString(dr[2]),
                    CopyEdit = Convert.ToInt32(dr[3]),
                    Coding = Convert.ToInt32(dr[4]),
                    Online = Convert.ToInt32(dr[5]),
                    PdfQA = Convert.ToInt32(dr[6]),
                    Benchmark = Convert.ToInt32(dr[7])

                });
            }
            return lst;
        }
        public List<ContextModel> GetJobType(int uid)
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_jobtype", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@int_useraccess", uid);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();


            List<ContextModel> lst = new List<ContextModel>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new ContextModel
                {
                    JobType_id = Convert.ToInt32(dr[0]),
                    JobType = Convert.ToString(dr[1])

                });
            }

            return lst;
        }
        public List<ContextModel> GetProduct()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_product", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();


            List<ContextModel> lst = new List<ContextModel>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new ContextModel
                {
                    product_id = Convert.ToInt32(dr[0]),
                    product = Convert.ToString(dr[1]),
                    charge_code = Convert.ToString(dr[2]),
                    editor = Convert.ToString(dr[3]),

                });
            }

            return lst;
        }
        public List<ContextModel> GetService()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_service", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            int ctr = 0;
            List<ContextModel> lst = new List<ContextModel>();
            foreach (DataRow dr in dt.Rows)
            {
                ctr += 1;
                lst.Add(new ContextModel
                {
                    service_id = ctr,
                    service_no = Convert.ToString(dr[0])

                });
            }

            return lst;
        }

        public List<ContextModel> GetTopic()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_topic", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            int ctr = 0;
            List<ContextModel> lst = new List<ContextModel>();
            foreach (DataRow dr in dt.Rows)
            {
                ctr += 1;
                lst.Add(new ContextModel
                {
                    topic_id = Convert.ToInt32(dr[0]),
                    topic = Convert.ToString(dr[1])

                });
            }

            return lst;
        }

    }
    public class ContextModel : BaseModel
    {
        public int UpdateType_id { get; set; }

        [Display(Name = "Update Type")]
        public string UpdateType { get; set; }
        public string TaskType { get; set; }
        public int CopyEdit { get; set; }
        public int Coding { get; set; }
        public int Online { get; set; }
        public int PdfQA { get; set; }
        public int Benchmark { get; set; }
        new public IEnumerable<SelectListItem> GetUpdateType { get; set; }

        public int JobType_id { get; set; }
        public int JobType_User { get; set; }

        [Display(Name = "Level")]
        public string JobType { get; set; }
        new public IEnumerable<SelectListItem> GetJobType { get; set; }
        public int product_id { get; set; }
        public string product { get; set; }
        public string charge_code { get; set; }
        public string editor { get; set; }
        public int service_id { get; set; }
        public string service_no { get; set; }
        new public IEnumerable<SelectListItem> GetProduct { get; set; }

        public int topic_id { get; set; }
        public string topic { get; set; }
        new public IEnumerable<SelectListItem> GetTopic{ get; set; }

    }

}