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
    
    public partial class AccordanceCharacteristicValue
    {
        public long Id { get; set; }
        public long FirstSequenceId { get; set; }
        public long SecondSequenceId { get; set; }
        public short CharacteristicTypeLinkId { get; set; }
        public double Value { get; set; }
        public long FirstElementId { get; set; }
        public long SecondElementId { get; set; }
    
        public virtual Element FirstElement { get; set; }
        public virtual Element SecondElement { get; set; }
        public virtual CommonSequence FirstSequence { get; set; }
        public virtual CommonSequence SecondSequence { get; set; }
        public virtual AccordanceCharacteristicLink AccordanceCharacteristicLink { get; set; }
    }
}
