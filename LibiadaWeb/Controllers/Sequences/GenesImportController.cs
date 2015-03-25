﻿namespace LibiadaWeb.Controllers.Sequences
{
    using System;
    using System.Collections.Generic;
    using System.Data.Entity;
    using System.IO;
    using System.Linq;
    using System.Web;
    using System.Web.Mvc;

    using Bio.IO.GenBank;

    using LibiadaWeb.Helpers;
    using LibiadaWeb.Models;
    using LibiadaWeb.Models.Repositories.Catalogs;
    using LibiadaWeb.Models.Repositories.Sequences;

    /// <summary>
    /// The genes import controller.
    /// </summary>
    public class GenesImportController : AbstractResultController
    {
        /// <summary>
        /// The db.
        /// </summary>
        private readonly LibiadaWebEntities db;

        /// <summary>
        /// The feature repository.
        /// </summary>
        private readonly FeatureRepository featureRepository;

        /// <summary>
        /// The attribute repository.
        /// </summary>
        private readonly SequenceAttributeRepository sequenceAttributeRepository;

        /// <summary>
        /// The subsequence repository.
        /// </summary>
        private readonly SubsequenceRepository subsequenceRepository;

        /// <summary>
        /// Initializes a new instance of the <see cref="GenesImportController"/> class.
        /// </summary>
        public GenesImportController()
            : base("GenesImport", "Genes Import")
        {
            db = new LibiadaWebEntities();
            featureRepository = new FeatureRepository(db);
            sequenceAttributeRepository = new SequenceAttributeRepository(db);
            subsequenceRepository = new SubsequenceRepository(db);
        }

        /// <summary>
        /// The index.
        /// </summary>
        /// <returns>
        /// The <see cref="ActionResult"/>.
        /// </returns>
        public ActionResult Index()
        {
            var genesSequenceIds = db.Subsequence.Select(g => g.SequenceId).Distinct();
            var matterIds = db.DnaSequence.Where(c => c.WebApiId != null && !genesSequenceIds.Contains(c.Id)).Select(c => c.MatterId).ToList();

            var calculatorsHelper = new ViewDataHelper(db);

            var data = calculatorsHelper.FillMattersData(1, 1, false, m => matterIds.Contains(m.Id));

            data.Add("natureId", Aliases.Nature.Genetic);

            ViewBag.data = data;

            return View();
        }

        /// <summary>
        /// The index.
        /// </summary>
        /// <param name="matterId">
        /// The matter id.
        /// </param>
        /// <param name="localFile">
        /// The local file.
        /// </param>
        /// <returns>
        /// The <see cref="ActionResult"/>.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        /// Thrown if there is no file with sequence.
        /// </exception>
        /// <exception cref="Exception">
        /// Thrown if unknown part is found.
        /// </exception>
        [HttpPost]
        public ActionResult Index(long matterId, bool localFile)
        {
            return Action(() =>
            {
                long sequenceId = db.DnaSequence.Single(d => d.MatterId == matterId).Id;
                DnaSequence parentSequence = db.DnaSequence.Single(c => c.Id == sequenceId);

                Stream stream;
                if (localFile)
                {
                    HttpPostedFileBase file = Request.Files[0];

                    if (file == null || file.ContentLength == 0)
                    {
                        throw new ArgumentNullException("file", "Sequence file is empty");
                    }

                    stream = file.InputStream;
                }
                else
                {
                    stream = NcbiHelper.GetGenesFileStream(parentSequence.WebApiId.ToString());
                }

                List<FeatureItem> features = NcbiHelper.GetFeatures(stream);

                List<int> starts;
                List<int> ends;

                subsequenceRepository.CreateFeatureSubsequences(features, sequenceId, out starts, out ends);

                subsequenceRepository.CreateNonCodingSubsequences(starts, ends, sequenceId);

                db.SaveChanges();

                var matterName = db.Matter.Single(m => m.Id == matterId).Name;

                var sequenceSubsequences = db.Subsequence.Where(g => g.SequenceId == sequenceId).Include(g => g.Position).Include(g => g.Feature).Include(g => g.SequenceAttribute);

                return new Dictionary<string, object>
                                     {
                                         { "matterName", matterName }, 
                                         { "genes", sequenceSubsequences }
                                     };
            });
        }
    }
}
