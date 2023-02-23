using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace JobTrack_AUNZ.Models.PE
{
    public class PESTPCreateModel
    {
        public string product { get; set; }
        public string target_date { get; set; }
        public string legislation_material { get; set; }
        public string path_input_files { get; set; }
        public bool conso_highlight { get; set; }
        public bool filing_instruction { get; set; }
        public bool dummy_filing1 { get; set; }
        public bool dummy_filing2 { get; set; }
        public bool uecj { get; set; }
        public bool pc1pc2 { get; set; }
        public bool ready_to_print { get; set; }
        public bool sending_to_puddingburn { get; set; }
        public bool posting_back_stable_data { get; set; }
        public bool updating_ebinder { get; set; }
        public string special_instruction { get; set; }
    }
}