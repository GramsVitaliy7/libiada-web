﻿namespace LibiadaWeb.Controllers.Calculators
{
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Http;

    using LibiadaCore.Core;
    using LibiadaCore.Core.Characteristics.Calculators.FullCalculators;
    using LibiadaCore.Misc.Iterators;

    using LibiadaWeb.Models;
    using LibiadaWeb.Models.Repositories.Catalogs;

    using Newtonsoft.Json;

    /// <summary>
    /// The local calculation web api controller.
    /// </summary>
    [Authorize]
    public class LocalCalculationWebApiController : ApiController
    {
        /// <summary>
        /// The get subsequence characteristic.
        /// </summary>
        /// <param name="subsequenceId">
        /// The subsequence id.
        /// </param>
        /// <param name="characteristicLinkId">
        /// The characteristic type link id.
        /// </param>
        /// <param name="windowSize">
        /// The window size.
        /// </param>
        /// <param name="step">
        /// The step.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        public string GetSubsequenceCharacteristic(long subsequenceId, int characteristicLinkId, int windowSize, int step)
        {
            Chain chain;
            IFullCalculator calculator;
            Link link;

            using (var context = new LibiadaWebEntities())
            {
                var characteristicTypeLinkRepository = new CharacteristicLinkRepository(context);

                FullCharacteristic characteristic = characteristicTypeLinkRepository.GetFullCharacteristic(characteristicLinkId);
                calculator = FullCalculatorsFactory.CreateCalculator(characteristic);
                link = characteristicTypeLinkRepository.GetLinkForFullCharacteristic(characteristicLinkId);

                var subsequenceExtractor = new SubsequenceExtractor(context);

                Subsequence dbSubsequence = context.Subsequence.Single(s => s.Id == subsequenceId);

                chain = subsequenceExtractor.ExtractChains(new[] { dbSubsequence }).Single();
            }

            CutRule cutRule = new SimpleCutRule(chain.GetLength(), step, windowSize);

            CutRuleIterator iter = cutRule.GetIterator();

            var fragments = new List<Chain>();

            while (iter.Next())
            {
                var fragment = new Chain(iter.GetEndPosition() - iter.GetStartPosition());

                for (int k = 0; iter.GetStartPosition() + k < iter.GetEndPosition(); k++)
                {
                    fragment.Set(chain[iter.GetStartPosition() + k], k);
                }

                fragments.Add(fragment);
            }

            var characteristics = new double[fragments.Count];

            for (int k = 0; k < fragments.Count; k++)
            {
                characteristics[k] = calculator.Calculate(fragments[k], link);
            }

            return JsonConvert.SerializeObject(characteristics);
        }
    }
}
