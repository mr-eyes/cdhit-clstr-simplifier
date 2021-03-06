#### Clone

```sh
git clone --recursive https://github.com/mr-eyes/master-analysis
cd master-analysis/
```

#### Dependencies

```bash
# autoconf
sudo apt-get install autoconf
```

#### Data preparation

```bash
mkdir data; cd data/

#1 Download Human Transcriptome
wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_28/gencode.v28.transcripts.fa.gz

#2 Download GTF: Comprehensive gene annotation | PRI
wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_28/gencode.v28.annotation.gtf.gz

#3 Extract files
gunzip *

#4 Generate protein_coding sequences
python ../scripts/filter_multifasta.py gencode.v28.transcripts.fa protein_coding

#5 Adding gene locus to human transcriptome fasta headers
python ../scripts/add_locus.py -i gencode.v28.transcripts.fa -g gencode.v28.annotation.gtf -o loci_gencode.v28.transcripts.fa

#6 Adding gene locus to protein coding transcripts fasta headers
python ../scripts/add_locus.py -i protein_coding_gencode.v28.transcripts.fa -g gencode.v28.annotation.gtf -o loci_protein_coding_gencode.v28.transcripts.fa
```

#### Data Exploration

```bash
mkdir overview; cd overview/
#1 Generating Histograms

## Histogram_1
python ../../scripts/histogram.py ../gencode.v28.transcripts.fa 1200 0

## Histogram_2
python ../../scripts/histogram.py ../gencode.v28.transcripts.fa 99 0


#2 Replicating gencode stats | RNA Types count
python ../../scripts/extract_RNA_types.py ../gencode.v28.transcripts.fa > rna_types.txt

#3 Get stats about the GTF
python ../../scripts/gtf_stats.py ../gencode.v28.annotation.gtf > gtf_stats.txt

# Move to root directory
cd ../../
```

#### kCluster Kmer-based clustering experiment

```bash
cd experiments/kmers_clustering/

#1 Clone and build kCluster
bash install_kCluster.sh


#2 Run kCluster for protein coding transcripts

## Prepare data for indexing

python kCluster/scripts/kProcessor_prepare.py ../../data/loci_protein_coding_gencode.v28.transcripts.fa

## Perform clustering, assessement and visualization

for kmer in {21 25 31};
do bash run.sh min_loci_protein_coding_gencode.v28.transcripts.fa ${kmer} protein_coding;
done

#3 Run kCluster for full Human Full Transcriptome

## Prepare data for indexing

python kCluster/scripts/kProcessor_prepare.py ../../data/loci_gencode.v28.transcripts.fa

## Perform clustering, assessement and visualization

for kmer in {21 25 31};
do bash run.sh loci_gencode.v28.transcripts.fa ${kmer} protein_coding;
done

# Return to expirements root directory
cd ../
```

#### CD-HIT Clustering by similarity thresholds experiments

```bash
cd cd-hit/

#1 Install CD-HIT software
bash install_cdhit.sh

#2 Automate CD-HIT Clustering and Assessment using similarity thresholds {0.8, 0.85, 0.9, 0.95}
# Protein Coding Human Transcripts

THRESHOLDS=(0.95 0.90 0.85 0.8);
WORD_COUNTS=(10 8 6 5);

for  i  in {0..3};
do bash run.sh ../../data/loci_protein_coding_gencode.v28.transcripts.fa ${THRESHOLDS[${i}]}  ${WORD_COUNTS[${i}]} protein_coding_assessement;
done;

# Full Human Transcriptome

THRESHOLDS=(0.95 0.90 0.85 0.8);
WORD_COUNTS=(10 8 6 5);

for  i  in {0..3};
do bash run.sh ../../data/loci_gencode.v28.transcripts.fa ${THRESHOLDS[${i}]}  ${WORD_COUNTS[${i}]} full_transcriptome_assessement;
done;

# Return to expirements root directory
cd ../
```

#### Visualizing CD-HIT clustering results

```bash
#1 Visualize Protein Coding clustering results
grep "" cd-hit/protein_coding_assessement/*/*summary* | python ../scripts/visualize_cdhit_clustering.py cdhit_protein_coding.html

#2 Visualize Full Human Transcriptome results
grep "" cd-hit/full_transcriptome_assessement/*/*summary* | python .../scripts/visualize_cdhit_clustering.py cdhit_full_transcriptome.html
```
