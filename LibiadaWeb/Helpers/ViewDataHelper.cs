﻿namespace LibiadaWeb.Helpers
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Linq;
    using System.Web.Mvc;
    using System.Web.Mvc.Html;

    using LibiadaCore.Extensions;

    using LibiadaWeb.Extensions;
    using LibiadaWeb.Models.CalculatorsData;
    using LibiadaWeb.Models.Repositories.Catalogs;
    using LibiadaWeb.Models.Repositories.Sequences;

    /// <summary>
    /// Class filling data for ViewBag.
    /// </summary>
    public class ViewDataHelper
    {
        /// <summary>
        /// The db.
        /// </summary>
        private readonly LibiadaWebEntities db;

        /// <summary>
        /// The matter repository.
        /// </summary>
        private readonly MatterRepository matterRepository;

        /// <summary>
        /// Initializes a new instance of the <see cref="ViewDataHelper"/> class.
        /// </summary>
        /// <param name="db">
        /// The db.
        /// </param>
        public ViewDataHelper(LibiadaWebEntities db)
        {
            this.db = db;
            matterRepository = new MatterRepository(db);
        }

        /// <summary>
        /// Fills matter creation data.
        /// </summary>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        public Dictionary<string, object> FillMatterCreationData()
        {
            IEnumerable<SelectListItem> natures;
            IEnumerable<Notation> notations;

            IEnumerable<RemoteDb> remoteDbs = ArrayExtensions.ToArray<RemoteDb>();
            IEnumerable<SequenceType> sequenceTypes = ArrayExtensions.ToArray<SequenceType>();
            IEnumerable<Group> groups = ArrayExtensions.ToArray<Group>();

            if (AccountHelper.IsAdmin())
            {
                natures = EnumHelper.GetSelectList(typeof(Nature));
                notations = ArrayExtensions.ToArray<Notation>();
            }
            else
            {
                natures = new[] { Nature.Genetic }.ToSelectList();
                notations = new[] { Notation.Nucleotides };
                remoteDbs = ArrayExtensions.ToArray<RemoteDb>().Where(rd => rd.GetNature() == Nature.Genetic);
                sequenceTypes = ArrayExtensions.ToArray<SequenceType>().Where(st => st.GetNature() == Nature.Genetic);
                groups = ArrayExtensions.ToArray<Group>().Where(g => g.GetNature() == Nature.Genetic);
            }

            return new Dictionary<string, object>
                       {
                           { "matters", matterRepository.GetMatterSelectList() },
                           { "natures", natures },
                           { "notations", notations.ToSelectListWithNature() },
                           { "remoteDbs", remoteDbs.ToSelectListWithNature() },
                           { "sequenceTypes", sequenceTypes.ToSelectListWithNature() },
                           { "groups", groups.ToSelectListWithNature() },
                           { "languages", EnumHelper.GetSelectList(typeof(Language)) },
                           { "translators", EnumHelper.GetSelectList(typeof(Translator)) }
                       };
        }

        /// <summary>
        /// Fills view data.
        /// </summary>
        /// <param name="minSelectedMatters">
        /// The minimum selected matters.
        /// </param>
        /// <param name="maxSelectedMatters">
        /// The maximum selected matters.
        /// </param>
        /// <param name="filter">
        /// The matters filter.
        /// </param>
        /// <param name="submitName">
        /// The submit button name.
        /// </param>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        public Dictionary<string, object> FillViewData(int minSelectedMatters, int maxSelectedMatters, Func<Matter, bool> filter, string submitName)
        {
            Dictionary<string, object> data = GetMattersData(minSelectedMatters, maxSelectedMatters, filter, submitName);

            IEnumerable<SelectListItem> natures;
            IEnumerable<Notation> notations;
            IEnumerable<SequenceType> sequenceTypes;
            IEnumerable<Group> groups;

            if (AccountHelper.IsAdmin())
            {
                natures = EnumHelper.GetSelectList(typeof(Nature));
                notations = ArrayExtensions.ToArray<Notation>();
                sequenceTypes = ArrayExtensions.ToArray<SequenceType>();
                groups = ArrayExtensions.ToArray<Group>();
            }
            else
            {
                natures = new[] { Nature.Genetic }.ToSelectList();
                notations = new[] { Notation.Nucleotides };
                sequenceTypes = ArrayExtensions.ToArray<SequenceType>().Where(st => st.GetNature() == Nature.Genetic);
                groups = ArrayExtensions.ToArray<Group>().Where(g => g.GetNature() == Nature.Genetic);
            }

            data.Add("natures", natures);
            data.Add("notations", notations.ToSelectListWithNature());
            data.Add("languages", EnumHelper.GetSelectList(typeof(Language)));
            data.Add("translators", EnumHelper.GetSelectList(typeof(Translator)));
            data.Add("sequenceTypes", sequenceTypes.ToSelectListWithNature(true));
            data.Add("groups", groups.ToSelectListWithNature(true));

            return data;
        }

        /// <summary>
        /// Fills view data.
        /// </summary>
        /// <param name="minSelectedMatters">
        /// The minimum Selected Matters.
        /// </param>
        /// <param name="maxSelectedMatters">
        /// The maximum Selected Matters.
        /// </param>
        /// <param name="submitName">
        /// The submit button name.
        /// </param>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        public Dictionary<string, object> FillViewData(int minSelectedMatters, int maxSelectedMatters, string submitName)
        {
            return FillViewData(minSelectedMatters, maxSelectedMatters, m => true, submitName);
        }

        /// <summary>
        /// The fill calculation data.
        /// </summary>
        /// <param name="characteristicsType">
        /// The characteristics category.
        /// </param>
        /// <param name="minSelectedMatters">
        /// The minimum Selected Matters.
        /// </param>
        /// <param name="maxSelectedMatters">
        /// The maximum Selected Matters.
        /// </param>
        /// <param name="submitName">
        /// The submit button name.
        /// </param>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        public Dictionary<string, object> FillViewData(CharacteristicCategory characteristicsType, int minSelectedMatters, int maxSelectedMatters, string submitName)
        {
            Dictionary<string, object> data = FillViewData(minSelectedMatters, maxSelectedMatters, submitName);

            List<CharacteristicData> characteristicTypes;

            switch (characteristicsType)
            {
                case CharacteristicCategory.Full:
                    characteristicTypes = FullCharacteristicRepository.Instance.GetFullCharacteristicTypes();
                    break;
                case CharacteristicCategory.Congeneric:
                    characteristicTypes = CongenericCharacteristicRepository.Instance.GetCongenericCharacteristicTypes();
                    break;
                case CharacteristicCategory.Accordance:
                    characteristicTypes = AccordanceCharacteristicRepository.Instance.GetAccordanceCharacteristicTypes();
                    break;
                case CharacteristicCategory.Binary:
                    characteristicTypes = BinaryCharacteristicRepository.Instance.GetBinaryCharacteristicTypes();
                    break;
                default:
                    throw new InvalidEnumArgumentException(nameof(characteristicsType), (int)characteristicsType, typeof(CharacteristicCategory));
            }

            data.Add("characteristicTypes", characteristicTypes);

            return data;
        }

        /// <summary>
        /// Fills subsequences calculation data dictionary.
        /// </summary>
        /// <param name="minSelectedMatters">
        /// The minimum Selected Matters.
        /// </param>
        /// <param name="maxSelectedMatters">
        /// The maximum Selected Matters.
        /// </param>
        /// <param name="submitName">
        /// The submit button name.
        /// </param>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        public Dictionary<string, object> FillSubsequencesViewData(int minSelectedMatters, int maxSelectedMatters, string submitName)
        {
            var sequenceIds = db.Subsequence.Select(s => s.SequenceId).Distinct();
            var matterIds = db.DnaSequence.Where(c => sequenceIds.Contains(c.Id)).Select(c => c.MatterId).ToList();

            var data = GetMattersData(minSelectedMatters, maxSelectedMatters, m => matterIds.Contains(m.Id), submitName);

            var geneticNotations = ArrayExtensions.ToArray<Notation>().Where(n => n.GetNature() == Nature.Genetic);
            var sequenceTypes = ArrayExtensions.ToArray<SequenceType>().Where(st => st.GetNature() == Nature.Genetic);
            var groups = ArrayExtensions.ToArray<Group>().Where(g => g.GetNature() == Nature.Genetic);
            var features = ArrayExtensions.ToArray<Feature>().Where(f => f.GetNature() == Nature.Genetic).ToArray();
            var selectedFeatures = features.Where(f => f != Feature.NonCodingSequence);
            var characteristicTypes = FullCharacteristicRepository.Instance.GetFullCharacteristicTypes();

            data.Add("characteristicTypes", characteristicTypes);
            data.Add("notations", geneticNotations.ToSelectListWithNature());
            data.Add("nature", (byte)Nature.Genetic);
            data.Add("features", features.ToSelectListWithNature(selectedFeatures));
            data.Add("sequenceTypes", sequenceTypes.ToSelectListWithNature(true));
            data.Add("groups", groups.ToSelectListWithNature(true));

            return data;
        }

        /// <summary>
        /// Fills matters data dictionary.
        /// </summary>
        /// <param name="minSelectedMatters">
        /// The minimum selected matters.
        /// </param>
        /// <param name="maxSelectedMatters">
        /// The maximum selected matters.
        /// </param>
        /// <param name="filter">
        /// Filter for matters.
        /// </param>
        /// <param name="submitName">
        /// The submit button name.
        /// </param>
        /// <returns>
        /// The <see cref="Dictionary{String, Object}"/>.
        /// </returns>
        private Dictionary<string, object> GetMattersData(int minSelectedMatters, int maxSelectedMatters, Func<Matter, bool> filter, string submitName)
        {
            return new Dictionary<string, object>
                {
                    { "minimumSelectedMatters", minSelectedMatters },
                    { "maximumSelectedMatters", maxSelectedMatters },
                    { "matters", matterRepository.GetMatterSelectList(filter) },
                    { "radiobuttonsForMatters", maxSelectedMatters == 1 && minSelectedMatters == 1 },
                    { "submitName", submitName }
                };
        }
    }
}
