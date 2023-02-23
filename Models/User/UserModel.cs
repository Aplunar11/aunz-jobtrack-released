using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace JobTrack_AUNZ.Models.User
{
    public class UserModel 
    {

        public MySqlConnection conn = new MySqlConnection(ConfigurationManager.ConnectionStrings["dsn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public List<UserLoginModel> GetUsers()
        {
            List<UserLoginModel> lst = new List<UserLoginModel>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_user", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new UserLoginModel
                {
                    ID = Convert.ToInt32(dr[0]),
                    Username = Convert.ToString(dr[1]),
                    Password = Decrypt(Convert.ToString(dr[2])),
                    //Password = Convert.ToString(dr[2]),
                    //PasswordSalt = Convert.ToString(dr[3]),
                    UserAccess = Convert.ToString(dr[7]),

                });
            }

            return lst;
        }
        public List<UserRegisterModel> GetUserLevel()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("sp_get_useraccess", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (conn.State == ConnectionState.Closed)
                conn.Open();

            List<UserRegisterModel> lst = new List<UserRegisterModel>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new UserRegisterModel
                {
                    UserlevelValue = Convert.ToInt32(dr[0]),
                    UserlevelText = Convert.ToString(dr[1])
                });
            }
            return lst;
        }
        public bool Register(UserRegisterModel urm)
        {
            var crypto = new SimpleCrypto.PBKDF2();
            var encrypPass = crypto.Compute(urm.Password);

            string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            char[] stringChars = new char[8];
            Random random = new Random();

            for (int i = 0; i < stringChars.Length; i++)
            {
                stringChars[i] = chars[random.Next(chars.Length)];
            }

            string password = new String(stringChars);
            password = Encrypt(urm.Password);

            cmd = new MySqlCommand("sp_insert_user", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@var_user_name", urm.UserName);
            cmd.Parameters.AddWithValue("@var_password", password);
            cmd.Parameters.AddWithValue("@var_first_name", urm.FirstName);
            cmd.Parameters.AddWithValue("@var_last_name", urm.LastName);
            cmd.Parameters.AddWithValue("@var_email_address", urm.EmailAddress);
            //cmd.Parameters.AddWithValue("@var_project_id", urm.Project);
            cmd.Parameters.AddWithValue("@var_project_id", 1);
            cmd.Parameters.AddWithValue("@var_user_access", urm.UserLevel);
            cmd.Parameters.AddWithValue("@var_manager", (urm.BoolManager) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@var_editorialcontact", (urm.BoolEditorialContact) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@var_email_list", (urm.BoolEmailList) ? "YES" : "NO");
            cmd.Parameters.AddWithValue("@var_mandatory_recipient", (urm.BoolMandatoryRecipient) ? "YES" : "NO");

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
        public string Encrypt(string password)
        {
            byte[] PasswordByte = new byte[password.Length];
            PasswordByte = System.Text.Encoding.UTF8.GetBytes(password);
            string EncodedData = Convert.ToBase64String(PasswordByte);
            return EncodedData;
        }
        public string Decrypt(string password)
        {
            System.Text.UTF8Encoding encoder = new System.Text.UTF8Encoding();
            System.Text.Decoder utf8Decode = encoder.GetDecoder();
            byte[] PasswordByte = Convert.FromBase64String(password);
            int charCount = utf8Decode.GetCharCount(PasswordByte, 0, PasswordByte.Length);
            char[] DecodedChar = new char[charCount];
            utf8Decode.GetChars(PasswordByte, 0, PasswordByte.Length, DecodedChar, 0);
            string DecodedData = new string(DecodedChar);
            return DecodedData;
        }

    }
}