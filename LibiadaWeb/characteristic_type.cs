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
    
    public partial class characteristic_type
    {
        public characteristic_type()
        {
            this.binary_characteristic = new HashSet<binary_characteristic>();
            this.characteristic = new HashSet<characteristic>();
            this.congeneric_characteristic = new HashSet<congeneric_characteristic>();
        }
    
        public int id { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public Nullable<int> characteristic_group_id { get; set; }
        public string class_name { get; set; }
        public bool linkable { get; set; }
        public bool full_chain_applicable { get; set; }
        public bool congeneric_chain_applicable { get; set; }
        public bool binary_chain_applicable { get; set; }
    
        public virtual ICollection<binary_characteristic> binary_characteristic { get; set; }
        public virtual ICollection<characteristic> characteristic { get; set; }
        public virtual characteristic_group characteristic_group { get; set; }
        public virtual ICollection<congeneric_characteristic> congeneric_characteristic { get; set; }
    }
}
