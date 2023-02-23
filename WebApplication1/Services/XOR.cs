using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;

namespace JobTrack.Services
{
    public class XOR
    {
        public static string encrypt(string text, string key)
        {
            byte[] decrypted = Encoding.UTF8.GetBytes(text);
            byte[] encrypted = new byte[decrypted.Length];

            for (int i = 0; i < decrypted.Length; i++)
            {
                encrypted[i] = (byte)(decrypted[i] ^ key[i % key.Length]);
            }

            string xored = System.Convert.ToBase64String(encrypted);

            return xored;
        }
        public static string decrypt(string text, string key)
        {
            var decoded = System.Convert.FromBase64String(HttpUtility.UrlDecode(text));

            byte[] result = new byte[decoded.Length];

            for (int c = 0; c < decoded.Length; c++)
            {
                result[c] = (byte)((uint)decoded[c] ^ (uint)key[c % key.Length]);
            }

            string dexored = Encoding.UTF8.GetString(result);

            return dexored;
        }
    }
}