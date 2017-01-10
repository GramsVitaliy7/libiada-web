﻿namespace LibiadaWeb
{
    using System.ComponentModel;
    using System.ComponentModel.DataAnnotations;

    using LibiadaWeb.Attributes;

    /// <summary>
    /// The feature.
    /// </summary>
    public enum Feature : byte
    {
        /// <summary>
        /// The feature coding sequence.
        /// </summary>
        [Display(Name = "Coding DNA sequence")]
        [Description("Coding sequence; sequence of nucleotides that corresponds with the sequence of amino acids in a protein (location includes stop codon); feature includes amino acid conceptual translation.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("CDS")]
        CodingSequence = 4,

        /// <summary>
        /// The Ribosomal RNA feature.
        /// </summary>
        [Display(Name = "Ribosomal RNA")]
        [Description("RNA component of the ribonucleoprotein particle (ribosome) which assembles amino acids into proteins.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("rRNA")]
        RibosomalRNA = 5,

        /// <summary>
        /// The Transfer RNA feature.
        /// </summary>
        [Display(Name = "Transfer RNA")]
        [Description("A small RNA molecule (75-85 bases long) that mediates the translation of a nucleic acid sequence into an amino acid sequence.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("tRNA")]
        TransferRNA = 6,

        /// <summary>
        /// The feature Non-coding RNA.
        /// </summary>
        [Display(Name = "Non-coding RNA")]
        [Description("A non-protein-coding gene, other than ribosomal RNA and transfer RNA, the functional molecule of which is the RNA transcript")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("ncRNA")]
        NoncodingRNA = 7,

        /// <summary>
        /// The feature Transfer-messenger RNA.
        /// </summary>
        [Display(Name = "Transfer-messenger RNA")]
        [Description("tmRNA acts as a tRNA first, and then as an mRNA that encodes a peptide tag; the ribosome translates this mRNA region of tmRNA and attaches the encoded peptide tag to the C-terminus of the unfinished protein; this attached tag targets the protein for destruction or proteolysis")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("tmRNA")]
        TransferMessengerRNA = 8,

        /// <summary>
        /// The feature pseudo gen.
        /// </summary>
        [Display(Name = "Pseudo gene")]
        [Description("Indicates that this feature is a non-functional version of the element named by the feature key")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("pseudo")]
        PseudoGen = 9,

        /// <summary>
        /// The feature repeat region.
        /// </summary>
        [Display(Name = "Repeat region")]
        [Description("Region of genome containing repeating units.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("repeat_region")]
        RepeatRegion = 13,

        /// <summary>
        /// The feature non coding sequence.
        /// </summary>
        [Display(Name = "Non-coding sequence")]
        [Description("Non-coding sequence")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("")]
        NonCodingSequence = 14,

        /// <summary>
        /// The feature Miscellaneous other RNA.
        /// </summary>
        [Display(Name = "Miscellaneous other RNA")]
        [Description("Any transcript or RNA product that cannot be defined by other RNA keys (prim_transcript, precursor_RNA, mRNA, 5UTR, 3UTR, exon, CDS, sig_peptide, transit_peptide, mat_peptide, intron, polyA_site, ncRNA, rRNA and tRNA)")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("misc_RNA")]
        MiscellaneousOtherRNA = 16,

        /// <summary>
        /// The miscellaneous feature.
        /// </summary>
        [Display(Name = "Miscellaneous feature")]
        [Description("Region of biological interest which cannot be described by any other feature key; a new or rare feature.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("misc_feature")]
        MiscellaneousFeature = 18,

        /// <summary>
        /// The Messenger RNA feature.
        /// </summary>
        [Display(Name = "Messenger RNA")]
        [Description("Includes 5untranslated region (5UTR), coding sequences (CDS, exon) and 3untranslated region (3UTR).")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("mRNA")]
        MessengerRNA = 19,

        /// <summary>
        /// The regulatory feature.
        /// </summary>
        [Display(Name = "Regulatory")]
        [Description("Any region of sequence that functions in the regulation of transcription or translation.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("regulatory")]
        Regulatory = 20,

        /// <summary>
        /// The sequence tagged site.
        /// </summary>
        [Display(Name = "Sequence tagged site")]
        [Description("Short, single-copy DNA sequence that characterizes a mapping landmark on the genome and can be detected by PCR; a region of the genome can be mapped by determining the order of a series of STSs.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("STS")]
        SequenceTaggedSite = 21,

        /// <summary>
        /// The origin of replication.
        /// </summary>
        [Display(Name = "Origin of replication")]
        [Description("Starting site for duplication of nucleic acid to give two identical copies.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("rep_origin")]
        OriginOfReplication = 22,

        /// <summary>
        /// The signal peptide coding sequence.
        /// </summary>
        [Display(Name = "Signal peptide coding sequence")]
        [Description("Coding sequence for an N-terminal domain of a secreted protein; this domain is involved in attaching nascent polypeptide to the membrane leader sequence.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("sig_peptide")]
        SignalPeptideCodingSequence = 23,

        /// <summary>
        /// The miscellaneous binding.
        /// </summary>
        [Display(Name = "Miscellaneous binding")]
        [Description("Site in nucleic acid which covalently or non-covalently binds another moiety that cannot be described by any other binding key (primer_bind or protein_bind).")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("misc_binding")]
        MiscellaneousBinding = 24,

        /// <summary>
        /// The stem loop.
        /// </summary>
        [Display(Name = "Stem loop")]
        [Description("Hairpin; a double-helical region formed by base-pairing between adjacent (inverted) complementary sequences in a single strand of RNA or DNA.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("stem_loop")]
        StemLoop = 25,

        /// <summary>
        /// The displacement loop.
        /// </summary>
        [Display(Name = "Displacement loop")]
        [Description("A region within mitochondrial DNA in which a short stretch of RNA is paired with one strand of DNA, displacing the original partner DNA strand in this region; also used to describe the displacement of a region of one strand of duplex DNA by a single stranded invader in the reaction catalyzed by RecA protein.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("D-loop")]
        DisplacementLoop = 26,

        /// <summary>
        /// The diversity segment.
        /// </summary>
        [Display(Name = "Diversity segment")]
        [Description("Diversity segment of immunoglobulin heavy chain, and T-cell receptor beta chain.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("D_segment")]
        DiversitySegment = 27,

        /// <summary>
        /// The mobile element.
        /// </summary>
        [Display(Name = "Mobile element")]
        [Description("Region of genome containing mobile elements.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("mobile_element")]
        MobileElement = 28,

        /// <summary>
        /// The variation.
        /// </summary>
        [Display(Name = "Variation")]
        [Description("A related strain contains stable mutations from the same gene (e.g., RFLPs, polymorphisms, etc.) which differ from the presented sequence at this location (and possibly others). Used to describe alleles, RFLPs,and other naturally occurring mutations and  polymorphisms; variability arising as a result of genetic manipulation (e.g. site directed mutagenesis) should described with the misc_difference feature.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("variation")]
        Variation = 29,

        /// <summary>
        /// The protein bind.
        /// </summary>
        [Display(Name = "Protein_bind")]
        [Description("Non-covalent protein binding site on nucleic acid. Note that feature key regulatory with /regulatory_class='ribosome_binding_site' should be used for ribosome binding sites.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("protein_bind")]
        ProteinBind = 30,

        /// <summary>
        /// The mature peptid.
        /// </summary>
        [Display(Name = "Mature peptid")]
        [Description("Mature peptide or protein coding sequence; coding sequence for the mature or final peptide or protein product following post-translational modification; the location does not include the stop codon (unlike the corresponding CDS).")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("mat_peptide")]
        MaturePeptid = 31,

        /// <summary>
        /// The miscellaneous difference.
        /// </summary>
        [Display(Name = "Miscellaneous difference")]
        [Description("feature sequence is different from that presented in the entry and cannot be described by any other difference key (old_sequence, variation, or modified_base).")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("misc_difference")]
        MiscellaneousDifference = 32,

        /// <summary>
        /// The non coding gene.
        /// </summary>
        [Display(Name = "Gene (non coding)")]
        [Description("Gene without CDS (coding sequence) associated with it.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("gene")]
        Gene = 33,

        /// <summary>
        /// 3'UTR end.
        /// </summary>
        [Display(Name = "3 end")]
        [Description("Region at the 3 end of a mature transcript (following the stop codon) that is not translated into a protein; region at the 3 end of an RNA virus (following the last stop codon) that is not translated into a protein.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("3'UTR")]
        ThreeEnd = 34,

        /// <summary>
        /// 5'UTR end.
        /// </summary>
        [Display(Name = "5 end")]
        [Description("Region at the 5 end of a mature transcript (preceding the initiation codon) that is not translated into a protein;region at the 5 end of an RNA virus genome (preceding the first initiation codon) that is not translated into a protein.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("5'UTR")]
        FiveEnd = 35,

        /// <summary>
        /// Primer bind site.
        /// </summary>
        [Display(Name = "Primer bind")]
        [Description("Non-covalent primer binding site for initiation of replication, transcription, or reverse transcription; includes site(s) for synthetic e.g., PCR primer elements.")]
        [Nature(Nature.Genetic)]
        [GenBankFeatureName("primer_bind")]
        PrimerBind = 36
    }
}