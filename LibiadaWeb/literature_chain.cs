//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace LibiadaWeb
{
    using System;
    using System.Collections.Generic;
    
    public partial class literature_chain
    {
        public literature_chain()
        {
            this.binary_characteristic = new HashSet<binary_characteristic>();
            this.congeneric_characteristic = new HashSet<congeneric_characteristic>();
            this.characteristic = new HashSet<characteristic>();
        }
    
        public long id { get; set; }
        public int notation_id { get; set; }
        public System.DateTimeOffset created { get; set; }
        public long matter_id { get; set; }
        public bool dissimilar { get; set; }
        public int piece_type_id { get; set; }
        public Nullable<int> translator_id { get; set; }
        public long piece_position { get; set; }
        public bool original { get; set; }
        public int language_id { get; set; }
        public Nullable<int> remote_db_id { get; set; }
        public string remote_id { get; set; }
        public Nullable<System.DateTimeOffset> modified { get; set; }
        public string description { get; set; }
    
        public virtual ICollection<binary_characteristic> binary_characteristic { get; set; }
        public virtual ICollection<congeneric_characteristic> congeneric_characteristic { get; set; }
        public virtual ICollection<characteristic> characteristic { get; set; }
        public virtual language language { get; set; }
        public virtual matter matter { get; set; }
        public virtual notation notation { get; set; }
        public virtual piece_type piece_type { get; set; }
        public virtual translator translator { get; set; }
        public virtual remote_db remote_db { get; set; }
    }
}
