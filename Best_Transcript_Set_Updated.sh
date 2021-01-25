#Method for running Trinity, then processing results with TransDecoder and InterProscan, then reducing the sequences to a "best" set using cd-hit and some scripts.
#Modified from a script wrote by David Mathog available here: https://github.com/trinityrnaseq/trinity_community_codebase/wiki/Trinity-best-transcript-set
#Requires hmmscan_split.sh, blastp_split.sh, TransDecoder, InterProscan, CD-HIT, DRM-tools, fastaselecth, match_many.pl
#You will need to update the paths and files names

TransDecoder.LongOrfs -t Transcriptome.fasta

mv Transcriptome.fasta.transdecoder_dir/longest_orfs.pep .

bash hmmscan_split.sh 32 /home/schottr/Databases/Pfam-A.hmm Transcriptome.fasta.transdecoder_dir/longest_orfs.pep

bash blastp_split.sh 32 /home/schottr/Databases/uniprot_sprot Transcriptome.fasta.transdecoder_dir/longest_orfs.pep

TransDecoder.Predict -t ../Transcriptome.fasta --retain_pfam_hits longest_orfs_pfam_out.txt --retain_blastp_hits blastp.outfmt6

mkdir interproscan
tr -d '*' < Transcriptome.fasta.transdecoder.pep >interproscan/proteins.fasta
cd interproscan
/home/schottr/interproscan-5.39-77.0/interproscan.sh -cpu 16 -appl PfamA -iprlookup -goterms -f tsv -dp -i proteins.fasta

perl /home/schottr/bin/trinity_cdhitfeeder2.pl \
  -infile Trinity.fasta.transdecoder.pep \
  -output Trinity.fasta.transdecoder.pep_pass1 \
  -tmp_dir /tmp/tmpfeed -max_children 30 -params "$CDH_BAND"

cd-hit -i Trinity.fasta.transdecoder.pep_pass1.fasta \
  -o Trinity.fasta.transdecoder.pep_pass2 \
  -d 0 -T 30 -b 180 -M 3000

export LD_LIBRARY_PATH=/home/schottr/miniconda3/envs/Bioinformatics/lib/:$LD_LIBRARY_PATH
/home/schottr/bin/DRM-tools/extract -in Trinity.fasta.transdecoder.pep_pass2 -wl 1000000 -mt -dl '>.' -fmt '[1]' -if '>' -ifonly | uniq - > keep_these
cat keep_these | ~/bin/fastaselecth/fastaselecth -sel - -in ../Trinity.fasta >Trinity_reduced.fasta
cat keep_these | ~/bin/match_many.pl Trinity.fasta.transdecoder.gff3 1 >Trinity_reduced.transdecoder.gff3
cat keep_these | ~/bin/match_many.pl Trinity.fasta.transdecoder.bed  1 >Trinity_reduced.transdecoder.bed
cp  Trinity.fasta.transdecoder.pep_pass2 Trinity_reduced.transdecoder.pep
/home/schottr/bin/DRM-tools/extract -in Trinity.fasta.transdecoder.pep_pass2 -wl 1000000 -mt -dl '> ' -fmt '[1]' -if '>' -ifonly >keep_these2
cat keep_these2 | ~/bin/fastaselecth/fastaselecth -sel - -in Trinity.fasta.transdecoder.cds >Trinity_reduced.transdecoder.cds
cat keep_these2 | ~/bin/match_many.pl interproscan/proteins.fasta.tsv 1 >Trinity_reduced.ips.tsv