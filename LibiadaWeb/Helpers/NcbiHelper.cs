﻿namespace LibiadaWeb.Helpers
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Net;
    using System.Xml;

    using Bio;
    using Bio.IO;
    using Bio.IO.FastA;
    using Bio.IO.GenBank;

    /// <summary>
    /// The ncbi helper.
    /// </summary>
    public static class NcbiHelper
    {
        /// <summary>
        /// The base url.
        /// </summary>
        private const string BaseUrl = @"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/";

        /// <summary>
        /// Gets features from GenBank file stream.
        /// </summary>
        /// <param name="genBankFileStream">
        /// The genBank file stream.
        /// </param>
        /// <returns>
        /// The <see cref="GenBankMetadata"/>.
        /// </returns>
        /// <exception cref="Exception">
        /// Thrown if metadata is empty.
        /// </exception>
        public static List<FeatureItem> GetFeatures(Stream genBankFileStream)
        {
            ISequenceParser parser = new GenBankParser();
            ISequence sequence = parser.ParseOne(genBankFileStream);

            GenBankMetadata metadata = sequence.Metadata["GenBank"] as GenBankMetadata;

            if (metadata == null)
            {
                throw new Exception("GenBank file metadata is empty.");
            }

            return metadata.Features.All;
        }

        /// <summary>
        /// The get sequence string.
        /// </summary>
        /// <param name="fastaFileStream">
        /// The fasta file stream.
        /// </param>
        /// <returns>
        /// The <see cref="ISequence"/>.
        /// </returns>
        public static ISequence GetFastaSequence(Stream fastaFileStream)
        {
            var fastaParser = new FastAParser();
            return fastaParser.ParseOne(fastaFileStream);
        }

        /// <summary>
        /// The get id.
        /// </summary>
        /// <param name="id">
        /// The id.
        /// </param>
        /// <returns>
        /// The <see cref="int"/>.
        /// </returns>
        /// <exception cref="Exception">
        /// Thrown if received not one sequence.
        /// </exception>
        public static int GetId(string id)
        {
            var memoryStream = GetResponseStream(@"esearch.fcgi?db=nucleotide&term=" + id);
            var doc = new XmlDocument();

            try
            {
                doc.Load(memoryStream);
            }
            finally
            {
                memoryStream.Close();
            }
            
            XmlNodeList elemList = doc.GetElementsByTagName("Id");

            if (elemList.Count != 1)
            {
                throw new Exception(string.Format("Resieved not one id of sequence (ids count = {0}).", elemList.Count));
            }

            return int.Parse(elemList[0].InnerText);
        }

        /// <summary>
        /// Returns genbank file FileStream.
        /// </summary>
        /// <param name="id">
        /// The id.
        /// </param>
        /// <returns>
        /// The <see cref="Stream"/>.
        /// </returns>
        public static Stream GetGenesFileStream(string id)
        {
            return GetResponseStream(@"efetch.fcgi?db=nuccore&rettype=gbwithparts&retmode=text&id=" + id);
        }

        /// <summary>
        /// The get file.
        /// </summary>
        /// <param name="id">
        /// The ncbi id.
        /// </param>
        /// <returns>
        /// The <see cref="Stream"/>.
        /// </returns>
        public static Stream GetFileStream(string id)
        {
            return GetResponseStream(@"efetch.fcgi?db=nuccore&rettype=fasta&retmode=text&id=" + id);
        }

        /// <summary>
        /// The get response.
        /// </summary>
        /// <param name="url">
        /// The url.
        /// </param>
        /// <returns>
        /// The <see cref="Stream"/>.
        /// </returns>
        /// <exception cref="Exception">
        /// Thrown if response stream is null.
        /// </exception>
        private static Stream GetResponseStream(string url)
        {
            var resultUrl = BaseUrl + url;
            var downloader = new WebClient();
            var memoryStream = new MemoryStream();
            using (var stream = downloader.OpenRead(resultUrl))
            {
                if (stream == null)
                {
                    throw new Exception("Response stream was null.");
                }

                stream.CopyTo(memoryStream);
            }

            memoryStream.Position = 0;
            return memoryStream;
        }
    }
}
