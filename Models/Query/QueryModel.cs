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
namespace JobTrack_AUNZ.Models.Query
{
    public class QueryModel
    {
        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public int AddQuery(QueryCreateModel QM)
        { 
            cmd = new MySqlCommand("sp_insert_query", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_postedBy", QM.PostedBy);
            cmd.Parameters.AddWithValue("@vc_query", QM.Query);
            cmd.Parameters.AddWithValue("@vc_task", QM.Task);
            cmd.Parameters.AddWithValue("@vc_topic", QM.Topic);
            cmd.Parameters.AddWithValue("@vc_file", QM.file);
            cmd.Parameters.AddWithValue("@output_id", "@output_id");
            cmd.Parameters["@output_id"].Direction = ParameterDirection.Output;

            if (conn.State == ConnectionState.Closed)
                conn.Open();
            int x = cmd.ExecuteNonQuery();

            return Convert.ToInt32(cmd.Parameters["@output_id"].Value);

        }
        public int updateQuery(QueryCreateModel QM, int query_id)
        {
            cmd = new MySqlCommand("sp_update_query", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_postedBy", QM.PostedBy);
            cmd.Parameters.AddWithValue("@vc_query", QM.Query);
            cmd.Parameters.AddWithValue("@vc_task", QM.Task);
            cmd.Parameters.AddWithValue("@vc_topic", QM.Topic);
            cmd.Parameters.AddWithValue("@vc_file", QM.file);
            cmd.Parameters.AddWithValue("@output_id", "@output_id");
            cmd.Parameters["@output_id"].Direction = ParameterDirection.Output;

            if (conn.State == ConnectionState.Closed)
                conn.Open();
            int x = cmd.ExecuteNonQuery();

            return Convert.ToInt32(cmd.Parameters["@output_id"].Value);

        }

        public List<QueryListModel> GetQueryList(int jobId)
        {
            List<QueryListModel> lst = new List<QueryListModel>();

            DataTable dt = new DataTable();
            cmd = new MySqlCommand("sp_get_query", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_jobid", jobId);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new QueryListModel
                {
                    Status = Convert.ToString(dr[0]),
                    QueryId = Convert.ToInt32(dr[1]),
                    Topic = Convert.ToString(dr[2]),
                    DatePosted = Convert.ToString(dr[3]),
                    PostedBy = Convert.ToString(dr[4]),
                    jobId = Convert.ToInt32(dr[5]),

                });
            }



            return lst;
        }

        public List<QueryListModel> GetSubQueryList(int queryid)
        {
            List<QueryListModel> lst = new List<QueryListModel>();

            DataTable dt = new DataTable();
            cmd = new MySqlCommand("sp_get_subquery", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@int_queryid", queryid);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new QueryListModel
                {
                    Status = Convert.ToString(dr[0]),
                    QueryId = Convert.ToInt32(dr[1]),
                    Topic = Convert.ToString(dr[2]),
                    jobId = Convert.ToInt32(dr[3]),
                    query = Convert.ToString(dr[4]),
                    subDatePosted = Convert.ToString(dr[5]),
                    subPostedBy = Convert.ToString(dr[6]),
                    filename = Convert.ToString(dr[7]),

                });
            }



            return lst;
        }
    }
}