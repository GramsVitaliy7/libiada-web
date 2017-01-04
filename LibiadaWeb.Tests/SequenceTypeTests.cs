﻿namespace LibiadaWeb.Tests
{
    using System.Linq;

    using LibiadaWeb.Extensions;

    using NUnit.Framework;

    [TestFixture(TestOf = typeof(SequenceType))]
    public class SequenceTypeTests
    {
        private const int SequenceTypesCount = 11;

        /// <summary>
        /// Tests count of sequence types.
        /// </summary>
        [Test]
        public void SequenceTypeCountTest()
        {
            var actualCount = EnumExtensions.ToArray<SequenceType>().Length;
            Assert.AreEqual(SequenceTypesCount, actualCount);
        }

        /// <summary>
        /// Tests values of sequence types.
        /// </summary>
        [Test]
        public void SequenceTypeValuesTest()
        {
            var sequenceTypes = EnumExtensions.ToArray<SequenceType>();

            for (int i = 1; i <= SequenceTypesCount; i++)
            {
                Assert.IsTrue(sequenceTypes.Contains((SequenceType)i));
            }
        }

        /// <summary>
        /// Tests names of sequence types.
        /// </summary>
        [TestCase((SequenceType)1, "CompleteGenome")]
        [TestCase((SequenceType)2, "CompleteMusicalComposition")]
        [TestCase((SequenceType)3, "CompleteText")]
        [TestCase((SequenceType)4, "CompleteNumericSequence")]
        [TestCase((SequenceType)5, "Plasmid")]
        [TestCase((SequenceType)6, "MitochondrionGenome")]
        [TestCase((SequenceType)7, "ChloroplastGenome")]
        [TestCase((SequenceType)8, "RRNA16S")]
        [TestCase((SequenceType)9, "RRNA18S")]
        [TestCase((SequenceType)10, "Mitochondrion16SRRNA")]
        [TestCase((SequenceType)11, "Plastid")]
        public void SequenceTypeNamesTest(SequenceType sequenceType, string name)
        {
            Assert.AreEqual(name, sequenceType.GetName());
        }

        /// <summary>
        /// Tests that all sequence types have display value.
        /// </summary>
        /// <param name="sequenceType">
        /// The sequence type.
        /// </param>
        [Test]
        public void SequenceTypeHasDisplayValueTest([Values]SequenceType sequenceType)
        {
            Assert.IsFalse(string.IsNullOrEmpty(sequenceType.GetDisplayValue()));
        }

        /// <summary>
        /// Tests that all sequence types have description.
        /// </summary>
        [Test]
        public void SequenceTypeHasDescriptionTest([Values]SequenceType sequenceType)
        {
            Assert.IsFalse(string.IsNullOrEmpty(sequenceType.GetDescription()));
        }

        /// <summary>
        /// Tests that all sequence types have valid nature attribute.
        /// </summary>
        [Test]
        public void SequenceTypeHasNatureTest([Values]SequenceType sequenceType)
        {
            var natures = EnumExtensions.ToArray<Nature>();
            Assert.True(natures.Contains(sequenceType.GetNature()));
        }

        /// <summary>
        /// Tests that all sequence types values are unique.
        /// </summary>
        [Test]
        public void SequenceTypeValuesUniqueTest()
        {
            var sequenceTypes = EnumExtensions.ToArray<SequenceType>();
            var sequenceTypeValues = sequenceTypes.Cast<byte>();
            Assert.That(sequenceTypeValues, Is.Unique);
        }
    }
}